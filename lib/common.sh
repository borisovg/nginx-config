#!/bin/bash

function initEnv {
	set -o errexit
	set -o nounset

	CONFIG_INIT=${CONFIG_INIT:-0};
	
	local BASE_DIR=$1

	if [ $CONFIG_INIT -eq 0 ]; then
		. $BASE_DIR/config || exit 1
		CONFIG_INIT=1
	fi

	if [ $CONFIG_DEBUG -gt 0 ]; then
		set -o xtrace
	fi
}
