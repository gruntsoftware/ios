import SwiftUI

struct LockScreenHeaderView: View {
	// MARK: - Combine Variables

	@ObservedObject
	var viewModel: LockScreenViewModel

	@State
	private var fiatValue = ""

	@State
	private var currentFiatValue = S.History.currentLitecoinValue.localize()

	init(viewModel: LockScreenViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
        BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
			.overlay(
				VStack {
					Spacer()
					Text(fiatValue)
						.font(Font(UIFont.barlowSemiBold(size: 16.0)))
                        .foregroundColor(BrainwalletColor.content)

					Text(currentFiatValue)
						.font(Font(UIFont.barlowRegular(size: 14.0)))
                        .foregroundColor(BrainwalletColor.content)
						.padding(.bottom, 10)
                    Divider().background(BrainwalletColor.gray)
				})
			.onAppear {
				Task {
					fiatValue = " 1 LTC = \(viewModel.currentValueInFiat)"
					currentFiatValue = "\(S.History.currentLitecoinValue.localize()) \(viewModel.currencyCode)"
				}
			}
			.onChange(of: viewModel.currentValueInFiat) { newValue in
				fiatValue = " 1 LTC = \(newValue)"
			}
	}
}
