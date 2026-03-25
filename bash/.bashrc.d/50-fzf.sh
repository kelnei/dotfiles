# fzf
export FZF_DEFAULT_OPTS='--height 40% --layout reverse --border'
export FZF_CTRL_T_OPTS='--walker-skip .git,node_modules,target --bind ctrl-/:change-preview-window(down|hidden|)'
export FZF_ALT_C_OPTS='--walker-skip .git,node_modules,target'

if command -v fdfind &>/dev/null; then
  FZF_FD='fdfind'
elif command -v fd &>/dev/null; then
  FZF_FD='fd'
fi

if [ -n "${FZF_FD:-}" ]; then
  export FZF_DEFAULT_COMMAND="$FZF_FD --type f --strip-cwd-prefix --hidden --follow --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="$FZF_FD --type d --strip-cwd-prefix --hidden --follow --exclude .git"
fi

if command -v batcat &>/dev/null; then
  export FZF_CTRL_T_OPTS="$FZF_CTRL_T_OPTS --preview '\''batcat -n --color=always {}'\''"
  export FZF_FILE_PREVIEW='batcat -n --color=always'
elif command -v bat &>/dev/null; then
  export FZF_CTRL_T_OPTS="$FZF_CTRL_T_OPTS --preview '\''bat -n --color=always {}'\''"
  export FZF_FILE_PREVIEW='bat -n --color=always'
else
  export FZF_FILE_PREVIEW='sed -n 1,200p'
fi

if command -v fzf &>/dev/null; then
  eval "$(fzf --bash)"
fi

fe() {
  if [ -n "${FZF_FD:-}" ]; then
    FILE=$($FZF_FD --type f --strip-cwd-prefix --hidden --follow --exclude .git 2>/dev/null | fzf --preview "$FZF_FILE_PREVIEW {}")
  else
    FILE=$(rg --files --hidden -g '!.git' 2>/dev/null | fzf --preview "$FZF_FILE_PREVIEW {}")
  fi

  if [ -n "$FILE" ]; then
    nvim "$FILE"
  fi
}

fbr() {
  BRANCH=$(git for-each-ref --format='%(refname:short)' refs/heads refs/remotes 2>/dev/null | fzf)

  if [ -n "$BRANCH" ]; then
    git checkout "$BRANCH"
  fi
}
