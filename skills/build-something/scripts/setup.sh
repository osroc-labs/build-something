#!/usr/bin/env bash
# Gets a never-set-up computer ready for /build-something. Safe to re-run.
# Installs Node.js into ~/.local/node (no admin password) and checks for git.
set -euo pipefail

NODE_MAJOR=24
DEST="$HOME/.local/node"

case "$(uname -m)" in
  arm64|aarch64) arch=arm64 ;;
  x86_64|amd64)  arch=x64 ;;
  *) echo "UNSUPPORTED_ARCH $(uname -m)"; exit 1 ;;
esac

os="$(uname -s)"
case "$os" in
  Darwin)               plat=darwin; ext=tar.gz; bindir="$DEST/bin" ;;
  Linux)                plat=linux;  ext=tar.xz; bindir="$DEST/bin" ;;
  MINGW*|MSYS*|CYGWIN*) plat=win;    ext=zip;    bindir="$DEST" ;;
  *) echo "UNSUPPORTED_OS $os"; exit 1 ;;
esac

have_node() {
  command -v node >/dev/null 2>&1 &&
    [ "$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0)" -ge 20 ]
}

sha256() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | awk '{print $1}'
  else shasum -a 256 "$1" | awk '{print $1}'; fi
}

# --- Node.js ---------------------------------------------------------------
if have_node; then
  echo "NODE_OK $(node -v) (already installed at $(command -v node))"
else
  export PATH="$bindir:$PATH"
  if ! have_node; then
    base="https://nodejs.org/dist/latest-v${NODE_MAJOR}.x"
    sums="$(curl -fsSL "$base/SHASUMS256.txt")"
    line="$(printf '%s\n' "$sums" | grep -E "node-v[0-9.]+-${plat}-${arch}\.${ext}\$" | head -n1)"
    [ -n "$line" ] || { echo "NODE_DOWNLOAD_NOT_FOUND ${plat}-${arch}"; exit 1; }
    want="$(echo "$line" | awk '{print $1}')"
    file="$(echo "$line" | awk '{print $2}')"

    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT
    echo "Downloading $file ..."
    curl -fsSL "$base/$file" -o "$tmp/$file"
    [ "$(sha256 "$tmp/$file")" = "$want" ] || { echo "NODE_CHECKSUM_MISMATCH"; exit 1; }

    case "$ext" in
      tar.gz) tar -xzf "$tmp/$file" -C "$tmp" ;;
      tar.xz) tar -xJf "$tmp/$file" -C "$tmp" ;;
      zip)
        if command -v unzip >/dev/null 2>&1; then unzip -q "$tmp/$file" -d "$tmp"
        else powershell.exe -NoProfile -Command "Expand-Archive -Path '$(cygpath -w "$tmp/$file")' -DestinationPath '$(cygpath -w "$tmp")'"; fi ;;
    esac

    mkdir -p "$(dirname "$DEST")"
    rm -rf "$DEST"
    mv "$tmp/${file%.$ext}" "$DEST"
    hash -r
  fi

  # Make it stick for future terminals and Claude Code sessions.
  marker="# added by build-something"
  for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile"; do
    if [ "$rc" = "$HOME/.zshrc" ] && [ "$os" != "Darwin" ] && [ ! -f "$rc" ]; then continue; fi
    touch "$rc"
    grep -qF "$marker" "$rc" || printf '\nexport PATH="%s:$PATH" %s\n' "$bindir" "$marker" >> "$rc"
  done

  echo "NODE_OK $(node -v) installed at $DEST"
  echo "PATH_LINE export PATH=\"$bindir:\$PATH\""
fi

npm config set fund false >/dev/null 2>&1 || true
npm config set update-notifier false >/dev/null 2>&1 || true

# --- git -------------------------------------------------------------------
if [ "$os" = "Darwin" ] && ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install >/dev/null 2>&1 || true
  echo "GIT_INSTALLING (macOS developer tools pop-up shown; click Install)"
elif command -v git >/dev/null 2>&1 && git --version >/dev/null 2>&1; then
  echo "GIT_OK $(git --version)"
else
  echo "GIT_MISSING (continue without commits; see troubleshooting)"
fi
