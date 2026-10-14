#!/usr/bin/env bash
#
# install-profile-theme.sh -- install the omarchy-profile SDDM theme.
#
# Copies omarchy/sddm/omarchy-profile/ to /usr/share/sddm/themes/omarchy-profile and
# points SDDM at it via /etc/sddm.conf.d/zz-omarchy-profile.conf (sorts after
# stock 10-theme.conf and 99-omarchy-login.conf, so ours wins; those stock
# files are left untouched, so `omarchy refresh sddm` / package updates won't
# wipe the avatar).
#
# Source of truth for the avatar: pictures/profile.png (synced to
# sddm/omarchy-profile/avatar.png on every run).
#
# Usage:
#   ./install-profile-theme.sh

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SRC="$DOTFILES_DIR/omarchy/sddm/omarchy-profile"
THEME_NAME="omarchy-profile"
DEST="/usr/share/sddm/themes/$THEME_NAME"
THEME_CONF="/etc/sddm.conf.d/zz-omarchy-profile.conf"

run_privileged() {
  if sudo -n true 2>/dev/null; then
    sudo "$@"
  elif command -v pkexec >/dev/null 2>&1; then
    pkexec "$@"
  else
    sudo "$@"
  fi
}

if [[ ! -d "$SRC" ]]; then
  echo "missing theme source: $SRC" >&2
  exit 1
fi

# Keep avatar in sync with pictures/profile.png (source of truth).
if [[ -f "$DOTFILES_DIR/pictures/profile.png" ]]; then
  cp "$DOTFILES_DIR/pictures/profile.png" "$SRC/avatar.png"
  echo "synced: pictures/profile.png -> omarchy/sddm/omarchy-profile/avatar.png"
fi

for f in Main.qml metadata.desktop theme.conf avatar.png bullet.png entry.png entry-failed.png lock.png lock-failed.png; do
  if [[ ! -f "$SRC/$f" ]]; then
    echo "missing theme file: $SRC/$f" >&2
    exit 1
  fi
done

run_privileged mkdir -p "$DEST"
for f in Main.qml metadata.desktop theme.conf avatar.png bullet.png entry.png entry-failed.png lock.png lock-failed.png; do
  # install(1) via privileged shell so mode/ownership are deterministic.
  run_privileged install -o 0 -g 0 -m 0644 -- "$SRC/$f" "$DEST/$f"
  echo "installed: $DEST/$f"
done

# Point SDDM at the custom theme. Only the Current= line is touched.
if [[ -f "$THEME_CONF" ]]; then
  if grep -qE "^Current=" "$THEME_CONF"; then
    run_privileged sed -i -E "s/^Current=.*/Current=$THEME_NAME/" "$THEME_CONF"
  else
    run_privileged bash -c "printf '\nCurrent=$THEME_NAME\n' >> '$THEME_CONF'"
  fi
else
  run_privileged bash -c "printf '[Theme]\nCurrent=$THEME_NAME\n' > '$THEME_CONF'"
fi
echo "sddm theme -> $THEME_NAME ($THEME_CONF)"

echo "done. Takes effect at the next login screen (no reboot needed to verify config)."
