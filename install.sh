#!/bin/bash
#
# Sheikah — optional post-install step.
#
# The theme itself installs normally:
#
#     omarchy theme install https://github.com/<you>/omarchy-sheikah-theme.git
#
# That gets you the palette, the wallpapers and the ASCII art. Two things it
# cannot get you, because Omarchy deliberately does not let an installed theme
# supply them, are the window-border glow (Hyprland Lua) and having the
# screensaver/about art actually applied. Run this script once to enable both.
#
#     ./install.sh              enable
#     ./install.sh --uninstall  undo
#
# What it changes, all inside your home directory -- nothing system-wide, no
# sudo, and nothing under /usr:
#
#     ~/.config/omarchy/hooks/theme-set.d/omarchy-theme-extras
#
# That one hook is theme-agnostic. It stays out of the way of themes that ship
# none of these files, and it keeps working if you later install other themes
# that do.

set -euo pipefail

THEME_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
THEME_NAME="$(basename "$THEME_DIR")"
HOOK_NAME="omarchy-theme-extras"
HOOK_DIR="$HOME/.config/omarchy/hooks/theme-set.d"
HOOK_DEST="$HOOK_DIR/$HOOK_NAME"

say()  { printf '  %s\n' "$*"; }
fail() { printf '\n  Error: %s\n\n' "$*" >&2; exit 1; }

printf '\n  Sheikah — post-install\n\n'

# --- uninstall ------------------------------------------------------------
if [[ ${1:-} == "--uninstall" ]]; then
  if [[ -f $HOOK_DEST ]]; then
    rm -f "$HOOK_DEST"
    say "Removed $HOOK_DEST"
  else
    say "Nothing to remove."
  fi
  ALLOWLIST="$HOME/.config/omarchy/theme-extras.allow"
  if [[ -f $ALLOWLIST ]] && grep -qxF -- "$THEME_NAME" "$ALLOWLIST"; then
    grep -vxF -- "$THEME_NAME" "$ALLOWLIST" >"$ALLOWLIST.tmp" || true
    mv "$ALLOWLIST.tmp" "$ALLOWLIST"
    say "De-allowlisted $THEME_NAME"
  fi
  say "Branding art is left as-is. Restore Omarchy's with:"
  say "    omarchy branding screensaver reset && omarchy branding about reset"
  printf '\n'
  exit 0
fi

# --- preflight ------------------------------------------------------------
command -v omarchy >/dev/null || fail "This does not look like an Omarchy system."
[[ -f $THEME_DIR/colors.toml ]] || fail "Run this from inside the theme directory."

# --- install the hook -----------------------------------------------------
mkdir -p "$HOOK_DIR"
install -m 755 "$THEME_DIR/install/$HOOK_NAME" "$HOOK_DEST"
say "Installed hook  → $HOOK_DEST"

# Vouch for this theme's Lua. Omarchy denies Lua from installed themes because
# it is executable code; the allowlist re-enables it for this theme only, and
# running this script is what counts as consent. Other installed themes stay
# denied.
ALLOWLIST="$HOME/.config/omarchy/theme-extras.allow"
if [[ -f $ALLOWLIST ]] && grep -qxF -- "$THEME_NAME" "$ALLOWLIST"; then
  say "Already allowlisted for Lua ($THEME_NAME)"
else
  printf '%s\n' "$THEME_NAME" >>"$ALLOWLIST"
  say "Allowlisted    → $ALLOWLIST ($THEME_NAME)"
fi

# --- apply now ------------------------------------------------------------
# The hook normally fires from omarchy-theme-set. Run it directly so the
# current session picks everything up without a second theme switch.
current="$(omarchy theme current 2>/dev/null || true)"
current_slug="$(printf '%s' "$current" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"

if [[ $current_slug == "$THEME_NAME" ]]; then
  bash "$HOOK_DEST" "$THEME_NAME"
  say "Applied to the running session."
  printf '\n  Done. Border glow and branding are live.\n\n'
else
  say "Theme '$THEME_NAME' is not currently active (active: ${current:-none})."
  printf '\n  Done. Select it from Omarchy menu → Style → Theme and the\n'
  printf '  glow and branding will apply automatically.\n\n'
fi
