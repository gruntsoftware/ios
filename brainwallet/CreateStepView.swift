import SwiftUI

struct CreateStepView: View {
	@EnvironmentObject
	var viewModel: StartViewModel

    var backgroundColor: Color = BrainwalletColor.surface
	var createStepConfig: CreateStepConfig = .intro

	let hugeFont = Font.barlowBold(size: 30.0)

	init(createConfig: CreateStepConfig) {
		createStepConfig = createConfig
	}

	var body: some View {
		GeometryReader { _ in
			ZStack { 

				createStepConfig.backgroundColor
					.edgesIgnoringSafeArea(.all)

				VStack {
					if createStepConfig == .intro {
						IntroStepView()
							.environmentObject(viewModel)
					} else if createStepConfig == .checkboxes {
						CheckboxesStepView()
							.environmentObject(viewModel)
					} else if createStepConfig == .seedPhrase {
						SeedPhraseStepView()
							.environmentObject(viewModel)
					} else {
						FinishedStepView()
					}
				}
			}
		}
	}
}

#Preview {
	CreateStepView(createConfig: .intro)
}
