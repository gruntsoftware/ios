import SwiftUI

struct LockScreenView: View {
	// MARK: - Combine Variables

	@ObservedObject
	var viewModel: LockScreenViewModel

	@State
	private var fiatValue = ""
 
    @State
    private var pinState: [Bool] = [false,false,false,false]
    
    @State
    private var pinDigits: [Int] = []
    
    @State
    private var didFillPIN: Bool = false
    
	init(viewModel: LockScreenViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
        
        GeometryReader { geometry in
            
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        Text(fiatValue)
                            .font(Font(UIFont.barlowLight(size: 16.0)))
                            .foregroundColor(BrainwalletColor.content)
                            .frame(width: width * 0.9, alignment: .trailing)
                            .padding(.trailing, 16.0)
                    }
                    .padding(.top, 16.0)
                    
                    Image("bw-logotype")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: width * 0.65)
                        .padding(.top, 40.0)
                        .padding(10.0)
                    
                    Spacer()
                    
                    PINRowView(pinState: $pinState)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 40.0)
                        .padding([.top,.bottom], 20.0)
                    
                    Spacer()

                    
                    PasscodeGridView(digits: $pinDigits)
                        .frame(maxWidth: width * 0.65, maxHeight: height * 0.4, alignment: .center)
                        .padding(.bottom, 10.0)
                    
                    
                    LockScreenFooterView(viewModel: viewModel)
                        .frame(width: width, height: 60.0, alignment: .center)
                        .padding(.bottom, 20.0)
                    
                    Text(AppVersion.string)
                        .font(Font(UIFont.barlowLight(size: 15.0)))
                        .foregroundColor(BrainwalletColor.content)
                        .frame(alignment: .center)
                        .padding(.bottom, 10.0)
                }
                .onAppear {
                    Task {
                        fiatValue = String(format: String(localized: "%@ = 1Ł"), viewModel.currentValueInFiat)
                    }
                }
                .onChange(of: viewModel.currentValueInFiat) { newValue in
                    fiatValue = String(format: String(localized: "%@ = 1Ł"), newValue)
                }
                .onChange(of: pinDigits) { _ in
                    
                    pinState = (0..<4).map { $0 < pinDigits.count }
                    
                    didFillPIN  = pinState.allSatisfy { $0 == true }
                    
                    let pinString = pinDigits.map(String.init).joined()
                    
                    if didFillPIN {
                        viewModel.pinDigits = pinDigits
                        viewModel.userSubmittedPIN?(pinString)
                    }
                }
            }
        }
	}
}

struct LockScreenView_Previews: PreviewProvider {
    static let viewModel = LockScreenViewModel(store: Store())
    static var previews: some View {
        LockScreenView(viewModel: viewModel)
    }
}
