# Enable programmable completion features.
# (Interactive-only: ~/.bashrc.d/05-interactive.sh stops the loop before here in
# non-interactive shells, which also keeps bash-completion's extglob `case`
# patterns out of Codex's `declare -f` snapshot, where they fail to re-parse.)
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
