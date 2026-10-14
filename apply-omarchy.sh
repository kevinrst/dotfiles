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

# Cache sudo credentials once: several steps below need privilege (package
# installs, limine timeout, stock theme pruning, plymouth). Without this the
# script prompts for the password at each step; with it, once (and the
# timestamp is kept alive while the script runs).
if command -v sudo >/dev/null 2>&1; then
  sudo -v || echo "warning: sudo auth failed; you will be prompted per privileged step" >&2
  ( while true; do sudo -n true 2>/dev/null || exit; sleep 50; done ) &
  _sudo_keepalive=$!
  trap 'kill "$_sudo_keepalive" 2>/dev/null || true' EXIT
fi

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
branding/screensaver.txt:.config/omarchy/branding/screensaver.txt
scripts/monitor-arrange.sh:.local/bin/omarchy-monitor-arrange
"

timestamp=$(date +%s)

# Terminal + shell prerequisites (Omarchy-native installs).
# kitty.conf sets `shell /usr/bin/zsh`, so zsh must exist -- without it kitty
# fails with "Failed to launch child: zsh / No such file or directory".
# `install terminal kitty` installs kitty (if missing) and sets it as the
# default for xdg-terminal-exec / SUPER+RETURN handling.
omarchy pkg add zsh
omarchy install terminal kitty
# Prompt (oh-my-posh) required by omarchy/zsh/.zshrc. AUR-only on Arch;
# best-effort so the script still succeeds when the AUR is unreachable.
if ! command -v oh-my-posh >/dev/null 2>&1; then
  omarchy pkg aur add oh-my-posh || echo "warning: oh-my-posh not installed; zsh prompt will error until it is" >&2
fi

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

# NvChad (replaces any existing config, e.g. the LazyVim starter).
# Source lives in config/nvim, outside omarchy/ so it can't go in MAP above.
# Move (not copy-over) so stale files from the old config can't linger.
if [[ -d "$DOTFILES_DIR/config/nvim" ]]; then
  if [[ -e "$HOME/.config/nvim" ]]; then
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$timestamp"
    echo "backup: ~/.config/nvim -> ~/.config/nvim.bak.$timestamp"
  fi
  cp -r "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
  echo "applied: ~/.config/nvim (NvChad from dotfiles config/nvim)"
  echo "note: NvChad plugins install on first nvim launch via lazy bootstrap"
fi

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
# 2. NvChad follows `omarchy theme set` via a theme-set hook (maps the
# Omarchy theme to the closest base46 theme, persists it in chadrc.lua and
# live-reloads running nvim -- no restart needed).
mkdir -p "$HOME/.config/omarchy/hooks/theme-set.d"
cp "$DOTFILES_DIR/omarchy/hooks/theme-set.d/nvchad-theme" "$HOME/.config/omarchy/hooks/theme-set.d/nvchad-theme"
chmod +x "$HOME/.config/omarchy/hooks/theme-set.d/nvchad-theme"
echo "applied: ~/.config/omarchy/hooks/theme-set.d/nvchad-theme"

# 3. Idle timings: screensaver after 10min, lock 2.5min later (stock gap).
# Patch only the idle keys so bar/layout customizations in shell.json survive
# (shell.json hot-reloads, no restart needed).
python3 - <<'EOF'
import json
from pathlib import Path
p = Path.home() / ".config/omarchy/shell.json"
d = json.loads(p.read_text())
d.setdefault("idle", {})["screensaver"] = 600
d["idle"]["lock"] = 750
p.write_text(json.dumps(d, indent=2) + "\n")
EOF
echo "applied: idle screensaver=600 lock=750 in shell.json"

# 4. Bar: no menu icon on the left; workspaces widget shows only used ones.
# Clone once (registers kevin.workspaces and switches the bar to it), then
# sync our edited QML over it so re-applies keep the customization.
if [[ ! -d "$HOME/.config/omarchy/plugins/kevin.workspaces" ]]; then
  omarchy plugin clone omarchy.workspaces
fi
mkdir -p "$HOME/.config/omarchy/plugins/kevin.workspaces"
cp "$DOTFILES_DIR/omarchy/plugins/kevin.workspaces/Workspaces.qml" "$HOME/.config/omarchy/plugins/kevin.workspaces/Workspaces.qml"
cp "$DOTFILES_DIR/omarchy/plugins/kevin.workspaces/manifest.json" "$HOME/.config/omarchy/plugins/kevin.workspaces/manifest.json"
echo "applied: kevin.workspaces (only-used workspaces)"
# Plugin file saves usually auto-reload, but a copy-over can be missed --
# force a rescan so the running shell picks up the new QML now, not later.
# Best-effort: no-ops when the shell isn't running (-q suppresses the error).
omarchy-shell -q shell rescanPlugins || true
echo "rescanned: shell plugins"
# Drop the menu icon from bar left (plugin stays enabled, Super menu works);
# ensure our workspaces clone is there. Other bar keys are left untouched.
python3 - <<'EOF'
import json
from pathlib import Path
p = Path.home() / ".config/omarchy/shell.json"
d = json.loads(p.read_text())
left = d.get("bar", {}).get("layout", {}).get("left", [])
left = [w for w in left if w.get("id") != "omarchy.menu"]
if not any(w.get("id") == "kevin.workspaces" for w in left):
    left.append({"id": "kevin.workspaces"})
d["bar"]["layout"]["left"] = left
p.write_text(json.dumps(d, indent=2) + "\n")
EOF
echo "applied: bar left without menu icon"

# Custom Omarchy themes (colors.toml derived from NvChad base46 palettes via
# omarchy/themes/generate-from-base46.py). Sync whole dirs; custom slugs
# shadow same-named stock themes (catppuccin, everforest, tokyo-night).
mkdir -p "$HOME/.config/omarchy/themes"
# Declared set = every directory under omarchy/themes/. Anything else in
# ~/.config/omarchy/themes/ is stale (a theme removed from the repo or installed
# via `omarchy theme install`) and is pruned below so only declared ones remain
# in user space.
keep_slugs=()
for theme_dir in "$DOTFILES_DIR"/omarchy/themes/*/; do
  slug="$(basename "$theme_dir")"
  keep_slugs+=("$slug")
  # Fresh sync so files deleted from the repo don't linger in ~/.config.
  rm -rf "$HOME/.config/omarchy/themes/$slug"
  mkdir -p "$HOME/.config/omarchy/themes/$slug"
  cp -r "$theme_dir"* "$HOME/.config/omarchy/themes/$slug/"
  echo "applied: ~/.config/omarchy/themes/$slug/"
done

# One wallpaper per theme (see omarchy/themes/wallpapers.map). Custom themes
# keep it in their own backgrounds/; stock themes use backgrounds/<slug/>.
# Each destination is cleared on first use so wallpapers removed from the map
# don't linger (the map lists every wallpaper a kept theme should have).
declare -A _cleaned_bg_dirs=()
while IFS=: read -r slug file; do
  case "$slug" in \#*|"") continue ;; esac
  if [[ -d "$DOTFILES_DIR/omarchy/themes/$slug" ]]; then
    dest="$HOME/.config/omarchy/themes/$slug/backgrounds"
  else
    dest="$HOME/.config/omarchy/backgrounds/$slug"
  fi
  mkdir -p "$dest"
  if [[ -z "${_cleaned_bg_dirs[$dest]:-}" ]]; then
    rm -f "$dest"/*
    _cleaned_bg_dirs[$dest]=1
  fi
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

# Prune user-space themes/backgrounds not declared above (nord is kept: it has
# the preview override and a wallpapers.map entry). If the active theme is
# about to be pruned, switch to the first declared theme first so the session
# never points at a deleted directory.
is_kept_user_theme() {
  local s="$1"
  [[ "$s" == "nord" ]] && return 0
  local k
  for k in "${keep_slugs[@]}"; do [[ "$k" == "$s" ]] && return 0; done
  return 1
}
current_slug="$(cat "$HOME/.local/state/omarchy/current/theme.name" 2>/dev/null || true)"
if [[ -n "$current_slug" ]] && ! is_kept_user_theme "$current_slug"; then
  if [[ -d "$HOME/.config/omarchy/themes/$current_slug" ]]; then
    echo "current theme '$current_slug' is not declared; switching to '${keep_slugs[0]}' before pruning"
    omarchy theme set "${keep_slugs[0]}"
  fi
fi
for user_theme_dir in "$HOME"/.config/omarchy/themes/*/; do
  [[ -d "$user_theme_dir" ]] || continue
  slug="$(basename "$user_theme_dir")"
  if ! is_kept_user_theme "$slug"; then
    rm -rf "$user_theme_dir"
    echo "pruned: ~/.config/omarchy/themes/$slug/ (not declared)"
  fi
done
# Prune per-theme user background folders for slugs with no wallpapers.map
# entry (kept themes were already synced to exactly the mapped files above).
if [[ -d "$HOME/.config/omarchy/backgrounds" ]]; then
  for bg_dir in "$HOME"/.config/omarchy/backgrounds/*/; do
    [[ -d "$bg_dir" ]] || continue
    slug="$(basename "$bg_dir")"
    if ! grep -qE "^${slug}:" "$DOTFILES_DIR/omarchy/themes/wallpapers.map"; then
      rm -rf "$bg_dir"
      echo "pruned: ~/.config/omarchy/backgrounds/$slug/ (not declared)"
    fi
  done
fi

# Stock themes live in /usr/share/omarchy/themes/ (owned by the omarchy
# package). `omarchy theme list` shows the union of stock + user themes, so
# pruning user space above does NOT hide stock themes -- there is no supported
# hide mechanism, and anything deleted here returns on the next `omarchy
# update`. To also hide them ephemerally, re-run with PRUNE_STOCK_THEMES=1.
if [[ "${PRUNE_STOCK_THEMES:-0}" == "1" ]]; then
  for stock_theme_dir in /usr/share/omarchy/themes/*/; do
    [[ -d "$stock_theme_dir" ]] || continue
    slug="$(basename "$stock_theme_dir")"
    if ! is_kept_user_theme "$slug"; then
      if sudo -n true 2>/dev/null; then
        sudo rm -rf "$stock_theme_dir"
      elif command -v pkexec >/dev/null 2>&1; then
        pkexec rm -rf "$stock_theme_dir"
      else
        sudo rm -rf "$stock_theme_dir"
      fi
      echo "pruned (ephemeral, restored by omarchy update): /usr/share/omarchy/themes/$slug/"
    fi
  done
else
  echo "note: stock themes in /usr/share/omarchy/themes/ are left alone (re-run with PRUNE_STOCK_THEMES=1 to hide them until the next omarchy update)"
fi

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

# Change omarchy title from login screen to an image
omarchy plymouth set '#2e3440' '#d8dee9' "$DOTFILES_DIR/pictures/profile-round.png"

echo "done. verify with: omarchy menu keybindings --print"
