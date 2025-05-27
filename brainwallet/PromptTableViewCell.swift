import LocalAuthentication
import UIKit

class PromptTableViewCell: UITableViewCell {
	@IBOutlet var closeButton: UIButton!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var bodyLabel: UILabel!
	@IBOutlet var tapButton: UIButton!

	var type: PromptType?
	var didClose: (() -> Void)?
	var didTap: (() -> Void)?

	@IBAction func didTapAction(_: Any) {
		didTap?()
	}

	@IBAction func closeAction(_: Any) {
		didClose?()
	}
}

enum PromptType {
	case biometrics
	case paperKey
	case upgradePin
	case recommendRescan
	case noPasscode
	case shareData

	static var defaultOrder: [PromptType] = [.recommendRescan, .upgradePin, .paperKey, .noPasscode, .biometrics, .shareData]

	var title: String {
		switch self {
		case .biometrics: return LAContext.biometricType() == .face ?  String(localized: "Enable Face ID") :  String(localized: "Enable Touch ID")
		case .paperKey: return String(localized: "Action Required")
		case .upgradePin: return String(localized: "Set PIN")
		case .recommendRescan: return String(localized: "Transaction Rejected")
		case .noPasscode: return String(localized: "Turn device passcode on")
		case .shareData: return String(localized: "Share Anonymous Data")
		}
	}

	var name: String {
		switch self {
		case .biometrics: return "biometricsPrompt"
		case .paperKey: return "paperKeyPrompt"
		case .upgradePin: return "upgradePinPrompt"
		case .recommendRescan: return "recommendRescanPrompt"
		case .noPasscode: return "noPasscodePrompt"
		case .shareData: return "shareDataPrompt"
		}
	}

	var body: String {
		switch self {
		case .biometrics: return LAContext.biometricType() == .face ? String(localized: "Tap here to enable Face ID")  : String(localized: "Tap here to enable Touch ID")
		case .paperKey: return String(localized: "Tap here to verify your 12 word seed phrase")
		case .upgradePin: return String(localized: "Tap here to update your PIN")
		case .recommendRescan: return String(localized: "Tap here to perform a rescan")
		case .noPasscode: return String(localized: "Tap here to turn on passcode")
		case .shareData: return String(localized: "Tap here to share analytics data anonymously")
		}
	}

	// This is the trigger that happens when the prompt is tapped
	var trigger: TriggerName? {
		switch self {
		case .biometrics: return .promptBiometrics
		case .paperKey: return .promptPaperKey
		case .upgradePin: return .promptUpgradePin
		case .recommendRescan: return .recommendRescan
		case .noPasscode: return nil
		case .shareData: return .promptShareData
		}
	}

	func shouldPrompt(walletManager: WalletManager, state: ReduxState) -> Bool {
		switch self {
		case .biometrics:
			return !UserDefaults.hasPromptedBiometrics && LAContext.canUseBiometrics && !UserDefaults.isBiometricsEnabled
		case .paperKey:
			return UserDefaults.walletRequiresBackup
		case .upgradePin:
			return walletManager.pinLength != kPinDigitConstant
		case .recommendRescan:
			return state.recommendRescan
		case .noPasscode:
			return !LAContext.isPasscodeEnabled
		case .shareData:
			return !UserDefaults.hasAquiredShareDataPermission && !UserDefaults.hasPromptedShareData
		}
	}
}
