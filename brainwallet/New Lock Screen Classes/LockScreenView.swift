import SwiftUI
import CoreHaptics

struct LockScreenView: View {
    let versionFont: Font = .barlowLight(size: 15.0)

	@ObservedObject
	var viewModel: LockScreenViewModel

	@State
	private var fiatValue = ""

    @State
    private var debugLocale = ""

    @State
    private var startShake = false

    @State
    private var pinState: [Bool] = [false,false,false,false]

    @State
    private var pinDigits: [Int] = []

    @State
    private var didFillPIN: Bool = false

    @State
    private var userPrefersDarkMode: Bool = true

	init(viewModel: LockScreenViewModel) {
		self.viewModel = viewModel
    }

    func updateVersionLabel() {
        // Get current locale
        let currentLocale = Locale.current
         // Print locale identifier in native language
        if let localeIdentifier = currentLocale.identifier as String? {
            #if targetEnvironment(simulator)
            let nativeLocaleName = currentLocale.localizedString(forIdentifier: localeIdentifier)
            let nativeLocaleString = nativeLocaleName?.capitalized ?? localeIdentifier
            debugLocale = "| " + nativeLocaleString
            #endif
        }
    }

    func clearPINSettings() {
        /// Resetting for another attempt
        self.pinDigits = []
        self.pinState = [false,false,false,false]
        viewModel.authenticationFailed = false
        viewModel.pinDigits = []
    }

	var body: some View {

        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)

                VStack {
                    HStack {
                        Text(fiatValue)
                            .font(Font(UIFont.barlowLight(size: 16.0)))
                            .foregroundColor(BrainwalletColor.content)
                            .frame(width: width * 0.9, alignment: .trailing)
                            .padding(.trailing, 16.0)
                    }
                    .padding(.top, 16.0)

                    Image("bw-logotype")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: width * 0.65)
                        .padding(.top, 25.0)
                        .padding(4.0)

                    Spacer()
                        .frame(minHeight: height * 0.02)
                    PINRowView(pinState: $pinState)
                        .frame(width: 180, height: 30.0)
                        .offset(x: startShake ? 7 : 0)
                        .animation(.spring(response: 0.15, dampingFraction: 0.1, blendDuration: 0.2), value: startShake)

                    Spacer()
                        .frame(minHeight: height * 0.02)
                    PasscodeGridView(digits: $pinDigits)
                        .frame(maxWidth: width * 0.65, maxHeight: height * 0.4, alignment: .center)
                        .padding(.bottom, 5.0)

                    LockScreenFooterView(viewModel: viewModel,
                                         userPrefersDarkMode: $userPrefersDarkMode)
                        .frame(width: width, height: 45, alignment: .center)
                        .padding(.top, 20.0)
                        .padding(.bottom, 20.0)

                    Spacer()
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
                    .frame(height: 22.0, alignment: .center)

                }
                .onChange(of: viewModel.currentFiatValue) { newValue in
                    fiatValue = String(format: String(localized: "%@ = 1Ł"), newValue)
                }
                .onChange(of: pinDigits) { _ in

                    pinState = (0..<4).map { $0 < pinDigits.count }

                    didFillPIN  = pinState.allSatisfy { $0 == true }

                    let pinString = pinDigits.map(String.init).joined()

                    if didFillPIN {
                        viewModel.pinDigits = pinDigits
                        viewModel.userSubmittedPIN?(pinString)
                    }
                }
                .onChange(of: viewModel.authenticationFailed) { didFailAuthentication in
                    if didFailAuthentication {
                        startShake.toggle()
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.error)

                        delay(0.4) {
                            clearPINSettings()
                            startShake.toggle()
                        }
                    }
                }

            }
            .background(BrainwalletColor.surface)
            .onChange(of: userPrefersDarkMode) { preference in
                viewModel.userDidSetThemePreference(userPrefersDarkMode: preference)
            }
            .onAppear {
                userPrefersDarkMode = UserDefaults.userPreferredDarkTheme
                fiatValue = String(format: String(localized: "%@ = 1Ł"), viewModel.currentFiatValue)
                updateVersionLabel()
            }.onDisappear {
                clearPINSettings()
            }
        }
	}
}
