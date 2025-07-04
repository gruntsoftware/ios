import Foundation
import SwiftUI

struct PinDigit: Identifiable, Hashable {
	let id = UUID()
	let digit: String
}

struct PinDigitView: View {
	let pinDigit: PinDigit

	var body: some View {
		GeometryReader { _ in

			ZStack {
				VStack {
					ZStack {
						RoundedRectangle(cornerRadius: bigButtonCornerRadius)
							.frame(height: 45, alignment: .center)
							.foregroundColor(.red)
							.shadow(radius: 3, x: 3.0, y: 3.0)

						Text(pinDigit.digit)
							.frame(height: 45, alignment: .center)
							.font(.barlowSemiBold(size: 18.0))
							.foregroundColor(.black)
					}
				}
			}
		}
	}
}

#Preview {
	PinDigitView(pinDigit: PinDigit(digit: "0"))
}

/// Inspired by https://stackoverflow.com/questions/72926965/creating-an-ios-passcode-view-with-swiftui-how-to-hide-a-textview

struct PasscodeView: View {
	@EnvironmentObject
	var viewModel: StartViewModel
	@Environment(\.dismiss) var dismiss

	private let maxDigits: Int = 4
	private let userPasscode = "0000"

	@State var enteredPasscode: String = ""
	@FocusState var keyboardFocused: Bool

	public var body: some View {
		ZStack {
			HStack {
				ForEach(0 ..< maxDigits, id: \.self) { _ in
					ZStack {
						Image(systemName: "circle")
					}
				}
			}
			HStack {
				TextField("", text: $enteredPasscode)
					.opacity(1.0)
					.keyboardType(.decimalPad)
					.focused($keyboardFocused)
					.onAppear {
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
							keyboardFocused = true
						}
					}
			}
		}
		.padding()
		.onChange(of: enteredPasscode) { _ in

		}
	}
}

struct StaticPasscodeView: View {

    public var body: some View {
        ZStack {
            HStack {
                ForEach(0 ..< kPinDigitConstant, id: \.self) { _ in
                    Image(systemName: "circle.fill")
                        .padding(1.0)
                }
            }
        }
    }
}
