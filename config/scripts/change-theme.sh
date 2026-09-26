THEME="$1"
THEME_DIR="$HOME/.config/themes/$THEME"

WAYBAR=false
if pgrep -x waybar > /dev/null; then
  killall waybar
  WAYBAR=true
fi

# SwayNC
cp -r "$THEME_DIR/swaync" "$HOME/.config"
swaync-client -rs

# Waybar
cp "$THEME_DIR/waybar.css" "$HOME/.config/waybar/style.css"
cp "$THEME_DIR/waybar-config" "$HOME/.config/waybar/config"

# Rofi
cp -r "$THEME_DIR/rofi" "$HOME/.config"

# Kitty
cp "$THEME_DIR/kitty.conf" "$HOME/.config/kitty/kitty-style.conf"

# Nvim
CHADRC="$HOME/.config/nvim/lua/chadrc.lua"
sed -i -E "s/(theme *= *)\"[^\"]+\"/\1\"$THEME\"/" "$CHADRC"
nvim --headless +"lua require('base46').compile()" +q

hyprctl reload
if [ "$WAYBAR" = true ]; then 
  waybar &
fi
killall -SIGUSR1 kitty
