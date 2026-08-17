#!/bin/sh
# Apple Xcode Cloud Documentation
# https://developer.apple.com/documentation/xcode/writing-custom-build-scripts#Create-a-custom-build-script
# ci_post_clone: Adding post clone tools prior to building

# Exit on error
set -e

RESOURCES_DIR="$CI_PRIMARY_REPOSITORY_PATH/brainwallet/PreLaunchResources"

# Write the files to the correct location.
# These env vars are base64-encoded in Xcode Cloud's environment variable
# settings (App Store Connect).
echo "$GOOGLE_SERVICES_PLIST" | base64 --decode > "$RESOURCES_DIR/GoogleService-Info.plist"
echo "$REMOTE_CONFIG_DEFAULTS" | base64 --decode > "$RESOURCES_DIR/remote-config-defaults.plist"
echo "$DEBUG_SERVICE_DATA" | base64 --decode > "$RESOURCES_DIR/service-data.plist"
echo "$BRAINWALLET_IOS_STOREKIT_V1_0_FILE" | base64 --decode > "$RESOURCES_DIR/Brainwallet-StoreKit-v1.storekit"

# Fail fast here instead of ~90s into xcodebuild with a cryptic
#   error: unable to read input file as a property list: ... (SWBUtil.PropertyListConversionError error 2.)
# from the CopyPlistFile resource-processing step -- that's exactly what
# happened on Build 431: DEBUG_SERVICE_DATA's value in Xcode Cloud's
# environment variable settings didn't decode to a valid plist. Naming the
# broken var/file here points straight at what to fix in App Store Connect.
check_plist() {
  name="$1"; path="$2"
  if [ ! -s "$path" ] || ! /usr/libexec/PlistBuddy -c "Print" "$path" >/dev/null 2>&1; then
    echo "❌ ERROR: $name did not decode to a valid plist -- check its value in Xcode Cloud's environment variables (App Store Connect)"
    exit 1
  fi
}
check_plist "GOOGLE_SERVICES_PLIST -> GoogleService-Info.plist" "$RESOURCES_DIR/GoogleService-Info.plist"
check_plist "REMOTE_CONFIG_DEFAULTS -> remote-config-defaults.plist" "$RESOURCES_DIR/remote-config-defaults.plist"
check_plist "DEBUG_SERVICE_DATA -> service-data.plist" "$RESOURCES_DIR/service-data.plist"

# Brainwallet-StoreKit-v1.storekit is JSON (Xcode's StoreKit Configuration
# format), not a plist -- plutil -lint rejects JSON outright, so validate
# with a real JSON parser instead.
if [ ! -s "$RESOURCES_DIR/Brainwallet-StoreKit-v1.storekit" ] || ! python3 -m json.tool "$RESOURCES_DIR/Brainwallet-StoreKit-v1.storekit" >/dev/null 2>&1; then
  echo "❌ ERROR: BRAINWALLET_IOS_STOREKIT_V1_0_FILE -> Brainwallet-StoreKit-v1.storekit did not decode to valid JSON -- check its value in Xcode Cloud's environment variables (App Store Connect)"
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