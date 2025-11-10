import SwiftUI

struct SendButtonView: View {
	// MARK: - Public Variables

	var doSendTransaction: (() -> Void)?

	var body: some View {
		GeometryReader { geometry in
			ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)

				VStack {
					Spacer()
					Button(action: {
						doSendTransaction?()
					}) {
						HStack {
							ZStack {
								RoundedRectangle(cornerRadius: 4)
									.frame(width: geometry.size.width * 0.9, height: 45, alignment: .center)
                                    .foregroundColor(BrainwalletColor.surface)
                                    .shadow(color: BrainwalletColor.nearBlack, radius: 3, x: 0, y: 4)

								Text("Send")
									.frame(width: geometry.size.width * 0.9, height: 45, alignment: .center)
									.font(Font(UIFont.customMedium(size: 18.0)))
									.foregroundColor(BrainwalletColor.content)
									.overlay(
										RoundedRectangle(cornerRadius: 8)
                                            .stroke(BrainwalletColor.background)
									)
							}
						}
					}
					.padding(.all, 8.0)
					Spacer()
				}
			}
		}
	}
}

struct SendButtonView_Previews: PreviewProvider {
	static var previews: some View {
		SendButtonView()
	}
}
