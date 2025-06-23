import SwiftUI
struct ConfirmPasscodeView: View {

    @ObservedObject
    var viewModel: StartViewModel

    @Binding
    var path: [Onboarding]

    private let pinDigits: [Int]

    @State
    private var confirmPinDigits: [Int] = []

    private let isRestore: Bool?

    @State
    var pinState: [Bool] = [false,false,false,false]

    @State
    private var didConfirmPIN: Bool = false

    let subTitleFont: Font = .barlowSemiBold(size: 32.0)
    let largeButtonFont: Font = .barlowBold(size: 24.0)
    let detailFont: Font = .barlowRegular(size: 26.0)

    let verticalPadding: CGFloat = 20.0
    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let themeButtonSize: CGFloat = 28.0
    let themeBorderSize: CGFloat = 44.0
    let largeButtonHeight: CGFloat = 65.0

    let arrowSize: CGFloat = 60.0

    init(pinDigits: [Int], viewModel: StartViewModel, path: Binding<[Onboarding]>) {
        self.viewModel = viewModel
        _path = path

        self.pinDigits = pinDigits
        isRestore = true
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

                                        .foregroundColor(BrainwalletColor.content)
                                    Spacer()
                                }
                            }.frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(height: squareImageSize)
                        .padding(.all, 20.0)

                            Text( "Confirm" )
                                .font(subTitleFont)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(BrainwalletColor.content)
                            Text( "You didn’t forget did you? Enter it again. Or, go back to start over.")
                                .font(detailFont)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(BrainwalletColor.content)
                                .padding(.all, 20.0)

                        PINRowView(pinState: $pinState)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .frame(height: 40.0)
                                .padding(.top, 40.0)

                        Spacer()
                        PasscodeGridView(digits: $confirmPinDigits)
                            .frame(maxWidth: width * 0.65, maxHeight: height * 0.4, alignment: .center)
                            .padding(.bottom, 80.0)
                        }
                }
                .onChange(of: confirmPinDigits) { _ in

                    pinState = (0..<4).map { $0 < confirmPinDigits.count }
                    let currentPinState = pinState.allSatisfy { $0 == true }
                    let pinDoesMatch = confirmPinDigits == self.pinDigits
                    didConfirmPIN  = currentPinState && pinDoesMatch

                    if didConfirmPIN {

                        switch isRestore {
                        case true :
                                path.append(.inputWordsView)
                        case false :
                                path.append(.yourSeedWordsView)
                        case nil :
                                path.append(.tempSettingsView)
                        case .some:
                                    path.append(.tempSettingsView)
                        }
                    }
                }
            }
    }
}
