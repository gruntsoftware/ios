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
		return UIFont(name: "BarlowSemiCondensed-Medium", size: size) ?? UIFont.preferredFont(forTextStyle: .body)
	}

	static func ibmPlexSansBold(size: CGFloat) -> UIFont {
		return UIFont(name: "BarlowSemiCondensed-Bold", size: size) ?? UIFont.preferredFont(forTextStyle: .body)
	}

	static func ibmPlexSansSemiBold(size: CGFloat) -> UIFont {
		return UIFont(name: "BarlowSemiCondensed-SemiBold", size: size) ?? UIFont.preferredFont(forTextStyle: .body)
	}

	static func ibmPlexSansItalic(size: CGFloat) -> UIFont {
		return UIFont(name: "BarlowSemiCondensed-Italic", size: size) ?? UIFont.preferredFont(forTextStyle: .body)
	}

	static func ibmPlexSansMedium(size: CGFloat) -> UIFont {
		return UIFont(name: "BarlowSemiCondensed-Medium", size: size) ?? UIFont.preferredFont(forTextStyle: .body)
	}

	static func ibmPlexSansRegular(size: CGFloat) -> UIFont {
		return UIFont(name: "BarlowSemiCondensed-Regular", size: size) ?? UIFont.preferredFont(forTextStyle: .body)
	}

	static func ibmPlexSansLight(size: CGFloat) -> UIFont {
		return UIFont(name: "BarlowSemiCondensed-Light", size: size) ?? UIFont.preferredFont(forTextStyle: .body)
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
		return Font.custom("BarlowSemiCondensed-SemiBold", size: size)
	}

	static func ibmPlexSansBold(size: CGFloat) -> Font {
		return Font.custom("BarlowSemiCondensed-Bold", size: size)
	}

	static func ibmPlexSansItalic(size: CGFloat) -> Font {
		return Font.custom("BarlowSemiCondensed-Italic", size: size)
	}

	static func ibmPlexSansMedium(size: CGFloat) -> Font {
		return Font.custom("BarlowSemiCondensed-Medium", size: size)
	}

	static func ibmPlexSansRegular(size: CGFloat) -> Font {
		return Font.custom("BarlowSemiCondensed-Regular", size: size)
	}

	static func ibmPlexSansLight(size: CGFloat) -> Font {
		return Font.custom("BarlowSemiCondensed-Light", size: size)
	}
    
    static func ibmPlexSansThin(size: CGFloat) -> Font {
        return Font.custom("BarlowSemiCondensed-Thin", size: size)
    }
}
