import SwiftUI
import CoreHaptics

struct LockScreenView: View {

	@ObservedObject
	var viewModel: LockScreenViewModel

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

                    Image("bw-logotype")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(16.0)
                        .frame(width: width * 0.7,
                               alignment: .top)
                        .accessibilityIdentifier("brainwalletLogo")
                        .padding(.top, 10.0)
                    Spacer()

                    PINRowView(pinState: $pinState)
                        .frame(width: 180, height: 30.0)
                        .offset(x: startShake ? 7 : 0)
                        .animation(.spring(response: 0.15, dampingFraction: 0.1, blendDuration: 0.2), value: startShake)
                        .padding(.bottom, 20.0)

                    Spacer()
                    PasscodeGridView(digits: $pinDigits,
                                     userPrefersDarkMode: $userPrefersDarkMode)
                    .frame(maxWidth: width * 0.65, maxHeight: height * 0.3, alignment: .bottom)
                    .padding(.bottom, 5.0)

                    LockScreenFooterView(viewModel: viewModel,
                                         userPrefersDarkMode: $userPrefersDarkMode)
                    .frame(width: width, height: 45, alignment: .center)
                    .padding(.top, 20.0)
                    .padding(.bottom, 20.0)
                    .accessibilityIdentifier("Lock Screen Footer View")
                    HStack {
                        Text(AppVersion.string)
                            .frame(alignment: .center)
                            .modifier(BWIPSRegular(size: 11.0))
                            .foregroundColor(BrainwalletColor.content)
                            .accessibilityIdentifier("brainwalletVersion")
                        if !debugLocale.isEmpty {
                            Text("\(debugLocale)")
                                .frame(alignment: .center)
                                .modifier(BWIPSRegular(size: 11.0))
                                .foregroundColor(BrainwalletColor.chili.opacity(0.8))
                                .padding(.all, 5.0)
                        }
                    }

                    .padding(.bottom, 4.0)

                }
                .onChange(of: pinDigits) { _,_ in

                    pinState = (0..<4).map { $0 < pinDigits.count }

                    didFillPIN  = pinState.allSatisfy { $0 == true }

                    let pinString = pinDigits.map(String.init).joined()

                    if didFillPIN {
                        viewModel.pinDigits = pinDigits
                        viewModel.userSubmittedPIN?(pinString)
                    }
                }
                .onChange(of: viewModel.authenticationFailed) { _,didFailAuthentication in
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
            .onChange(of: userPrefersDarkMode) { _,preference in
                viewModel.userDidSetThemePreference(userPrefersDarkMode: preference)
            }
            .sheet(isPresented: $viewModel.shouldShowReceiveAddress) {
                    LockReceiveModalView(viewModel: viewModel,
                                         shouldShowAddressModal: $viewModel.shouldShowReceiveAddress,
                                         userPrefersDarkMode: $userPrefersDarkMode)
                    .background(BrainwalletColor.surface)
                    .cornerRadius(bentoCornerRadius)
                    .presentationDragIndicator(.hidden)
                    .presentationDetents([.height(height * 0.3)])
                    .presentationBackground(.ultraThickMaterial)
                    .ignoresSafeArea(edges: .bottom)

            }
            .onAppear {
                userPrefersDarkMode = UserDefaults.userPreferredDarkTheme
                updateVersionLabel()
            }.onDisappear {
                clearPINSettings()
            }
        }
	}
}
