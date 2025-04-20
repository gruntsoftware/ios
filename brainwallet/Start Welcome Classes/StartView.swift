import SwiftUI
import Lottie


enum ReadyOrRestore: Hashable, CaseIterable {
    case ready
    case restore
    case setPasscode
    case inputWords
    case topUp
    
    var headerTitle: String {
        switch self {
        case .ready:
            return S.Onboarding.readyTitle.localize()
        case .restore:
            return S.Onboarding.restoreTitle.localize()
        case .topUp:
            return S.TopUp.topUpTitle.localize()
        default :
            return ""
        }
    }
    
    var detailDescription: String {
        switch self {
        case .ready:
            return S.Onboarding.readyDetail.localize()
        case .restore:
            return S.Onboarding.restoreTitle.localize()
        case .topUp:
            return S.TopUp.detail1.localize()
        default :
            return ""
        }
    }
    
    var continueButtonTitle: String {
        switch self {
        case .ready:
            return S.Onboarding.readyNextButton.localize()
        case .restore:
            return S.Onboarding.restoreNextButton.localize()
        case .topUp:
            return S.TopUp.topUpNextButton.localize()
        default :
            return ""
        }
    }
}

struct StartView: View {
    let selectorFont: Font = .barlowSemiBold(size: 16.0)
    let buttonLightFont: Font = .barlowLight(size: 16.0)
    let regularButtonFont: Font = .barlowRegular(size: 24.0)
    let largeButtonFont: Font = .barlowBold(size: 24.0)

    let versionFont: Font = .barlowSemiBold(size: 16.0)
    let verticalPadding: CGFloat = 20.0
	let squareButtonSize: CGFloat = 55.0
	let squareImageSize: CGFloat = 25.0
    let themeButtonSize: CGFloat = 28.0
    let themeBorderSize: CGFloat = 44.0
    let largeButtonHeight: CGFloat = 65.0
    let lottieFileName: String = "welcomeemoji20250212.json"
    
    @State
    private var readyOrRestorePath: [ReadyOrRestore] = []
    
    @State
    private var isShowingOnboardView: Bool = true
    
	@ObservedObject
	var startViewModel: StartViewModel

	@State
	private var selectedLang: Bool = false
    
    @State
    private var selectedFiat: Bool = false

	@State
	private var delayedSelect: Bool = false
    
    @State
    private var userPrefersDarkMode: Bool = false

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
                BrainwalletColor.surface.ignoresSafeArea()
                
                    VStack {
                        
                        Group {
                            Image("bw-logotype")
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
                                                    .foregroundColor(BrainwalletColor.content)
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
                                            userPrefersDarkMode.toggle()
                                            startViewModel.userDidChangeDarkMode(state: userPrefersDarkMode)
                                        }) {
                                            ZStack {
                                                Ellipse()
                                                    .frame(width: themeBorderSize,
                                                           height: themeBorderSize,
                                                           alignment: .center)
                                                    .overlay {
                                                        Ellipse()
                                                            .frame(width: themeBorderSize,
                                                                   height: themeBorderSize,
                                                                   alignment: .center)
                                                            .foregroundColor(BrainwalletColor.midnight)
                                                    }
                                                
                                                Image(systemName: userPrefersDarkMode ?  "rays" : "moon")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: themeButtonSize,
                                                           height: themeButtonSize,
                                                           alignment: .center)
                                                    .foregroundColor( userPrefersDarkMode ?  BrainwalletColor.warn : BrainwalletColor.surface)
                                                
                                            }
                                        }
                                        .frame(width: width * 0.1)
                                        
                                        Picker("", selection: $pickedCurrency) {
                                            ForEach(startViewModel.currencies, id: \.self) {
                                                Text($0.fullCurrencyName)
                                                    .font(selectorFont)
                                                    .foregroundColor(BrainwalletColor.content)
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
                                             ReadyRestoreView(viewModel: startViewModel, path: .ready)
                                            .navigationBarBackButtonHidden(true))
                            {
                            ZStack {
                                RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                    .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                    .foregroundColor(BrainwalletColor.surface)
                                    .shadow(radius: 3, x: 3.0, y: 3.0)
                                
                                Text(S.StartView.readyButton.localize())
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
                        
                        NavigationLink(destination:
                                        ReadyRestoreView(viewModel: startViewModel, path: .restore)
                                        .navigationBarBackButtonHidden(true))
                        {
                            ZStack {
                                RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                    .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                    .foregroundColor(BrainwalletColor.surface)
                                    .shadow(radius: 5, x: 3.0, y: 3.0)
                                
                                Text(S.StartView.restoreButton.localize())
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
                        
                        Text(AppVersion.string)
                            .frame(alignment: .center)
                            .font(versionFont)
                            .foregroundColor(BrainwalletColor.content)
                            .padding(.all, 5.0)
                    }
                }
                .padding(.all, swiftUICellPadding)
                .scrollContentBackground(.hidden)
                .background(BrainwalletColor.surface)
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
