# fnm - Fast Node Manager
# make fnm fallback to ~/.local/state/fnm_multishells
# instead of /run/user/1000/fnm_multishells
_old_xdg="$XDG_RUNTIME_DIR"
unset XDG_RUNTIME_DIR
eval "$(fnm env --use-on-cd --shell bash)"
[ -n "$_old_xdg" ] && export XDG_RUNTIME_DIR="$_old_xdg"
unset _old_xdg
