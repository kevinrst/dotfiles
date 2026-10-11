-- Personal look'n'feel ported from config/hypr/hyprland.lua (old Arch setup).
-- Overrides Omarchy defaults (loaded earlier via require("default.hypr.omarchy")).

-- Borders / gaps: old setup had no borders and large outer gaps.
-- (Active/inactive border colors already match Omarchy defaults.)
hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 10,

    border_size = 0,

    resize_on_border = false,
    allow_tearing = false,
    layout = "dwindle",
  },
})

hl.config({
  decoration = {
    rounding = 10,
    rounding_power = 2,

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
    enabled = true,
  },
})

-- Bezier curves (overrides Omarchy's easeInOutCubic points with old values)
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

hl.config({
  misc = {
    force_default_wallpaper = -1,
  },
  ecosystem = {
    no_update_news = true,
  },
})
