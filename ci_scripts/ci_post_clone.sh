#!/bin/sh
# Apple Xcode Cloud Documentation
# https://developer.apple.com/documentation/xcode/writing-custom-build-scripts#Create-a-custom-build-script
# ci_post_clone: Adding post clone tools prior to building

# Exit on error
set -e

# Write the files to the correct location
echo "GOOGLE_SERVICES_PLIST" > "$CI_PRIMARY_REPOSITORY_PATH/brainwallet/PreLaunchResources/GoogleService-Info.plist"
echo "REMOTE_CONFIG_DEFAULTS" > "$CI_PRIMARY_REPOSITORY_PATH/brainwallet/PreLaunchResources/remote-config-defaults.plist"
echo "DEBUG_SERVICE_DATA" > "$CI_PRIMARY_REPOSITORY_PATH/brainwallet/PreLaunchResources/service-data.plist"