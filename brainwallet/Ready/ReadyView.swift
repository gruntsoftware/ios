import SwiftUI

struct ReadyView: View {

    @ObservedObject
    var viewModel: NewMainViewModel

    @Binding
    var path: [Onboarding]

    let selectorFont: Font = .barlowSemiBold(size: 16.0)
    let buttonLightFont: Font = .barlowLight(size: 16.0)
    let regularButtonFont: Font = .barlowRegular(size: 20.0)
    let largeButtonFont: Font = .barlowSemiBold(size: 24.0)
    let detailFont: Font = .barlowRegular(size: 22.0)
    let billboardFont: Font = .barlowSemiBold(size: 50.0)

    let versionFont: Font = .barlowSemiBold(size: 16.0)
    let verticalPadding: CGFloat = 20.0
    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let themeButtonSize: CGFloat = 28.0
    let themeBorderSize: CGFloat = 44.0
    let largeButtonHeight: CGFloat = 65.0

    let arrowSize: CGFloat = 40.0

    let userPrefersDarkTheme = UserDefaults.userPreferredDarkTheme

    init(viewModel: NewMainViewModel, path: Binding<[Onboarding]>) {
        self.viewModel = viewModel
        _path = path
    }
    var body: some View {

            GeometryReader { geometry in

                let width = geometry.size.width

                let readyText = String(localized:
                    "Switching devices? Lost it in a boating accident? You can restore your Brainwallet here.")

                ZStack {
                    BrainwalletColor.surface.edgesIgnoringSafeArea(.all)

                    VStack {
                        HStack {
                            Button(action: {
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
                            }
                            Spacer()
                        }
                        .padding(.all, 20.0)

                        Spacer()
                        HStack {
                            Image(systemName: "arrow.down.right")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .font(Font.system(size: 35, weight: .light))
                                .frame(width: arrowSize,
                                       alignment: .center)
                                .padding(.leading, 20.0)
                            Spacer()
                        }
                        .frame(maxHeight: .infinity, alignment: .bottomLeading)
                        .padding(.bottom, 10.0)
                        HStack {
                            VStack {
                                HStack {
                                    Text("Ready?")
                                        .font(billboardFont)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(userPrefersDarkTheme ? .white : BrainwalletColor.nearBlack)
                                }
                                .padding(.bottom, 20.0)
                                Text(readyText)
                                    .font(detailFont)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(userPrefersDarkTheme ? .white : BrainwalletColor.nearBlack)
                                    .padding(.all, 10.0)

                            }
                            Spacer()
                        }
                        .padding(.bottom, 40.0)
                        .padding(.leading, 20.0)

                        Spacer(minLength: 40.0)
                            Button(action: {
                                path.append(.setPasscodeView(isRestoringAnOldWallet: true))
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                        .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                        .foregroundColor(BrainwalletColor.grape)

                                    Text("Setup app passcode")
                                        .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                        .font(regularButtonFont)
                                        .foregroundColor(.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                                .stroke(.white, lineWidth: 1.0)
                                        )
                                }
                                .padding(.all, 8.0)
                            }
                        }
                    }
                }
            }
    }
