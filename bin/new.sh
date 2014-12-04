#!/bin/bash

# This script creates a new domain directory.
#
# Author: George Borisov <git@gir.me.uk>

BASE_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd)
. $BASE_DIR/lib/common.sh
initEnv $BASE_DIR

DOMAIN=${1:-}

while [ -z $DOMAIN ]; do
	echo -n "Enter a domain: "
	read DOMAIN
done

if [ -e "$BASE_DIR/data/$DOMAIN" ]; then
	echo 'ERROR: domain already defined'
	exit 1
fi

mkdir -p "$BASE_DIR/data/$DOMAIN"

touch "$BASE_DIR/data/$DOMAIN/config"

$BASE_DIR/bin/edit.sh $DOMAIN
