# Source secret environment variables (not tracked by git)
if [ -d "$HOME/.bashrc.secrets.d" ]; then
  for f in "$HOME/.bashrc.secrets.d"/*.sh; do
    [ -r "$f" ] && source "$f"
  done
  unset f
fi
