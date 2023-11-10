alias n='tmux new-window'
alias e='emacsclient -t'
alias t='trash'

function .. () {
    if [[ -z "$1" ]]; then
        cd ..
    elif [[ "$1" = "-" ]]; then
        cd -
    elif [[ -z "$(echo "$1"|tr -d [0-9])" ]]; then
        for ((i=0; i<$1; i++)); do
            cd ..
        done
    else
        local _PWD
        _PWD=$(dirname $(pwd))
        while [[ $_PWD != "/" ]]; do
            if [[ $(basename $_PWD) == *$1* ]]; then
                cd $_PWD
                return
            fi
            _PWD=$(dirname $_PWD)
        done
        # fallback
        cd ..
     fi
}

alias ggrep='git grep -n'
alias g='grep -rn'

dtsgrep() {
    git grep -n "$@" -- arch/arm/boot/dts/
}

dts64grep() {
    git grep -n "$@" -- arch/arm64/boot/dts/rockchip
}

drvgrep() {
    git grep -n "$@" -- drivers/
}

fn() {
    local arg1=$1
    shift
    find -name '*'"${arg1}"'*' "$@"
}

# alias emacs
alias emacsd='emacs --daemon'
alias e='emacsclient -t'
alias ec='emacsclient -c'

# run emacs daemon
[[ -z $(ps -C 'emacs --daemon' -o pid=) ]] && emacsd

# add kill emacs function
function kill-emacs(){
    emacsclient -e "(kill-emacs)"
    emacs_pid=$( ps -C 'emacs --daemon' -o pid= )
    if [[ -n "${emacs_pid}" ]];then
        kill -9 "${emacs_pid}"
    fi
}
