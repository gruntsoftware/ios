import SafariServices
import SwiftUI

struct CheckboxesStepView: View {
	@EnvironmentObject
	var viewModel: StartViewModel

	let paragraphFont: Font = .ibmPlexSansSemiBold(size: 22.0)
	let calloutFont: Font = .ibmPlexSansLight(size: 12.0)

	let genericPad = 5.0

	@State private var scroll = false

	var body: some View {
		GeometryReader { geometry in

			let width = geometry.size.width

			ZStack {
				CreateStepConfig
					.checkboxes
					.backgroundColor
					.edgesIgnoringSafeArea(.all)
				VStack {}
					.frame(width: width * 0.9)
			}
		}
	}
}

#Preview {
	CheckboxesStepView()
}
