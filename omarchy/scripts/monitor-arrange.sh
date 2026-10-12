#!/usr/bin/env bash
#
# monitor-arrange.sh -- position the external monitor live via hyprctl.
#
# Deployed as ~/.local/bin/omarchy-monitor-arrange (see apply-omarchy.sh).
# Used by the System Options menu (SUPER+O) in
# omarchy/extensions/omarchy-menu.jsonc.
#
# Usage:
#   omarchy-monitor-arrange left|right
#
# Positions the first external monitor to the left or right of the internal
# (laptop) display. Live-only: arrangement resets on reboot/replug. For a
# persistent layout, edit ~/.config/hypr/monitors.lua instead ("Monitors
# config" row in the same menu).

set -euo pipefail

mode="${1:-}"

if [[ "$mode" != "left" && "$mode" != "right" ]]; then
  echo "Usage: $(basename "$0") left|right" >&2
  exit 2
fi

for cmd in hyprctl jq omarchy-hyprland-monitor-laptop; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "error: required command not found: $cmd" >&2
    exit 1
  fi
done

internal="$(omarchy-hyprland-monitor-laptop)"
monitors_json="$(hyprctl monitors -j)"

external="$(printf '%s' "$monitors_json" | jq -r --arg i "$internal" '.[] | select(.name != $i) | .name' | head -n 1)"

if [[ -z "$external" ]]; then
  omarchy-notification-send "Monitor" "No external monitor connected" -t 2500 2>/dev/null || true
  echo "no external monitor connected" >&2
  exit 1
fi

# Leave mirror mode first: a mirrored output ignores positioning.
omarchy-hyprland-monitor-internal-mirror off 2>/dev/null || true

iw="$(printf '%s' "$monitors_json" | jq -r --arg i "$internal" '.[] | select(.name == $i) | .width')"
ew="$(printf '%s' "$monitors_json" | jq -r --arg e "$external" '.[] | select(.name == $e) | .width')"

if [[ "$mode" == "left" ]]; then
  hyprctl keyword monitor "$external,preferred,-${ew}x0,1" >/dev/null
  hyprctl keyword monitor "$internal,preferred,0x0,1" >/dev/null
else
  hyprctl keyword monitor "$internal,preferred,0x0,1" >/dev/null
  hyprctl keyword monitor "$external,preferred,${iw}x0,1" >/dev/null
fi

omarchy-notification-send "Monitor" "External monitor ($external) on the $mode" -t 2500 2>/dev/null || true
echo "external ($external) placed on the $mode of $internal"
