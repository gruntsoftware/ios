import Foundation

class TransactionsViewModel: ObservableObject, Subscriber, Trackable {
    
    @Published
    var transactions: [Transaction] = []
    
    private var allTransactions: [Transaction] = [] {
        didSet {
            transactions = allTransactions
        }
    }
    
    @Published
    var currentFiatValue = ""
     
    @Published
    var currencyCode = ""
    
    @Published
    var shouldBeSyncing: Bool = false
    
	var store: Store?

	var walletManager: WalletManager
    
    private var rate: Rate? {
        didSet {
            
        }
    }

	init(store: Store, walletManager: WalletManager) {
		self.store = store
		self.walletManager = walletManager
        fetchAllTransactions()
	}
    
    func fetchAllTransactions() {
        
    }
    
    /// Update displayed transactions. Used mainly when the database needs an update
    /// - Parameter txHash: String reprsentation of the TX
    private func updateTransactions(txHash: String) {
        for (i, tx) in transactions.enumerated() {
            if tx.hash == txHash {
                DispatchQueue.main.async {
//                    self.tableView.beginUpdates()
//                    self.tableView.reloadRows(at: [IndexPath(row: i, section: 1)], with: .automatic)
//                    self.tableView.endUpdates()
                }
            }
        }
    }
    
    /// Dyanmic Update Progress View: Advances the progress bar
    /// - Parameters:
    ///   - syncProgress: The state of the initial Sync Progress
    ///   - lastBlockTimestamp: Corresponding timestamp
    /// - Returns: CGFloat value
    private func updateProgressView(syncProgress: CGFloat, lastBlockTimestamp: Double) -> CGFloat {
        /// DEV:  HACK if the previous value is the same add a ration
        /// The problem is the progress needs to go to o to 1 .
        var progressValue: CGFloat = 0.0
        let num = lastBlockTimestamp - kFiveYears
        let den = kTodaysEpochTime - kFiveYears
        if syncProgress == 0.05 {
            progressValue = abs(CGFloat(num) / CGFloat(den))
        } else {
            progressValue = syncProgress
        }

        return progressValue
    }
    
    // MARK: - Subscription Methods

    private func addSubscriptions() {
        guard let store = self.store
        else {
            NSLog("ERROR: Store not initialized")
            return
        }

        // MARK: - Wallet State: Transactions

        store.subscribe(self, selector: { $0.walletState.transactions != $1.walletState.transactions },
                        callback: { state in
                            self.allTransactions = state.walletState.transactions
                           
                        })


        // MARK: - Wallet State:  CurrentRate

        store.subscribe(self, selector: { $0.currentRate != $1.currentRate },
                        callback: { self.rate = $0.currentRate })

        // MARK: - Wallet State:  Max Digits

        store.subscribe(self, selector: { $0.maxDigits != $1.maxDigits }, callback: { [weak self] _ in
        })

        // MARK: - Wallet State:  Sync Progress

        store.subscribe(self, selector: { $0.walletState.lastBlockTimestamp != $1.walletState.lastBlockTimestamp },
                        callback: { reduxState in
                                self.shouldBeSyncing = true
                                if reduxState.walletState.syncProgress >= 0.99 {
                                    self.shouldBeSyncing = false
                                }
                            })

        // MARK: - Wallet State:  Sync State

        store.subscribe(self, selector: { $0.walletState.syncState != $1.walletState.syncState },
                        callback: { reduxState in

            guard let _ = self.walletManager.peerManager
                            else {
                                assertionFailure("PEER MANAGER Not initialized")
                                return
                            }

//                            if reduxState.walletState.syncState == .syncing {
//                                self.shouldBeSyncing = true
//                                self.initSyncingHeaderView(reduxState: reduxState, completion: {
//                                    self.syncingHeaderView?.isRescanning = reduxState.walletState.isRescanning
//                                    self.syncingHeaderView?.progress = 0.02
//                                    self.syncingHeaderView?.headerMessage = reduxState.walletState.syncState
//                                    self.syncingHeaderView?.noSendImageView.alpha = 1.0
//                                    self.syncingHeaderView?.timestamp = reduxState.walletState.lastBlockTimestamp
//                                })
//                            }
//
//                            if reduxState.walletState.syncState == .success {
//                                self.shouldBeSyncing = false
//                                self.syncingHeaderView = nil
//                            }
                        })

        // MARK: - Subscription:  Recommend Rescan

        store.subscribe(self, selector: { $0.recommendRescan != $1.recommendRescan }, callback: { [weak self] _ in
          //  self.attemptShowPrompt()
        })

        // MARK: - Subscription:  Did Upgrade PIN

        store.subscribe(self, name: .didUpgradePin, callback: { [weak self] _ in
//            if self?.currentPromptType == .upgradePin {
//                self?.currentPromptType = nil
//            }
        })

        // MARK: - Subscription:  Did Enable Share Data

        store.subscribe(self, name: .didEnableShareData, callback: { [weak self] _ in
//            if self?.currentPromptType == .shareData {
//                self?.currentPromptType = nil
//            }
        })

        // MARK: - Subscription:  Did Write Paper Key

        store.subscribe(self, name: .didWritePaperKey, callback: { [weak self] _ in
//            if self?.currentPromptType == .paperKey {
//                self?.currentPromptType = nil
//            }
        })

        // MARK: - Subscription:  Memo Updated

        store.subscribe(self, name: .txMemoUpdated(""), callback: { [weak self] in
            guard let trigger = $0 else { return }
            if case let .txMemoUpdated(txHash) = trigger {
                self?.updateTransactions(txHash: txHash)
            }
        })

    }
}
