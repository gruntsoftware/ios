#!/bin/bash
# ci_scripts/ci_post_xcodebuild.sh
# Requirement per the Xcode Cloud path
# Apple Xcode Cloud Documentation
# https://developer.apple.com/documentation/xcode/writing-custom-build-scripts#Create-a-custom-build-script
# ci_post_xcodebuild: Actions post building

set -e

# --- TestFlight "What to Test" -----------------------------------------------------------
# Xcode Cloud uses TestFlight/WhatToTest.<locale>.txt (next to ci_scripts) as the build's
# "What to Test" when the TestFlight post-actions run. TestFlight Build runs once a day, so a
# build can hold several merged PRs: what_to_test.py lists each PR merged since the previous
# scheduled build (title plus a one- or two-sentence summary from its merge commit), capped
# at 3,000 characters, and adds the build number and commit so QA can tell builds apart.
write_what_to_test() {
  local repo="$CI_PRIMARY_REPOSITORY_PATH"
  local notes="$repo/TestFlight/WhatToTest.en-US.txt"
  local branch="${CI_BRANCH:-develop}"

  if python3 -I "$repo/ci_scripts/what_to_test.py" \
      --repo "$repo" --out "$notes" --ref HEAD \
      --build "${CI_BUILD_NUMBER:-?}" --branch "$branch"; then
    return 0
  fi

  # The script failed: fall back to this commit's subject so the notes aren't stale.
  echo "⚠️ what_to_test.py failed -- using the latest commit's subject"
  mkdir -p "$(dirname "$notes")"
  {
    git -C "$repo" log -1 --pretty=format:"%s" HEAD
    echo
    echo
    echo "Build ${CI_BUILD_NUMBER:-?} · $branch @ $(git -C "$repo" rev-parse --short=7 HEAD)"
  } > "$notes"
  cat "$notes"
}

if [ "${CI_XCODEBUILD_ACTION:-}" = "archive" ]; then
  write_what_to_test || echo "⚠️ Could not write What to Test notes"
fi

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