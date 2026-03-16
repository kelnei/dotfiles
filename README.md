# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Packages

| Package | Maps to |
|---|---|
| `bash` | `~/.bashrc`, `~/.bashrc.d/` |
| `git` | `~/.gitconfig` |
| `install` | `~/.local/bin/install_*` |
| `starship` | `~/.config/starship.toml` |

## Setup

### 1. Clone the repo

```bash
git clone git@github.com:kelnei/dotfiles.git ~/.dotfiles
```

### 2. Stow the packages

```bash
cd ~/.dotfiles
stow git bash starship install
```

### 3. Install tools

```bash
install_all
```

This installs: starship, go, rust, uv, bun, gh, aws, fnm, claude, and opencode.

## Adding a New Tool

See [AGENTS.md](AGENTS.md) for full conventions and style guide.
