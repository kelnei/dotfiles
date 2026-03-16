# AGENTS.md

Guidelines for agentic coding agents working in this repository.

---

## Security: No Secrets

This is a **public repository**. Never commit secrets of any kind, including:

- API keys, tokens, or credentials
- Passwords or passphrases
- Private SSH keys or certificates
- Environment variables containing sensitive values

If a tool requires credentials at runtime, it must read them from outside the repo
(e.g. environment variables set manually, a secrets manager, or `~/.config/<tool>/credentials`
that is not tracked here). Never add such files to a stow package.

---

## Repository Overview

A personal dotfiles repository managed with [GNU Stow](https://www.gnu.org/software/stow/).
Files are organized into stow packages (top-level directories). Each package's internal
directory tree mirrors `$HOME` exactly. Stowing a package creates symlinks in `$HOME`.

```
~/.dotfiles/
  bash/        -> ~/.bashrc, ~/.bashrc.d/
  git/         -> ~/.gitconfig
  install/     -> ~/.local/bin/install_*
  starship/    -> ~/.config/starship.toml
```

To stow a package:
```bash
stow --dir=$HOME/.dotfiles --target=$HOME <package>
```

To restow all packages after adding files:
```bash
stow --dir=$HOME/.dotfiles --target=$HOME --restow bash git install starship
```

---

## No Build, Lint, or Test Commands

This is a shell/config repository. There is no build system, test suite, or linter.
Validation is done by sourcing or running scripts manually:

```bash
# Test bash config by sourcing
source ~/.bashrc

# Test a single install script
install_gh

# Dry-run stow to check for conflicts without making changes
stow --dir=$HOME/.dotfiles --target=$HOME --simulate <package>
```

---

## Stow Package Conventions

- Package names are **single lowercase words** (e.g. `bash`, `git`, `install`, `starship`)
- The directory tree inside each package **mirrors `$HOME` exactly**
- New tools that write to `~/.config/` go in `<package>/.config/<tool>/config-file`
- New tools that write scripts to `~/.local/bin/` go in `install/.local/bin/<script-name>`
- After adding files to a package, restow it:
  ```bash
  stow --dir=$HOME/.dotfiles --target=$HOME --restow <package>
  ```

---

## Bash Config: `.bashrc.d/` Structure

`.bashrc` simply sources all `*.sh` files in `~/.bashrc.d/` in glob (alphabetical) order.
Files are numbered with a two-digit prefix to control load order:

| Prefix | Purpose |
|---|---|
| `00` | Guards and prerequisites (interactivity check) |
| `10` | Shell behavior (history) |
| `20` | Environment setup — PATH exports, env variables |
| `30` | Prompt |
| `40` | Aliases |
| `50` | Tool integrations (completions, fnm, etc.) |
| `60+` | Reserved for future tool-specific additions |

**Critical ordering rule:** anything that must be on `$PATH` before another file uses it
must be in a file with a lower prefix number. For example, `~/.local/bin` is added in
`20-path.sh` so that `30-prompt.sh` can call `starship`.

When adding a new tool integration, create a new `.bashrc.d/` file with the appropriate
prefix rather than modifying an existing file.

---

## Shell Script Style Guide

### Shebang and Safety Flags

Every executable script must start with:
```bash
#!/usr/bin/env bash
set -euo pipefail
```

Sourced `.bashrc.d/` files do **not** use `set -euo pipefail` — they run in an
interactive shell context where `-e` and `-u` would cause unexpected exits.

### Variables

- All variables are **UPPERCASE**
- Always double-quote variables used in paths or commands: `"$HOME/.local/bin"`
- Use `${VAR}` brace syntax for string operations: `"${LATEST#v}"`
- Declare constants at the top of the script before any logic
- Use `$HOME` instead of hardcoded `/home/<user>` paths for portability

### Functions

- Use `name() {` style — no `function` keyword
- Function names are **lowercase**
- No `local` variables (keep functions simple)

### Error Handling

- Rely on `set -euo pipefail` for implicit error propagation — no explicit `if`/`||`/trap
- No `die()` helper or `trap` statements
- Do not suppress errors with `|| true` unless explicitly necessary

### Downloading Files

Use `curl -fsSL` for all downloads. Exception: use `curl --proto '=https' --tlsv1.2 -sSf`
when security is critical (e.g. bootstrapping a toolchain like rustup).

### Install Script Pattern

All install scripts follow this three-phase structure:

```bash
#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"

echo "Installing latest <tool>..."
# ... install command ...

echo "<tool> $("<binary>" --version) installed to $INSTALL_DIR/<binary>"
```

- Announce what is being installed before starting
- Confirm the installed version at the end using the binary itself
- Always fetch the **latest** version — no pinned versions

### Comments

- Lowercase, no trailing period
- On their own line, not inline
- Describe intent, not mechanics

```bash
# correct
# fnm must come before claude (npm dependency)

# incorrect
export PATH="$HOME/.local/bin:$PATH" # add local bin to PATH
```

---

## Adding a New Tool

1. Create an install script in `install/.local/bin/install_<tool>`:
   - Follow the install script pattern above
   - Use `curl -fsSL` and always install the latest version
   - Install binaries to `$HOME/.local/bin` where possible
2. If the tool needs PATH or env vars, add them to `bash/.bashrc.d/20-path.sh`
3. If the tool needs shell initialization (e.g. `eval "$(tool init bash)"`), create
   `bash/.bashrc.d/<prefix>-<tool>.sh` with the appropriate numeric prefix
4. Add the new install script to `install_all` in dependency order
5. Restow affected packages
6. Commit each logical change separately

---

---

## Git Commit Style

- Lowercase imperative present tense: `add`, `remove`, `update`, `fix`, `move`, `switch`
- Single line only — no commit body
- No conventional commits prefix (`feat:`, `fix:`, `chore:` etc.)
- No trailing period
- Include a brief reason when non-obvious, appended naturally:

```
# correct
add install_fnm script
move ~/.local/bin to 20-path.sh so it loads before starship prompt init
switch install_claude to use npm (via fnm node LTS)

# incorrect
Add install script for fnm.
feat: add fnm installation
```

---

## PATH Conventions

All PATH exports live in `bash/.bashrc.d/20-path.sh`. When adding a new entry:

- Prepend to PATH (use `$PATH` at the end) unless load order requires otherwise
- Use `$HOME` not `~` in exported variables
- Group with a comment matching the tool name

```bash
# <tool name>
export PATH="$HOME/.<tool>/bin:$PATH"
```

