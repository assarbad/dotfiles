#!/usr/bin/env bash
[[ -t 1 ]] && { cG="\e[1;32m"; cR="\e[1;31m"; cB="\e[1;34m"; cW="\e[1;37m"; cY="\e[1;33m"; cG_="\e[0;32m"; cR_="\e[0;31m"; cB_="\e[0;34m"; cW_="\e[0;37m"; cY_="\e[0;33m"; cZ="\e[0m"; export cR cG cB cY cW cR_ cG_ cB_ cY_ cW_ cZ; }
for tool in readlink tr fold head mktemp cat awk find grep; do type $tool > /dev/null 2>&1 || { echo -e "${cR}ERROR:${cZ} couldn't find '$tool' which is required by this script."; exit 1; }; done
pushd $(dirname $0) > /dev/null; CURRABSPATH=$(readlink -nf "$(pwd)"); popd > /dev/null; # Get the directory in which the script resides
###############################################################################
### Feel free to override any of those variables up to the next "ruler"
###############################################################################
export PASSPHRASE=${PASSPHRASE:-$(tr -dc '[:upper:]' < /dev/urandom | fold -w 32 | head -n1)}
export GNUPGHOME=${GNUPGHOME:-$(mktemp -d)}
NAME=${NAME:-Jane Doe}
MAIL=${MAIL:-j.doe@example.com}
let KEYLEN=${KEYLEN:-4096}
let SUBKEYLEN=${SUBKEYLEN:-$KEYLEN}
# GnuPG expects a particular format for the time ...
TIME=${TIME:-$(date +"%Y%m%dT000000")} # today at midnight
###############################################################################
BATCH=$(mktemp -p "$GNUPGHOME")
echo -e "export ${cW}GNUPGHOME${cZ}=${cW}$GNUPGHOME${cZ}"
echo -e "${cW}INFO:${cZ} writing ${cW}\$GNUPGHOME/gpg.conf${cZ}"
cat <<EOGPGCONF >> "$GNUPGHOME/gpg.conf"
# https://github.com/drduh/config/blob/master/gpg.conf
# https://www.gnupg.org/documentation/manuals/gnupg/GPG-Configuration-Options.html
# https://www.gnupg.org/documentation/manuals/gnupg/GPG-Esoteric-Options.html
# Use AES256, 192, or 128 as cipher
personal-cipher-preferences AES256 AES192 AES
# Use SHA512, 384, or 256 as digest
personal-digest-preferences SHA512 SHA384 SHA256
# Use ZLIB, BZIP2, ZIP, or no compression
personal-compress-preferences ZLIB BZIP2 ZIP Uncompressed
# Default preferences for new keys
default-preference-list SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed
# SHA512 as digest to sign keys
cert-digest-algo SHA512
# SHA512 as digest for symmetric ops
s2k-digest-algo SHA512
# AES256 as cipher for symmetric ops
s2k-cipher-algo AES256
# UTF-8 support for compatibility
charset utf-8
# Show Unix timestamps
fixed-list-mode
# No comments in signature
no-comments
# No version in signature
no-emit-version
# Disable banner
no-greeting
# Long hexidecimal key format
keyid-format 0xlong
# Display UID validity
list-options show-uid-validity
verify-options show-uid-validity
# Display all keys and their fingerprints
with-fingerprint
# Display key origins and updates
#with-key-origin
# Cross-certify subkeys are present and valid
require-cross-certification
# Disable caching of passphrase for symmetrical ops
no-symkey-cache
# Enable smartcard
use-agent
# Disable recipient key ID in messages
throw-keyids
# Default/trusted key ID to use (helpful with throw-keyids)
#default-key 0xFF3E7D88647EBCDB
#trusted-key 0xFF3E7D88647EBCDB
# Group recipient keys (preferred ID last)
#group keygroup = 0xFF00000000000001 0xFF00000000000002 0xFF3E7D88647EBCDB
# Keyserver URL
#keyserver hkps://keys.openpgp.org
#keyserver hkps://keyserver.ubuntu.com:443
#keyserver hkps://hkps.pool.sks-keyservers.net
#keyserver hkps://pgp.ocf.berkeley.edu
# Proxy to use for keyservers
#keyserver-options http-proxy=socks5-hostname://127.0.0.1:9050
# Verbose output
#verbose
# Show expired subkeys
#list-options show-unusable-subkeys
EOGPGCONF
# Show what we've got ...
grep -ve "^#" "$GNUPGHOME/gpg.conf"
echo -e "${cW}INFO:${cZ} writing master key generation 'batch' script"
cat <<EOKEYGEN|tee "$BATCH"
Key-Type: RSA
Key-Length: 4096
Key-Usage: cert
Name-Real: $NAME
Name-Email: $MAIL
Expire-Date: 0
%commit
EOKEYGEN
echo -e "${cW}INFO:${cZ} attempting key generation"
if ( set -x; gpg --batch --faked-system-time $TIME --passphrase "$PASSPHRASE" --status-fd=1 --pinentry-mode=loopback --gen-key "$BATCH" ); then
	echo -e "${cG}SUCCESS:${cZ} Key was generated."
else
	echo -e "${cR}FATAL:${cZ} Key generation failed."
	exit 1
fi
echo -e "${cW}INFO:${cZ} listing freshly generated (and presumably only) secret key"
( set -x; gpg --batch --list-secret-keys )
KEYID=$(gpg --batch --list-secret-keys --with-colons|awk -F : '$1 ~ /^sec$/ {print "0x" $5}')
KEYFPR=$(gpg --batch --list-secret-keys --with-colons|awk -F : '$1 ~ /^fpr$/ {print $10}')
echo -e "${cW}INFO:${cZ} using key ${cW}$KEYID${cZ} (${cY}$KEYFPR${cZ})"
# Alternative to get fingerprint ... gpg --list-options show-only-fpr-mbox --list-secret-keys
echo -e "${cW}INFO:${cZ} fetching auto-generated revocation certificate"
( set -x; cp -a "$GNUPGHOME/openpgp-revocs.d/$KEYFPR.rev" "$GNUPGHOME"/ ) \
	|| { echo -e "${cR}FATAL:${cZ} failed to save the revocation certificate."; exit 1; }
{
	echo addkey
	echo 4 # RSA (sign only)
	echo $SUBKEYLEN
	echo 0 # does not expire
	echo save
} | gpg --faked-system-time $TIME --passphrase "$PASSPHRASE" --command-fd=0 --status-fd=1 --pinentry-mode=loopback --edit-key "$KEYID" \
	|| { echo -e "${cR}FATAL:${cZ} failed to generate signing subkey."; exit 1; }
{
	echo addkey
	echo 6 # RSA (encrypt only)
	echo $SUBKEYLEN
	echo 0 # does not expire
	echo save
} | gpg --faked-system-time $TIME --passphrase "$PASSPHRASE" --command-fd=0 --status-fd=1 --pinentry-mode=loopback --edit-key "$KEYID" \
	|| { echo -e "${cR}FATAL:${cZ} failed to generate encryption subkey."; exit 1; }
{
	echo addkey
	echo 8 # RSA (own options)
	echo a # toggle authenticate (on)
	echo e # toggle encrypt (off)
	echo s # toggle sign (off)
	echo q # toggle sign (off)
	echo $SUBKEYLEN
	echo 0 # does not expire
	echo save
} | gpg --faked-system-time $TIME --passphrase "$PASSPHRASE" --command-fd=0 --status-fd=1 --pinentry-mode=loopback --expert --edit-key "$KEYID" \
	|| { echo -e "${cR}FATAL:${cZ} failed to generate authentication subkey."; exit 1; }
echo -e "${cW}INFO:${cZ} exporting secret keys."
( set -x; gpg --batch --passphrase "$PASSPHRASE" --pinentry-mode=loopback --armor --export-secret-keys "$KEYID" > "$GNUPGHOME/$KEYFPR-full-key.asc" ) \
	|| { echo -e "${cR}FATAL:${cZ} failed to export _all_ secret keys in one fell swoop."; exit 1; }
( set -x; gpg --batch --passphrase "$PASSPHRASE" --pinentry-mode=loopback --armor --export-secret-subkeys "$KEYID" > "$GNUPGHOME/$KEYFPR-subkeys-only.asc" ) \
	|| { echo -e "${cR}FATAL:${cZ} failed to export only secret subkeys."; exit 1; }
echo -e "${cG}SUCCESS${cZ} artifacts are in ${cW}$GNUPGHOME${cZ}:"
find "$GNUPGHOME" -maxdepth 1 -type f -name $KEYFPR'*' -printf '%f\n'|while read fname; do
	echo -e "\t${cW}$fname${cZ}"
done
echo -e "${cG}PASSPHRASE ${cB_}$PASSPHRASE${cZ}"
( set -x; gpg --batch --list-secret-keys )
