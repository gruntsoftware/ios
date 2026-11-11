# Brainwallet iOS v3.10.4

Build 2602323. First public release of the 3.10 line. It includes all of the planned 3.10.0 work, plus the fixes needed to pass App Review and to run on iOS 27.

## Highlights

### Trusted Node (new)
- Connect Brainwallet to your own Litecoin node by entering its IP address and port in Settings.
- Unlocked with an in-app purchase (`trusted_ltc_node_2`). The purchase state, IP and port are stored in the iOS Keychain (service `brainwallet.trustednode`).
- A toggle switches between your trusted node and random mainnet peers. The choice is passed to `BRPeerManager` (`PeerSyncMode`: `random_mainnet` / `trusted`).
- The sync status view shows an icon for the current peer sync mode.
- Replaces the old, unused `customNodeIP` / `customNodePort` defaults.
- Fixed before release: the purchase sheet could appear empty because the app listed a retired product id (`trusted_ltc_node_1`). It now uses `trusted_ltc_node_2`, matching App Store Connect, and `TrustedNodeProductIdTests` keeps the ids in sync.

### Live network fees
- The Settings fee picker now shows real Economy / Regular / Luxury tiers from the fee-per-kb endpoint, replacing placeholder values.
- Shows the fiat cost of the selected tier and remembers your choice.
- The fee math lives in a new `NetworkFeeTier` type, tested by `NetworkFeeTierTests`.

### Redesigned Settings
- Blockchain, Currency, Security, Theme and Lock rows share one layout and row height.
- The blockchain detail view groups peer sync, blockchain sync and network fee sections more clearly.
- The blockchain sync confirmation alert is back.
- The old Settings footer view is removed.

### iOS 27 support
- iOS 27 stops apps at launch if they don't use the scene lifecycle. The app now uses `UIScene` (new `SceneDelegate` and scene manifest, main storyboard window removed).
- Window setup, lifecycle handling, URL handling and the Game SDK moved out of `AppDelegate`.
- Updated and added unit tests (`SceneLifecycleTests`, `SceneTests`, Application Controller tests).

### Safer wallet wipe
- Fixed a crash during wallet wipe.
- Wiping the wallet now waits for the wallet wipe, database deletion and keychain cleanup to finish, and reports failure instead of ignoring it.
- The wipe also clears the trusted-node keychain items, the remote-config environment keychain and saved game scores.
- The lock screen wipe UI shows an error if the wipe fails.

## App Review compliance
- Guideline 2.1(b): fixed the Trusted Node product id (see above). Build 2602316 replaced 2602315.
- Guideline 5.6.3: 3.10.4 was rejected for asking for a rating on first launch. The review prompt is removed from the welcome screen (`WelcomeMojiDemoView`).
- The review prompt now appears only after the user has played two games. Each game's score and time are saved to the Keychain as a JSON array (and cleared on wallet wipe), with unit tests for both the two-game rule and score storage.

## Other changes
- MoonPay web view has a back button, and the signed URL resets on each launch.
- Fixed the emoji keyboard not appearing on `PickEmojisView`. `@FocusState` was bound to a container and never reached the `UITextField`. The keyboard now opens 1s after page 2 becomes active.
- Fixed drag-and-drop on the seed word verification screen.
- Fixed the falling-dots animation in the demo scenes.
- Layout fixes for the tab bar, Enter PIN for Seed and Set Passcode screens.
- Transaction detail and color palette tweaks.
- Refreshed translations (`Localizable.xcstrings` auto-translate).
- Updated submodules: `Modules/core` and `Private/general-purpose` (now at `124e7b5`, with the product id fix).
- Added the Xcode Cloud manifest.
- Added the `brainwallet-local-storekit` scheme for local StoreKit testing. `bw-iap-config-v2.storekit` is not in the app's bundle resources, because it is gitignored and broke the Xcode Cloud build.
- `.gitignore` cleanup.

## Upgrade notes
- If you used the old custom node setting, set it up again as a Trusted Node. The old keys are removed.
- Wiping a wallet also clears trusted-node settings and the purchase flag from the Keychain. Use Restore Purchases from the App Store to get the purchase back.

## App Store "What's New"
> - New: Trusted Node. Connect Brainwallet to your own Litecoin node.
> - Network fees now show live Economy, Regular and Luxury rates, with the fiat cost.
> - Redesigned Settings.
> - More reliable wallet wipe, with a clear error if it fails.
> - Fixes for iOS 27, the emoji keyboard and seed phrase verification.
> - Updated translations and other improvements.

## Comparison basis
Changes are listed against `v3.9.18`, the last release. The release is tagged `v3.10.4` on the merge of #199 (`release/v3.10.0`) into `main`. `develop` has translation PR #198 and a stale catalog removal that are not in this release.

Full changelog: https://github.com/gruntsoftware/ios/compare/v3.9.18...v3.10.4
