------------------
---- MONITORS ----
------------------

hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1 }) -- Screen Only
hl.monitor({ output = "HDMI-A-1", disabled = true }) -- Screen Only
-- hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "0x0", scale = 1, mirror = "eDP-1" }) -- Duplicate
-- hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "-1920x0", scale = 1 }) -- Second Monitor to the Left
-- hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "1920x0", scale = 1 }) -- Second Monitor to the Right

---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "kitty"
local fileManager = "nautilus"
local menu = "rofi -show drun"
local browser = "zen-browser"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprlock & hyprpaper & hypridle")
    -- hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')
    hl.exec_cmd("systemctl --user start hyprpolkitagent")

    -- Spotify in last workspace
    hl.exec_cmd("kitty --hold --class=cava -e cava")
    hl.exec_cmd("spotify-launcher")

    -- battery notification
    hl.exec_cmd("~/.config/scripts/battery_notification.sh &")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- themes in ~/.local/share/themes/
hl.env("GTK_THEME", "catppuccin-mocha-blue-standard+default")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 30,

        border_size = 0,

        col = {
            active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        -- Set to true enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding = 10,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = false,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },

        blur = {
            enabled = false,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true, -- yes, please :)
    },
})

-- Bezier curves
hl.curve("easeOutBack", { type = "bezier", points = { { 0.34, 1.56 }, { 0.64, 1 } } })
hl.curve("easeInBack", { type = "bezier", points = { { 0.36, 0 }, { 0.66, -0.56 } } })
hl.curve("easeInCubic", { type = "bezier", points = { { 0.32, 0 }, { 0.67, 0 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0 }, { 0.35, 1 } } })

-- Animations
hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "easeOutBack", style = "popin" })
hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "easeInCubic" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "easeInOutCubic", style = "slide" })
hl.animation({ leaf = "layers", enabled = true, speed = 3, bezier = "easeOutBack", style = "fade" })

hl.animation({ leaf = "windowsIn", enabled = true, speed = 4, bezier = "easeOutBack", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "easeInBack", style = "popin 80%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 4, bezier = "easeInCubic" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 4, bezier = "easeInCubic" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 3, bezier = "easeInOutCubic", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 3, bezier = "easeInOutCubic", style = "slide" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 3, bezier = "easeInOutCubic", style = "popin" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 3, bezier = "easeInBack", style = "fade" })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
hl.config({
    master = {
        new_status = "master",
    },
})

hl.config({
    misc = {
        force_default_wallpaper = -1, -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo = true, -- If true disables the random hyprland logo / anime girl background. :(
        disable_splash_rendering = true,
    },
    ecosystem = {
        no_update_news = true,
    },
})

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("pgrep -x rofi && pkill -x rofi || ~/.config/scripts/powermenu.sh"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo()) -- dwindle
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("pgrep -x rofi && pkill -x rofi || ~/.config/scripts/options.sh"))

-- Screenshot
hl.bind(mainMod .. " + ALT + S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -'))
hl.bind(mainMod .. " + ALT + F", hl.dsp.exec_cmd("grim -o \"$(hyprctl activeworkspace -j | jq -r '.monitor')\" - | swappy -f -"))

-- Waybar
hl.bind(mainMod .. " + w", hl.dsp.exec_cmd("pgrep -x waybar && pkill waybar || waybar &"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Move windows
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({
    name = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name = "fix-xwayland-drags",
    match = { xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- Calendar
hl.window_rule({
    name = "calendar",
    match = { class = "calendar" },
    float = true,
    size = "600 400",
    move = "40 60",
})

-- Bluetooth
hl.window_rule({
    name = "bluetooth",
    match = { class = "blueman-manager" },
    float = true,
    size = "600 400",
    move = "(monitor_w-window_w-80) 60",
})

-- Wifi
hl.window_rule({
    name = "wifi",
    match = { class = "networkui" },
    float = true,
    size = "500 400",
    move = "(monitor_w-window_w-20) 60",
})

-- Audio
hl.window_rule({
    name = "pavucontrol",
    match = { class = "org.pulseaudio.pavucontrol" },
    float = true,
    size = "500 400",
    move = "(monitor_w-window_w-100) 60",
})

-- Spotify
hl.window_rule({
    name = "spotify",
    match = { class = "^(Spotify)$" },
    workspace = "10 silent",
    float = true,
    size = "(monitor_w*0.68) (monitor_h*0.9)",
    move = "(monitor_w*0.01) (monitor_h*0.07)",
})

-- Cava
hl.window_rule({
    name = "cava",
    match = { class = "^(cava)$" },
    workspace = "10 silent",
    float = true,
    size = "(monitor_w*0.28) (monitor_h*0.5)",
    move = "(monitor_w*0.7) (monitor_h*0.47)",
})
