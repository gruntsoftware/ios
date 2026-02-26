#!/bin/sh

# Exit on error
set -e

# Write the plist to the correct location
echo "$GOOGLE_SERVICE_INFO_PLIST" > "$CI_PRIMARY_REPOSITORY_PATH/brainwallet/PreLaunchResources/GoogleService-Info.plist"