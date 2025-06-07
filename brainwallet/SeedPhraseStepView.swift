import SwiftUI
import UIKit

let seedViewWidth: CGFloat = 65.0
let fieldViewHeight: CGFloat = 35.0

struct SeedPhraseStepView: View {
	@EnvironmentObject
	var viewModel: StartViewModel

	@State
	var pinDigits: String = ""

	let paragraphFont: Font = .barlowSemiBold(size: 22.0)

	let genericPad = 5.0

	private
	let pinPad = 110.0

	var columns: [GridItem] = [
		GridItem(.flexible(minimum: seedViewWidth)),
		GridItem(.flexible(minimum: seedViewWidth)),
		GridItem(.flexible(minimum: seedViewWidth)),
		GridItem(.flexible(minimum: seedViewWidth))
	]

	var body: some View {
		GeometryReader { geometry in

			let width = geometry.size.width

			ZStack {
				CreateStepConfig
					.seedPhrase
					.backgroundColor
					.edgesIgnoringSafeArea(.all)
				VStack {
					HStack {
						Text("Please write this down")
							.font(paragraphFont)
							.foregroundColor(.white)
							.frame(width: width * 0.6, alignment: .leading)
							.padding([.leading, .trailing], 20.0)

						Spacer()
					}
					.frame(width: width * 0.9)

					Spacer()
					Button(action: {
						hideKeyboard()
						delay(0.5) {
							viewModel.tappedIndex = 3
						}
					}) {
						HStack {
							Spacer()
							Image(systemName: "checkmark")
								.resizable()
								.frame(width: 30,
								       height: 30,
								       alignment: .center)
								.padding()
						}
					}
				}
			}
			.frame(width: width * 0.9)

		}.onTapGesture {
			hideKeyboard()
		}
	}
}

func hideKeyboard() {
	UIApplication
		.shared
		.sendAction(#selector(UIResponder.resignFirstResponder),
		            to: nil,
		            from: nil,
		            for: nil)
}

// #Preview {
//	SeedPhraseStepView()
//		.environmentObject(StartViewModel(store: Store(),
//		                                  walletManager:
//		                                  WalletManager(store: Store())))
// }
