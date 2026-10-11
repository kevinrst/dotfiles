#!/usr/bin/env bash
#
# apply-omarchy.sh -- apply this repo's Omarchy customizations.
#
# Ports from the old Arch setup live in omarchy/ and are copied over
# ~/.config/. Safe to re-run: existing files are backed up with a timestamp
# before being replaced, then Hyprland is reloaded and the config is validated.
#
# Usage:
#   ./apply-omarchy.sh

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_BASE="$DOTFILES_DIR/omarchy"

# Source:destination pairs, destination relative to $HOME.
MAP="
hypr/bindings.lua:.config/hypr/bindings.lua
hypr/looknfeel.lua:.config/hypr/looknfeel.lua
kitty/kitty.conf:.config/kitty/kitty.conf
ohmyposh/zen.toml:.config/ohmyposh/zen.toml
ohmyposh/base.json:.config/ohmyposh/base.json
zsh/.zshrc:.zshrc
tmux/tmux.conf:.config/tmux/tmux.conf
"

timestamp=$(date +%s)

for pair in $MAP; do
  src="$SRC_BASE/${pair%%:*}"
  dst="$HOME/${pair##*:}"
  if [[ ! -f "$src" ]]; then
    echo "missing source: $src" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$dst")"
  if [[ -f "$dst" ]]; then
    cp "$dst" "$dst.bak.$timestamp"
    echo "backup: $dst.bak.$timestamp"
  fi
  cp "$src" "$dst"
  echo "applied: $dst"
done

# TPM (tmux plugin manager) required by tmux.conf.
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  echo "installed: $HOME/.tmux/plugins/tpm"
fi

# Install tmux plugins (best-effort: needs network; otherwise press prefix+I inside tmux).
"$HOME/.tmux/plugins/tpm/bin/install_plugins" || echo "tmux plugin install had issues; press prefix+I inside tmux to retry"

# Strata file manager: install if missing, ensure default folder handler.
# Keybindings (SUPER+E / SHIFT+F) come from omarchy/hypr/bindings.lua (copied above).
if ! command -v strata >/dev/null 2>&1; then
  echo "installing strata file manager..."
  curl -fsSL https://raw.githubusercontent.com/lgse/strata/main/install.sh | bash -s -- --with-desktop-entry --with-folder-association
fi
if [[ -f "$HOME/.local/share/applications/io.github.lgse.Strata.desktop" ]]; then
  xdg-mime default io.github.lgse.Strata.desktop inode/directory
  echo "default file manager: $(xdg-mime query default inode/directory)"
fi

hyprctl reload
sleep 1

errors="$(hyprctl configerrors || true)"
if [[ -n "$errors" ]]; then
  echo "hyprctl configerrors reported errors:" >&2
  echo "$errors" >&2
  exit 1
fi
echo "hyprctl configerrors: clean"

omarchy restart terminal

echo "done. verify with: omarchy menu keybindings --print"
