# expo-notifications: `requestPermissionsAsync` rejects on Apple Silicon Mac ("Designed for iPad")

Minimal repro: a blank SDK 55 app with `expo-notifications`. When the iOS app runs on an
Apple Silicon Mac and the user clicks "Don't Allow" on the macOS prompt,
`requestPermissionsAsync` rejects with `ERR_PERMISSIONS_REQUEST_NOTIFICATIONS` /
"Notifications are not allowed for this application" instead of resolving a `denied` status.

## Run

    npm install
    TEAM_ID=<your Apple team ID> ./run-on-mac.sh

The script generates the iOS project, sets your team and bundle ID, and opens Xcode. Then:

1. Destination: **My Mac (Designed for iPad)**
2. Product → Run (⌘R)

`./run-on-mac.sh --fresh` uses a new bundle ID so macOS treats the app as never seen before.

## Steps

1. Tap **getPermissionsAsync**
2. Tap **requestPermissionsAsync**, then click **Don't Allow** on the macOS prompt
3. Tap **getPermissionsAsync**

## Observed (macOS 27.0.1, Xcode 27.1, expo 55.0.31)

1. `getPermissionsAsync` resolves `status: "undetermined"`, `canAskAgain: true`
2. `requestPermissionsAsync` **rejects**:
   `{ code: "ERR_PERMISSIONS_REQUEST_NOTIFICATIONS", message: "Notifications are not allowed for this application" }`
3. `getPermissionsAsync` resolves `status: "denied"`, `canAskAgain: false`, `ios.status: 1`
