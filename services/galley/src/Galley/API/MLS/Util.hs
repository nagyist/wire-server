-- This file is part of the Wire Server implementation.
--
-- Copyright (C) 2022 Wire Swiss GmbH <opensource@wire.com>
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

module Galley.API.MLS.Util where

import Control.Comonad
import Data.Id
import Data.Qualified
import Galley.Data.Conversation
import qualified Galley.Data.Conversation.Types as Data
import Galley.Effects
import Galley.Effects.ConversationStore
import Galley.Effects.MemberStore
import Galley.Effects.ProposalStore
import Imports
import Polysemy
import Polysemy.TinyLog (TinyLog)
import qualified Polysemy.TinyLog as TinyLog
import qualified System.Logger as Log
import Wire.API.Conversation hiding (Conversation)
import Wire.API.Conversation.Protocol
import Wire.API.Error
import Wire.API.Error.Galley
import Wire.API.MLS.GlobalTeamConversation
import Wire.API.MLS.KeyPackage
import Wire.API.MLS.Proposal
import Wire.API.MLS.Serialisation

getLocalConvForUser ::
  Members
    '[ ErrorS 'ConvNotFound,
       ConversationStore,
       MemberStore
     ]
    r =>
  Qualified UserId ->
  Local ConvId ->
  Sem r Data.Conversation
getLocalConvForUser qusr lcnv = do
  gtc <- getGlobalTeamConversationById lcnv
  conv <- case gtc of
    Just conv -> do
      localMembers <- getLocalMembers (qUnqualified . gtcId $ conv)
      pure $ toConv conv (qUnqualified qusr) localMembers
    Nothing -> do
      getConversation (tUnqualified lcnv) >>= noteS @'ConvNotFound

  -- check that sender is part of conversation
  isMember' <-
    foldQualified
      lcnv
      (fmap isJust . getLocalMember (convId conv) . tUnqualified)
      (fmap isJust . getRemoteMember (convId conv))
      qusr
  unless isMember' $ throwS @'ConvNotFound

  pure conv
  where
    toConv gtc usr lm =
      let mlsData = gtcMlsMetadata gtc
       in Data.Conversation
            { convId = qUnqualified $ gtcId gtc,
              convLocalMembers = lm,
              convRemoteMembers = mempty,
              convDeleted = False,
              convMetadata =
                ConversationMetadata
                  { cnvmType = GlobalTeamConv,
                    -- FUTUREWORK: Make this a qualified user ID.
                    cnvmCreator = usr,
                    cnvmAccess = [SelfInviteAccess],
                    cnvmAccessRoles = mempty,
                    cnvmName = Just $ gtcName gtc,
                    cnvmTeam = Just $ gtcTeam gtc,
                    cnvmMessageTimer = Nothing,
                    cnvmReceiptMode = Nothing
                  },
              convProtocol = ProtocolMLS mlsData
            }

getPendingBackendRemoveProposals ::
  Members '[ProposalStore, TinyLog] r =>
  GroupId ->
  Epoch ->
  Sem r [KeyPackageRef]
getPendingBackendRemoveProposals gid epoch = do
  proposals <- getAllPendingProposals gid epoch
  catMaybes
    <$> for
      proposals
      ( \case
          (Just ProposalOriginBackend, proposal) -> case rmValue proposal of
            RemoveProposal kp -> pure . Just $ kp
            _ -> pure Nothing
          (Just ProposalOriginClient, _) -> pure Nothing
          (Nothing, _) -> do
            TinyLog.warn $ Log.msg ("found pending proposal without origin, ignoring" :: ByteString)
            pure Nothing
      )
