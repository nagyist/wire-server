{-# LANGUAGE PartialTypeSignatures #-}
{-# OPTIONS_GHC -Wno-partial-type-signatures #-}

-- This file is part of the Wire Server implementation.
--
-- Copyright (C) 2020 Wire Swiss GmbH <opensource@wire.com>
--
-- This program is free software: you can redistribute it and/or modify it under
-- the terms of the GNU Affero General Public License as published by the Free
-- Software Foundation, either version 3 of the License, or (at your option) any
-- later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
-- details.
--
-- You should have received a copy of the GNU Affero General Public License along
-- with this program. If not, see <https://www.gnu.org/licenses/>.

module Federator.InternalServer where

import Control.Lens (view)
import Data.Either.Validation (Validation (..))
import qualified Data.Text as Text
import Federator.App (Federator, runAppT)
import Federator.Discovery (DiscoverFederator, runFederatorDiscovery)
import Federator.Env (Env, applog, dnsResolver)
import Federator.Remote (Remote, RemoteError, discoverAndCall, interpretRemote)
import Federator.Utils.PolysemyServerError (absorbServerError)
import Imports
import Mu.GRpc.Client.Record (GRpcReply (..))
import Mu.GRpc.Server (msgProtoBuf, runGRpcAppTrans)
import Mu.Server (ServerError, ServerErrorIO, SingleServerT, singleService)
import qualified Mu.Server as Mu
import Polysemy
import qualified Polysemy.Error as Polysemy
import Polysemy.IO (embedToMonadIO)
import Polysemy.TinyLog (TinyLog)
import qualified Polysemy.TinyLog as Log
import Wire.API.Federation.GRPC.Types
import Wire.Network.DNS.Effect (DNSLookup)
import qualified Wire.Network.DNS.Effect as Lookup

callRemote :: Member Remote r => RemoteCall -> Sem r Response
callRemote req = do
  case validateRemoteCall req of
    Success vReq -> do
      reply <- discoverAndCall vReq
      pure $ mkRemoteResponse reply
    Failure errs -> pure $ ResponseErr ("component -> local federator: invalid RemoteCall: " <> Text.pack (show errs))

-- FUTUREWORK: Make these errors less stringly typed
mkRemoteResponse :: Either RemoteError (GRpcReply Response) -> Response
mkRemoteResponse reply =
  case reply of
    Right (GRpcOk res) -> res
    Right (GRpcTooMuchConcurrency _) -> ResponseErr "remote federator -> local federator: too much concurrency"
    Right (GRpcErrorCode grpcErr) -> ResponseErr ("remote federator -> local federator: " <> Text.pack (show grpcErr))
    Right (GRpcErrorString grpcErr) -> ResponseErr ("remote federator -> local federator: error string: " <> Text.pack grpcErr)
    Right (GRpcClientError clientErr) -> ResponseErr ("remote federator -> local federator: client error: " <> Text.pack (show clientErr))
    Left err -> ResponseErr ("remote federator -> local federator: " <> Text.pack (show err))

routeToRemote :: (Members '[Remote, Polysemy.Error ServerError] r) => SingleServerT info RouteToRemote (Sem r) _
routeToRemote = singleService (Mu.method @"call" callRemote)

serveRouteToRemote :: Env -> Int -> IO ()
serveRouteToRemote env port = do
  runGRpcAppTrans msgProtoBuf port transformer routeToRemote
  where
    transformer :: Sem '[Remote, DiscoverFederator, TinyLog, DNSLookup, Polysemy.Error ServerError, Embed IO, Embed Federator] a -> ServerErrorIO a
    transformer action =
      runAppT env
        . runM
        . embedToMonadIO @Federator
        . absorbServerError
        . Lookup.runDNSLookupWithResolver (view dnsResolver env)
        . Log.runTinyLog (view applog env)
        . runFederatorDiscovery
        . interpretRemote
        $ action
