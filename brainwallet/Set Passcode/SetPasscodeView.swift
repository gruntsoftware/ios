
import SwiftUI
struct SetPasscodeView: View {
    
    
    @Binding
    var path: [Onboarding]
    
    @State var pinDigits: [Int] = []

    @State
    private var pinState: [Bool] = [false,false,false,false]

    private let isRestore: Bool?
    
    @State
    private var didFillPIN: Bool = false
     
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
    
    init(path: Binding<[Onboarding]>) {
        _path = path
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
                                    pinDigits = []
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
                     
                            Text( "Set app PIN" )
                                .font(subTitleFont)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(BrainwalletColor.content)
                            Text( "Pick a passcode to unlock your Brainwallet. Not a phone lock code! Make it different. Make it cool" )
                                .font(detailFont)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(BrainwalletColor.content)
                                .padding(.all, 20.0)

                        PINRowView(pinState: $pinState)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .frame(height: 40.0)
                                .padding(.top, 40.0)

                        Spacer()
                        PasscodeGridView(digits: $pinDigits)
                            .frame(maxWidth: width * 0.65, maxHeight: height * 0.4, alignment: .center)
                            .padding(.bottom, 80.0)
                        }
                }
            }
            .onChange(of: pinDigits) { _ in
                
                pinState = (0..<4).map { $0 < pinDigits.count }
                
                didFillPIN  = pinState.allSatisfy { $0 == true }
                if didFillPIN {
                
                   // path.append(.confirmPasscodeView(isRestore: self.isRestore, pinDigits: pinDigits))
                }
            }
    }
}
