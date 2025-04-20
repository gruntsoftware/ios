import SwiftUI

struct InputWordsView: View {
    
 
    @Environment(\.dismiss)
    private var dismiss
    
    @State
    private var didContinue: Bool = false
    
    @ObservedObject
    var viewModel: StartViewModel
    
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
        GeometryReader { geometry in
            
            
            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                
                VStack {
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.backward")
                            .foregroundColor(BrainwalletColor.content)
                    }
                    .padding(20)
                    Spacer()
                    Text("InputWordsView | Restore")
                    
                }
                .padding(.all, swiftUICellPadding)
                
                
            }
        }
    }
}
