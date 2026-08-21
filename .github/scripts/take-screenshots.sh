#!/usr/bin/env bash
#
# Drives the screenshot test in blocks of languages, a whole run's screenshots
# do not survive the hand-over to the driver. See integration_test/README.md.

set -euo pipefail

device_type=${1:?Usage: take-screenshots.sh <device type> [flutter drive args]}
shift

for block in 1 2 3 4 5; do
  flutter drive \
    --driver=test_driver/screenshot_driver.dart \
    --target=integration_test/make_screenshots_test.dart \
    --dart-define=DEVICE_TYPE="$device_type" \
    --dart-define=LANGUAGES="$block/5" \
    "$@"
done
