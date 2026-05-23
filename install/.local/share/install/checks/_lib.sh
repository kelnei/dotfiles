#!/usr/bin/env bash
# shared helpers for version check scripts
# source this file, do not execute it

# fetch json from the github api
# prefers gh cli (github.com auth), then curl with GITHUB_TOKEN, then anonymous curl
# falls back from gh to curl on failure
github_api() {
  if command -v gh &>/dev/null && gh auth status --hostname github.com &>/dev/null; then
    if gh api "$1" 2>/dev/null; then
      return
    fi
  fi
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    curl -fsSL -H "Authorization: Bearer $GITHUB_TOKEN" "https://api.github.com$1" 2>/dev/null
  else
    curl -fsSL "https://api.github.com$1" 2>/dev/null
  fi
}

# get the latest release tag for a github repo
# usage: github_latest owner/repo
github_latest() {
  github_api "/repos/$1/releases/latest" | grep -o '"tag_name": *"[^"]*"' | cut -d'"' -f4
}

# get the latest tag for a github repo (for repos that use tags instead of releases)
# usage: github_latest_tag owner/repo
github_latest_tag() {
  github_api "/repos/$1/tags?per_page=1" | grep -o '"name": *"[^"]*"' | head -1 | cut -d'"' -f4
}

# compare installed vs latest and print result
# usage: check_version tool installed latest
check_version() {
  TOOL="$1"
  INSTALLED="$2"
  LATEST="$3"

  if [ "$INSTALLED" = "not installed" ]; then
    echo "$TOOL: not installed (latest $LATEST)"
  elif [ "$INSTALLED" = "$LATEST" ]; then
    echo "$TOOL: up to date ($INSTALLED)"
  else
    echo "$TOOL: $INSTALLED -> $LATEST"
  fi
}
