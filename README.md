# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Packages

| Package | Maps to |
|---|---|
| `bash` | `~/.bashrc`, `~/.bashrc.d/` |
| `git` | `~/.gitconfig`, `~/.gitignore` |
| `ghostty` | `~/.config/ghostty/config` |
| `install` | `~/.local/bin/recipe_install`, `~/.local/bin/recipe_check`, `~/.local/bin/recipe_update`, `~/.local/share/install/recipes/*`, `~/.local/share/install/checks/*` |
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

This installs: starship, go, rust, uv, ruff, bun, gh, aws, ssm, ripgrep, shellcheck, shfmt, fzf, bat, just, docker, 1password, op, gopass, proton_pass, fnm, claude, codex, grok, opencode, neovim, ghostty, tmux, brave, and lmstudio.

After installing tmux, launch it and press `Ctrl+Space I` to install plugins.

### 4. Keeping tools up to date

```bash
recipe_check all   # see what has updates available
recipe_update all  # update everything that's out of date
```

`recipe_install` only installs tools that are missing; `recipe_update` is what
bumps already-installed tools to their latest version.

## Adding a New Tool

See [AGENTS.md](AGENTS.md) for full conventions and style guide.
