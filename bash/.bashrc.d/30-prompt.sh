# starship prompt (skip under dumb terminals)
if [[ "$TERM" != "dumb" ]]; then
  eval "$(starship init bash)"
fi
