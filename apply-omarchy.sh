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
extensions/omarchy-menu.jsonc:.config/omarchy/extensions/omarchy-menu.jsonc
scripts/monitor-arrange.sh:.local/bin/omarchy-monitor-arrange
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

# Menu helper deployed above must stay executable (cp does not guarantee +x).
chmod +x "$HOME/.local/bin/omarchy-monitor-arrange"

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

# System-level customizations (need privilege; scripts use sudo/pkexec).
# 1. Limine boot menu timeout -> 2s (default template leaves it at 5s).
"$DOTFILES_DIR/omarchy/boot/set-limine-timeout.sh" 2
# 2. SDDM login: profile avatar instead of the Omarchy logo.
"$DOTFILES_DIR/omarchy/sddm/install-profile-theme.sh"
# 3. NvChad follows `omarchy theme set` via a theme-set hook (maps the
# Omarchy theme to the closest base46 theme, persists it in chadrc.lua and
# live-reloads running nvim -- no restart needed).
mkdir -p "$HOME/.config/omarchy/hooks/theme-set.d"
cp "$DOTFILES_DIR/omarchy/hooks/theme-set.d/nvchad-theme" "$HOME/.config/omarchy/hooks/theme-set.d/nvchad-theme"
chmod +x "$HOME/.config/omarchy/hooks/theme-set.d/nvchad-theme"
echo "applied: ~/.config/omarchy/hooks/theme-set.d/nvchad-theme"

# Custom Omarchy themes (colors.toml derived from NvChad base46 palettes via
# omarchy/themes/generate-from-base46.py). Sync whole dirs; custom slugs
# shadow same-named stock themes (catppuccin, everforest).
mkdir -p "$HOME/.config/omarchy/themes"
for theme_dir in "$DOTFILES_DIR"/omarchy/themes/*/; do
  slug="$(basename "$theme_dir")"
  mkdir -p "$HOME/.config/omarchy/themes/$slug"
  cp -r "$theme_dir"* "$HOME/.config/omarchy/themes/$slug/"
  echo "applied: ~/.config/omarchy/themes/$slug/"
done

# One wallpaper per theme (see omarchy/themes/wallpapers.map). Custom themes
# keep it in their own backgrounds/; stock themes use backgrounds/<slug>/.
while IFS=: read -r slug file; do
  case "$slug" in \#*|"") continue ;; esac
  if [[ -d "$DOTFILES_DIR/omarchy/themes/$slug" ]]; then
    dest="$HOME/.config/omarchy/themes/$slug/backgrounds"
  else
    dest="$HOME/.config/omarchy/backgrounds/$slug"
  fi
  mkdir -p "$dest"
  cp "$DOTFILES_DIR/pictures/wallpapers/$file" "$dest/"
done < "$DOTFILES_DIR/omarchy/themes/wallpapers.map"
echo "applied: theme wallpapers (see omarchy/themes/wallpapers.map)"

# Stock nord's preview.png is an apps-mockup; every other theme previews just
# its background. Overlay a copy of our nord wallpaper as the preview so nord
# matches (user theme dirs shadow same-named stock files; the rest of nord
# still comes from stock).
mkdir -p "$HOME/.config/omarchy/themes/nord"
cp "$DOTFILES_DIR/pictures/wallpapers/nord_lake.png" "$HOME/.config/omarchy/themes/nord/preview.png"
echo "applied: nord preview override (background-only)"

# Stock nord ships several backgrounds; keep only ours (nord_lake.png, added
# above via backgrounds/nord/). Needs privilege; re-created by omarchy updates.
if [[ -d /usr/share/omarchy/themes/nord/backgrounds ]]; then
  if sudo -n true 2>/dev/null; then
    sudo rm -f /usr/share/omarchy/themes/nord/backgrounds/*
  elif command -v pkexec >/dev/null 2>&1; then
    pkexec rm -f /usr/share/omarchy/themes/nord/backgrounds/*
  else
    sudo rm -f /usr/share/omarchy/themes/nord/backgrounds/*
  fi
  echo "pruned: stock nord backgrounds (only nord_lake.png remains available)"
fi

echo "done. verify with: omarchy menu keybindings --print"
