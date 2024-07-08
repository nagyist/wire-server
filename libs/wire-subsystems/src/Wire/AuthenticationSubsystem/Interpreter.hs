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

module Wire.AuthenticationSubsystem.Interpreter
  ( interpretAuthenticationSubsystem,
    passwordResetCodeTtl,
    module Wire.AuthenticationSubsystem.Error,
  )
where

import Data.ByteString.Conversion
import Data.Id
import Data.Misc
import Data.Qualified
import Data.Time
import Imports hiding (lookup)
import Polysemy
import Polysemy.Error
import Polysemy.Input
import Polysemy.TinyLog (TinyLog)
import Polysemy.TinyLog qualified as Log
import System.Logger
import Wire.API.Allowlists (AllowlistEmailDomains)
import Wire.API.Allowlists qualified as AllowLists
import Wire.API.Password
import Wire.API.User
import Wire.API.User.Password
import Wire.AuthenticationSubsystem
import Wire.AuthenticationSubsystem.Error
import Wire.EmailSubsystem
import Wire.HashPassword
import Wire.PasswordResetCodeStore
import Wire.PasswordStore
import Wire.Sem.Now
import Wire.Sem.Now qualified as Now
import Wire.SessionStore
import Wire.UserKeyStore
import Wire.UserSubsystem (UserSubsystem, getLocalUserAccountByUserKey)

interpretAuthenticationSubsystem ::
  forall r.
  ( Member PasswordResetCodeStore r,
    Member Now r,
    Member (Error AuthenticationSubsystemError) r,
    Member TinyLog r,
    Member HashPassword r,
    Member SessionStore r,
    Member (Input (Local ())) r,
    Member (Input (Maybe AllowlistEmailDomains)) r,
    Member UserSubsystem r,
    Member PasswordStore r,
    Member EmailSubsystem r
  ) =>
  InterpreterFor AuthenticationSubsystem r
interpretAuthenticationSubsystem = interpret $ \case
  CreatePasswordResetCode userKey -> createPasswordResetCodeImpl userKey
  ResetPassword ident resetCode newPassword -> resetPasswordImpl ident resetCode newPassword
  InternalLookupPasswordResetCode userKey -> internalLookupPasswordResetCodeImpl userKey

maxAttempts :: Int32
maxAttempts = 3

passwordResetCodeTtl :: NominalDiffTime
passwordResetCodeTtl = 3600 -- 60 minutes

-- This type is not exported and used for internal control flow only
data PasswordResetError
  = AllowListError
  | InvalidResetKey
  | InProgress
  deriving (Show)

instance Exception PasswordResetError where
  displayException AllowListError = "email domain is not allowed for password reset"
  displayException InvalidResetKey = "invalid reset key for password reset"
  displayException InProgress = "password reset already in progress"

createPasswordResetCodeImpl ::
  forall r.
  ( Member PasswordResetCodeStore r,
    Member Now r,
    Member (Input (Local ())) r,
    Member (Input (Maybe AllowlistEmailDomains)) r,
    Member TinyLog r,
    Member UserSubsystem r,
    Member EmailSubsystem r
  ) =>
  EmailKey ->
  Sem r ()
createPasswordResetCodeImpl target =
  logPasswordResetError =<< runError do
    allowListOk <- (\e -> AllowLists.verify e (emailKeyOrig target)) <$> input
    unless allowListOk $ throw AllowListError
    user <- lookupActiveUserByUserKey target >>= maybe (throw InvalidResetKey) pure
    let uid = userId user
    Log.debug $ field "user" (toByteString uid) . field "action" (val "User.beginPasswordReset")

    mExistingCode <- lookupPasswordResetCode uid
    when (isJust mExistingCode) $
      throw InProgress

    let key = mkPasswordResetKey uid
    now <- Now.get
    code <- generateEmailCode
    codeInsert
      key
      (PRQueryData code uid (Identity maxAttempts) (Identity (passwordResetCodeTtl `addUTCTime` now)))
      (round passwordResetCodeTtl)
    sendPasswordResetMail (emailKeyOrig target) (key, code) (Just user.userLocale)
    pure ()
  where
    -- `PasswordResetError` are errors that we don't want to leak to the caller.
    -- Therefore we handle them here and only log without propagating them.
    logPasswordResetError :: Either PasswordResetError () -> Sem r ()
    logPasswordResetError = \case
      Left e ->
        Log.err $
          field "action" (val "User.beginPasswordReset")
            . field "error" (displayException e)
      Right v -> pure v

lookupActiveUserIdByUserKey ::
  (Member UserSubsystem r, Member (Input (Local ())) r) =>
  EmailKey ->
  Sem r (Maybe UserId)
lookupActiveUserIdByUserKey target =
  userId <$$> lookupActiveUserByUserKey target

lookupActiveUserByUserKey ::
  (Member UserSubsystem r, Member (Input (Local ())) r) =>
  EmailKey ->
  Sem r (Maybe User)
lookupActiveUserByUserKey target = do
  localUnit <- input
  let ltarget = qualifyAs localUnit target
  mUser <- getLocalUserAccountByUserKey ltarget
  case mUser of
    Just user -> do
      pure $
        if user.accountStatus == Active
          then Just user.accountUser
          else Nothing
    Nothing -> pure Nothing

internalLookupPasswordResetCodeImpl ::
  ( Member PasswordResetCodeStore r,
    Member Now r,
    Member (Input (Local ())) r,
    Member UserSubsystem r
  ) =>
  EmailKey ->
  Sem r (Maybe PasswordResetPair)
internalLookupPasswordResetCodeImpl key = do
  mUser <- lookupActiveUserIdByUserKey key
  case mUser of
    Just user -> do
      mCode <- lookupPasswordResetCode user
      let k = mkPasswordResetKey user
      pure $ (k,) <$> mCode
    Nothing -> pure Nothing

lookupPasswordResetCode ::
  ( Member PasswordResetCodeStore r,
    Member Now r
  ) =>
  UserId ->
  Sem r (Maybe PasswordResetCode)
lookupPasswordResetCode u = do
  let key = mkPasswordResetKey u
  now <- Now.get
  validate now =<< codeSelect key
  where
    validate now (Just (PRQueryData c _ _ (Just t))) | t > now = pure $ Just c
    validate _ _ = pure Nothing

resetPasswordImpl ::
  forall r.
  ( Member PasswordResetCodeStore r,
    Member Now r,
    Member (Input (Local ())) r,
    Member (Error AuthenticationSubsystemError) r,
    Member TinyLog r,
    Member UserSubsystem r,
    Member HashPassword r,
    Member SessionStore r,
    Member PasswordStore r
  ) =>
  PasswordResetIdentity ->
  PasswordResetCode ->
  PlainTextPassword8 ->
  Sem r ()
resetPasswordImpl ident code pw = do
  key <- passwordResetKeyFromIdentity

  muid :: Maybe UserId <- verify (key, code)
  case muid of
    Nothing -> throw AuthenticationSubsystemInvalidPasswordResetCode
    Just uid -> do
      Log.debug $ field "user" (toByteString uid) . field "action" (val "User.completePasswordReset")
      checkNewIsDifferent uid pw
      hashedPw <- hashPassword pw
      upsertHashedPassword uid hashedPw
      codeDelete key
      deleteAllCookies uid
  where
    passwordResetKeyFromIdentity :: Sem r PasswordResetKey
    passwordResetKeyFromIdentity = case ident of
      PasswordResetIdentityKey k -> pure k
      PasswordResetEmailIdentity e -> do
        mUserId <- lookupActiveUserIdByUserKey (mkEmailKey e)
        let mResetKey = mkPasswordResetKey <$> mUserId
        maybe (throw AuthenticationSubsystemInvalidPasswordResetKey) pure mResetKey
      PasswordResetPhoneIdentity _ -> do
        throw AuthenticationSubsystemInvalidPhone

    checkNewIsDifferent :: UserId -> PlainTextPassword' t -> Sem r ()
    checkNewIsDifferent uid newPassword = do
      mCurrentPassword <- lookupHashedPassword uid
      case mCurrentPassword of
        Just currentPassword
          | (verifyPassword newPassword currentPassword) -> throw AuthenticationSubsystemResetPasswordMustDiffer
        _ -> pure ()

    verify :: PasswordResetPair -> Sem r (Maybe UserId)
    verify (k, c) = do
      now <- Now.get
      passwordResetData <- codeSelect k
      case passwordResetData of
        Just (PRQueryData codeInDB u _ (Just t)) | c == codeInDB && t >= now -> pure (Just u)
        Just (PRQueryData codeInDB u (Just n) (Just t)) | n > 1 && t > now -> do
          -- If we only update retries, there is a chance that this races with
          -- the PasswordResetCodeTtl and we have a situation where only retries is non-null for
          -- a given key. To avoid this, we insert the whole row again.
          codeInsert k (PRQueryData codeInDB u (Identity (n - 1)) (Identity t)) (round passwordResetCodeTtl)
          pure Nothing
        Just PRQueryData {} -> codeDelete k $> Nothing
        Nothing -> pure Nothing
