# ~/.bashrc: executed by bash(1) for non-login shells.

# Source all files in ~/.bashrc.d/
# Files are ordered: 01-04 set up environment/PATH and run in every shell;
# 05-interactive.sh is the gate; 10+ are interactive-only. A subfile stops the
# rest of the loop by setting __bashrc_abort — a bare `return` from a sourced
# file only exits that file, not this loop, so we check an explicit sentinel.
if [ -d ~/.bashrc.d ]; then
    for f in ~/.bashrc.d/*.sh; do
        [ -r "$f" ] && source "$f"
        [ -n "${__bashrc_abort:-}" ] && break
    done
    unset f __bashrc_abort
fi

