import SwiftUI
import UIKit
import Lottie
//
//enum OnboardingPath (
//    
//)

struct StartView: View {
    let selectorFont: Font = .barlowSemiBold(size: 16.0)
    let buttonLightFont: Font = .barlowLight(size: 16.0)
    let regularButtonFont: Font = .barlowRegular(size: 24.0)
    let largeButtonFont: Font = .barlowBold(size: 24.0)

    let versionFont: Font = .barlowSemiBold(size: 16.0)
    let verticalPadding: CGFloat = 20.0

	let squareButtonSize: CGFloat = 55.0
	let squareImageSize: CGFloat = 25.0
    let lightButtonWidth: CGFloat = 40.0
    let largeButtonHeight: CGFloat = 65.0
    let lottieFileName: String = "welcomeemoji20250212.json"

    @State
    private var path: [any View] = []

	@ObservedObject
	var startViewModel: StartViewModel

	@State
	private var selectedLang: Bool = false
    
    @State
    private var selectedFiat: Bool = false

	@State
	private var delayedSelect: Bool = false

	@State
	private var currentTagline = ""

	@State
	private var animationAmount = 0.0

	@State
	private var pickedLanguage: LanguageSelection = .English
    
    @State
    private var pickedCurrency: CurrencySelection = .USD

	@State
	private var didContinue: Bool = false

	init(viewModel: StartViewModel) {
		startViewModel = viewModel
	}

	var body: some View {
		GeometryReader { geometry in

			let width = geometry.size.width
			let height = geometry.size.height
            
			NavigationView {
				ZStack {
                    Color.midnight.edgesIgnoringSafeArea(.all)
					VStack {
                        
                        Group {
                            Image("bw-logotype-white")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: width * 0.8,
                                       alignment: .center)
                                .padding([.top,.bottom], verticalPadding)
                            
                            WelcomeLottieView(lottieFileName: lottieFileName,
                                              shouldRunAnimation: true)
                            .frame(width: width * 0.9,
                                   height: height * 0.45,
                                   alignment: .center)
                        }
						HStack {
                            ZStack {
                                Group {
                                    HStack {
                                        Picker("", selection: $pickedLanguage) {
                                            ForEach(startViewModel.languages, id: \.self) {
                                                Text($0.nativeName)
                                                    .font(selectorFont)
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: width * 0.4)
                                        .onChange(of: $pickedLanguage.wrappedValue) { _ in
                                            startViewModel.currentLanguage = pickedLanguage
                                            selectedLang = true
                                            currentTagline = startViewModel.taglines[startViewModel.currentLanguage.rawValue]
                                            startViewModel.speakLanguage()
                                            delay(1.2) {
                                                delayedSelect = true
                                            }
                                        }
                                        
                                        Button(action: {
                                            
                                            startViewModel.userPrefersDarkMode.toggle()
                                            //TODO: Switch appearance reference
                                        }) {
                                            ZStack {
                                                Image(systemName: startViewModel.userPrefersDarkMode ? "moon" : "rays")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: lightButtonWidth,
                                                           height: lightButtonWidth,
                                                           alignment: .center)
                                                    .foregroundColor(startViewModel.userPrefersDarkMode ? Color.midnight : Color.cheddar)
                                            }
                                        }
                                        .frame(width: width * 0.15)
                                        
                                        Picker("", selection: $pickedCurrency) {
                                            ForEach(startViewModel.currencies, id: \.self) {
                                                Text($0.fullCurrencyName)
                                                    .font(selectorFont)
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: width * 0.4)
                                        .onChange(of: $pickedCurrency.wrappedValue) { _ in
                                            startViewModel.currentFiat = pickedCurrency
                                            selectedFiat = true
                                        }
                                    }
                                }
                            }
						}
						.frame(width: width * 0.9,
						       height: height * 0.1,
						       alignment: .center)
						.alert(startViewModel
							.alertMessage[startViewModel.currentLanguage.rawValue],
							isPresented: $delayedSelect)
						{
							HStack {
								Button(startViewModel
									.yesLabel[startViewModel.currentLanguage.rawValue], role: .cancel)
								{
									// Changes and Dismisses
									startViewModel.setLanguage(code: startViewModel.currentLanguage.code)
									selectedLang = false
								}
								Button(startViewModel
									.cancelLabel[startViewModel.currentLanguage.rawValue], role: .destructive)
								{
									// Dismisses
									selectedLang = false
								}
							}
						}
						Spacer()

                        NavigationLink(destination:

                            AnnounceUpdatesView(navigateStart: .create,
                                                language: startViewModel.currentLanguage,
                                                didTapContinue: $didContinue)
                                .environmentObject(startViewModel)
                                .navigationBarBackButtonHidden(false)
                        ) {
                            ZStack {
                                RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                    .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                    .foregroundColor(Color(UIColor.midnight))
                                    .shadow(radius: 3, x: 3.0, y: 3.0)

                                Text(S.StartView.readyButton.localize())
                                    .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                    .font(largeButtonFont)
                                    .foregroundColor(Color(UIColor.white))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                            .stroke(.white, lineWidth: 2.0)
                                    )
                            }
                        }
                        .padding([.top, .bottom], 10.0)
                        
                        NavigationLink(destination:

                            AnnounceUpdatesView(navigateStart: .recover,
                                                language: startViewModel.currentLanguage,
                                                didTapContinue: $didContinue)
                                .environmentObject(startViewModel)
                                .navigationBarBackButtonHidden(false)
                        ) {
                            ZStack {
                                RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                    .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                    .foregroundColor(Color(UIColor.midnight)
                                    ).shadow(radius: 5, x: 3.0, y: 3.0)

                                Text(S.StartView.restoreButton.localize())
                                    .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                    .font(regularButtonFont)
                                    .foregroundColor(Color(UIColor.white))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                            .stroke(.white)
                                    )
                            }
                        }
                        .padding([.top, .bottom], 10.0)

						Text(AppVersion.string)
							.frame(alignment: .center)
                            .font(versionFont)
							.foregroundColor(.white)
							.padding(.all, 5.0)
					}
					.padding(.all, swiftUICellPadding)
				}
			}
		}
		.alert(S.BrainwalletAlert.error.localize(),
		       isPresented: $startViewModel.walletCreationDidFail,
		       actions: {
		       	HStack {
		       		Button(S.Button.ok.localize(), role: .cancel) {
		       			startViewModel.walletCreationDidFail = false
		       		}
		       	}
		       })
	}
}

// #Preview {
//	StartView(viewModel: StartViewModel(store: Store(),
//	                                    walletManager: WalletManager(store: Store())))
//		.environment(\.locale, .init(identifier: "en"))
// }
