import SwiftUI

struct InputWordsView: View {
    
    @State
    private var didContinue: Bool = false
    
    @Binding
    var path: [Onboarding]
    
    @ObservedObject
    var viewModel: StartViewModel
    
    let subTitleFont: Font = .barlowSemiBold(size: 32.0)
    let largeButtonFont: Font = .barlowBold(size: 24.0)
    let detailFont: Font = .barlowRegular(size: 28.0)
    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0

    let arrowSize: CGFloat = 60.0
    
    init(viewModel: StartViewModel, path: Binding<[Onboarding]>) {
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
                    
                    Text("Your seed Words")
                        .font(subTitleFont)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(BrainwalletColor.content)
                    Text( S.SetPasscode.detail1.localize())
                        .font(detailFont)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(BrainwalletColor.content)
                        .padding(.all, 20.0)
                    
                    Spacer()
                    
                }
            }
        }
    }
}
