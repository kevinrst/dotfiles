#!/usr/bin/env python3
"""Generate Omarchy colors.toml files from NvChad base46 theme palettes.

Reads base46 theme tables (base_30 + base_16) from the installed NvChad
config and writes ~/.config-style Omarchy custom themes. Run:

    ./generate-from-base46.py

Output goes to ../<slug>/colors.toml (i.e. dotfiles omarchy/themes/);
apply-omarchy.sh syncs them to ~/.config/omarchy/themes/.

Key mapping (validated against Omarchy's tokyo-night, where several keys
match base46 values exactly: background/black, lighter_background/one_bg,
muted/one_bg2, foreground/base05, dark_foreground/grey_fg,
bright_foreground/white):
"""

import re
import sys
from pathlib import Path

BASE46_DIR = (
    Path.home()
    / ".local/share/nvim/lazy/base46/lua/base46/themes"
)

# omarchy slug -> base46 theme name (identical here, kept explicit so forks
# and renames stay obvious).
THEMES = {
    "catppuccin": "catppuccin",
    "doomchad": "doomchad",
    "embark": "embark",
    "everforest": "everforest",
    "nightlamp": "nightlamp",
    "onedark": "onedark",
    "sweetpastel": "sweetpastel",
    "tokyonight": "tokyonight",
    "vesper": "vesper",
}


def hex_to_rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i : i + 2], 16) for i in (0, 2, 4))


def rgb_to_hex(rgb):
    return "#%02x%02x%02x" % tuple(max(0, min(255, int(round(c)))) for c in rgb)


def mix(a, b, amount):
    """Mix hex color a towards hex color b by amount (0..1)."""
    ra, ga, ba = hex_to_rgb(a)
    rb, gb, bb = hex_to_rgb(b)
    return rgb_to_hex(
        (
            ra + (rb - ra) * amount,
            ga + (gb - ga) * amount,
            ba + (bb - ba) * amount,
        )
    )


def parse_table(text, name):
    """Parse a simple `M.<name> = { key = "#hex", ... }` lua table."""
    m = re.search(r"M\." + name + r"\s*=\s*\{(.*?)\n\}", text, re.S)
    if not m:
        return {}
    return dict(re.findall(r'(\w+)\s*=\s*"(#[0-9a-fA-F]{6})"', m.group(1)))


def build_colors(base30, base16):
    def get(table, *names):
        for n in names:
            if n in table:
                return table[n]
        raise KeyError(names)

    black = get(base30, "black")
    darker_black = get(base30, "darker_black")
    white = get(base30, "white")
    base05 = get(base16, "base05")
    blue = get(base30, "blue")
    red = get(base30, "red")
    orange = get(base30, "orange")
    purple = get(base30, "purple")

    return {
        "mode": "dark",
        "accent": blue,
        "selection": mix(blue, black, 0.8),
        "muted": get(base30, "one_bg2"),
        "background": black,
        "dark_background": darker_black,
        "darker_background": mix(darker_black, "#000000", 0.45),
        "lighter_background": get(base30, "one_bg"),
        "foreground": base05,
        "dark_foreground": get(base30, "grey_fg"),
        "light_foreground": mix(white, base05, 0.5),
        "bright_foreground": white,
        "red": red,
        "yellow": get(base30, "yellow"),
        "orange": orange,
        "green": get(base30, "green"),
        "cyan": get(base30, "cyan"),
        "blue": blue,
        "magenta": mix(purple, get(base30, "dark_purple", purple), 0.5),
        "brown": mix(orange, black, 0.45),
        "bright_red": mix(red, white, 0.25),
        "bright_yellow": mix(get(base30, "yellow"), white, 0.25),
        "bright_green": mix(get(base30, "green"), white, 0.25),
        "bright_cyan": mix(get(base30, "cyan"), white, 0.25),
        "bright_blue": mix(blue, white, 0.25),
        "bright_magenta": mix(purple, white, 0.25),
    }


ORDER = [
    "mode", "accent", "selection", "muted",
    "background", "dark_background", "darker_background", "lighter_background",
    "foreground", "dark_foreground", "light_foreground", "bright_foreground",
    "red", "yellow", "orange", "green", "cyan", "blue", "magenta", "brown",
    "bright_red", "bright_yellow", "bright_green", "bright_cyan",
    "bright_blue", "bright_magenta",
]


def main():
    out_base = Path(__file__).resolve().parent
    for slug, theme in THEMES.items():
        src = BASE46_DIR / f"{theme}.lua"
        if not src.exists():
            print(f"SKIP {slug}: {src} not found", file=sys.stderr)
            continue
        text = src.read_text()
        if 'M.type = "dark"' not in text:
            print(f"SKIP {slug}: not a dark theme", file=sys.stderr)
            continue
        colors = build_colors(parse_table(text, "base_30"),
                              parse_table(text, "base_16"))
        dest = out_base / slug / "colors.toml"
        dest.parent.mkdir(parents=True, exist_ok=True)
        with dest.open("w") as f:
            for key in ORDER:
                f.write(f'{key} = "{colors[key]}"\n')
        print(f"wrote {dest}")


if __name__ == "__main__":
    main()
