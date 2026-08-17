# Brainwallet: iOS

**Brainwallet** is a free, open-source, self-custodial [Litecoin](https://litecoin.org) wallet for iOS. Your seed phrase and keys stay on your device — Brainwallet never has custody of your funds.

[![Release](https://img.shields.io/github/v/release/gruntsoftware/ios?style=plastic)](https://github.com/gruntsoftware/ios/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## App Store

[![Download on the App Store](images/app-store-badge.svg)](https://apps.apple.com/us/app/brainwallet/id6444157498)

## Important Links & Download
- **Android Repo**: [gruntsoftware/android](https://github.com/gruntsoftware/android)
- **Website**: [brainwallet.co](https://brainwallet.co)
- **Support**: [brainwallet.co/support.html](https://brainwallet.co/support.html)

## Why Brainwallet?

**Standalone, not a client of our servers.** Brainwallet connects directly to the Litecoin peer-to-peer network using SPV (simplified payment verification), via the vendored `breadwallet-core` C library (`Modules/core`) — the same wallet-core lineage as the Android app. Checking balances and broadcasting transactions doesn't depend on any Brainwallet-run backend.

**Deterministic recovery.** Brainwallet is a [BIP32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki) hierarchical-deterministic wallet (`BRBIP32Sequence.c`) — one seed phrase (paper key) recovers your full balance and transaction history on any device, forever.

**Keys stay in the iOS Keychain.** Private keys are stored via iOS Keychain Services as device-only, non-synced items (`kSecAttrAccessibleWhenUnlockedThisDeviceOnly`/`AfterFirstUnlockThisDeviceOnly` in `WalletManager+Auth.swift`), not in Brainwallet's infrastructure — we never have custody of your funds and no backend path to recover them for you.

**Built on open standards**, not a proprietary protocol:
- SPV for fast sync without running a full node
- [BIP32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki) deterministic wallets
- [BIP38](https://github.com/bitcoin/bips/blob/master/bip-0038.mediawiki) import of password-protected paper wallets (`BRBIP38Key.c`)
- [BIP70](https://github.com/bitcoin/bips/blob/master/bip-0070.mediawiki) payment protocol support (`BRPaymentProtocol.c`)

## Features

- Self-custodial Litecoin wallet — your seed phrase never leaves your device
- Send/receive LTC with real-time fee estimation and fiat conversion
- Mini-games (Bento Game Hub) to help you memorize your seed phrase
- PIN app lock
- Buy/sell LTC and gift cards via in-app widgets
- SwiftUI-based Bento UI hosted in a lightweight UIKit shell, with legacy UIKit screens still being migrated

## Auditing code

### Prerequisites
- Xcode (current stable), Swift 5.0
- This repo uses git submodules for the wallet core and other modules — clone with `git clone --recurse-submodules`, or run `git submodule update --init --recursive` after a normal clone

## Architecture

- **Language/UI**: Swift 5, SwiftUI as the primary UI hosted in a thin UIKit shell (`AppDelegate` + `UIHostingController` subclasses such as `NewMainHostingController`) — legacy UIKit view controllers are still being migrated
- **DI**: no framework — dependency injection is manual, via a Redux-like `Store` constructed once in `ApplicationController` and passed through initializers
- **Concurrency**: GCD-first (`DispatchQueue`), with lighter use of Combine and async/await
- **Wallet core**: native C library (`Modules/core`, `breadwallet-core`), the same lineage as the Android app's wallet core, built as the `BRCore` static library target
- **Modules**: `brainwallet` (main app target), `BRCore` (native wallet core), plus private submodules `Private/general-purpose` and `Private/bw-gdlib` (mini-games)

## Testing

Test targets are `BrainwalletUnitTests` and `BrainwalletUITests`. Run via Fastlane, e.g. `bundle exec fastlane run_unit_tests_iPhone16ProMax` (see `fastlane/Fastfile` for other lanes). CI runs on Xcode Cloud (`ci_scripts/`); i18n translation coverage is checked separately via a GitHub Actions workflow (`.github/workflows/i18n-coverage.yml`).

## Security

Found a security vulnerability? Please **do not** open a public issue — see [SECURITY.md](SECURITY.md) for how to report it privately.

## License

Brainwallet iOS is released under the [MIT License](LICENSE). The vendored wallet core (`Modules/core`) may carry its own license terms.

---

## Release Notes

For the full, up-to-date changelog see [GitHub Releases](https://github.com/gruntsoftware/ios/releases) and the [compare view](https://github.com/gruntsoftware/ios/compare). Highlights from recent versions:

---

### **v3.9.15**  [PR [#151](https://github.com/gruntsoftware/ios/pull/151)]
---
- Fixed game-exit analytics events being silently dropped: `bw-gdlib` now wraps the exit payload as `{"exitData": ..., "events": [...]}`, and iOS decodes it (`GameExitPayload`) and forwards every collected event to Firebase Analytics instead of throwing/discarding it; Android's `AndroidLauncher` now forwards the same `jsonString` too
- Updated `Private/bw-gdlib` submodule to v1.6.4
- Removed redundant/duplicate Facebook & Analytics `logEvent` calls for the Game Hub and top-up-skip flows, including a duplicated `did_request_rating` event
- Removed duplicate/orphaned Legacy `BW_BRClasses` files no longer referenced by the Xcode project

**Full Changelog**: https://github.com/gruntsoftware/ios/compare/v3.9.13...v3.9.15

---

### **v3.9.11**  [PR [#127](https://github.com/gruntsoftware/ios/pull/127)]
---
Fixed a crash in the Game Hub introduced by v3.9.10's Fallinmoji launch:
- `GameHubBentoView`/`GameHubCarouselBentoView` refactored and stabilized
- Swapped the `BoldenVan` font for `LilitaOne`
- Minor fixes to `FallinMojiDemoView`/`WelcomMojiDemoView` and `CoreModeView`

**Full Changelog**: https://github.com/gruntsoftware/ios/compare/v3.9.10...v3.9.11

---

### **v3.9.10**  [PR [#124](https://github.com/gruntsoftware/ios/pull/124)]
---
**Fallinmoji** — the mini-game first added to the Android app now lands on iOS:
- New `Private/bw-gdlib` submodule wired in, with `GameContainerViewController`/`GameEmbedViewController`/`GameStructs` hosting the game inside the Game Hub Bento carousel
- New social sharing flow (`SocialPostHelper`, `SocialPostViewModel`)
- Large localization expansion (`Localizable.xcstrings`)

**Full Changelog**: https://github.com/gruntsoftware/ios/compare/v3.9.7...v3.9.10

---

### **v3.9.7**  [PR [#117](https://github.com/gruntsoftware/ios/pull/117)]
---
Continued the Shop Bento buy/sell-gift-card work started in v3.9.5:
- New `ShopCardsView`, `ShopImages`, `ShopStructs`; `ShopBentoViewModel` substantially refactored
- Replaced the old in-app `SignupWebView` with a `SafariServices`-based signup flow
- Added Indonesian localization scheme

**Full Changelog**: https://github.com/gruntsoftware/ios/compare/v3.9.5...v3.9.7

---

### **v3.9.5**  [PR [#111](https://github.com/gruntsoftware/ios/pull/111)]
---
- Added Shop Bento gift-card assets (Amazon, BitRefill, Visa) and a new `SignupAskView`
- Minor fixes to `ReadyView`, `RestoreView`, `ConfirmPasscodeView`, `SettingsView`

**Full Changelog**: https://github.com/gruntsoftware/ios/compare/v3.9.3...v3.9.5

---

### **v3.9.3**  [PR [#93](https://github.com/gruntsoftware/ios/pull/93)]
---
- **Test coverage**: two new suites adding 742+ assertions, covering emoji selection logic (`EmojiViewModel`, `EmojiTriplet`, `EmojiSection`) and fiat currency handling (`Currency`, `GlobalCurrency` across all 160 cases)
- **AI-assisted PR summaries**: new GitHub Actions workflow generating structured PR descriptions
- **CI/CD cleanup**: removed a problematic `ssh-add -D` step, simplified submodule init, refactored Xcode Cloud build scripts
- Localization updates across 16 languages; minor emoji/send-receive UI refinements

**Full Changelog**: https://github.com/gruntsoftware/ios/compare/v3.9.1...v3.9.3

---

### **v3.9.2**
---
Added the first Emoji Picker so that users are ready to set their first 3 emojis for gameplay.

#### Fixes and Changes:
- Minor layout changes
- Successfully enabled Xcode Cloud testing

---

### **v3.9.0 – v3.9.1**  [PR [#89](https://github.com/gruntsoftware/ios/pull/89)]
---
- Update README for improved description by @kcw-grunt in #78
- Beta Release [ 🚀 ] Merge Develop into Main by @kcw-grunt in #81

#### Fixes and Changes:
- Current fiat preference from Settings needs to be reset if set in the TickerBento
- Localizations are covered to 100%
- Mini game FALLINMOJI is present in the Welcome and Game Hub
- When setting the theme from the Settings and the Lock Screen and the Main screen is not consistently applied
- In general the fonts in the app are not consistent and need to be managed properly for consistency
- Mini game sounds set a nominal level
- Layout for iPhone 8 - iPhone 17 Pro Max is set for: Welcome Screen
- Support.brainwallet.co link is fixed

---

### **v3.6.0**
---
#### What's Changed
🚀[Release v3.5.0] Merge into Main by @kcw-grunt in #51
Full Changelog: v3.4.2...v3.6.0

#### Updates:
- using bundle exec fastlane single_unit_test_all
- downgrade firebase to 11.12.0
- polsih ci config
- 🦾 Chore/migrate ready onboarding
- Fix/login view crash
- 🧰 fix: Removed the thread blocking seen in the lock screen trx. loading
- Epic/settings migration (#50)
- Chore/refactor firebase analytics
- Chore/activate test coverage

---

### **v3.3.1**
---
- Added locale filter
- Made improvements to UI
- Fixes
