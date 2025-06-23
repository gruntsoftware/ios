import UIKit

enum MenuButtonType {
	case security
	case customerSupport
	case settings
	case lock

	var title: String {
		switch self {
		case .security:
			return  String(localized: "Security")
		case .customerSupport:
			return  String(localized: "Support")
		case .settings:
			return  String(localized: "Settings")
		case .lock:
			return  String(localized: "Lock")
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
