import SwiftUI
import UIKit

extension UIFont {
	static var header: UIFont {
		return UIFont(name: "BarlowSemiCondensed-Bold", size: 17.0) ?? UIFont.preferredFont(forTextStyle: .headline)
	}

	static func customBold(size: CGFloat) -> UIFont {
		return UIFont(name: "BarlowSemiCondensed-Bold", size: size) ?? UIFont.preferredFont(forTextStyle: .headline)
	}

	static func customBody(size: CGFloat) -> UIFont {
		return UIFont(name: "BarlowSemiCondensed-Regular", size: size) ?? UIFont.preferredFont(forTextStyle: .subheadline)
	}

	static func customMedium(size: CGFloat) -> UIFont {
		return UIFont(name: "IBMPlexSans-Medium", size: size) ?? UIFont.preferredFont(forTextStyle: .body)
	}

	static func ibmPlexSansBold(size: CGFloat) -> UIFont {
		return UIFont(name: "IBMPlexSans-Bold", size: size) ?? UIFont.preferredFont(forTextStyle: .body)
	}

	static func ibmPlexSansSemiBold(size: CGFloat) -> UIFont {
		return UIFont(name: "IBMPlexSans-SemiBold", size: size) ?? UIFont.preferredFont(forTextStyle: .body)
	}

	static func ibmPlexSansItalic(size: CGFloat) -> UIFont {
		return UIFont(name: "IBMPlexSans-Italic", size: size) ?? UIFont.preferredFont(forTextStyle: .body)
	}

	static func ibmPlexSansMedium(size: CGFloat) -> UIFont {
		return UIFont(name: "IBMPlexSans-Medium", size: size) ?? UIFont.preferredFont(forTextStyle: .body)
	}

	static func ibmPlexSansRegular(size: CGFloat) -> UIFont {
		return UIFont(name: "IBMPlexSans-Regular", size: size) ?? UIFont.preferredFont(forTextStyle: .body)
	}

	static func ibmPlexSansLight(size: CGFloat) -> UIFont {
		return UIFont(name: "IBMPlexSans-Light", size: size) ?? UIFont.preferredFont(forTextStyle: .body)
	}

    static func ibmPlexSansThin(size: CGFloat) -> UIFont {
        return UIFont(name: "IBMPlexSans-Thin", size: size) ?? UIFont.preferredFont(forTextStyle: .body)
    }

    static func boldenVan(size: CGFloat) -> UIFont {
        return UIFont(name: "BoldenVan", size: size) ?? UIFont.preferredFont(forTextStyle: .body)
    }

	static var regularAttributes: [NSAttributedString.Key: Any] {
		return [
			.font: UIFont.customBody(size: 14.0),
			.foregroundColor: BrainwalletUIColor.content
		]
	}

	static var boldAttributes: [NSAttributedString.Key: Any] {
		return [
			.font: UIFont.customBold(size: 14.0),
			.foregroundColor: BrainwalletUIColor.content
		]
	}
}

extension Font {
	static func ibmPlexSansSemiBold(size: CGFloat) -> Font {
		return Font.custom("IBMPlexSans-SemiBold", size: size)
	}

	static func ibmPlexSansBold(size: CGFloat) -> Font {
		return Font.custom("IBMPlexSans-Bold", size: size)
	}

	static func ibmPlexSansItalic(size: CGFloat) -> Font {
		return Font.custom("IBMPlexSans-Italic", size: size)
	}

	static func ibmPlexSansMedium(size: CGFloat) -> Font {
		return Font.custom("IBMPlexSans-Medium", size: size)
	}

	static func ibmPlexSansRegular(size: CGFloat) -> Font {
		return Font.custom("IBMPlexSans-Regular", size: size)
	}

	static func ibmPlexSansLight(size: CGFloat) -> Font {
		return Font.custom("IBMPlexSans-Light", size: size)
	}

    static func ibmPlexSansThin(size: CGFloat) -> Font {
        return Font.custom("IBMPlexSans-Thin", size: size)
    }

    static func boldenVan(size: CGFloat) -> Font {
        return Font.custom("BoldenVan", size: size)
    }
}
