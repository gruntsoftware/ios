import SwiftUI

struct RecoverWalletView: View {
	@EnvironmentObject
	var viewModel: StartViewModel

	init() {}

	var body: some View {
		GeometryReader { _ in
			ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
				VStack {
					Text("Recover")
				}
			}
		}
	}
}

#Preview {
	RecoverWalletView()
}
