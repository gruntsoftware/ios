
import SwiftUI
struct SetPasscodeView: View {
    
    
    @Environment(\.dismiss)
    private var dismiss
    
    @ObservedObject
    var viewModel: StartViewModel
    
    @State
    private var pinDigits: String = ""
    
    let subTitleFont: Font = .barlowSemiBold(size: 32.0)
    let largeButtonFont: Font = .barlowBold(size: 24.0)
    let detailFont: Font = .barlowRegular(size: 28.0)
    
    let verticalPadding: CGFloat = 20.0
    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let themeButtonSize: CGFloat = 28.0
    let themeBorderSize: CGFloat = 44.0
    let largeButtonHeight: CGFloat = 65.0
    
    let arrowSize: CGFloat = 60.0
    
    init(viewModel: StartViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        NavigationView {
            
            GeometryReader { geometry in
                
                let width = geometry.size.width
                let height = geometry.size.height
                
                ZStack {
                    BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        HStack {
                                Button(action: {
                                    dismiss()
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
                        .padding(.all, 20.0)
                        
                        Text( S.SetPasscode.subTitle.localize())
                            .font(subTitleFont)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(BrainwalletColor.content)
                            .padding(.bottom, 20.0)
                        Text( S.SetPasscode.detail1.localize())
                            .font(detailFont)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(BrainwalletColor.content)

                        PasscodeGridView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(40.0)

                        PINFieldView(pinText: $viewModel.pinDigits,
                                     pinIsFilled: $viewModel.pinIsFilled,
                                     viewRect: $viewModel.pinViewRect)
                            .onReceive(viewModel.$pinDigits) { newValue in
                                pinDigits = newValue
                            }
                            .frame(width: width * 0.4)
                            .opacity(0.7)
                        
//                        NavigationLink(destination:
//                                        //InputWordsView().navigationBarBackButtonHidden(true))
//                        {
//                            ZStack {
//                            }
//                            .padding(.all, 8.0)
//                        }
                    }
                }
            }
        }
    }
}
