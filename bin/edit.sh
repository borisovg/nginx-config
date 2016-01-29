#!/bin/bash

# Interactive domain configuration editor
#
# Author: George Borisov <git@gir.me.uk>

set -o errexit
set -o nounset

BASE_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd)
. $BASE_DIR/lib/common.sh
initEnv $BASE_DIR

DOMAIN=${1:-}
SSL=0	# 0: no, 1: yes, 2: yes + redirect all, 3: only SSL
PHP=0	# 0: no, 1: yes
HTTP_PORT=80
HTTPS_PORT=443
CSR_SUBJECT=
IP=

while [ -z $DOMAIN ]; do
	echo -n "Enter a domain: "
	read DOMAIN
done

if [ ! -e "$BASE_DIR/data/$DOMAIN" ]; then
	echo 'ERROR: domain is not defined'
	exit 1
fi

cd "$BASE_DIR/data/$DOMAIN"

. config

TMPFILE=`mktemp /tmp/tmpfile.XXXXXX` || exit 1
trap 'rm -f "$TMPFILE" >/dev/null 2>&1' 0
trap "exit 2" 1 2 3 13 15

echo "Enable PHP?"
echo -n "0: no, 1: yes [$PHP]:"
read LINE
PHP=${LINE:-$PHP}
echo "PHP=$PHP" >> $TMPFILE

echo "Enable SSL?"
echo -n "0: no, 1: yes, 2: yes + redirect, 3: only [$SSL]: "
read LINE
SSL=${LINE:-$SSL}
echo "SSL=$SSL" >> $TMPFILE

echo -n "HTTP Port [$HTTP_PORT]: "
read LINE
HTTP_PORT=${LINE:-$HTTP_PORT}
echo "HTTP_PORT=$HTTP_PORT" >> $TMPFILE

if [ $SSL -gt 0 ]; then
	echo -n "HTTPS Port [$HTTPS_PORT]: "
	read LINE
	HTTPS_PORT=${LINE:-$HTTPS_PORT}
	echo "HTTPS_PORT=$HTTPS_PORT" >> $TMPFILE
	
	if [ -n "$CSR_SUBJECT" ]; then
		echo "CSR subject string [$CSR_SUBJECT]: "

	else 
		echo "CSR subject string (e.g. /C=UK/L=London/O=My Company/CN=$DOMAIN []: "
	fi
	read LINE
	CSR_SUBJECT=${LINE:-$CSR_SUBJECT}
	echo "CSR_SUBJECT='$CSR_SUBJECT'" >> $TMPFILE
fi

echo -n "Server IP (optional) [$IP]: "
read LINE
IP=${LINE:-$IP}
echo "IP='$IP'" >> $TMPFILE

cat $TMPFILE > config

if [ $SSL -gt 1 ]; then
	if [ ! -e ssl ]; then
		$BASE_DIR/bin/keygen.sh $DOMAIN
	fi
fi

exit 0
