import UIKit

enum MenuButtonType {
	case security
	case customerSupport
	case settings
	case lock

	var title: String {
		switch self {
		case .security:
			return "Security"
		case .customerSupport:
			return "Support"
		case .settings:
			return "Settings"
		case .lock:
			return "Lock"
		}
	}

	var image: UIImage {
		switch self {
		case .security:
			return #imageLiteral(resourceName: "Shield")
		case .customerSupport:
			return #imageLiteral(resourceName: "FaqFill")
		case .settings:
			return #imageLiteral(resourceName: "Settings")
		case .lock:
			return #imageLiteral(resourceName: "Lock")
		}
	}
}
