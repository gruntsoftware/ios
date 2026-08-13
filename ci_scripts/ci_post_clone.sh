#!/bin/sh
# Apple Xcode Cloud Documentation
# https://developer.apple.com/documentation/xcode/writing-custom-build-scripts#Create-a-custom-build-script
# ci_post_clone: Adding post clone tools prior to building

# Exit on error
set -e

# Write the files to the correct location.
# These env vars are base64-encoded in Xcode Cloud's environment variable
# settings (App Store Connect), same as their CircleCI counterparts in
# .circleci/config.yml's "Setup environment files" step -- keep both in sync.
echo "$GOOGLE_SERVICES_PLIST" | base64 --decode > "$CI_PRIMARY_REPOSITORY_PATH/brainwallet/PreLaunchResources/GoogleService-Info.plist"
echo "$REMOTE_CONFIG_DEFAULTS" | base64 --decode > "$CI_PRIMARY_REPOSITORY_PATH/brainwallet/PreLaunchResources/remote-config-defaults.plist"
echo "$DEBUG_SERVICE_DATA" | base64 --decode > "$CI_PRIMARY_REPOSITORY_PATH/brainwallet/PreLaunchResources/service-data.plist"
echo "$BRAINWALLET_IOS_STOREKIT_V1_0_FILE" | base64 --decode > "$CI_PRIMARY_REPOSITORY_PATH/brainwallet/PreLaunchResources/Brainwallet-StoreKit-v1.storekit"

# Verify GoogleService-Info.plist decoded to a real plist and isn't empty/garbage
GSI_PATH="$CI_PRIMARY_REPOSITORY_PATH/brainwallet/PreLaunchResources/GoogleService-Info.plist"
if [ ! -s "$GSI_PATH" ] || ! /usr/libexec/PlistBuddy -c "Print" "$GSI_PATH" >/dev/null 2>&1; then
  echo "❌ ERROR: GoogleService-Info.plist is missing, empty, or not a valid plist"
  exit 1
fi

echo "✅ GoogleService-Info.plist written"
echo "🕹️ Remote Config written"
echo "💽 Service Data written"
echo "🛍️ StoreKit config written"

echo "Pre-resolving Swift Package dependencies..."
xcodebuild \
  -resolvePackageDependencies \
  -workspace "$CI_PRIMARY_REPOSITORY_PATH/BrainwalletHybrid.xcworkspace" \
  -scheme brainwalletUITests \
  -derivedDataPath "$CI_DERIVED_DATA_PATH" \
  2>&1 | tail -20

echo "✅ Package resolution complete"