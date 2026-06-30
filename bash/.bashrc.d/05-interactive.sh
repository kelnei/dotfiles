# Interactive gate. Everything in ~/.bashrc.d after this file is interactive-only
# (history, prompt, aliases, completion, fzf); environment and PATH setup lives
# in the lower-numbered files above, which already ran, so non-interactive shells
# (scripts, Codex's `bash -lc` snapshot shell) still get a correct environment.
#
# If not interactive, signal ~/.bashrc's loop to stop here. A bare `return` only
# exits this sourced file, not the loop, so set the sentinel it checks.
case $- in
  *i*) ;;
  *) __bashrc_abort=1; return ;;
esac
