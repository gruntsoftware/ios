import SwiftUI
struct ConfirmPasscodeView: View {

    @ObservedObject
    var viewModel: NewMainViewModel

    @Binding
    var path: [Onboarding]

    @State
    private var startShake = false

    private let pinDigits: [Int]

    @State
    private var confirmPinDigits: [Int] = []

    private let isRestoringAnOldWallet: Bool

    @State
    var pinState: [Bool] = [false,false,false,false]

    @State
    private var didConfirmPasscode: Bool = false

    let subTitleFont: Font = .barlowSemiBold(size: 32.0)
    let largeButtonFont: Font = .barlowBold(size: 24.0)
    let detailFont: Font = .barlowRegular(size: 22.0)

    let verticalPadding: CGFloat = 20.0
    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let themeButtonSize: CGFloat = 28.0
    let themeBorderSize: CGFloat = 44.0
    let largeButtonHeight: CGFloat = 65.0

    let arrowSize: CGFloat = 60.0
    let userPrefersDarkTheme = UserDefaults.userPreferredDarkTheme

    init(isRestoringAnOldWallet: Bool, pinDigits: [Int],
         viewModel: NewMainViewModel, path: Binding<[Onboarding]>) {
        self.pinDigits = pinDigits
        self.isRestoringAnOldWallet = isRestoringAnOldWallet
        self.viewModel = viewModel
        _path = path
    }

    var body: some View {

            GeometryReader { geometry in

                let width = geometry.size.width
                let height = geometry.size.height

                ZStack {
                    BrainwalletColor.surface.edgesIgnoringSafeArea(.all)

                    VStack {
                        HStack {
                                Button(action: {
                                    confirmPinDigits = []
                                    pinState = [false,false,false,false]
                                    path.removeLast()
                                }) {
                                    HStack {
                                    Image(systemName: "arrow.backward")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: squareImageSize,
                                               height: squareImageSize,
                                               alignment: .center)
                                        .foregroundColor(userPrefersDarkTheme ? .white : BrainwalletColor.nearBlack)
                                    Spacer()
                                }
                            }.frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(height: squareImageSize)
                        .padding(.all, 20.0)

                            Text( "Confirm passcode" )
                                .font(subTitleFont)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(userPrefersDarkTheme ? .white : BrainwalletColor.nearBlack)
                            Text( "You didn’t forget did you? Ok! Just go back to start over.")
                                .font(detailFont)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(userPrefersDarkTheme ? .white : BrainwalletColor.nearBlack)
                                .padding(.all, 20.0)

                        PINRowView(pinState: $pinState)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(height: 40.0)
                            .padding(.top, 40.0)
                            .offset(x: startShake ? 7 : 0)
                            .animation(.spring(response: 0.15, dampingFraction: 0.1, blendDuration: 0.2), value: startShake)

                        Spacer()
                        PasscodeGridView(digits: $confirmPinDigits)
                            .frame(width: width * 0.6,
                                   height: height * 0.35,
                                   alignment: .center)
                                .padding(.bottom, 80.0)
                        }
                }
                .onChange(of: confirmPinDigits) { _ in

                    pinState = (0..<4).map { $0 < confirmPinDigits.count }
                    let currentPinState = pinState.allSatisfy { $0 == true }
                    let pinDoesMatch = confirmPinDigits == self.pinDigits
                    didConfirmPasscode  = currentPinState && pinDoesMatch
                    viewModel.pinDigits = self.pinDigits

                    let store = viewModel.store

                    /// Pin digits filled
                    if confirmPinDigits.count == kPinDigitConstant {
                        /// Confirmed the Passcode
                        if didConfirmPasscode {
                            /// Set the PIN/Passcode into UserDefaults
                            viewModel.pinDigits = self.pinDigits
                            _ = viewModel.setPinPasscode(newPasscode:
                                pinDigits.map { String($0) }.joined())

                            store?.perform(action: SimpleReduxAlert.Show(.pinSet(callback: {
                            })))

                            if isRestoringAnOldWallet {
                               path.append(.yourSeedWordsView)
                            } else {
                               path.append(.inputWordsView)
                            }
                        } else {
                            startShake.toggle()
                            delay(0.4) {
                                startShake.toggle()
                                confirmPinDigits = []
                                pinState = [false,false,false,false]
                            }
                        }
                    }
                }
                .onChange(of: viewModel.walletCreationDidFail) { newValue in
                    /// Returns user to the StartView if there is a failure
                    if newValue {
                        path.removeAll(keepingCapacity: false)
                    }
                }
                .onAppear {
                    confirmPinDigits = []
                    pinState = [false,false,false,false]
                }
            }
    }
}
