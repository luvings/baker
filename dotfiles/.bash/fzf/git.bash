# https://gist.github.com/junegunn/8b572b8d4b5eddd8b85e5f4d40f17236
# GIT heart FZF
# -------------

is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

fzf-down() {
  fzf --height 50% "$@" --border
}

gf() {
  is_in_git_repo || return
  git -c color.status=always status --short |
  fzf-down -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' |
  cut -c4- | sed 's/.* -> //'
}

gb() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

gt() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-down --multi --preview-window right:70% \
    --preview 'git show --color=always {} | head -'$LINES
}

gh() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -'$LINES |
  grep -o "[a-f0-9]\{7,\}"
}

gr() {
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf-down --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1} | head -200' |
  cut -d$'\t' -f1
}


bind '"\er": redraw-current-line'
bind '"\C-gf": "$(gf)\e\C-e\er"'
bind '"\C-gb": "$(gb)\e\C-e\er"'
bind '"\C-gt": "$(gt)\e\C-e\er"'
bind '"\C-gh": "$(gh)\e\C-e\er"'
bind '"\C-gr": "$(gr)\e\C-e\er"'

# git diff - preview and show
gd() {
  __gd_args="$*"
  export __gd_args

  gd_preview() {
    local file ignore
    read file ignore <<< "$@"
    if [ -n "$file" ]; then
      git diff --color=always $__gd_args -- "$file" | head -$LINES
    fi
  }
  gd_execute() {
    local file ignore
    read file ignore <<< "$@"
    if [ -n "$file" ]; then
      git diff --color=always $__gd_args -- "$file" | less -R
    fi
  }
  git diff --color=always --stat=132,100 "$@" |
      fzf --ansi --reverse --tiebreak=index --no-sort \
              --bind=ctrl-s:toggle-sort \
              --preview "$(type gd_preview | grep -v "is a function"); gd_preview {}" \
              --bind "ctrl-m:execute:$(type gd_execute | grep -v "is a function"); gd_execute {}"
}

# https://junegunn.kr/2015/03/browsing-git-commits-with-fzf
# git show - git commit browser
gs() {
  gs_preview() {
    local sha
    sha=$(grep -o '[a-f0-9]\{7,\}' <<< "$@" | head -n 1)
    if [ -n "$sha" ]; then
      git show --color=always --stat -p $sha | head -n 100
    fi
  }
  gs_execute() {
    local sha
    sha=$(grep -o '[a-f0-9]\{7,\}' <<< "$@" | head -n 1)
    if [ -n "$sha" ]; then
      git --no-pager show --color=always --stat -p $sha | less -R
    fi
  }
  git log -n 60 --color=always \
            --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
      fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
            --preview "$(type gs_preview | grep -v "is a function"); gs_preview {}" \
            --bind "ctrl-m:execute:$(type gs_execute | grep -v "is a function"); gs_execute {}"
}

# git grep - preview and edit
gg() {
  gg_preview() {
    local file line ignore
    IFS=: read file line ignore <<< "$@"
    echo "$@"
    if [ -n "$line" ]; then
      nl -ba -nln $file | grep --color -C 10 "^$line "
    fi
  }
  gg_execute() {
    local file line ignore
    IFS=: read file line ignore <<< "$@"
    if [ -n "$line" ]; then
      e +$line $file
    fi
  }
  git grep -n -i "$@" |
      fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
            --preview "$(type gg_preview | grep -v "is a function"); gg_preview {}" \
            --bind "ctrl-m:execute:$(type gg_execute | grep -v "is a function"); gg_execute {}"
}
