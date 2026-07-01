#!/usr/bin/env bash
# shared helpers for install recipes
# source this file, do not execute it

# true if a checks/<name> status line indicates the tool isn't installed
# usage: recipe_status_missing "$STATUS"
recipe_status_missing() {
  case "$1" in
  *"not installed"*) return 0 ;;
  *) return 1 ;;
  esac
}

# true if a checks/<name> status line indicates the tool is already current
# usage: recipe_status_up_to_date "$STATUS"
recipe_status_up_to_date() {
  case "$1" in
  *"up to date"*) return 0 ;;
  *) return 1 ;;
  esac
}

# true if the tool's checks/<name> script reports it as already installed
# ignores whether it's the latest version - see recipe_update for that
recipe_is_installed() {
  CHECK="$HOME/.local/share/install/checks/$1"
  if [ ! -f "$CHECK" ] || [ ! -x "$CHECK" ]; then
    return 1
  fi
  STATUS=$("$CHECK" 2>/dev/null) || return 1
  ! recipe_status_missing "$STATUS"
}

# announce that a recipe is being skipped because it's already installed
# usage: recipe_announce_skip "$1"
recipe_announce_skip() {
  echo ""
  echo "==> $1 (already installed, skipping)"
}

# print the path to recipes/<name> and return 0, or print a usage error and
# return 1 if it doesn't exist - usage: RECIPE=$(require_recipe "$1") || return 1
require_recipe() {
  RECIPE="$HOME/.local/share/install/recipes/$1"
  if [ ! -f "$RECIPE" ] || [ ! -x "$RECIPE" ]; then
    echo "error: unknown recipe '$1'" >&2
    echo "run 'recipe_install --list' to see available recipes" >&2
    return 1
  fi
  echo "$RECIPE"
}

# print the path to checks/<name> and return 0, or print a usage error and
# return 1 if it doesn't exist - usage: CHECK=$(require_check "$1") || return 1
require_check() {
  CHECK="$HOME/.local/share/install/checks/$1"
  if [ ! -f "$CHECK" ] || [ ! -x "$CHECK" ]; then
    echo "error: no update check available for '$1'" >&2
    return 1
  fi
  echo "$CHECK"
}

# true if there's no graphical session (no DISPLAY or WAYLAND_DISPLAY)
is_headless() {
  [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]
}

# true if gh is installed and authenticated against github.com (not an enterprise host)
_have_gh_github() {
  command -v gh &>/dev/null && gh auth status --hostname github.com &>/dev/null
}

# curl with GITHUB_TOKEN if set, anonymous otherwise
_curl_github() {
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    curl -fsSL -H "Authorization: Bearer $GITHUB_TOKEN" "$@"
  else
    curl -fsSL "$@"
  fi
}

# fetch json from the github api
# prefers gh cli (github.com auth), then curl with GITHUB_TOKEN, then anonymous curl
# falls back from gh to curl on failure
github_api() {
  if _have_gh_github && gh api "$1"; then
    return
  fi
  _curl_github "https://api.github.com$1"
}

# get the latest release tag for a github repo
# usage: github_latest owner/repo
github_latest() {
  github_api "/repos/$1/releases/latest" |
    sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' |
    head -1
}

# download a release asset from a github repo
# usage: github_download owner/repo tag asset [output]
# output defaults to "-" (stdout) so the result can be piped to tar
# falls back from gh to curl when writing to a file; the streaming case can't
# fall back safely (partial gh output would corrupt the downstream pipe)
github_download() {
  local repo="$1" tag="$2" asset="$3" out="${4:--}"
  local url="https://github.com/$repo/releases/download/$tag/$asset"
  if [ "$out" = "-" ]; then
    if _have_gh_github; then
      gh release download "$tag" --repo "$repo" --pattern "$asset" --output -
    else
      _curl_github "$url"
    fi
  else
    if _have_gh_github && gh release download "$tag" --repo "$repo" --pattern "$asset" --output "$out" --clobber; then
      return
    fi
    _curl_github -o "$out" "$url"
  fi
}
