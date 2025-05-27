import SwiftUI

struct SeedWordContainerView: View {
	let generalPad: CGFloat = 10.0
	let largePad: CGFloat = 80.0

	let wordPad: CGFloat = 10.0

	let secureFieldHeight: CGFloat = 45.0

	let seedWordCount: Int = 12

	@State
	private var viewColumns = [GridItem]()

	@State
	private var wordViewWidthRoot = 3

	@State
	private var enteredPIN = ""

	@State
	private var shouldShowSeedWords = false

	@State
	private var didEnterPINCode = false

	@ObservedObject
	var seedViewModel = SeedViewModel(enteredPIN: .constant(""))

	var walletManager: WalletManager

	init(walletManager: WalletManager) {
		self.walletManager = walletManager
	}

	var body: some View {
		GeometryReader { geometry in

			let width = geometry.size.width
			let height = geometry.size.height
			let wordViewWidth = width / CGFloat(wordViewWidthRoot) - wordPad
			ZStack {
                
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
				VStack {
					HStack {
						Text("These are your seed words. If you show them to anyone, they can take your Litecoin")
							.font(.barlowSemiBold(size: 24.0))
							.multilineTextAlignment(.center)
                            .foregroundColor(BrainwalletColor.content)
							.padding()
					}
					.padding()
					Spacer()
					if shouldShowSeedWords {
						LazyVGrid(columns: viewColumns, spacing: 1.0) {
							ForEach(0 ..< seedWordCount, id: \.self) { increment in
								SeedWordView(seedWord: seedViewModel.seedWords[increment].word,
								             wordNumber: seedViewModel.seedWords[increment].tagNumber)
									.frame(width: wordViewWidth,
									       height: height * 0.1)
							}
						}
						Spacer()
					} else {
						HStack {
							SecureField("Enter PIN",
							            text: $enteredPIN)
								.keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
								.multilineTextAlignment(.center)
								.toolbar {
									ToolbarItemGroup(placement: .keyboard) {
										Spacer()
										Button("Done" ) {
											didEnterPINCode.toggle()
                                        }
                                        .foregroundColor(BrainwalletColor.content)
                                    }
								}
                                .frame(width: width * 0.3,
                                       height: secureFieldHeight, alignment: .center)
                                .background(BrainwalletColor.surface)
                        }
                        .frame(height: secureFieldHeight, alignment: .top)
                        .padding(.top, 32.0)
					}
					Spacer()
				}
			}
			.padding(.all, 10)
			.onAppear {
				viewColumns = [GridItem](repeating: GridItem(.flexible()),
				                         count: wordViewWidthRoot)
			}
			.onChange(of: didEnterPINCode) { _ in
				if let fetchedWords = seedViewModel.fetchWords(walletManager: self.walletManager,
				                                               appPIN: enteredPIN)
				{
					seedViewModel.seedWords = fetchedWords
					shouldShowSeedWords = true
				}
			}
		}
	}
}

