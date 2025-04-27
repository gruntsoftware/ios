import SwiftUI

 

struct ReadyRestoreView: View {
    
    @ObservedObject
    var viewModel: StartViewModel
    
    @Binding
    var path: [Onboarding]
      
    let selectorFont: Font = .barlowSemiBold(size: 16.0)
    let buttonLightFont: Font = .barlowLight(size: 16.0)
    let regularButtonFont: Font = .barlowRegular(size: 24.0)
    let largeButtonFont: Font = .barlowBold(size: 24.0)
    let detailFont: Font = .barlowRegular(size: 28.0)
    let billboardFont: Font = .barlowBold(size: 70.0)

    let versionFont: Font = .barlowSemiBold(size: 16.0)
    let verticalPadding: CGFloat = 20.0
    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let themeButtonSize: CGFloat = 28.0
    let themeBorderSize: CGFloat = 44.0
    let largeButtonHeight: CGFloat = 65.0
    
    let arrowSize: CGFloat = 60.0
    
    private let isRestore: Bool
    
    init(isRestore: Bool, viewModel: StartViewModel, path: Binding<[Onboarding]>) {
        self.viewModel = viewModel
        self.isRestore = isRestore
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
                            }
                            Spacer()
                        }
                        .padding(.all, 20.0)
                        
                        Spacer()
                        HStack {
                            Image(systemName: "arrow.down.right")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
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
                                    Text( isRestore ? S.Onboarding.restoreTitle.localize() : S.Onboarding.readyTitle.localize())
                                        .font(billboardFont)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(BrainwalletColor.content)
                                }
                                .padding(.bottom, 20.0)
                                Text( isRestore ? S.Onboarding.restoreDetail.localize() : S.Onboarding.readyDetail.localize())
                                    .font(detailFont)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(BrainwalletColor.content)
                            }
                            Spacer()
                        }
                        .padding(.bottom, 40.0)
                        .padding(.leading, 20.0)
                        
                        Spacer(minLength: 20.0)
                            Button(action: {
                                path.append(.setPasscodeView(isRestore: isRestore))
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                        .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                        .foregroundColor(BrainwalletColor.surface)
                                    
                                    Text(S.Onboarding.readyNextButton.localize())
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
                        }
                    }
                }
            }
    }
