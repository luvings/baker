# Setup fzf
# ---------
if [[ ! "$PATH" == */home/huang/.fzf/bin* ]]; then
  export PATH="$PATH:/home/huang/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/huang/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
export FZF_DEFAULT_OPTS="--reverse"
export FZF_DEFAULT_COMMAND='
  (git ls-tree -r --name-only HEAD ||
   find . -path "*/\.*" -prune -o -type f -print -o -type l -print |
      sed s/^..//) 2> /dev/null'
source "/home/huang/.fzf/shell/key-bindings.bash"

# Extensions
# ---------------
source "/home/huang/.fzf/shell/git.bash"
