import SwiftUI

struct InputWordsView: View {
    
    @State
    private var didContinue: Bool = false
    
    @FocusState
    private var fieldInFocus: Bool
    
    @Binding
    var path: [Onboarding]
    
    @ObservedObject
    var viewModel: StartViewModel
    
    let subTitleFont: Font = .barlowSemiBold(size: 32.0)
    let largeButtonFont: Font = .barlowBold(size: 24.0)
    let detailFont: Font = .barlowRegular(size: 25.0)
    let detailerFont: Font = .barlowRegular(size: 20.0)

    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let largeButtonHeight: CGFloat = 65.0

    let arrowSize: CGFloat = 60.0
    
    ///Reuse the seed grid for yourr seedwords
    private let isRestore = true
    
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
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: squareImageSize)
                    .padding([.leading, .trailing], 20.0)
                    .padding(.bottom, 0.0)
                    
                    Text("Restore your power")
                        .font(subTitleFont)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: height * 0.05)
                        .foregroundColor(BrainwalletColor.content)
                        .padding(.top, 5.0)
                    
                    Text( "You can get back from where you started" )
                        .font(detailFont)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: height * 0.1)
                        .foregroundColor(BrainwalletColor.content)
                        .padding(.top, 2.0)
                        .padding([.leading, .trailing], 20.0)
                    
                    
                    SeedWordsGridView(isRestore: isRestore)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: height * 0.3, alignment: .center)
                        .padding(.all, 2.0)
                    
                    Spacer()
               
                    
                        Text( "Don’t guess.\n\nIt would take you 5,444,517,950,000,000,000,000,000,000,000,000,000,000,000,000,000 tries.")
                            .font(detailerFont)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(BrainwalletColor.content)
                            .frame(height: height * 0.2, alignment: .center)
                            .padding(.top, 5.0)
                            .padding([.leading, .trailing], 24.0)
                        
                        Text( "Blockchain: Litecoin" )
                            .font(detailerFont)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(height: height * 0.04, alignment: .center)
                            .foregroundColor(BrainwalletColor.content)
                            .padding(.all, 5.0)
                        
                   
                    
                    Button(action: {
                       // path.append(.setPasscodeView(isRestore: isRestore))
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                .foregroundColor(BrainwalletColor.surface)
                            
                            Text("Setup app passcode")
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
                .ignoresSafeArea(.keyboard) 
            }
        }
    }
}

struct InputWordsView_Previews: PreviewProvider {
    static var previews: some View {
        let walletManager = (try? WalletManager(store: Store(), dbPath: nil))!
        let viewModel = StartViewModel(store: Store(), walletManager: walletManager)
             
        //InputWordsView(viewModel: viewModel, path: .constant([.]))
    }
}
