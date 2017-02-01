#!/bin/bash

# This script creates a new domain directory.
#
# Author: George Borisov <git@gir.me.uk>

set -o errexit
set -o nounset

BASE_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd)
. $BASE_DIR/lib/common.sh
initEnv $BASE_DIR

DOMAIN=${1:-}
CSR_SUBJECT=${CSR_SUBJECT:-}

while [ -z $DOMAIN ]; do
	echo -n "Enter a domain: "
	read DOMAIN
done

if [ ! -e "$BASE_DIR/data/$DOMAIN" ]; then
	echo 'ERROR: domain is not defined'
	exit 1
fi

if ! command -pv openssl >/dev/null 2>&1; then
	echo "ERROR: OpenSSL not found"
	exit 1
fi

cd "$BASE_DIR/data/$DOMAIN"

. "$BASE_DIR/config"
. config

function newKey {
	local KEY_LENGTH=${1:-2048}
	openssl genpkey -out key.pem -algorithm RSA -pkeyopt rsa_keygen_bits:$KEY_LENGTH
}

function newCSR {
	local SUBJECT=${1:-}

	if [ -n "$SUBJECT" ]; then
		openssl req -new -out csr.pem -sha256 -key key.pem -subj "$SUBJECT"

	else
		openssl req -new -out csr.pem -sha256 -key key.pem
	fi
}

function makeCert {
	echo -n "Certificate lifetime (in years) [1]: "
	read LINE
	local YEARS=${LINE:-1}

	openssl req -x509 -in csr.pem -out cert.pem -days $((YEARS*365)) -key key.pem
}

if [ -e ssl ]; then
	cd ssl

	while [ true ]; do
		echo "1 - New private key and CSR"
		echo "2 - Make a self-signed certificate (not-recommended)"
		echo "0 - Do nothing"
		echo
		echo -n "Your choice: "

		read LINE
		if [ $LINE -eq 1 ]; then
			newKey $CONFIG_SSL_KEY_LENGTH
			newCSR "$CSR_SUBJECT"
			break

		elif [ $LINE -eq 2 ]; then
			makeCert
			break

		elif [ $LINE -eq 0 ]; then
			exit 0
		fi
	done

else
	echo "Generating a new SSL private key and CSR."
	echo "You will also need a certificate (save to cert.pem)."
	mkdir -p ssl
	cd ssl
	newKey
	newCSR "$CSR_SUBJECT"
fi

exit 0
