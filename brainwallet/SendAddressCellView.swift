import SwiftUI

struct SendAddressCellView: View {
	// MARK: - Combine Variables

	@ObservedObject
	var viewModel = SendAddressCellViewModel()

	@State
	private var didStartEditing: Bool = false

	let actionButtonWidth: CGFloat = 45.0
	let textFieldHeight: CGFloat = 45.0

	var body: some View {
		GeometryReader { _ in
			ZStack {
				VStack {
					Spacer()

					/// Send Address Field
					HStack {
						VStack {
							AddressFieldView(placeholder: "Enter LTC Address" ,
							                 text: $viewModel.addressString)
								.onTapGesture {
									didStartEditing = true
								}
								.frame(height: textFieldHeight, alignment: .leading)
						}
						.padding(.leading, swiftUICellPadding)

						Spacer()

						/// Paste Address button
						Button(action: {
							viewModel.shouldPasteAddress?()
						}) {
							HStack {
								ZStack {
									RoundedRectangle(cornerRadius: 4)
										.frame(width: actionButtonWidth, height: 30,
										       alignment: .center)
                                        .foregroundColor(BrainwalletColor.content)
                                        .shadow(color: BrainwalletColor.surface, radius: 3, x: 0, y: 4)
										.padding(.trailing, 3.0)

									Text("Paste")
										.frame(width: actionButtonWidth, height: 30, alignment: .center)
										.font(Font(UIFont.customMedium(size: 15.0)))
                                        .foregroundColor(BrainwalletColor.background)
										.overlay(
											RoundedRectangle(cornerRadius: 4)
                                                .stroke(BrainwalletColor.border)
										)
										.padding(.trailing, 3.0)
								}
							}
						}

						/// Scan Address
						Button(action: {
							viewModel.shouldScanAddress?()
						}) {
							HStack {
								ZStack {
									RoundedRectangle(cornerRadius: 4)
										.frame(width: actionButtonWidth, height: 30, alignment: .center)
										.foregroundColor(BrainwalletColor.background)
                                        .shadow(color: BrainwalletColor.border,
										        radius: 3,
										        x: 0, y: 4)
										.padding(.trailing, 8.0)

									Text("Scan")
										.frame(width: actionButtonWidth, height: 30, alignment: .center)
										.font(Font(UIFont.customMedium(size: 15.0)))
										.foregroundColor(BrainwalletColor.background)
										.overlay(
											RoundedRectangle(cornerRadius: 4)
												.stroke(BrainwalletColor.border)
										)
										.padding(.trailing, 8.0)
								}
							}
						}
					}
					.background(
                        BrainwalletColor.background.clipShape(RoundedRectangle(cornerRadius: 8.0))
					)
					.padding([.leading, .trailing], swiftUICellPadding)

					Spacer()
				}
			}
            .background(BrainwalletColor.surface)
		}
	}
}

#Preview {
	SendAddressCellView(viewModel: SendAddressCellViewModel())
}
