import SwiftUI

struct LocaleChangeView: View {
	// MARK: - Combine Variables

	@ObservedObject
	var viewModel: LocaleChangeViewModel

	init(viewModel: LocaleChangeViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		VStack {
			Text("Locale: \(viewModel.displayName)")
				.font(Font(UIFont.barlowSemiBold(size: 18.0)))
                .foregroundColor(BrainwalletColor.content)
				.padding(.leading, 20)
				.padding(.top, 10)

			Spacer()
		}
	}
}

#Preview {
	LocaleChangeView(viewModel: LocaleChangeViewModel())
		.environment(\.locale, .init(identifier: "fr"))
}
