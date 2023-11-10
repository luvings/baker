##
## Log
##

# To turn on debug message, set
# DEBUG=y
DEBUG=""

V () {
    echo ">>> $*"
    "$@"
}

D () {
    [ "$DEBUG" == "y" ] && echo "$*"
}

I () {
    echo "INFO: $*"
}

W () {
    echo "WARNING: $*"
}

N () {
    echo "NOTICE: $*"
    notify-send -t 10 --urgency=low "$*" >/dev/null 2>&1 || :
}

E () {
    echo "ERROR: $*" >&2
}

F () {
    echo "FATAL: $*" >&2
    exit 1
}

BANNER () {
    echo "########################################"
    echo "# $(date)"
    echo "# $*"
    echo "########################################"
}

USAGE () {
    echo "Usage: $*" >&2
    exit 1
}

##
## Utility
##

CLEAN_MKDIR () {
   [[ -d "$1" ]]  && rm -rf "$1"
   mkdir -p "$1"
}

LAZY_MKDIR () {
    [[ -d "$1" ]]  || mkdir -p "$1"
}

PUSHD () {
    pushd "$@" >/dev/null
}

POPD () {
    popd >/dev/null
}

SOURCE () {
    PUSHD "$(dirname $1)"
    . "$(basename $1)"
    POPD
}

TIMESTAMP () {
    date +%Y%m%d%H%M%S
}

IS_TRUE () {
    local bool="${1,,}"
    [[ "$bool" == "yes" || "$bool" == "true" || "$bool" == "1" ]]
}

# PROP_SET
#   Set value of key in file (with key=value format).
# $1 - key
# $2 - value
# $3 - property file
# $4 - OPTIONAL, if KEY is not found, append it after this key.
PROP_SET () {
    local K="$1" V="$2" F="$3" AFTER_KEY="${4:-}"
    D "PROP_SET: ${F}: ${K}=${V}"
    if grep -q "^${K}=" "${F}"; then
        # "KEY=VALUE"
        sed -i "s~^\(${K}\=\).*$~\1${V}~" "${F}"
    elif grep -q "^# ${K} is" "${F}"; then
        # "# KEY is not set"
        sed -i "s~^# ${K} is.*$~${K}=${V}~" "${F}"
    else
        # not found, insert it.
        if [ -n "${AFTER_KEY}" ]; then
            AFTER_KEY="/${AFTER_KEY}/"
        else
            AFTER_KEY="$"
        fi
        sed -i "${AFTER_KEY} a${K}=${V}" "${F}"
    fi
}

# PROP_UNSET
#   Unset value of key in file (with key=value format).
# $1 - key
# $2 - value (ignored)
# $3 - property file
PROP_UNSET () {
    local K="$1" F="$3"
    D "PROP_UNSET: ${F}: ${K}"
    if grep -q "^${K}=" "${F}"; then
        # "KEY=VALUE"
        sed -i "s~^\(${K}\=\).*$~# ${K} is not set~" "${F}"
    elif grep -q "^# ${K} is" "${F}"; then
        # "# KEY is not set"
        :
    else
        # Append
        echo "# ${K} is not set" >> "${F}"
    fi
}

# PROP_GET
#   Get value of key in prop_file (with key=value format).
# $1 - key
# $2 - property file
PROP_GET () {
    sed -n "/^${1}=/ s~${1}=~~p" "${2}"
}

CHECK_FILE_EXISTS () {
    while [ -n "${1:-}" ]; do
        [ -s "$1" ] || F "$1 not exists!"
        shift
	done
}


_COPY_FILES () {
    local SRC_DIR="$1" DST_DIR="$2" SRC DST
    shift 2
    while [ -n "${1:-}" ]; do
        SRC="$SRC_DIR/${1%:*}"
        DST=$DST_DIR/${1#*:}
        [ -e "$SRC" ] || F "$SRC not exists!"
        cp $CP_OPTS $SRC $DST || F "cp $CP_OPTS $SRC $DST failed!"
        shift
    done
}

# COPY_FILES <SRC_DIR> <DST_DIR> <SRC_FILE1> [<SRC_FILE2>...]
COPY_FILES () {
    local CP_OPTS=""
    _COPY_FILES "$@"
}

# Like COPY_FILES, but use hard link instead of copy
COPY_FILES_BY_HARD_LINK () {
    local CP_OPTS="-lf"
    _COPY_FILES "$@"
}

_COPY_FIRST_AVAILABE_FILE () {
    local SRC_FILE="$1" DST_DIR="$2" SRC DST
    shift 2
    while [ -n "${1:-}" ]; do
        SRC="$1/$SRC_FILE"
        if [[ -e "$SRC" ]]; then
            cp $CP_OPTS $SRC $DST_DIR/ || F "cp $SRC $DST_DIR/ failed!"
            return
        fi
        shift
    done
    F "$SRC_FILE not exists!"
}

COPY_FIRST_AVAILABE_FILE () {
    local CP_OPTS=""
    _COPY_FIRST_AVAILABE_FILE "$@"
}

COPY_FIRST_AVAILABE_FILE_BY_HARK_LINK () {
    local CP_OPTS="-lf"
    _COPY_FIRST_AVAILABE_FILE "$@"
}

FIND_FIRST_AVAILABE_FILE () {
    local SRC_FILE="$1" SRC
    shift 1
    while [ -n "${1:-}" ]; do
        SRC="$1/$SRC_FILE"
        if [[ -e "$SRC" ]]; then
            echo "$SRC"
            return
        fi
        shift
    done
    return 1
}

# Replace bytes in file
# $1 - filename to patch
# $2 - offset in bytes
# $3... - bytes in hex
# e.g. REPLACE_BYTES idb.img $((64*512+128*4+104)) 1 01 0xb1 b1
REPLACE_BYTES() {
    python3 -c '
import sys

fileName = sys.argv[1]
offset = int(sys.argv[2], 0)
data = bytes([int(x, 16) for x in sys.argv[3:]])

with open(fileName, "r+b") as fh:
    fh.seek(offset)
    fh.write(data)
' "$@"
}
CHECK_MISSING_OPT () {
    local VAL=${!1:-}
    [ -n "$VAL" ] || F "Missing option $1"
}

SET_DEFAULT_OPT () {
    local VAL=${!1:-}
    [ -n "$VAL" ] || eval $1="$2"
}
