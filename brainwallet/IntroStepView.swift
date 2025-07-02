import SwiftUI

struct IntroStepView: View {
	@EnvironmentObject
	var viewModel: StartViewModel

	let paragraphFont: Font = .barlowBold(size: 35.0)

	let genericPad = 5.0

	var body: some View {
		GeometryReader { geometry in

			let width = geometry.size.width

			ZStack {
				CreateStepConfig
					.intro
					.backgroundColor
					.edgesIgnoringSafeArea(.all)
				VStack {
					Text("Take the next 5 minutes to secure your Litecoin.")
						.font(paragraphFont)
						.foregroundColor(BrainwalletColor.content)
						.frame(width: width * 0.9, alignment: .leading)
						.padding([.leading, .trailing], genericPad)
						.padding([.bottom], genericPad)

					Text("Please find a private place to write down your PIN and seed phrase.")
						.font(paragraphFont)
                        .foregroundColor(BrainwalletColor.content)
						.frame(width: width * 0.9, alignment: .leading)
						.padding([.leading, .trailing], genericPad)
						.padding([.bottom], genericPad)
				}
				.frame(width: width * 0.9)
			}
		}
	}
}
