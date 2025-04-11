import SwiftUI
import UIKit
import Lottie
//
//enum OnboardingPath (
//    
//)

struct StartView: View {
    let buttonFont: Font = .barlowSemiBold(size: 16.0)
    let buttonLightFont: Font = .barlowLight(size: 16.0)
    let largeButtonFont: Font = .barlowSemiBold(size: 22.0)

	let tinyFont: Font = .barlowRegular(size: 16.0)
    let verticalPadding: CGFloat = 10.0

	let squareButtonSize: CGFloat = 55.0
	let squareImageSize: CGFloat = 25.0
    let lightButtonWidth: CGFloat = 44.0
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
                            Image("bw-logotype-white")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                                .frame(width: width * 0.8,
                                       alignment: .center)
                                .padding(.vertical, verticalPadding)
                            
                            WelcomeLottieView(lottieFileName: lottieFileName,
                                              shouldRunAnimation: true)
                            .frame(width: width * 0.9,
                                   height: height * 0.45,
                                   alignment: .center)
                       
						
						HStack {
                            ZStack {
                                Group {
                                    HStack {
                                        Picker("", selection: $pickedLanguage) {
                                            ForEach(startViewModel.languages, id: \.self) {
                                                Text($0.nativeName)
                                                    .font(selectedLang ? buttonFont : buttonLightFont)
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: width * 0.35)
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
                                            //TODO: Switch appearance reference
                                        }) {
                                            ZStack {
                                                Image(systemName: "rays")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: lightButtonWidth,
                                                           height: lightButtonWidth,
                                                           alignment: .center)
                                                    .foregroundColor(Color.cheddar)
                                            }
                                        }
                                        .frame(width: width * 0.15)
                                        
                                        Picker("", selection: $pickedCurrency) {
                                            ForEach(startViewModel.currencies, id: \.self) {
                                                Text($0.fullCurrencyName)
                                                    .font(selectedFiat ? buttonFont : buttonLightFont)
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: width * 0.35)
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

                        Button(
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

								Text(S.StartViewController.createButton.localize())
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

                        Button(
                            
                     //       startViewModel.didTapRecover!()
                            
                            startViewModel
                                .cancelLabel[startViewModel.currentLanguage.rawValue], role: .destructive

                        ){
							ZStack {
								RoundedRectangle(cornerRadius: largeButtonHeight/2)
									.frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
									.foregroundColor(Color(UIColor.midnight)
									)

								Text(S.StartViewController.recoverButton.localize())
									.frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
									.font(largeButtonFont)
                                    .foregroundColor(Color(UIColor.white))
									.overlay(
										RoundedRectangle(cornerRadius: largeButtonHeight/2)
											.stroke(.white)
									)
							}
						}
						.padding([.top, .bottom], 10.0)

						Text(AppVersion.string)
							.frame(width: 100, alignment: .center)
							.font(tinyFont)
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
