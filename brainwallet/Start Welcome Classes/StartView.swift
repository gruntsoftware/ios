import SwiftUI
import Lottie

struct StartView: View {
    let selectorFont: Font = .barlowSemiBold(size: 16.0)
    let buttonLightFont: Font = .barlowLight(size: 16.0)
    let regularButtonFont: Font = .barlowRegular(size: 24.0)
    let largeButtonFont: Font = .barlowBold(size: 24.0)

    let versionFont: Font = .barlowSemiBold(size: 16.0)
    let verticalPadding: CGFloat = 20.0
    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let themeButtonSize: CGFloat = 32.0
    let themeBorderSize: CGFloat = 44.0
    let largeButtonHeight: CGFloat = 60.0
    let lottieFileName: String = "welcomeemoji20250212.json"

    @State
    private var isShowingOnboardView: Bool = true

	@ObservedObject
	var startViewModel: StartViewModel

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @State
    private var path: [Onboarding] = []

	@State
	private var selectedLang: Bool = false

    @State
    private var selectedFiat: Bool = false

	@State
	private var delayedSelect: Bool = false

    @State
    private var userPrefersDarkMode: Bool = true

	@State
	private var currentTagline = ""

	@State
	private var animationAmount = 0.0

    @State
    private var debugLocale = ""

    @State
    private var pickedCurrency: GlobalCurrency = .USD

	@State
	private var didContinue: Bool = false

    init(startViewModel: StartViewModel, newMainViewModel: NewMainViewModel) {
        self.startViewModel = startViewModel
        self.newMainViewModel = newMainViewModel
	}

    func updateVersionLabel() {
        // Get current locale
        let currentLocale = Locale.current
         // Print locale identifier in native language
        if let localeIdentifier = currentLocale.identifier as String? {
            #if DEBUG || targetEnvironment(simulator)
            let nativeLocaleName = currentLocale.localizedString(forIdentifier: localeIdentifier)
            let nativeLocaleString = nativeLocaleName?.capitalized ?? localeIdentifier
            debugLocale = "| " + nativeLocaleString
            #endif
        }
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height
            NavigationStack(path: $path) {
                ZStack {
                    BrainwalletColor.surface.edgesIgnoringSafeArea(.all)

                    VStack {
                        Group {
                            Image("bw-logotype")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: width * 0.65,
                                       alignment: .center)
                                .padding([.top,.bottom], verticalPadding)

                            WelcomeLottieView(lottieFileName: lottieFileName, shouldRunAnimation: true)
                                .frame(height: height * 0.35, alignment: .center)
                                .padding(.top, verticalPadding)
                        }

                        Spacer()
                        HStack {
                            ZStack {
                                Group {
                                    HStack {
                                        Button(action: {
                                            userPrefersDarkMode.toggle()
                                        }) {
                                            ZStack {
                                                Image(systemName: userPrefersDarkMode ?
                                                    "moon.circle" : "sun.max.circle")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: themeBorderSize,
                                                           height: themeBorderSize,
                                                           alignment: .center)
                                                    .foregroundColor(BrainwalletColor.content)
                                            }
                                        }
                                        .frame(width: width * 0.1)
                                        .onChange(of: userPrefersDarkMode) { preference in
                                            startViewModel.userDidSetThemePreference(userPrefersDarkMode: preference)
                                        }

                                        Picker("", selection: $pickedCurrency) {
                                            ForEach(startViewModel.globalCurrencies, id: \.self) {
                                                Text("\($0.fullCurrencyName)   \($0.code) (\($0.symbol))")
                                                    .font(selectorFont)
                                                    .foregroundColor(BrainwalletColor.content)
                                            }

                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: width * 0.6)
                                        .onChange(of: pickedCurrency) { _ in
                                            selectedFiat = true
                                        }.padding(.trailing, width * 0.1)
                                    }
                                }
                            }
						}
						.frame(width: width * 0.9,
						       height: height * 0.1,
						       alignment: .center)

                        Button(action: {
                                 startViewModel.didTapCreate!()
                                // path.append(.inputWordsView)
                                // path.append(.readyView)
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                    .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                    .foregroundColor(BrainwalletColor.surface)

                                Text( "Ready" )
                                    .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                    .font(largeButtonFont)
                                    .foregroundColor(BrainwalletColor.content)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                            .stroke(BrainwalletColor.content, lineWidth: 2.0)
                                    )
                            }
                            .padding(.all, 8.0)
                        }

                        Button(action: {
                                 startViewModel.didTapRecover!()
                                // path.append(.restoreView)
                                // path.append(.yourSeedWordsView)
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                    .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                    .foregroundColor(BrainwalletColor.surface)

                                Text("Restore")
                                    .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                    .font(regularButtonFont)
                                    .foregroundColor(BrainwalletColor.content)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                            .stroke(BrainwalletColor.content, lineWidth: 1.0)
                                    )
                            }
                            .padding(.all, 8.0)
                        }
                        HStack {
                            Text(AppVersion.string)
                                .frame(alignment: .center)
                                .font(versionFont)
                                .foregroundColor(BrainwalletColor.content)
                                .padding(.all, 5.0)
                            if !debugLocale.isEmpty {
                                Text("\(debugLocale)")
                                    .frame(alignment: .center)
                                    .font(versionFont)
                                    .foregroundColor(BrainwalletColor.chili.opacity(0.8))
                                    .padding(.all, 5.0)
                            }
                        }
                    }
                }
                .padding(.all, swiftUICellPadding)
                .scrollContentBackground(.hidden)
                .background(BrainwalletColor.surface)
                .navigationDestination(for: Onboarding.self) { onboard in
                    switch onboard {
                    case .restoreView:
                        ReadyRestoreView(isRestore: true, viewModel: startViewModel, path: $path)
                                .navigationBarBackButtonHidden()
                    case .readyView:
                        ReadyRestoreView(isRestore: false, viewModel: startViewModel, path: $path)
                                .navigationBarBackButtonHidden()
                    case .setPasscodeView:
                        ZStack {
                           SetPasscodeView(path: $path)
                                .navigationBarBackButtonHidden()
                        }
                    case .confirmPasscodeView(let pinDigits):
                        ZStack {
                            ConfirmPasscodeView(pinDigits: pinDigits, viewModel: startViewModel, path: $path)
                               .navigationBarBackButtonHidden()
                        }
                    case .inputWordsView:
                        ZStack {
                             InputWordsView(viewModel: startViewModel, path: $path)
                                .navigationBarBackButtonHidden()
                        }
                    case .yourSeedWordsView:
                        ZStack {
                            YourSeedWordsView(viewModel: startViewModel, path: $path)
                                                        .navigationBarBackButtonHidden()
                        }
                    case .yourSeedProveView:
                        YourSeedProveItView(viewModel: startViewModel, path: $path)
                            .navigationBarBackButtonHidden()
                    case .topUpView:
                        ZStack {
                            TopUpView(viewModel: startViewModel, path: $path)
                                .navigationBarBackButtonHidden()
                        }
                    case .topUpSetAmountView:
                        ZStack {
                            TopUpSetAmountView(viewModel: startViewModel, path: $path)
                                .navigationBarBackButtonHidden()
                        }
                    case .tempSettingsView:
                        ZStack {
                            SettingsView(viewModel: newMainViewModel, path: $path)
                                .navigationBarBackButtonHidden()
                        }
                    }
                }
            }
            .alert( "Error" ,
                   isPresented: $startViewModel.walletCreationDidFail,
                   actions: {
                HStack {
                    Button("Ok" , role: .cancel) {
                        startViewModel.walletCreationDidFail = false
                    }
                }
            })
            .onAppear {
                Task {
                    userPrefersDarkMode = UserDefaults.userPrefersDarkTheme
                    updateVersionLabel()
                }
            }

        }
    }
}

enum Onboarding: Hashable {
    case readyView
    case restoreView
    case setPasscodeView
    case confirmPasscodeView(pinDigits: [Int])
    case inputWordsView
    case yourSeedWordsView
    case yourSeedProveView
    case topUpView
    case topUpSetAmountView
    case tempSettingsView
}
