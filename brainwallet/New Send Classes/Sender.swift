import BRCore
import Foundation
import UIKit
import FirebaseAnalytics
import FirebaseCrashlytics

enum SendResult {
	case success
	case creationError(String)
	case publishFailure(BRPeerManagerError)
}

class Sender {
	// MARK: - Private Variables

	private let walletManager: WalletManager
	private let kvStore: BRReplicatedKVStore
	private let store: Store

	// MARK: - Public Variables

	var transaction: BRTxRef?
    var rate: Rate?
	var memoString: String?
	var feePerKb: UInt64?
	var networkFee: UInt64 {
		guard let transaction = transaction else { return 0 }
		return walletManager.wallet?.feeForTx(transaction) ?? 0
	}

	var canUseBiometrics: Bool {
		guard let transaction = transaction else { return false }
		return walletManager.canUseBiometrics(forTx: transaction)
	}

	init(walletManager: WalletManager, kvStore: BRReplicatedKVStore, store: Store) {
		self.walletManager = walletManager
		self.kvStore = kvStore
		self.store = store
	}

	func createTransaction(amount: UInt64, to: String) -> Bool {
		transaction = walletManager.wallet?.createTransaction(forAmount: amount, toAddress: to)
		return transaction != nil
	}

    func createTransactionWithOpsOutputs(amount: UInt64, toAddress: String) -> Bool {
        guard amount > 0 else {
            assertionFailure("createTransactionWithOpsOutputs called with zero amount")
            return false
        }

        // Dust threshold check — 546 litoshis is standard P2PKH dust limit
        guard amount >= litoshiDustThreshold else {
            return false
        }

        // BRWalletCreateOpsTransaction() (core) hard-asserts — SIGABRT, not a
        // recoverable error — on an invalid address for either output, so both
        // addresses must be validated before we ever call into it. See
        // BRWalletCreateOpsTransaction.cold.4 crashes (e.g. Crashlytics issue
        // d20dcdc984ce6926d52abfc6644330d6): a malformed/placeholder ops
        // address from Partner.partnerKeyPath (missing or malformed
        // service-data.plist) reached the core call unvalidated and aborted
        // the process on the main thread.
        guard toAddress.isValidAddress else {
            Crashlytics.crashlytics().record(error: NSError(
                domain: "Sender",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "createTransactionWithOpsOutputs rejected invalid destination address"]))
            return false
        }

        let opsAddress = Partner.partnerKeyPath(name: .walletOps)
        guard opsAddress.isValidAddress else {
            Crashlytics.crashlytics().record(error: NSError(
                domain: "Sender",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "createTransactionWithOpsOutputs rejected invalid ops address: \(opsAddress)"]))
            return false
        }

        transaction = walletManager.wallet?.createOpsTransaction(forAmount: amount,
                                                                 toAddress: toAddress,
                                                                 opsFee: tieredOpsFee(amount: amount),
                                                                 opsAddress: opsAddress)

        return transaction != nil
    }

	func feeForTx(amount: UInt64) -> UInt64 {
		return walletManager.wallet?.feeForTx(amount: amount) ?? 0
	}

    private func updateFBData() {
        Analytics
            .logEvent("did_send_ltc",
                      parameters: [
                        "request_placement":
                            String(describing: type(of: WalkthroughStep3View.self))
                      ])
    }
    /// Send
    /// - Parameters:
    ///   - biometricsMessage: Response from decoding the biometrics
    ///   - rate: LTC - Fiat rate
    ///   - memoString: Memo note for the user recall in the database
    ///   - feePerKb: rate  of fee per kb
    ///   - pinCode: PIN code
    ///   - completion: completion
    func send(biometricsMessage: String,
              rate: Rate?,
              memoString: String?,
              feePerKb: UInt64,
              pinCode: String,
              completion: @escaping (SendResult) -> Void) {
        guard let transaction = transaction
        else {
            return completion(.creationError("Could not create transaction."))
        }

        self.rate = rate
        self.memoString = memoString
        self.feePerKb = feePerKb

        if UserDefaults.isBiometricsEnabled,
           walletManager.canUseBiometrics(forTx: transaction) {
            DispatchQueue.walletQueue.async { [weak self] in
                guard let myself = self else { return }
                myself
                    .walletManager
                    .signTransaction(transaction,
                                     biometricsPrompt:
                                     biometricsMessage,
                                     completion: { result in
                                         if result == .success {
                                             myself.publish(completion: completion)
                                             myself.updateFBData()

                                         } else {
                                             if result == .failure || result == .fallback {

                                             }
                                         }
                                     })
            }
        } else {
            let group = DispatchGroup()
            group.enter()
            DispatchQueue.walletQueue.async {
                if self.walletManager.signTransaction(transaction, pin: pinCode) {
                    self.publish(completion: completion)
                    self.updateFBData()

                }
                group.leave()
            }
        }
    }

	/// Send
	/// - Parameters:
	///   - biometricsMessage: Response from decoding the biometrics
	///   - rate: LTC - Fiat rate
	///   - memoString: Memo note for the user recall in the database
	///   - feePerKb: rate  of fee per kb
	///   - verifyPinFunction: verification
	///   - completion: completion
	func send(biometricsMessage: String,
	          rate: Rate?,
              memoString: String?,
	          feePerKb: UInt64,
	          verifyPinFunction:
	          @escaping (@escaping (String) -> Bool) -> Void,
	          completion: @escaping (SendResult) -> Void) {
		guard let transaction = transaction
		else {
			return completion(.creationError("Could not create transaction." ))
		}

		self.rate = rate
		self.memoString = memoString
		self.feePerKb = feePerKb

		if UserDefaults.isBiometricsEnabled,
		   walletManager.canUseBiometrics(forTx: transaction) {
			DispatchQueue.walletQueue.async { [weak self] in
				guard let myself = self else { return }
				myself
					.walletManager
					.signTransaction(transaction,
					                 biometricsPrompt:
					                 biometricsMessage,
					                 completion: { result in
					                 	if result == .success {
					                 		myself.publish(completion: completion)
                                            myself.updateFBData()
					                 	} else {
					                 		if result == .failure || result == .fallback {
					                 			myself.verifyPin(tx: transaction,
					                 			                 withFunction: verifyPinFunction,
					                 			                 completion: completion)
					                 		}
					                 	}
					                 })
			}
		} else {
			verifyPin(tx: transaction, withFunction: verifyPinFunction, completion: completion)
		}
	}

	/// Verify Pin
	/// - Parameters:
	///   - tx: TX package
	///   - withFunction: completion mid-range
	///   - completion: completion

	// DEV: Important Note
	// This func needs to be REFACTORED as it violates OOP and intertangles TX and Pin authentication
	// This means it should be 2 functions.
	// VerifyPIN and VerifyTX
	private func verifyPin(tx: BRTxRef,
	                       withFunction: (@escaping (String) -> Bool) -> Void,
	                       completion: @escaping (SendResult) -> Void) {
		withFunction { pin in
			var success = false
			let group = DispatchGroup()
			group.enter()
			DispatchQueue.walletQueue.async {
				if self.walletManager.signTransaction(tx, pin: pin) {
					self.publish(completion: completion)
					success = true
				}
				group.leave()
			}
			let result = group.wait(timeout: .now() + 30.0)
			if result == .timedOut {

				let alert = UIAlertController(title: "Corruption Error",
				                              message: "Your local database is corrupted. Go to Settings > Blockchain: Settings > Delete Database to refresh",
				                              preferredStyle: .alert)

				UserDefaults.didSeeCorruption = true
				alert.addAction(UIAlertAction(title: "OK",
				                              style: .default,
				                              handler: nil))
				return false
			}
			return success
		}
	}

	/// Publish TX
	/// - Parameter completion: completion
	private func publish(completion: @escaping (SendResult) -> Void) {
		guard let tx = transaction else { assertionFailure("publish failure"); return }
		DispatchQueue.walletQueue.async { [weak self] in
			guard let myself = self else { assertionFailure("myself didn't exist"); return }
			myself.walletManager.peerManager?.publishTx(tx, completion: { _, error in
				DispatchQueue.main.async {
					if let error = error {
						completion(.publishFailure(error))
					} else {
						myself.setMetaData()
						completion(.success)
					}
				}
			})
		}
	}

	/// Set transaction metadata
	private func setMetaData() {
		// Fires an event if the rate is not set
		guard let rate = rate
		else {
			return
		}

		// Fires an event if the transaction is not set
		guard let transaction = transaction
		else {
			return
		}

		// Fires an event if the feePerKb is not set
		guard let feePerKb = feePerKb
		else {
			return
		}

		let metaData = TxMetaData(transaction: transaction.pointee,
		                          exchangeRate: rate.rate,
		                          exchangeRateCurrency: rate.code,
		                          feeRate: Double(feePerKb),
		                          deviceId: UserDefaults.standard.deviceID,
                                  memoString: memoString)
		do {
			_ = try kvStore.set(metaData)
		} catch let error {
            debugPrint("::: ERROR \(error)")
		}
		store.trigger(name: .txMemoUpdated(transaction.pointee.txHash.description))
	}
}
