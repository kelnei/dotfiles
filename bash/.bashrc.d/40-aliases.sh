# Enable color support of ls and handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Alert alias for long running commands. Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# git
alias gg='git grep'
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
alias gp='git push'
alias gpl='git pull'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gca='git commit --amend'

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias '~'='cd ~'
alias code='cd ~/code'

# tmux
alias tn='tmux new -s'
alias ta='tmux attach -t'

# dotfiles
alias restow='stow --dir=$HOME/.dotfiles --target=$HOME --restow'

# utilities
alias fd='fdfind'
alias vim='nvim'
alias vimdiff='nvim -d'
alias cls='clear'
alias path='echo $PATH | tr ":" "\n"'
alias ports='ss -tulnp'

# claude code accounts
alias claude-work="CLAUDE_CONFIG_DIR=$HOME/.claude-work command claude"
alias claude-personal="CLAUDE_CONFIG_DIR=$HOME/.claude-personal command claude"
alias claude="echo 'Use claude-work or claude-personal'"

# ripgrep and bat (if installed)
if command -v rg &>/dev/null; then
    alias grep='rg'
fi
if command -v batcat &>/dev/null; then
    alias bat='batcat'
    alias cat='batcat'
fi

# Source ~/.bash_aliases if it exists
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
