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
    curl -fsSL -H "User-Agent: kelnei" -H "Authorization: Bearer $GITHUB_TOKEN" "https://api.github.com$1" 2>/dev/null
  else
    curl -fsSL -H "User-Agent: kelnei" "https://api.github.com$1" 2>/dev/null
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

# print this machine's architecture in the given naming scheme, failing on
# architectures no recipe supports - usage: ARCH=$(recipe_arch deb|uname|x64)
#   deb   -> amd64 | arm64     (debian packages, apt Packages indexes)
#   uname -> x86_64 | aarch64  (rust target triples)
#   x64   -> x64 | arm64       (node/electron style: lmstudio)
recipe_arch() {
  local machine
  machine=$(uname -m)
  case "$1:$machine" in
  deb:x86_64) echo amd64 ;;
  uname:x86_64) echo x86_64 ;;
  x64:x86_64) echo x64 ;;
  deb:aarch64) echo arm64 ;;
  uname:aarch64) echo aarch64 ;;
  x64:aarch64) echo arm64 ;;
  *)
    echo "error: unsupported architecture '$machine'" >&2
    return 1
    ;;
  esac
}

# fetch a package's version from a debian "Packages" index
# downloads to a temp file first - piping curl straight into an awk that
# exits early races with curl still writing the rest of the file, which
# can fail with "curl: (23) Failure writing output to destination"
# some repos (e.g. claude-desktop) list every version they've ever shipped
# as separate stanzas, so this collects them all and picks the highest via
# dpkg's own version comparison rather than trusting file order
# usage: apt_package_version url package-name
apt_package_version() {
  TMP=$(mktemp)
  curl -fsSL "$1" -o "$TMP"
  BEST=""
  while IFS= read -r VERSION; do
    if [ -z "$BEST" ] || dpkg --compare-versions "$VERSION" gt "$BEST"; then
      BEST="$VERSION"
    fi
  done < <(awk -v pkg="$2" '$0 == "Package: " pkg {FOUND=1; next} FOUND && /^Version: /{print $2; FOUND=0}' "$TMP")
  echo "$BEST"
  rm -f "$TMP"
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
