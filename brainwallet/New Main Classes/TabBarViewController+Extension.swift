//
//  TabBarViewController+Extension.swift
//  brainwallet
//
//  Created by Kerry Washington on 19/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import Foundation
import UIKit

extension TabBarViewController {

    // MARK: - Adding Subscriptions

  func addSubscriptions() {
        guard let store = store
        else {
            debugPrint("::: ERROR - Store not passed")
            return
        }

        guard let primaryLabel = primaryBalanceLabel,
              let secondaryLabel = secondaryBalanceLabel
        else {
            debugPrint("::: ERROR: Price labels not initialized")
            return
        }

        store.subscribe(self, selector: { $0.walletState.syncProgress != $1.walletState.syncProgress },
                        callback: { _ in
                    if let rate = store.state.currentRate {
                        let maxDigits = store.state.maxDigits
                        let placeholderAmount = Amount(amount: 0, rate: rate, maxDigits: maxDigits)
                        secondaryLabel.formatter = placeholderAmount.localFormat
                        primaryLabel.formatter = placeholderAmount.ltcFormat
                        self.exchangeRate = rate
                    }
        })

        store.lazySubscribe(self,
                            selector: { $0.isLtcSwapped != $1.isLtcSwapped },
                            callback: { self.isLtcSwapped = $0.isLtcSwapped })
        store.lazySubscribe(self,
                            selector: { $0.currentRate != $1.currentRate },
                            callback: {
                                if let rate = $0.currentRate {
                                    let placeholderAmount = Amount(amount: 0, rate: rate, maxDigits: $0.maxDigits)
                                    secondaryLabel.formatter = placeholderAmount.localFormat
                                    primaryLabel.formatter = placeholderAmount.ltcFormat
                                }
                                self.exchangeRate = $0.currentRate
                            })

        store.lazySubscribe(self,
                            selector: { $0.maxDigits != $1.maxDigits },
                            callback: {
                                if let rate = $0.currentRate {
                                    let placeholderAmount = Amount(amount: 0, rate: rate, maxDigits: $0.maxDigits)
                                    secondaryLabel.formatter = placeholderAmount.localFormat
                                    primaryLabel.formatter = placeholderAmount.ltcFormat
                                    self.setBalances()
                                }
                            })

        store.subscribe(self,
                        selector: { $0.walletState.balance != $1.walletState.balance },
                        callback: { state in
                            if let balance = state.walletState.balance {
                                self.balance = balance
                                self.setBalances()
                            }
                        })
    }

    @objc
    func currencySwitchTapped() {
        view.layoutIfNeeded()
        guard let store = store else { return }
        guard let isLTCSwapped = isLtcSwapped else { return }
        guard let primaryLabel = primaryBalanceLabel,
              let secondaryLabel = secondaryBalanceLabel
        else {
            NSLog("ERROR: Price labels not initialized")
            return
        }

        UIView.spring(0.7, animations: {
            primaryLabel.transform = primaryLabel.transform.isIdentity ? self.transform(forView: primaryLabel) : .identity
            secondaryLabel.transform = secondaryLabel.transform.isIdentity ? self.transform(forView: secondaryLabel) : .identity
            NSLayoutConstraint.deactivate(!isLTCSwapped ? self.regularConstraints : self.swappedConstraints)
            NSLayoutConstraint.activate(!isLTCSwapped ? self.swappedConstraints : self.regularConstraints)
            self.view.layoutIfNeeded()
        }) { _ in }
        store.perform(action: CurrencyChange.toggle())
    }
}
