# fnm - Fast Node Manager
# make fnm fallback to /tmp/fnm_multishells
# instead of /run/user/1000/fnm_multishells
_old_xdg="$XDG_RUNTIME_DIR"
XDG_RUNTIME_DIR="/tmp"
eval "$(fnm env --use-on-cd --shell bash)"
[ -n "$_old_xdg" ] && export XDG_RUNTIME_DIR="$_old_xdg"
unset _old_xdg
