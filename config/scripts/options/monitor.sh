CONF="$HOME/.config/hypr/hyprland.lua"

options="Screen Only\nDuplicate\nSecond Monitor Left\nSecond Monitor Right"

choice=$(printf "%b" "$options" | rofi -dmenu -config ~/.config/rofi/options/monitor.rasi)

# First: comment lines 6–8 (ensure they start with --)
sed -i '6,9 s|^[[:space:]]*\(--[[:space:]]*\)\?|-- |' "$CONF"

case "$choice" in
    *Screen*)
        # uncomment line 5 & 6
        sed -i '5 s|^-- ||' "$CONF"
        sed -i '6 s|^-- ||' "$CONF"
        ;;
    *Duplicate*)
        # uncomment line 7
        sed -i '7 s|^-- ||' "$CONF"
        ;;
    *Left*)
        # uncomment line 8
        sed -i '8 s|^-- ||' "$CONF"
        ;;
    *Right*)
        # uncomment line 9
        sed -i '9 s|^-- ||' "$CONF"
        ;;
esac

hyprctl reload
