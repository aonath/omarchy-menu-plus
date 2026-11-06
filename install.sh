#!/bin/bash

# Install omarchy-menu-plus: Omarchy's menu, dock app grid, emoji picker,
# clipboard history and image picker, reworked so the menu reads and moves
# better and every list or panel opened from it leads back to it. Each one
# replaces its Omarchy original (as `omarchy plugin clone` does). Run again to
# update; uninstall.sh brings the originals back.

set -euo pipefail

SRC=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CONFIG=${XDG_CONFIG_HOME:-$HOME/.config}
PLUGINS="$CONFIG/omarchy/plugins"
BIN="$HOME/.local/bin"
MENU="$CONFIG/omarchy/extensions/omarchy-menu.jsonc"
IDS=(menuplus.menu menuplus.dock menuplus.emojis menuplus.clipboard menuplus.image-picker)

say() { printf '\033[1momarchy-menu-plus:\033[0m %s\n' "$*"; }
fail() { printf 'omarchy-menu-plus: %s\n' "$*" >&2; exit 1; }

# The shell learns about new plugin folders on a rescan; wait until it lists them.
wait_known() {
  omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
  local id tries
  for id in "$@"; do
    for tries in $(seq 50); do
      omarchy plugin list --json 2>/dev/null | jq -e --arg id "$id" 'any(.[]; .id == $id)' >/dev/null && break
      sleep 0.2
    done
  done
}

command -v omarchy >/dev/null || fail "Omarchy is not installed (no omarchy command)"

for id in "${IDS[@]}"; do
  omarchy plugin validate "$SRC/plugins/$id" || fail "invalid plugin: $id"
done

mkdir -p "$PLUGINS"
for id in "${IDS[@]}"; do
  rm -rf "${PLUGINS:?}/$id"
  cp -r "$SRC/plugins/$id" "$PLUGINS/$id"
  say "plugin $id"
done

mkdir -p "$BIN"
install -m 755 "$SRC/bin/menu-select" "$BIN/menu-select"
say "command $BIN/menu-select"

wait_known "${IDS[@]}"

# Each plugin replaces the Omarchy plugin it was made from (the menu also in
# the bar, where its button takes the original's place).
for id in "${IDS[@]}"; do
  omarchy plugin enable "$id" >/dev/null
done

# Omarchy's on/off pairs as switches that keep the menu open.
mkdir -p "$(dirname "$MENU")"
[[ -f $MENU ]] || printf '{\n}\n' >"$MENU"
cp "$MENU" "$MENU.bak.$(date +%s)"
python3 - "$MENU" "$SRC/menu/toggles.jsonc" <<'PY'
import sys
path, block_path = sys.argv[1:3]
BEGIN, END = "  // omarchy-menu-plus begin", "  // omarchy-menu-plus end"
block = open(block_path).read().rstrip("\n")
lines = open(path).read().split("\n")
if BEGIN in lines:
    start, end = lines.index(BEGIN), lines.index(END)
    del lines[start:end + 1]
close = max(i for i, l in enumerate(lines) if l.strip() == "}")
for i in range(close - 1, -1, -1):
    stripped = lines[i].strip()
    if stripped and not stripped.startswith("//"):
        if not stripped.endswith((",", "{")):
            lines[i] = lines[i] + ","
        break
lines[close:close] = [BEGIN, block, END]
open(path, "w").write("\n".join(lines))
PY
say "menu switches in $MENU"

# With omarchy-matrix installed, its Workspace Layout rows get the tiles of
# its bar button.
if [[ -f $MENU ]] && grep -q '// omarchy-matrix begin' "$MENU"; then
  sed -i '/\/\/ omarchy-matrix begin/,/\/\/ omarchy-matrix end/{s/"icon":"󱓻"/"icon":"layout:dwindle"/; s/"icon":"󰝥"/"icon":"layout:scrolling"/; s/"icon":"󰔶"/"icon":"layout:floating"/; s/"icon":"󰕰"/"icon":"layout:matrix"/}' "$MENU"
fi

# Service and overlay plugins load with the shell.
omarchy restart shell >/dev/null 2>&1 || true
say "installed"
