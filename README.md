# ios
The open source code of Brainwallet iOS

## CI/CD Status
**main**: [![CircleCI](https://dl.circleci.com/status-badge/img/gh/gruntsoftware/ios/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/gruntsoftware/ios/tree/main)

**develop**: [![CircleCI](https://dl.circleci.com/status-badge/img/gh/gruntsoftware/ios/tree/develop.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/gruntsoftware/ios/tree/develop)


## Release Notes

### v3.9.2
 Added the first Emoji Picker so that users are ready to set their first 3 emojis for gameplay.

#### Fixes and Changes:
- Minor layout changes
- Successfully enabled Xcode Cloud testing


### v3.9.0 - v3.9.1 Latest
Update README for improved description by @kcw-grunt in #78
Beta Release [ 🚀 ] Merge Develop into Main by @kcw-grunt in #81

#### Fixes and Changes:
- Current fiat preference from Settings needs to be reset if set in the TickerBento
- Localizations are covered to 100%
- Mini game FALLINMOJI is present in the Welcome and Game Hub
- When setting the theme from the Settings and the Lock Screen and the Main screen is not consistently applied
- In general the fonts in the app are not consistent and need to be managed properly for consistency
- Mini game sounds set a nominal level
- Layout for iPhone 8 - iPhone 17 Pro Max is set for: Welcome Screen
- Support.brainwallet.co link is fixed

### v3.6.0 Latest

#### What's Changed
🚀[Release v3.5.0] Merge into Main by @kcw-grunt in #51
Full Changelog: v3.4.2...v3.6.0\

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

### v3.3.1
- Added locale filter
- Made improvements to UI
- Fixes
