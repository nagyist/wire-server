# WARNING: GENERATED FILE, DO NOT EDIT.
# This file is generated by running hack/bin/generate-local-nix-packages.sh and
# must be regenerated whenever local packages are added or removed, or
# dependencies are added or removed.
{ mkDerivation
, aeson
, ansi-terminal
, api-client
, async
, attoparsec
, base
, base64-bytestring
, bilge
, bytestring
, bytestring-conversion
, cereal
, containers
, cryptobox-haskell
, cryptonite
, exceptions
, filepath
, gitignoreSource
, HaskellNet
, HaskellNet-SSL
, http-client
, imports
, iso639
, lib
, memory
, metrics-core
, mime
, monad-control
, mwc-random
, optparse-applicative
, resource-pool
, stm
, text
, time
, tinylog
, transformers-base
, types-common
, unordered-containers
, uuid
, vector
}:
mkDerivation {
  pname = "api-bot";
  version = "0.4.2";
  src = gitignoreSource ./.;
  libraryHaskellDepends = [
    aeson
    ansi-terminal
    api-client
    async
    attoparsec
    base
    base64-bytestring
    bilge
    bytestring
    bytestring-conversion
    cereal
    containers
    cryptobox-haskell
    cryptonite
    exceptions
    filepath
    HaskellNet
    HaskellNet-SSL
    http-client
    imports
    iso639
    memory
    metrics-core
    mime
    monad-control
    mwc-random
    optparse-applicative
    resource-pool
    stm
    text
    time
    tinylog
    transformers-base
    types-common
    unordered-containers
    uuid
    vector
  ];
  description = "(Internal) API automation around wire-client";
  license = lib.licenses.agpl3Only;
}