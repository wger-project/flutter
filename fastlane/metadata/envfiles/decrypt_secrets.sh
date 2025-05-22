#!/bin/sh

# --batch to prevent interactive command
# --yes to assume "yes" for questions

# To encrypt a new version of the keys:
# gpg -c filename.json

if [ -n "$DECRYPTKEY_PLAYSTORE" ]; then
  echo "decrypting playstore API keys"
  gpg --quiet --batch --yes --decrypt --passphrase="$DECRYPTKEY_PLAYSTORE" \
  --output ./playstore.json playstore.json.gpg
fi

if [ -n "$DECRYPTKEY_PROPERTIES" ]; then
  echo "decrypting key.properties"
  gpg --quiet --batch --yes --decrypt --passphrase="$DECRYPTKEY_PROPERTIES" \
  --output ./key.properties key.properties.gpg
fi

if [ -n "$DECRYPTKEY_PLAYSTORE_SIGNING_KEY" ]; then
  echo "decrypting playstore signing keys"
  gpg --quiet --batch --yes --decrypt --passphrase="$DECRYPTKEY_PLAYSTORE_SIGNING_KEY" \
  --output ./keys.jks keys.jks.gpg
fi