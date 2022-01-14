{-# LANGUAGE StandaloneKindSignatures #-}

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
module Wire.API.Federation.Version where

import Data.Aeson
import Data.Singletons
import GHC.Generics
import Imports
import Wire.API.Arbitrary
import Wire.API.Federation.Version.TH

data Version = V0
  deriving (Eq, Ord, Show, Generic)
  deriving (Arbitrary) via (GenericUniform Version)

versionOptions :: Options
versionOptions =
  defaultOptions
    { constructorTagModifier = map toLower,
      tagSingleConstructors = True
    }

instance ToJSON Version where
  toJSON = genericToJSON @Version versionOptions

instance FromJSON Version where
  parseJSON = genericParseJSON @Version versionOptions

$(genVersions ''Version)

supportedVersions :: [Version]
supportedVersions = demote @SupportedVersions
