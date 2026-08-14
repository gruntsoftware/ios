import Foundation
import SwiftUI

extension View {
	/// From Stack Overflow
	/// https://stackoverflow.com/questions/56760335/round-specific-corners-swiftui

	/// Switchable View corners
	/// - Parameters:
	///   - radius: CGFloat
	///   - corners: topleft, topright, bottomleft, bottomright
	/// - Returns: RoundedCornersView
	func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
		clipShape(RoundedCorner(radius: radius, corners: corners))
	}

	/// Added View Border
	/// - Parameters:
	///   - content: the VIew
	///   - width: CGFloat
	///   - cornerRadius: CGFloat
	/// - Returns: ShapeStyle
	public func addBorder<S>(_ content: S,
	                         width: CGFloat = 1,
	                         cornerRadius: CGFloat) -> some View where S: ShapeStyle {
		let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
		return clipShape(roundedRect)
			.overlay(roundedRect.strokeBorder(content, lineWidth: width))
	}
}

/// Helper struct for the custom Rounded Rect corners
struct RoundedCorner: Shape {
	var radius: CGFloat = .infinity
	var corners: UIRectCorner = .allCorners

	func path(in rect: CGRect) -> Path {
		let path = UIBezierPath(roundedRect: rect,
		                        byRoundingCorners: corners,
		                        cornerRadii: CGSize(width: radius,
		                                            height: radius))
		return Path(path.cgPath)
	}
}

