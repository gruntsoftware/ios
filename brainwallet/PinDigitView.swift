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
							.modifier(BWIPSSemiBold(size: 18.0))
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
