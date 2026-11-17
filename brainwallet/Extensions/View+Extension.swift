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


// MARK: - Translucent sheet

/// How tall a `translucentSheet` card is, mirroring the `.sheet` detents it replaces.
enum TranslucentSheetHeight {
	/// Full height below the status bar, like `.large`.
	case large
	/// Half the screen, like `.medium`.
	case medium
	/// A fixed height in points, like `.height(_:)`.
	case height(CGFloat)
}

extension View {
	/// Presents `content` as a bottom card whose translucent `background` shows the view underneath.
	func translucentSheet<Background: ShapeStyle, SheetContent: View>(
		isPresented: Binding<Bool>,
		height: TranslucentSheetHeight = .large,
		background: Background,
		showsDragIndicator: Bool = false,
		@ViewBuilder content: @escaping () -> SheetContent
	) -> some View {
		modifier(TranslucentSheetModifier(isPresented: isPresented,
		                                  height: height,
		                                  background: AnyShapeStyle(background),
		                                  showsDragIndicator: showsDragIndicator,
		                                  sheetContent: content))
	}
}

private struct TranslucentSheetModifier<SheetContent: View>: ViewModifier {
	@Binding
	var isPresented: Bool

	let height: TranslucentSheetHeight

	let background: AnyShapeStyle

	let showsDragIndicator: Bool

	let sheetContent: () -> SheetContent

	@State
	private var isCoverPresented = false

	@State
	private var isCardShown = false

	@State
	private var dragOffset: CGFloat = 0

	private let dismissDistance: CGFloat = 120.0

	private let slideAnimation: Animation = .smooth(duration: 0.3)

	func body(content: Content) -> some View {
		content
			.fullScreenCover(isPresented: $isCoverPresented) {
				GeometryReader { geometry in
					let cardHeight = resolvedHeight(in: geometry)
					let bottomInset = homeIndicatorInset(in: geometry)
					let offscreen = cardHeight + bottomInset

					ZStack(alignment: .bottom) {
						Color.black
							.opacity(isPartialHeight && isCardShown ? 0.15 : 0.001)
							.ignoresSafeArea()
							.onTapGesture { if isPartialHeight { isPresented = false } }

						card(height: cardHeight, bottomInset: bottomInset)
							.offset(y: isCardShown ? dragOffset : offscreen)
					}
					// The card runs under the home indicator like a sheet; see `card`.
					.ignoresSafeArea(.container, edges: .bottom)
				}
				.presentationBackground(.clear)
				.onAppear { withAnimation(slideAnimation) { isCardShown = true } }
			}
			.onChange(of: isPresented) { _, newValue in
				newValue ? present() : dismiss()
			}
			.onChange(of: isCoverPresented) { _, newValue in
				if !newValue {
					isCardShown = false
					if isPresented { isPresented = false }
				}
			}
			.onAppear { if isPresented { present() } }
	}

	private var isPartialHeight: Bool {
		if case .large = height { return false }
		return true
	}

	private func homeIndicatorInset(in geometry: GeometryProxy) -> CGFloat {
		let windowInset = UIApplication.shared.connectedScenes
			.compactMap { ($0 as? UIWindowScene)?.keyWindow }
			.first?.safeAreaInsets.bottom ?? geometry.safeAreaInsets.bottom
		return geometry.safeAreaInsets.bottom > windowInset + 1.0 ? 0 : geometry.safeAreaInsets.bottom
	}

	private func resolvedHeight(in geometry: GeometryProxy) -> CGFloat {
		switch height {
		case .large: return geometry.size.height - 8.0
		case .medium: return (geometry.size.height + geometry.safeAreaInsets.top) * 0.5
		case let .height(points): return min(points, geometry.size.height)
		}
	}

	private func card(height cardHeight: CGFloat, bottomInset: CGFloat) -> some View {
		let shape = UnevenRoundedRectangle(topLeadingRadius: bentoCornerRadius,
		                                   topTrailingRadius: bentoCornerRadius)
		return sheetContent()
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
			.safeAreaPadding(.bottom, bottomInset)
			.frame(height: cardHeight + bottomInset)
			.overlay(alignment: .top) {
				if showsDragIndicator {
					Capsule()
						.fill(.secondary)
						.frame(width: 36.0, height: 5.0)
						.padding(.top, 5.0)
				}
			}
			.background {
				shape.fill(background)
			}
			.clipShape(shape)
			.contentShape(shape)
			.simultaneousGesture(swipeDownToDismiss)
	}

	private var swipeDownToDismiss: some Gesture {
		DragGesture(minimumDistance: 20.0)
			.onChanged { value in
				guard value.translation.height > abs(value.translation.width) else { return }
				dragOffset = max(0, value.translation.height)
			}
			.onEnded { value in
				let flung = dragOffset > 0 && value.predictedEndTranslation.height > dismissDistance * 2.5
				if dragOffset > dismissDistance || flung {
					isPresented = false
				} else {
					withAnimation(.spring) { dragOffset = 0 }
				}
			}
	}

	private func present() {
		guard !isCoverPresented else {
			withAnimation(slideAnimation) { isCardShown = true }
			return
		}
		dragOffset = 0
		isCardShown = false
		var transaction = SwiftUI.Transaction()
		transaction.disablesAnimations = true
		withTransaction(transaction) { isCoverPresented = true }
	}

	private func dismiss() {
		guard isCoverPresented else { return }
		withAnimation(slideAnimation) {
			isCardShown = false
		} completion: {
			guard !isPresented else { return }
			var transaction = SwiftUI.Transaction()
			transaction.disablesAnimations = true
			withTransaction(transaction) { isCoverPresented = false }
			dragOffset = 0
		}
	}
}
