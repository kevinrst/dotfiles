-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Custom bindings ported from config/hypr/hyprland.lua (old Arch setup).
-- Old config used: terminal=kitty, browser=zen-browser, fileManager=nautilus.
-- SUPER+R/O use Omarchy's built-in menus instead of the old rofi scripts.
-- SUPER+M removed: power menu lives on SUPER+ESC (Omarchy default).

-- App launches (no conflicts, no unbind needed)
o.bind("SUPER + B", "Browser (zen)", { launch = "zen-browser" })
o.bind("SUPER + Q", "Terminal (kitty)", { launch = "kitty" })
o.bind("SUPER + E", "File manager", { launch = "strata" })
o.bind("SUPER + R", "Apps menu", "omarchy-menu toggle apps")

-- Unbind existing SUPER+C (was: Universal copy)
hl.unbind("SUPER + C")
o.bind("SUPER + C", "Close window", hl.dsp.window.close())

-- Unbind existing SUPER+V (was: Universal paste)
hl.unbind("SUPER + V")
o.bind("SUPER + V", "Toggle floating", hl.dsp.window.float({ action = "toggle" }))

-- Unbind existing SUPER+O (was: Pop window out (float & pin))
hl.unbind("SUPER + O")
o.bind("SUPER + O", "Setup menu (settings)", "omarchy-menu toggle setup")

-- Unbind existing SUPER+ALT+S (was: Move window to scratchpad)
hl.unbind("SUPER + ALT + S")
o.bind("SUPER + ALT + S", "Screenshot region (grim+swappy)", 'grim -g "$(slurp)" - | swappy -f -')

-- Unbind existing SUPER+ALT+F (was: Full width / maximized)
hl.unbind("SUPER + ALT + F")
o.bind("SUPER + ALT + F", "Screenshot monitor (grim+swappy)", 'grim -o "$(hyprctl activeworkspace -j | jq -r \'.monitor\')" - | swappy -f -')

-- Move windows with SUPER+SHIFT+arrows (overrides Omarchy Swap window in those keys)
hl.unbind("SUPER + SHIFT + LEFT")
hl.unbind("SUPER + SHIFT + RIGHT")
hl.unbind("SUPER + SHIFT + UP")
hl.unbind("SUPER + SHIFT + DOWN")
o.bind("SUPER + SHIFT + LEFT", "Move window left", hl.dsp.window.move({ direction = "left" }))
o.bind("SUPER + SHIFT + RIGHT", "Move window right", hl.dsp.window.move({ direction = "right" }))
o.bind("SUPER + SHIFT + UP", "Move window up", hl.dsp.window.move({ direction = "up" }))
o.bind("SUPER + SHIFT + DOWN", "Move window down", hl.dsp.window.move({ direction = "down" }))

-- Special workspace "magic" (overrides scratchpad on SUPER+S, Google Maps on SUPER+SHIFT+S)
hl.unbind("SUPER + S")
hl.unbind("SUPER + SHIFT + S")
o.bind("SUPER + S", "Toggle special workspace (magic)", hl.dsp.workspace.toggle_special("magic"))
o.bind("SUPER + SHIFT + S", "Move window to special workspace (magic)", hl.dsp.window.move({ workspace = "special:magic" }))

-- NOTE: intentionally NOT ported from old config (already covered by Omarchy defaults):
-- SUPER+P/J/F, SUPER+arrows focus, SUPER+numbers workspaces, SUPER+mouse scroll/drag/resize,
-- XF86 volume/brightness/media keys, playerctl binds -> kept Omarchy versions (OSD-integrated).
-- SUPER+w waybar toggle skipped: Omarchy uses its own shell bar (toggle: SUPER+SHIFT+SPACE).

-- strata-installer: file-manager start
-- Strata file manager (default folder handler, see apply-omarchy.sh).
-- SUPER+E above is the main binding; SUPER+SHIFT+F and the cwd variant are
-- intentionally disabled (unbound below). Markers kept so a manual installer
-- run detects this and does not re-add binds.
hl.unbind("SUPER + SHIFT + F")
hl.unbind("SUPER + ALT + SHIFT + F")
-- strata-installer: file-manager end

-- Disabled unwanted default bindings (no replacement).
hl.unbind("SUPER + RETURN") -- was: Terminal (using SUPER+Q instead)
hl.unbind("SUPER + W") -- was: Close window (using SUPER+C instead)
hl.unbind("SUPER + CTRL + ALT + W") -- was: Toggle weather
hl.unbind("SUPER + CTRL + L") -- was: Lock system
hl.unbind("SUPER + T") -- was: Toggle floating (using SUPER+V instead)
hl.unbind("SUPER + X") -- was: Universal cut
hl.unbind("SUPER + PRINT") -- was: Color picker
hl.unbind("PRINT") -- was: Screenshot (no PRINT key on this keyboard)
hl.unbind("SUPER + ALT + RETURN") -- was: Tmux
hl.unbind("SUPER + CTRL + RETURN") -- was: Herdr
hl.unbind("SUPER + SHIFT + ALT + B") -- was: Browser (private)
hl.unbind("SUPER + CTRL + TAB") -- was: Former workspace
hl.unbind("SUPER + SHIFT + TAB") -- was: Previous workspace (keeping SUPER+TAB = next)

-- Screenrecording moved off ALT+PRINT (no PRINT key): now SUPER+ALT+R.
hl.unbind("ALT + PRINT")
o.bind("SUPER + ALT + R", "Screenrecording",
  "omarchy-capture-screenrecording --stop-recording || omarchy-menu toggle trigger.capture.screenrecord")

-- Bulk cleanup: disable unwanted default bindings.

-- Core app launches (using SUPER+Q terminal, SUPER+E strata, SUPER+B zen instead)
hl.unbind("SUPER + SHIFT + RETURN") -- was: Browser
hl.unbind("SUPER + SHIFT + B") -- was: Browser
hl.unbind("SUPER + SHIFT + N") -- was: Editor

-- Preinstalled web apps / services
hl.unbind("SUPER + SHIFT + A") -- was: ChatGPT
hl.unbind("SUPER + SHIFT + ALT + A") -- was: Grok
hl.unbind("SUPER + SHIFT + C") -- was: Calendar (web)
hl.unbind("SUPER + SHIFT + E") -- was: Email
hl.unbind("SUPER + SHIFT + ALT + E") -- was: New email
hl.unbind("SUPER + SHIFT + Y") -- was: YouTube
hl.unbind("SUPER + SHIFT + ALT + G") -- was: WhatsApp
hl.unbind("SUPER + SHIFT + CTRL + G") -- was: Google Messages
hl.unbind("SUPER + SHIFT + P") -- was: Google Photos
hl.unbind("SUPER + SHIFT + X") -- was: X
hl.unbind("SUPER + SHIFT + ALT + X") -- was: X Post
hl.unbind("SUPER + SHIFT + M") -- was: Music (Spotify)
hl.unbind("SUPER + SHIFT + ALT + M") -- was: Music TUI
hl.unbind("SUPER + SHIFT + D") -- was: Docker
hl.unbind("SUPER + SHIFT + G") -- was: Signal
hl.unbind("SUPER + SHIFT + O") -- was: Obsidian

-- Bar panels / widgets
hl.unbind("SUPER + CTRL + code:10") -- was: Bar panel 1
hl.unbind("SUPER + CTRL + code:11") -- was: Bar panel 2
hl.unbind("SUPER + CTRL + code:12") -- was: Bar panel 3
hl.unbind("SUPER + CTRL + code:13") -- was: Bar panel 4
hl.unbind("SUPER + CTRL + code:14") -- was: Bar panel 5
hl.unbind("SUPER + CTRL + code:15") -- was: Bar panel 6
hl.unbind("SUPER + CTRL + code:16") -- was: Bar panel 7
hl.unbind("SUPER + CTRL + code:17") -- was: Bar panel 8
hl.unbind("SUPER + CTRL + code:18") -- was: Bar panel 9
hl.unbind("SUPER + CTRL + A") -- was: Audio panel
hl.unbind("SUPER + CTRL + B") -- was: Bluetooth panel
hl.unbind("SUPER + CTRL + P") -- was: Power panel
hl.unbind("SUPER + CTRL + O") -- was: Toggle menu
hl.unbind("SUPER + CTRL + ALT + D") -- was: Calendar panel
hl.unbind("SUPER + CTRL + ALT + B") -- was: Battery
hl.unbind("SUPER + CTRL + ALT + T") -- was: Time
hl.unbind("SUPER + CTRL + ALT + R") -- was: Show reminders

-- Toggles / utilities
hl.unbind("SUPER + CTRL + F") -- was: Tiled full screen
hl.unbind("SUPER + CTRL + BACKSPACE") -- was: Single-window square aspect
hl.unbind("SUPER + CTRL + ALT + Z") -- was: Reset zoom
hl.unbind("SUPER + CTRL + ALT + Delete") -- was: Display mirroring
hl.unbind("SUPER + Home") -- was: Restore window width

-- Window grouping (all of it: group windows are tiled windows tabbed together)
hl.unbind("SUPER + G") -- was: Toggle window grouping
hl.unbind("SUPER + ALT + G") -- was: Move window out of group
hl.unbind("SUPER + ALT + LEFT") -- was: Move window into group (left)
hl.unbind("SUPER + ALT + RIGHT") -- was: Move window into group (right)
hl.unbind("SUPER + ALT + UP") -- was: Move window into group (top)
hl.unbind("SUPER + ALT + DOWN") -- was: Move window into group (bottom)
hl.unbind("SUPER + ALT + TAB") -- was: Next window in group
hl.unbind("SUPER + ALT + SHIFT + TAB") -- was: Previous window in group
hl.unbind("SUPER + CTRL + LEFT") -- was: Grouped window focus left
hl.unbind("SUPER + CTRL + RIGHT") -- was: Grouped window focus right
hl.unbind("SUPER + ALT + mouse_down") -- was: Next window in group (mouse)
hl.unbind("SUPER + ALT + mouse_up") -- was: Previous window in group (mouse)
hl.unbind("SUPER + ALT + code:10") -- was: Group window 1
hl.unbind("SUPER + ALT + code:11") -- was: Group window 2
hl.unbind("SUPER + ALT + code:12") -- was: Group window 3
hl.unbind("SUPER + ALT + code:13") -- was: Group window 4
hl.unbind("SUPER + ALT + code:14") -- was: Group window 5

-- Toggle top bar moved from SUPER+SHIFT+SPACE to SUPER+W.
hl.unbind("SUPER + SHIFT + SPACE")
hl.unbind("SUPER + W") -- already unbound above (was: Close window); ensure free
o.bind_toggle("SUPER + W", "Toggle top bar", "bar")
