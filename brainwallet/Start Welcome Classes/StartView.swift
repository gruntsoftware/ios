import SwiftUI
import Lottie
import FirebaseAnalytics
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
    private var fiatValue = ""

	@State
	private var animationAmount = 0.0

    @State
    private var debugLocale = ""

	@State
	private var didContinue: Bool = false

    @State
    private var isRestoringAnOldWallet: Bool = false

    init(newMainViewModel: NewMainViewModel) {
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
                        HStack {
                            Text(newMainViewModel.currentFiatValue)
                                .font(Font(UIFont.barlowLight(size: 16.0)))
                                .foregroundColor(BrainwalletColor.content)
                                .animation(.bouncy(duration: 0.5))
                                .frame(width: width * 0.9, alignment: .trailing)
                                .padding(.trailing, 16.0)
                        }
                        .padding(.top, 16.0)
                        .frame(height: 20.0)

                        Image("bw-logotype")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: width * 0.65,
                                   alignment: .center)
                            .padding([.top,.bottom], verticalPadding)

                        WelcomeLottieView(lottieFileName: lottieFileName, shouldRunAnimation: true)
                            .frame(height: height * 0.35, alignment: .center)
                            .padding(.top, verticalPadding)

                        Spacer()
                        HStack {
                            Button(action: {
                                userPrefersDarkMode.toggle()
                            }) {
                                ZStack {
                                    Image(systemName: userPrefersDarkMode ?
                                        "moon.circle" : "sun.max.circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: themeButtonSize,
                                               height: themeButtonSize,
                                               alignment: .center)
                                        .foregroundColor(BrainwalletColor.content)
                                }
                            }
                            .frame(width: width * 0.1, alignment: .center)
                            .onChange(of: userPrefersDarkMode) { preference in
                                newMainViewModel.userDidSetThemePreference(userPrefersDarkMode: preference)
                            }
                            Picker("", selection: $newMainViewModel.currentGlobalFiat) {
                                    ForEach(newMainViewModel.globalCurrencies, id: \.self) {
                                        Text("\($0.fullCurrencyName)   \($0.code) (\($0.symbol))")
                                            .font(selectorFont)
                                            .frame(maxWidth: .infinity,
                                                alignment: .center)
                                            .foregroundColor(BrainwalletColor.content)
                                    }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: width * 0.8, alignment: .center)
                            .onChange(of: newMainViewModel.currentGlobalFiat) { _ in
                                selectedFiat = true
                                newMainViewModel
                                    .userDidSetCurrencyPreference(currency:
                                        newMainViewModel.currentGlobalFiat)

                            }

						}
						.frame(width: width * 0.9,
						       height: height * 0.1,
						       alignment: .center)

                        Button(action: {
                            isRestoringAnOldWallet = false
                            path.append(.readyView)
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                    .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                    .foregroundColor(BrainwalletColor.surface)

                                Text("Ready")
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
                            isRestoringAnOldWallet = true
                            path.append(.restoreView)
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
                        RestoreView(viewModel: newMainViewModel, path: $path)
                                .navigationBarBackButtonHidden()
                    case .readyView:
                        ReadyView(viewModel: newMainViewModel, path: $path)
                                .navigationBarBackButtonHidden()
                    case .setPasscodeView(let isRestoringAnOldWallet):
                        ZStack {
                            SetPasscodeView(isRestoringAnOldWallet: isRestoringAnOldWallet, path: $path)
                                .navigationBarBackButtonHidden()
                        }
                    case .confirmPasscodeView(let isRestoringAnOldWallet, let pinDigits):
                        ZStack {
                            ConfirmPasscodeView(isRestoringAnOldWallet: isRestoringAnOldWallet, pinDigits: pinDigits, viewModel: newMainViewModel, path: $path)
                               .navigationBarBackButtonHidden()
                        }
                    case .inputWordsView:
                        ZStack {
                             InputWordsView(viewModel: newMainViewModel, path: $path)
                                .navigationBarBackButtonHidden()
                        }
                    case .yourSeedWordsView:
                        ZStack {
                            YourSeedWordsView(viewModel: newMainViewModel, path: $path)
                                                        .navigationBarBackButtonHidden()
                        }
                    case .yourSeedProveView:
                        YourSeedProveItView(viewModel: newMainViewModel, path: $path)
                            .navigationBarBackButtonHidden()
                    case .topUpView:
                        ZStack {
                            TopUpView(viewModel: newMainViewModel, path: $path)
                                .navigationBarBackButtonHidden()
                        }
                    case .topUpSetAmountView:
                        ZStack {
                            TopUpSetAmountView(viewModel: newMainViewModel, path: $path)
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
            .alert(String(localized: "Wallet Creation Error"),
                isPresented: $newMainViewModel.walletCreationDidFail,
                actions: {
                    Button( String(localized: "OK"), role: .cancel) {
                        newMainViewModel.walletCreationDidFail = false

                        Analytics.logEvent("wallet_creation_error",
                            parameters: [
                                "platform": "ios",
                                "app_version": AppVersion.string,
                                "error_message": "failed_to_create_wallet"
                            ])
                    }
                },
                message: {
                        Text(String(localized: "There was a serious error in creating your Brainwallet. Visit us at brainwallet.co to file a customer support ticket."))
            })
            .onAppear {
                Task {
                    userPrefersDarkMode = UserDefaults.userPreferredDarkTheme
                    let currentValue = newMainViewModel.currentFiatValue
                    fiatValue = String(format: String(localized: "%@ = 1Ł"), currentValue)
                    updateVersionLabel()
                }
            }

        }
    }
}

enum Onboarding: Hashable {
    case readyView
    case restoreView
    case setPasscodeView(isRestoringAnOldWallet: Bool)
    case confirmPasscodeView(isRestoringAnOldWallet: Bool, pinDigits: [Int])
    case inputWordsView
    case yourSeedWordsView
    case yourSeedProveView
    case topUpView
    case topUpSetAmountView
    case tempSettingsView
}
