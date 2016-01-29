#!/bin/bash

# This script is run at install time.
#
# Author: George Borisov <git@gir.me.uk>

set -o errexit
set -o nounset

BASE_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd)
. $BASE_DIR/lib/common.sh
initEnv $BASE_DIR

mkdir -p data
