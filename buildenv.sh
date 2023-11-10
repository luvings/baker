# setup environment
set -o pipefail

if [[ "$0" == "$BASH_SOURCE" ]]; then
    echo "buildenv.sh should be sourced, and executed directly" >&2
    exit 1
fi

TOP_DIR=$(cd $(dirname "$BASH_SOURCE") && pwd)
BIN=$TOP_DIR/bin
PROFILE=$TOP_DIR/profile

# unpack/build/pack directories
OUT=${TOP_DIR}/out
UNPACK=${OUT}/unpack
STAGE=${OUT}/stage
PACK=${OUT}/pack

. $PROFILE/common
. $BIN/lib.sh
[[ -x $BIN/mkbootimg ]] || make -C $BIN
. $BIN/app.sh

[[ "$1" == "-q" ]] || echo "To get command list, type 'help'."
