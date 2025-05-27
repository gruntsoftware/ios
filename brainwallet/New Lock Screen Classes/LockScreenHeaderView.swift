import SwiftUI

struct LockScreenHeaderView: View {
	// MARK: - Combine Variables

	@ObservedObject
	var viewModel: LockScreenViewModel

	@State
	private var fiatValue = ""
 

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
                    HStack {
                        Text(fiatValue)
                            .font(Font(UIFont.barlowLight(size: 16.0)))
                            .foregroundColor(BrainwalletColor.content)
                            .frame(width: width * 0.9, alignment: .trailing)
                            .padding(.trailing, 16.0)
                    }
                    Image("bw-logotype")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: width * 0.65)
                        .padding(.top, 40.0)
                        .padding(10.0)
                }
                .frame(height: 180)
                .onAppear {
                    Task {
                        fiatValue = String(format: String(localized: "%@ = 1Ł"), viewModel.currentValueInFiat)
                    }
                }
                .onChange(of: viewModel.currentValueInFiat) { newValue in
                    fiatValue = String(format: String(localized: "1 LTC = %@"), newValue)
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
