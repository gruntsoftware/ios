import SwiftUI

struct LockScreenHeaderView: View {
    // MARK: - Combine Variables

    @ObservedObject
    var viewModel: LockScreenViewModel

    @State
    private var fiatValue = ""
  
    var viewHeight: CGFloat = 60.0
    
    init(viewModel: LockScreenViewModel, viewHeight: CGFloat) {
        self.viewModel = viewModel
        self.viewHeight = viewHeight
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let width = geometry.size.width

            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                
                VStack {
                   
                    Text(fiatValue)
                        .font(Font(UIFont.barlowLight(size: 14.0)))
                        .foregroundColor(BrainwalletColor.content)
                        .frame(maxWidth: .infinity, alignment: .init(horizontal: .trailing, vertical: .center))
                        .padding(.trailing, 16.0)
                        .padding(.top, 5.0)

                    Image("bw-logotype")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: width * 0.7)
                        .padding(.top, 20.0)
                        .padding([.leading,.trailing], 20.0)
                    
                    Spacer()
                }
                .onAppear {
                    Task {
                        fiatValue = String(format: String(localized: "%@ = Ł1"), viewModel.currentValueInFiat)
                    }
                }
                .onChange(of: viewModel.currentValueInFiat) { newValue in
                    fiatValue = String(format: String(localized: "%@ = Ł1"), newValue)
                }
            }
        }
    }
}

struct LockScreenHeaderView_Previews: PreviewProvider {
    static let viewModel = LockScreenViewModel(store: Store())
    static var previews: some View {
        LockScreenHeaderView(viewModel: viewModel, viewHeight: 60.0)
    }
}
