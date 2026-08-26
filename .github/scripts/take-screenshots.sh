#!/usr/bin/env bash
#
# Drives the screenshot test in blocks of languages, a whole run's screenshots
# do not survive the hand-over to the driver. See integration_test/README.md.

set -euo pipefail

blocks=5
attempts=3
block_timeout=10m

# Homebrew installs coreutils under the g-prefixed names only
timeout=$(command -v timeout || command -v gtimeout) || {
  echo "Found neither timeout nor gtimeout, install coreutils"
  exit 1
}

device_type=${1:?Usage: take-screenshots.sh <device type> [flutter drive args]}
shift

# flutter drive gives up within seconds on an offline device, so wait for it
# to come back instead of burning the next attempt on it
wait_for_device() {
  adb devices | tail -n +2 | grep -q . || return 0
  adb reconnect offline || true
  "$timeout" 120s adb wait-for-device shell \
    'while [ "$(getprop sys.boot_completed)" != 1 ]; do sleep 2; done' || true
}

for block in $(seq "$blocks"); do
  for attempt in $(seq "$attempts"); do
    status=0
    # Both the Xcode build and the driver's connect retry forever on their own.
    # timeout signals the whole process group, so no dart child survives.
    "$timeout" --kill-after=30s "$block_timeout" flutter drive \
      --driver=test_driver/screenshot_driver.dart \
      --target=integration_test/make_screenshots_test.dart \
      --dart-define=DEVICE_TYPE="$device_type" \
      --dart-define=LANGUAGES="$block/$blocks" \
      "$@" || status=$?

    if [ "$status" -eq 0 ]; then
      break
    fi

    if [ "$attempt" -eq "$attempts" ]; then
      echo "Block $block still fails after $attempts attempts, giving up"
      exit 1
    fi

    # Usually the device went offline while handing the images over
    echo "Block $block failed with $status, attempt $((attempt + 1)) of $attempts"
    wait_for_device
  done
done
