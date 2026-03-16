# ~/.bashrc: executed by bash(1) for non-login shells.

# Source all files in ~/.bashrc.d/
if [ -d ~/.bashrc.d ]; then
    for f in ~/.bashrc.d/*.sh; do
        [ -r "$f" ] && source "$f"
    done
    unset f
fi

