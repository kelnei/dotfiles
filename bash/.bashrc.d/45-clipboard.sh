# OSC 52 clipboard helper — the SSH-friendly replacement for `xclip`.
#
# Copies stdin (or file args) to the LOCAL system clipboard by emitting an
# OSC 52 escape sequence to the terminal. Works from any remote host over a
# plain SSH connection — no forwarding, no wl-clipboard/xclip on the remote.
# Inside tmux, `set-clipboard on` (see ~/.tmux.conf) catches the sequence and
# forwards it out to Ghostty.
#
# Usage:
#   cat file | clip
#   clip file
#   some-command | clip
#
# Note: terminals cap the OSC 52 payload (~74 KB of input for Ghostty), so this
# is for text/snippets, not large binaries.
clip() {
  # `command cat` bypasses the batcat alias so we copy raw bytes.
  printf '\033]52;c;%s\a' "$(command cat "$@" | base64 | tr -d '\n')" > /dev/tty
}
