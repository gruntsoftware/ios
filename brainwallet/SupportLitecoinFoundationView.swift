import Foundation
import SwiftUI
import WebKit

/// This cell is under the amount view and above the Memo view in the Send VC
struct SupportLitecoinFoundationView: View {
	// MARK: - Combine Variables

	@ObservedObject
	var viewModel: SupportLitecoinFoundationViewModel

	// MARK: - Public
//
//	var supportSafariView = SupportSafariView(url: FoundationSupport.url,
//	                                          viewModel: SupportSafariViewModel())

	init(viewModel: SupportLitecoinFoundationViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		VStack {
			Spacer(minLength: 40)

//			supportSafariView
//				.frame(height: 300,
//				       alignment: .center)
//				.padding([.bottom, .top], 10)

			// Copy the LF Address and paste into the SendViewController
			Button(action: {
//				UIPasteboard.general.string = FoundationSupport.supportLTCAddress
//				self.viewModel.didTapToDismiss?()
			}) {
                Text(S.URLHandling.copy.localize())
					.font(Font(UIFont.customMedium(size: 16.0)))
					.padding()
					.frame(maxWidth: .infinity)
                    .foregroundColor(BrainwalletColor.content)
                    .background(BrainwalletColor.surface)
					.cornerRadius(4.0)
			}
			.padding([.leading, .trailing], 40)
			.padding(.bottom, 10)

			// Cancel
			Button(action: {
				self.viewModel.didTapToDismiss?()
			}) {
				Text(S.Button.cancel.localize())
					.font(Font(UIFont.customMedium(size: 16.0)))
					.padding()
					.frame(maxWidth: .infinity)
                    .foregroundColor(BrainwalletColor.content)
                    .background(BrainwalletColor.surface)
					.cornerRadius(4.0)
					.overlay(
						RoundedRectangle(cornerRadius: 4)
                            .stroke(BrainwalletColor.border)
					)
			}
			.padding([.leading, .trailing], 40)

			Spacer(minLength: 100)
		}
	}
}

struct SupportLitecoinFoundationView_Previews: PreviewProvider {
	static let viewModel = SupportLitecoinFoundationViewModel()

	static var previews: some View {
		Group {
			SupportLitecoinFoundationView(viewModel: viewModel)
				.previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
				.previewDisplayName("iPhone 12 Pro Max")

			SupportLitecoinFoundationView(viewModel: viewModel)
				.previewDevice(PreviewDevice(rawValue: "iPhone SE"))
				.previewDisplayName("iPhone SE")
		}
	}
}
