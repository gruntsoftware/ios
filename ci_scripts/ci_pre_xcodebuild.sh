#!/bin/bash
# ci_scripts/ci_pre_xcodebuild.sh
# Requirement per the Xcode Cloud path
# Apple Xcode Cloud Documentation
# https://developer.apple.com/documentation/xcode/writing-custom-build-scripts#Create-a-custom-build-script
# ci_pre_xcodebuild: Actions prior to building
#
# Builds the game framework (BWIOSGdx.xcframework) from the Private/bw-gdlib submodule.
#
# The framework is a RoboVM/Gradle build artifact that is never committed, so a fresh
# Xcode Cloud clone doesn't have it. Simulator builds (the test actions) don't need it --
# the game is device-only and the "Embed BWIOSGdx" build phase skips it -- but an archive
# is a device build and fails with "Unable to resolve module dependency: 'BWIOSGdx'".
# So build it here, for archive actions only, exactly as it is built locally:
#   cd Private/bw-gdlib && ./gradlew :ios:robovmInstall

set -euo pipefail

if [ "${CI_XCODEBUILD_ACTION:-}" != "archive" ]; then
  echo "ℹ️ ${CI_XCODEBUILD_ACTION:-unknown} action -- BWIOSGdx.xcframework not needed, skipping"
  exit 0
fi

GDX_DIR="$CI_PRIMARY_REPOSITORY_PATH/Private/bw-gdlib"
FRAMEWORK="$GDX_DIR/ios/build/robovm/BWIOSGdx.xcframework/arm64/BWIOSGdx.framework"

if [ ! -x "$GDX_DIR/gradlew" ]; then
  echo "❌ ERROR: $GDX_DIR/gradlew not found -- is the Private/bw-gdlib submodule checked out?"
  exit 1
fi

# bw-gdlib's Gradle settings import a version catalog from its own nested submodule
# (android-build-logic, a public repo). Fetch it if the clone didn't.
if [ ! -f "$GDX_DIR/android-build-logic/gradle/libs.versions.toml" ]; then
  echo "📦 Fetching bw-gdlib's android-build-logic submodule..."
  git -C "$GDX_DIR" submodule update --init android-build-logic
fi

# --- JDK 17 (Xcode Cloud images don't ship one; Gradle 8.14 runs on it) -------------------
# Gradle downloads the JDK 11 toolchain that :core asks for by itself (foojay resolver).
case "$(uname -m)" in
  arm64) JDK_ARCH="aarch64" ;;
  *)     JDK_ARCH="x64" ;;
esac
JDK_ROOT="$HOME/ci-jdk17"
if [ ! -d "$JDK_ROOT" ]; then
  echo "☕ Downloading Temurin JDK 17 ($JDK_ARCH)..."
  mkdir -p "$JDK_ROOT"
  curl -fsSL --retry 3 \
    "https://api.adoptium.net/v3/binary/latest/17/ga/mac/${JDK_ARCH}/jdk/hotspot/normal/eclipse" \
    | tar -xz -C "$JDK_ROOT"
fi
JAVA_HOME="$(find "$JDK_ROOT" -maxdepth 3 -type d -path '*/Contents/Home' | head -1)"
if [ -z "$JAVA_HOME" ] || [ ! -x "$JAVA_HOME/bin/java" ]; then
  echo "❌ ERROR: JDK 17 download/extract failed"
  exit 1
fi
export JAVA_HOME
export PATH="$JAVA_HOME/bin:$PATH"
java -version

# --- Build the framework --------------------------------------------------------------------
echo "🎮 Building BWIOSGdx.xcframework (RoboVM, this takes a while)..."
start=$(date +%s)
(
  cd "$GDX_DIR"
  ./gradlew :ios:robovmInstall \
    --no-daemon \
    --console=plain \
    -Dorg.gradle.logging.level=lifecycle
)
echo "⏱️ BWIOSGdx build took $(( $(date +%s) - start ))s"

if [ ! -d "$FRAMEWORK" ]; then
  echo "❌ ERROR: Gradle finished but $FRAMEWORK is missing"
  exit 1
fi
echo "✅ BWIOSGdx.xcframework built"
