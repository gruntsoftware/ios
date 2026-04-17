#!/bin/bash
# ci_scripts/ci_post_xcodebuild.sh
# Requirement per the Xcode Cloud path
# Apple Xcode Cloud Documentation
# https://developer.apple.com/documentation/xcode/writing-custom-build-scripts#Create-a-custom-build-script
# ci_post_xcodebuild: Actions post building

set -e

echo "--- Collecting test diagnostics for download ---"

# Xcode Cloud exposes this automatically — it's the resultbundle.xcresult path
RESULT_BUNDLE="${CI_RESULT_BUNDLE_PATH}"

if [ -z "$RESULT_BUNDLE" ]; then
  echo "CI_RESULT_BUNDLE_PATH not set, skipping"
  exit 0
fi

if [ ! -d "$RESULT_BUNDLE" ]; then
  echo "Result bundle not found at: $RESULT_BUNDLE"
  exit 0
fi

echo "Result bundle: $RESULT_BUNDLE"

# Collect all Session logs from the Diagnostics folder
DIAGNOSTICS_DIR="${RESULT_BUNDLE}/Staging"
ARTIFACTS_OUT="${CI_DERIVED_DATA_PATH}/test_diagnostics"
mkdir -p "$ARTIFACTS_OUT"

# Copy all .log files out (Session logs, crash logs, etc.)
find "$DIAGNOSTICS_DIR" -name "*.log" -exec cp {} "$ARTIFACTS_OUT/" \; 2>/dev/null || true
find "$DIAGNOSTICS_DIR" -name "*.ips" -exec cp {} "$ARTIFACTS_OUT/" \; 2>/dev/null || true
find "$DIAGNOSTICS_DIR" -name "*.crash" -exec cp {} "$ARTIFACTS_OUT/" \; 2>/dev/null || true

# Also zip the full xcresult so you can open it in Xcode locally
echo "Zipping xcresult bundle..."
zip -r "${CI_DERIVED_DATA_PATH}/resultbundle.zip" "$RESULT_BUNDLE" 2>/dev/null || true

echo "--- Artifacts collected at: $ARTIFACTS_OUT ---"
ls -la "$ARTIFACTS_OUT"