import SwiftUI

struct LockScreenHeaderView: View {
	// MARK: - Combine Variables

	@ObservedObject
	var viewModel: LockScreenViewModel

	@State
	private var fiatValue = ""

	@State
	private var currentFiatValue = "Current Litecoin value in"

	init(viewModel: LockScreenViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
        
        GeometryReader { geometry in
            
            let width = geometry.size.width
            
            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    Text(fiatValue)
                        .font(Font(UIFont.barlowSemiBold(size: 16.0)))
                        .foregroundColor(BrainwalletColor.content)
                    
                    Text(currentFiatValue)
                        .font(Font(UIFont.barlowRegular(size: 14.0)))
                        .foregroundColor(BrainwalletColor.content)
                        .padding(.bottom, 10)
                    Divider().background(BrainwalletColor.gray)
                    
                    Image("bw-logotype")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: width * 0.75)
                        .padding(.top, 40.0)
                        .padding(10.0)
                }
                .frame(height: 180)
                .onAppear {
                    Task {
                        fiatValue = "1 LTC = \(viewModel.currentValueInFiat)"
                        currentFiatValue = "Current Litecoin value in \(viewModel.currencyCode)"
                    }
                }
                .onChange(of: viewModel.currentValueInFiat) { newValue in
                    fiatValue = " 1 LTC = \(newValue)"
                }
            }
        }
	}
}

struct LockScreenHeaderView_Previews: PreviewProvider {
    static let viewModel = LockScreenViewModel(store: Store())
    static var previews: some View {
        LockScreenHeaderView(viewModel: viewModel)
    }
}

//GeometryReader { geometry in
//    
//    let width = geometry.size.width
//    
//    let buttonSize = 30.0
//    ZStack {
