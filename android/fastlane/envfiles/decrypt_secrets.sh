#!/bin/sh

# --batch to prevent interactive command
# --yes to assume "yes" for questions

echo "decrypting playstore API keys"
gpg --quiet --batch --yes --decrypt --passphrase="$DECRYPTKEY_PLAYSTORE" \
--output ./playstore.json playstore.json.gpg

echo "decrypting key.properties"
gpg --quiet --batch --yes --decrypt --passphrase="$DECRYPTKEY_PROPERTIES" \
--output ./key.properties key.properties.gpg

echo "decrypting playstore signing keys"
gpg --quiet --batch --yes --decrypt --passphrase="$DECRYPTKEY_PLAYSTORE_SIGNING_KEY" \
--output ./keys.jks keys.jks.gpg