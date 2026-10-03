# Brainwallet iOS v3.10.0

## Highlights

### Trusted Node (new)
- Connect Brainwallet to your own Litecoin node by entering its IP address and port in Settings.
- Unlocked with an in-app purchase (`trusted_ltc_node_2`); the purchase state, IP and port are stored in the iOS Keychain (service `brainwallet.trustednode`).
- A toggle lets you switch between your trusted node and random mainnet peers. The preference is passed to `BRPeerManager` (`PeerSyncMode`: `random_mainnet` / `trusted`).
- The sync status view shows an icon for the current peer sync mode.
- Replaces the old, unused `customNodeIP` / `customNodePort` defaults.

### Live network fees
- The Settings fee picker now shows real Economy / Regular / Luxury tiers fetched from the fee-per-kb endpoint, instead of placeholder values.
- Shows the fiat cost of the selected tier and remembers your choice.
- Fee tier math is in a new `NetworkFeeTier` type, covered by `NetworkFeeTierTests`.

### Redesigned Settings
- Blockchain, Currency, Security, Theme and Lock rows share one layout and row heights.
- The blockchain detail view groups peer sync, blockchain sync and network fee sections more clearly.
- The blockchain sync confirmation alert is back.
- The old Settings footer view is removed.

### Safer wallet wipe
- Wiping the wallet now waits for the wallet wipe, database deletion and keychain cleanup to finish, and reports failure instead of ignoring it.
- The wipe also clears the trusted-node keychain items and the remote-config environment keychain.
- Lock screen wipe UI shows an error state if the wipe fails.

## Other changes
- Refreshed translations (`Localizable.xcstrings` auto-translate).
- Transaction detail and color palette tweaks.
- Updated submodules: `Modules/core` and `Private/general-purpose`.
- Added the `brainwallet-local-storekit` scheme for local StoreKit testing.
- `.gitignore` cleanup.

## Upgrade notes
- If you used the old custom node preference, re-enter it as a Trusted Node. The old keys are removed.
- Wiping a wallet also clears trusted-node settings and the purchase flag from the Keychain. Restore the purchase from the App Store.

## App Store "What's New"
> - New: Trusted Node. Connect Brainwallet to your own Litecoin node.
> - Network fees now show live Economy, Regular and Luxury rates, with the fiat cost.
> - Redesigned Settings.
> - More reliable wallet wipe, with a clear error if it fails.
> - Updated translations and other improvements.

## Comparison basis
Changes are listed against `main` (the last release, `v3.9.18`). `develop` and `release/v3.10.0` share the Trusted Node merge (#197). The release branch adds only the version bump and an i18n catalog update. `develop` has one more translation PR (#198) and a stale catalog removal that are not in the release.
