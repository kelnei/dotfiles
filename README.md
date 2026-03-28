# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Packages

| Package | Maps to |
|---|---|
| `bash` | `~/.bashrc`, `~/.bashrc.d/` |
| `git` | `~/.gitconfig`, `~/.gitignore` |
| `ghostty` | `~/.config/ghostty/config` |
| `install` | `~/.local/bin/recipe_install`, `~/.local/share/install/recipes/*` |
| `nvim` | `~/.config/nvim/` |
| `starship` | `~/.config/starship.toml` |
| `tmux` | `~/.tmux.conf` |

## Setup

### 1. Clone the repo

```bash
git clone git@github.com:kelnei/dotfiles.git ~/.dotfiles
```

### 2. Bootstrap

```bash
~/.dotfiles/bootstrap
```

This will:

- Install system dependencies (wget, curl, git, git-lfs, stow, build-essential, gettext, ninja-build, make, cmake)
- Create `~/.local/bin`
- Remove the default `~/.bashrc` from a fresh install (so stow can symlink ours)
- Stow all packages

### 3. Install tools

Open a new shell (so the stowed bash config is active), then:

```bash
recipe_install all
```

This installs: starship, go, rust, uv, bun, gh, aws, ssm, ripgrep, shellcheck, shfmt, fzf, bat, docker, 1password, op, gopass, proton-pass, fnm, claude, codex, opencode, neovim, ghostty, tmux, brave, and lmstudio.

After installing tmux, launch it and press `Ctrl+Space I` to install plugins.

## Adding a New Tool

See [AGENTS.md](AGENTS.md) for full conventions and style guide.
