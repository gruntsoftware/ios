# Brainwallet iOS v3.11.0

Build 2602332. Released on the App Store on 2026-11-18.

## Highlights

### Emojis for seed words 4–6 (new)
- Once you've played two games, tapping the Game Hub opens a new step (`SetSixthEmojiView`). Enter your PIN, then pick emojis for seed words 4–6. Seed words stay hidden until you tap the eye.
- Tapping the Game Hub now does one of three things: opens emoji setup for words 1–3 if no emojis are set, opens setup for words 4–6 if 3 are set and you've played 2 or more games, or starts the game.
- The second set of emojis is only added when exactly 3 are stored, so tapping twice can't store 9.
- Wiping a wallet now clears emojis, and game scores are cleared before the KV store step, which used to skip them.

### Simpler onboarding
- After you confirm your passcode, restoring users go straight to Input Words and new users go to Your Seed Words. The push-notification ask (`SignupAskView`) is removed.
- The last onboarding buttons now say **"Done"** (they said "Restore & Sync" / "Game & Sync").
- Fixed the "Done" translation in Swedish, Indonesian and Japanese.
- New `OnboardingFinishFlowTests`.

### Trusted Node is easier to find
- App Review couldn't find the Trusted Node in-app purchase. The entry point is now "Set Trusted Node" under "Trusted Node mode".
- The Settings action buttons stand out more (blue fill, shadow, 140pt width).

### Translucent sheets on iOS 26+
- From iOS 26, full-height sheets get an opaque Liquid Glass background. A shared `translucentSheet` modifier restores the see-through look from iOS 17 to iOS 27.
- Applies to the tutorials (Send, Receive, Walkthrough), Send / No-send, Confirm send, Buy/Receive, emoji setup and the lock screen receive address.
- Tutorial tint raised from 10% to 20%. Spacing tweaks on the emoji setup intro.

## Other changes
- Fixed the draggable seed words on `YourSeedProveItView` overflowing into the Reset button. The grid now matches the word buckets grid.
- Settings (hamburger) icon now matches the tab icon size, with more padding around the nav bar buttons.
- Analytics: debug, simulator and TestFlight builds now run in Firebase debug mode, so they show in DebugView and stay out of production reports.
- New `user_confirmed_wallet` analytics event when onboarding finishes (`create` or `restore`).
- Updated the private framework submodule to v1.4.0.
- Refreshed translations (`Localizable.xcstrings` auto-translate) and removed a stale catalog.
- README: added a line about the mini-games.

## App Store "What's New"
> - Trusted Node: connect to your own Litecoin node (IP + port) & toggle between trusted node & litecoin peers.
> - Minor improvements

## Comparison basis
Changes are listed against `v3.10.4`. The release is tagged `v3.11.0` on `94c93ca` ("build bump"), the source of approved build 2602332. #217 (sync button width) and #218 (core `peerThreadCount` double-decrement fix) were merged to `develop` after that build was uploaded and are not in this release.

Full changelog: https://github.com/gruntsoftware/ios/compare/v3.10.4...v3.11.0
