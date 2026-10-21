#!/usr/bin/env bash
# Prepares the repro to run as "Designed for iPad" on this Mac and opens it in Xcode.
# Gatekeeper only accepts an iOS app on Mac that Xcode (or the App Store) installed,
# so the final Run (⌘R) happens in Xcode.
#
# Usage: TEAM_ID=<your team ID> ./run-on-mac.sh [--fresh]
#   --fresh  Use a new bundle ID so macOS treats it as a never-before-seen app (case 1 in README)
set -euo pipefail

: "${TEAM_ID:?Set TEAM_ID to your Apple developer team ID (Xcode → Settings → Accounts)}"

SCHEME="notificationsmacrepro"
BUNDLE_ID="com.example.notificationsmacrepro"
if [[ "${1:-}" == "--fresh" ]]; then
  BUNDLE_ID="$BUNDLE_ID.fresh$(date +%s)"
fi

cd "$(dirname "$0")"
PBXPROJ="ios/$SCHEME.xcodeproj/project.pbxproj"
XCSCHEME="ios/$SCHEME.xcodeproj/xcshareddata/xcschemes/$SCHEME.xcscheme"
ENTITLEMENTS="ios/$SCHEME/$SCHEME.entitlements"

if [[ ! -d node_modules ]]; then
  echo "Installing JS dependencies..."
  npm install
fi

if [[ ! -d "ios/$SCHEME.xcworkspace" ]]; then
  echo "Generating the iOS project..."
  npx expo prebuild -p ios
fi

echo "Configuring team $TEAM_ID and bundle ID $BUNDLE_ID..."
sed -i '' -E "s/PRODUCT_BUNDLE_IDENTIFIER = [^;]+;/PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID;/" "$PBXPROJ"
sed -i '' -E "/DEVELOPMENT_TEAM = [^;]+;/d" "$PBXPROJ"
sed -i '' -E "s/^([[:space:]]*)(CODE_SIGN_ENTITLEMENTS = .*;)$/\1\2\\
\1DEVELOPMENT_TEAM = $TEAM_ID;/" "$PBXPROJ"

# Requesting permission doesn't need the push entitlement expo-notifications adds, and
# personal teams can't sign it. The rejection reproduces with or without it.
/usr/libexec/PlistBuddy -c "Delete :aps-environment" "$ENTITLEMENTS" 2>/dev/null || true

# Run in Release so the JS bundle is embedded and no Metro server is needed
perl -0pi -e 's/(<LaunchAction\s+buildConfiguration = )"Debug"/$1"Release"/' "$XCSCHEME"

open "ios/$SCHEME.xcworkspace"
cat <<EOF

Xcode is opening. To run:
  1. Destination (top bar): My Mac (Designed for iPad)
  2. Product → Run (⌘R)

Bundle ID: $BUNDLE_ID (find it in System Settings → Notifications for case 3)
EOF
