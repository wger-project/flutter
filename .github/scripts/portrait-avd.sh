#!/usr/bin/env bash
#
# Turns the AVD panel portrait.
#
# The tablet profiles define a landscape panel and rely on
# hw.initialOrientation to turn it, which the emulator does not do when it runs
# with -no-window: the same profile that gives 1600x2560 on a desktop produced
# 2560x1600 in CI. Swapping the panel itself takes the rotation out of it.
#
# Runs as the pre-emulator-launch-script of android-emulator-runner, after the
# AVD is created and before the emulator starts.

set -euo pipefail

CONFIG="$HOME/.android/avd/${AVD_NAME:-test}.avd/config.ini"

width=$(grep '^hw.lcd.width=' "$CONFIG" | cut -d= -f2)
height=$(grep '^hw.lcd.height=' "$CONFIG" | cut -d= -f2)

# config.ini is an unordered list of key=value, so dropping the old line and
# appending the new one is enough, and unlike sed -i that behaves the same
# on a runner and on a Mac
set_property() {
  grep -v "^$1=" "$CONFIG" > "$CONFIG.tmp" || true
  echo "$1=$2" >> "$CONFIG.tmp"
  mv "$CONFIG.tmp" "$CONFIG"
}

# Short edge first, which leaves an already portrait panel as it is
set_property hw.lcd.width "$((width < height ? width : height))"
set_property hw.lcd.height "$((width < height ? height : width))"

grep -E '^hw\.lcd\.(width|height)' "$CONFIG"
