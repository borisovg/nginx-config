#!/bin/bash

# Build nginx config file
#
# Author: George Borisov <git@gir.me.uk>

set -o errexit
set -o nounset

BASE_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd)
. $BASE_DIR/lib/common.sh
initEnv $BASE_DIR

DOMAIN=${1:-}

while [ -z $DOMAIN ]; do
	echo -n "Enter a domain: "
	read DOMAIN
done

if [ ! -e "$BASE_DIR/data/$DOMAIN" ]; then
	echo 'ERROR: domain is not defined'
	exit 1
fi

DATA_DIR="$BASE_DIR/data/$DOMAIN"

. $DATA_DIR/config

TMPFILE=`mktemp /tmp/tmpfile.XXXXXX` || exit 1
trap 'rm -f "$TMPFILE" >/dev/null 2>&1' 0
trap "exit 2" 1 2 3 13 15

function insertAfterLine {
	local DST=$1
	local SRC=$2
	local MARKER=$3
	local L1=
	local L2=

	while IFS= read L1; do
		echo "$L1"
		if echo $L1 | fgrep -q "$MARKER"; then
			while IFS= read L2; do
				echo "$L2"
			done < $SRC
		fi
	done < $DST
}

cd "$BASE_DIR/templates"

if [ $SSL -ne 3 ]; then
	cat http.tpl >> $TMPFILE
	
	if [ $SSL -eq 2 ]; then
		CODE=$(insertAfterLine $TMPFILE redirectToHTTPS.tpl 'LOCAL http_tpl')
		echo "$CODE" > $TMPFILE
	
	else
		if [ $PHP -eq 1 ]; then
			CODE=$(insertAfterLine $TMPFILE php.tpl 'LOCAL http_tpl')
			echo "$CODE" > $TMPFILE
		fi
	fi

    if [[ -n $IP ]]; then
	    sed -i "s/%%HTTP_PORT%%/:$HTTP_PORT/g" $TMPFILE

    else
	    sed -i "s/%%HTTP_PORT%%/$HTTP_PORT/g" $TMPFILE
    fi

    if [[ -f $DATA_DIR/nginx_local_http.conf ]]; then
        CODE=$(insertAfterLine $TMPFILE $DATA_DIR/nginx_local_http.conf 'LOCAL http_tpl')
		echo "$CODE" > $TMPFILE
    fi
fi

if [ $SSL -gt 0 ]; then
	cat https.tpl >> $TMPFILE

	if [ $PHP -eq 1 ]; then
		CODE=$(insertAfterLine $TMPFILE php.tpl 'LOCAL https_tpl')
		echo "$CODE" > $TMPFILE
		sed -i "/LOCAL php_tpl/a fastcgi_param HTTPS on;" $TMPFILE
	fi
    
    if [[ -n $IP ]]; then
	    sed -i "s/%%HTTPS_PORT%%/:$HTTPS_PORT/g" $TMPFILE

    else
	    sed -i "s/%%HTTPS_PORT%%/$HTTPS_PORT/g" $TMPFILE
    fi

    if [[ -f $DATA_DIR/nginx_local_https.conf ]]; then
        CODE=$(insertAfterLine $TMPFILE $DATA_DIR/nginx_local_https.conf 'LOCAL https_tpl')
		echo "$CODE" > $TMPFILE
    fi
fi

if [ $PHP -eq 1 ]; then
	sed -i "s/%%INDEX%%/index.php index.html/g" $TMPFILE

else
	sed -i "s/%%INDEX%%/index.html/g" $TMPFILE
fi

sed -i "s/%%IP%%/$IP/g" $TMPFILE
sed -i "s/%%DOMAIN%%/$DOMAIN/g" $TMPFILE

cd "$BASE_DIR/data/$DOMAIN"

mkdir -p nginx

cat $TMPFILE > nginx/nginx.conf 
