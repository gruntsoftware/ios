#!/bin/bash
# ci_scripts/ci_post_xcodebuild.sh
# Requirement per the Xcode Cloud path
# Apple Xcode Cloud Documentation
# https://developer.apple.com/documentation/xcode/writing-custom-build-scripts#Create-a-custom-build-script
# ci_post_xcodebuild: Actions post building

set -e

# --- TestFlight "What to Test" -----------------------------------------------------------
# Xcode Cloud uses TestFlight/WhatToTest.<locale>.txt (next to ci_scripts) as the build's
# "What to Test" when the TestFlight post-actions run. Each PR to develop updates the file
# with QA steps for its change. If the commit being built didn't touch it, the notes are
# from an older build, so replace them with this commit's message. Then add the build
# number and commit so QA can tell builds apart.
write_what_to_test() {
  local notes_dir="$CI_PRIMARY_REPOSITORY_PATH/TestFlight"
  local notes="$notes_dir/WhatToTest.en-US.txt"
  local repo="$CI_PRIMARY_REPOSITORY_PATH"
  mkdir -p "$notes_dir"

  # Xcode Cloud clones shallowly; we need the parent commit to see what changed.
  git -C "$repo" rev-parse -q --verify HEAD^ >/dev/null 2>&1 \
    || git -C "$repo" fetch -q --deepen 1 origin 2>/dev/null || true

  if ! git -C "$repo" diff --name-only HEAD^ HEAD 2>/dev/null | grep -qx "TestFlight/WhatToTest.en-US.txt"; then
    echo "ℹ️ WhatToTest.en-US.txt not updated in this commit -- using the commit message"
    {
      echo "No QA notes were added for this build. Changes:"
      echo
      # Drop co-author trailers and the blank lines they leave at the end.
      git -C "$repo" log -1 --pretty=format:"%B" HEAD \
        | sed '/^Co-[Aa]uthored-[Bb]y:/d' \
        | awk '{ lines[NR] = $0 } NF { last = NR } END { for (i = 1; i <= last; i++) print lines[i] }'
    } > "$notes"
  fi

  {
    echo
    echo
    echo "Build ${CI_BUILD_NUMBER:-?} · ${CI_BRANCH:-?} @ $(echo "${CI_COMMIT:-$(git -C "$repo" rev-parse HEAD)}" | cut -c1-7)"
  } >> "$notes"

  # TestFlight allows up to 4,000 characters.
  local trimmed
  trimmed="$(head -c 3990 "$notes")"
  printf '%s\n' "$trimmed" > "$notes"

  echo "--- TestFlight What to Test ---"
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