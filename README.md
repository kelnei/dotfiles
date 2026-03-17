# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Packages

| Package | Maps to |
|---|---|
| `bash` | `~/.bashrc`, `~/.bashrc.d/` |
| `git` | `~/.gitconfig`, `~/.gitignore` |
| `ghostty` | `~/.config/ghostty/config` |
| `install` | `~/.local/bin/install_*` |
| `nvim` | `~/.config/nvim/` |
| `starship` | `~/.config/starship.toml` |
| `tmux` | `~/.tmux.conf` |

## Setup

### 1. Install dependencies

```bash
sudo apt-get install -y git stow
```

### 2. Clone the repo

```bash
git clone git@github.com:kelnei/dotfiles.git ~/.dotfiles
```

### 3. Stow the packages

```bash
mkdir -p ~/.local/bin
cd ~/.dotfiles
stow git bash starship ghostty nvim tmux install
```

### 4. Install tools

```bash
install_all
```

This installs: starship, go, rust, uv, bun, gh, aws, ripgrep, bat, 1password, op, gopass, proton-pass, fnm, claude, codex, opencode, neovim, ghostty, and tmux.

After installing tmux, launch it and press `Ctrl+Space I` to install plugins.

## Adding a New Tool

See [AGENTS.md](AGENTS.md) for full conventions and style guide.
