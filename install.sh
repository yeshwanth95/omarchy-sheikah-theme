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
#     ./install.sh --with-lock  also replace the lock screen (see below)
#
# The lock screen is opt-in. Everything else here is cosmetic and reversible;
# the lock screen is the one thing that, if it broke, would keep you out of
# your own machine. It is not a reasonable side effect of installing a theme,
# so it only happens when you ask for it by name.
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
HOOK_NAME="sheikah-theme-extras"
HOOK_DIR="$HOME/.config/omarchy/hooks/theme-set.d"
HOOK_DEST="$HOOK_DIR/$HOOK_NAME"
PLUGIN_ID="sheikah.workspaces"
PLUGIN_SRC="$THEME_DIR/install/plugins/$PLUGIN_ID"
PLUGIN_DEST="$HOME/.config/omarchy/plugins/$PLUGIN_ID"
LOCK_ID="sheikah.lock"
LOCK_DEST="$HOME/.config/omarchy/plugins/$LOCK_ID"
LOCK_SRC="${OMARCHY_PATH:-/usr/share/omarchy}/shell/plugins/lock"
LOCK_PATCH="$THEME_DIR/install/lock-frame"
WITH_LOCK=0
[[ ${1:-} == "--with-lock" ]] && WITH_LOCK=1

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
  # Disable before removing. The restore that puts omarchy.workspaces back in
  # the same layout slot reads clonedFrom out of the manifest, so deleting the
  # directory first would strand a dead entry in shell.json and leave the bar
  # with no workspace indicator at all.
  if [[ -d $PLUGIN_DEST ]]; then
    omarchy plugin disable "$PLUGIN_ID" >/dev/null 2>&1 || true
    rm -rf "$PLUGIN_DEST"
    say "Restored built-in workspaces widget"
  fi
  # Disable before removing, same reason as above and more sharply: the restore
  # that puts omarchy.lock back reads clonedFrom out of this manifest, so
  # deleting the directory first strands omarchy.lock in disabledPlugins and
  # leaves the session with NO lock plugin at all.
  if [[ -d $LOCK_DEST ]]; then
    omarchy plugin disable "$LOCK_ID" >/dev/null 2>&1 || true
    rm -rf "$LOCK_DEST"
    say "Restored built-in lock screen"
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

# --- the workspace quest marker -------------------------------------------
# Omarchy reserves the omarchy.* plugin namespace and rejects any third-party
# plugin that collides with a built-in, so the marker cannot be a patch to
# omarchy.workspaces. It ships instead as a stand-in bar widget declaring
# clonedFrom: omarchy.workspaces -- Omarchy then hands it the built-in's slot
# on enable, and hands the slot back on disable. The widget decides at runtime
# whether the active theme ships assets/quest_marker.svg and draws the stock
# Nerd Font dot when it does not, so it is safe under any theme.
install_marker_widget() {
  [[ -d $PLUGIN_SRC ]] || { say "No marker widget in this checkout; skipping."; return 0; }
  command -v omarchy-plugin-enable >/dev/null 2>&1 \
    || { say "This Omarchy has no shell plugins; skipping marker widget."; return 0; }

  # Copied, never symlinked: omarchy plugin validate refuses a symlink
  # anywhere inside a plugin folder.
  mkdir -p "$PLUGIN_DEST"
  install -m 644 "$PLUGIN_SRC/manifest.json" "$PLUGIN_DEST/manifest.json"
  install -m 644 "$PLUGIN_SRC/BarWidget.qml" "$PLUGIN_DEST/BarWidget.qml"
  omarchy plugin validate "$PLUGIN_DEST" >/dev/null \
    || fail "the marker widget failed omarchy plugin validate"
  say "Installed widget → $PLUGIN_DEST"

  omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true

  local i
  for i in 1 2 3 4 5 6 7 8 9 10; do
    omarchy plugin list 2>/dev/null | grep -q "$PLUGIN_ID" && break
    sleep 0.2
  done

  if ! omarchy plugin list 2>/dev/null | grep -q "$PLUGIN_ID"; then
    say "Shell has not picked it up yet; run 'omarchy restart shell'."
    return 0
  fi

  if omarchy plugin list 2>/dev/null | grep -qE "^[^ ]*$PLUGIN_ID.*enabled"; then
    say "Widget already on  → $PLUGIN_ID"
  else
    omarchy plugin enable "$PLUGIN_ID" >/dev/null 2>&1 || true
    say "Enabled widget  → $PLUGIN_ID (took the omarchy.workspaces slot)"
  fi
}

install_marker_widget

# --- the lock screen frame and fade (opt-in) -------------------------------
# Built from the running Omarchy's own lock plugin, never from a copy frozen
# into this repo. Service.qml carries the PAM flow and the stranded-lock
# recovery; shipping a stale one would be a broken lock screen on any Omarchy
# but the exact version this theme was written against.
#
# Every edit below is anchored on a line checked to occur exactly once first,
# and if an anchor has moved that edit does not happen. Most are inserts. Two
# are whole-line replacements, which is a sharper tool, so each is gated by
# itself -- see replace_line and the stages inside install_lock_frame. The
# authentication code is never touched by any of them.
insert_before() {
  local anchor="$1" snippet="$2" target="$3"
  awk -v anchor="$anchor" -v snippet="$snippet" '
    $0 == anchor { while ((getline line < snippet) > 0) print line; close(snippet) }
    { print }
  ' "$target" >"$target.new" && mv "$target.new" "$target"
}

# Swap one whole line for another. Unlike insert_before this changes code that
# is already there, so the caller must have checked the line occurs exactly
# once -- unique_line below -- before calling it.
replace_line() {
  local from="$1" to="$2" target="$3"
  awk -v from="$from" -v to="$to" '
    $0 == from { print to; next }
    { print }
  ' "$target" >"$target.new" && mv "$target.new" "$target"
}

# Exact whole-line occurrences of $1 in $2.
unique_line() {
  grep -cxF "$1" "$2" 2>/dev/null || true
}

install_lock_frame() {
  local anchor_props="  signal submitPassword(string password)"
  local anchor_overlay="    BorderSurface {"

  [[ -d $LOCK_SRC ]] || { say "This Omarchy has no lock plugin; skipping frame."; return 0; }
  [[ -f $THEME_DIR/assets/sheikah_frame.png ]] || { say "No baked frame in this checkout; skipping."; return 0; }
  command -v omarchy-plugin-enable >/dev/null 2>&1 || { say "No shell plugins; skipping lock frame."; return 0; }
  command -v jq >/dev/null 2>&1 || { say "jq not found; skipping lock frame."; return 0; }

  local stage
  stage=$(mktemp -d "$HOME/.config/omarchy/plugins/.sheikah-lock.XXXXXX")
  install -m 644 "$LOCK_SRC/Service.qml" "$LOCK_SRC/LockView.qml" "$stage/"

  # Both anchors must occur exactly once, or upstream has changed underneath
  # us and a blind insert could produce a lock screen with no password field.
  local a b
  a=$(grep -cxF "$anchor_props"   "$stage/LockView.qml" || true)
  b=$(grep -cxF "$anchor_overlay" "$stage/LockView.qml" || true)
  if [[ $a != 1 || $b != 1 ]]; then
    rm -rf "$stage"
    say "This Omarchy's LockView.qml is not shaped as expected ($a/$b anchors);"
    say "leaving the stock lock screen untouched."
    return 0
  fi

  insert_before "$anchor_props"   "$LOCK_PATCH/properties.qml" "$stage/LockView.qml"
  insert_before "$anchor_overlay" "$LOCK_PATCH/overlay.qml"    "$stage/LockView.qml"

  # --- the unlock fade, gated separately --------------------------------
  # The fade-in above lives entirely in LockView.qml and rides the anchor the
  # frame already uses. The fade-OUT cannot: WlSessionLock destroys its
  # surfaces the instant `locked` goes false, so the release has to be held
  # back, and the only place to do that is Service.qml -- the PAM file this
  # installer otherwise copies untouched.
  #
  # So it gets its own gate rather than joining the one above. Service.qml is
  # 551 lines of lifecycle, PAM and recovery and is far likelier to move
  # between Omarchy releases than the view; folding it into the same check
  # would mean a future Omarchy costing you the frame and the fade-in too.
  # This way the worst it can cost is the unlock fade.
  local svc_props_anchor="  function realScreenCount() {"
  local svc_bind_anchor="        onWakeRequested: root.runWake()"
  local svc_release_from="    sessionLock.locked = false"
  local p b r
  p=$(unique_line "$svc_props_anchor"  "$stage/Service.qml")
  b=$(unique_line "$svc_bind_anchor"   "$stage/Service.qml")
  r=$(unique_line "$svc_release_from"  "$stage/Service.qml")
  if [[ $p == 1 && $b == 1 && $r == 1 ]]; then
    insert_before "$svc_props_anchor" "$LOCK_PATCH/service-props.qml" "$stage/Service.qml"
    insert_before "$svc_bind_anchor"  "$LOCK_PATCH/service-bind.qml"  "$stage/Service.qml"
    replace_line  "$svc_release_from" "    root.releaseSessionLock()" "$stage/Service.qml"
  else
    say "This Omarchy's lock Service.qml is not shaped as expected ($p/$b/$r);"
    say "installing without the unlock fade. Locking still fades in."
  fi

  # How long the lock screen waits before blanking the display. Upstream's 5s
  # is brisk if you lock while still reading something; 10s is the local
  # preference. Gated on its own too: if upstream retunes that timer, every
  # other part of this install still goes in.
  local blank_from="    interval: 5000"
  if [[ $(unique_line "$blank_from" "$stage/Service.qml") == 1 ]]; then
    replace_line "$blank_from" "    interval: 10000" "$stage/Service.qml"
  else
    say "Leaving the lock screen's blank delay at its Omarchy default."
  fi

  jq --arg id "$LOCK_ID" --arg name "Sheikah Lock Screen" '
      .id = $id | .name = $name
      | .omarchy = ((.omarchy // {}) + { clonedFrom: "omarchy.lock" })
    ' "$LOCK_SRC/manifest.json" >"$stage/manifest.json"

  # What this was built from, so a later Omarchy upgrade is detectable:
  #   (cd /usr/share/omarchy/shell/plugins/lock && sha256sum -c ~/.config/omarchy/plugins/sheikah.lock/UPSTREAM)
  (cd "$LOCK_SRC" && sha256sum manifest.json Service.qml LockView.qml) >"$stage/UPSTREAM"

  rm -rf "$LOCK_DEST"
  mv "$stage" "$LOCK_DEST"
  chmod 755 "$LOCK_DEST"; chmod 644 "$LOCK_DEST"/*

  omarchy plugin validate "$LOCK_DEST" >/dev/null \
    || { rm -rf "$LOCK_DEST"; fail "the lock frame clone failed omarchy plugin validate"; }
  say "Installed lock  → $LOCK_DEST"

  omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
  local i
  for i in 1 2 3 4 5 6 7 8 9 10; do
    omarchy plugin list 2>/dev/null | grep -q "$LOCK_ID" && break
    sleep 0.2
  done
  if ! omarchy plugin list 2>/dev/null | grep -q "$LOCK_ID"; then
    say "Shell has not picked the lock up; run 'omarchy restart shell'."
    return 0
  fi

  if omarchy plugin list 2>/dev/null | grep -qE "^[^ ]*$LOCK_ID.*enabled"; then
    say "Lock frame already on → $LOCK_ID"
  else
    # Takes omarchy.lock's place: Omarchy adds the source to disabledPlugins
    # for a non-widget clone, because two live WlSessionLock clients would
    # fight over the session.
    omarchy plugin enable "$LOCK_ID" >/dev/null 2>&1 || true
    say "Enabled lock    → $LOCK_ID (replaced omarchy.lock)"
  fi

  say ""
  say "The lock screen needs a shell restart to take effect:"
  say "    omarchy restart shell"
  say "Then preview it WITHOUT locking yourself out:"
  say "    omarchy-shell lock preview      (click anywhere to dismiss)"
}

if (( WITH_LOCK )); then
  install_lock_frame
else
  say "Lock screen frame not installed (opt in with --with-lock)."
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
