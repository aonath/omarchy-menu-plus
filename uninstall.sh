#!/bin/bash

# Take omarchy-menu-plus out and bring Omarchy's own menu, dock, emoji picker,
# clipboard history and image picker back.

set -euo pipefail

CONFIG=${XDG_CONFIG_HOME:-$HOME/.config}
PLUGINS="$CONFIG/omarchy/plugins"
BIN="$HOME/.local/bin"
MENU="$CONFIG/omarchy/extensions/omarchy-menu.jsonc"

say() { printf '\033[1momarchy-menu-plus:\033[0m %s\n' "$*"; }

for name in menu dock emojis clipboard image-picker; do
  omarchy plugin disable "menuplus.$name" >/dev/null 2>&1 || true
  omarchy plugin enable "omarchy.$name" >/dev/null 2>&1 || true
  rm -rf "${PLUGINS:?}/menuplus.$name"
done
rm -f "$BIN/menu-select"

if [[ -f $MENU ]] && grep -q '// omarchy-menu-plus begin' "$MENU"; then
  cp "$MENU" "$MENU.bak.$(date +%s)"
  sed -i '/^  \/\/ omarchy-menu-plus begin$/,/^  \/\/ omarchy-menu-plus end$/d' "$MENU"
fi

# The stock menu cannot draw layout tiles: give omarchy-matrix rows glyphs.
if [[ -f $MENU ]] && grep -q '// omarchy-matrix begin' "$MENU"; then
  sed -i '/\/\/ omarchy-matrix begin/,/\/\/ omarchy-matrix end/{s/"icon":"layout:dwindle"/"icon":"󱓻"/; s/"icon":"layout:scrolling"/"icon":"󰝥"/; s/"icon":"layout:floating"/"icon":"󰔶"/; s/"icon":"layout:matrix"/"icon":"󰕰"/}' "$MENU"
fi

omarchy restart shell >/dev/null 2>&1 || true
say "uninstalled; Omarchy's own plugins are back"
