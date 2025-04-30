import SafariServices
import SwiftUI

struct BuyView: View {
    @ObservedObject
    var viewModel: BuyViewModel
    
    let paragraphFont: Font = .barlowSemiBold(size: 20.0)
    let calloutFont: Font = .barlowLight(size: 12.0)
    let smallCalloutFont: Font = .barlowLight(size: 10.0)
    
    let genericPad = 25.0
    let selectButtonHeight = 35.0
    let smallPad = 6.0
    let buttonHeight = 44.0
    let pageHeight = 145.0
    let hugeFont = Font.barlowBold(size: 30.0)
    let buttonLightFont: Font = .barlowLight(size: 15.0)
    let buttonRegularFont: Font = .barlowSemiBold(size: 18.0)
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let themeButtonSize: CGFloat = 28.0
    let themeBorderSize: CGFloat = 44.0
    let largeButtonHeight: CGFloat = 65.0
    let largeButtonFont: Font = .barlowBold(size: 24.0)
    
    @State
    private var shouldShowSafariVC = false
    
    @State
    private var didTapCopy = false
    // https://en.wikipedia.org/wiki/Template:Most_traded_currencies
    /// As of 1716366977
    let rankedFiatCodes: [String] = ["USD", "EUR", "JPY", "GBP",
                                     "CNY", "AUD", "CAD", "CHF",
                                     "HKD", "SGD", "SEK", "NOK",
                                     "NZD", "MXN", "TWD", "ZAR",
                                     "BRL", "DKK", "PLN", "THB",
                                     "ILS", "IDR", "CZK", "TRY",
                                     "RON", "PEN"]
    
    init(viewModel: BuyViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                VStack {
                    Divider()
                        .frame(height: 1.0)
                        .background(BrainwalletColor.content)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Text(S.BuyCenter.buyModalTitle.localize())
                        .font(hugeFont)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(idealHeight: buttonHeight)
                        .foregroundColor(BrainwalletColor.content)
                        .padding([.leading, .trailing], genericPad)
                        .padding(.all, genericPad)
                    
                    HStack {
                        VStack {
                            Picker(S.BuyCenter.buyDetail.localize() + " " + viewModel.receivingAddress,
                                   selection: $viewModel.selectedCode)
                            {
                                ForEach(rankedFiatCodes, id: \.self) {
                                    BuyTileView(code: $0)
                                }
                            }
                            .pickerStyle(.wheel)
                            Spacer()
                        }
                        
                        VStack {
                            Text(S.BuyCenter.buyDetail.localize())
                                .font(buttonRegularFont)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(idealHeight: buttonHeight)
                                .foregroundColor(BrainwalletColor.content)
                                .padding([.leading, .trailing], genericPad)
                                .padding(.top, 0.0)
                            HStack {
                                Text(viewModel.receivingAddress)
                                    .font(buttonLightFont)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(idealHeight: buttonHeight)
                                    .foregroundColor(didTapCopy ? BrainwalletColor.content : BrainwalletColor.grape)
                                    .padding([.top, .bottom], smallPad)
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(didTapCopy ? BrainwalletColor.content : BrainwalletColor.background)
                            }
                            .onTapGesture {
                                UIPasteboard.general.string = viewModel.receivingAddress
                                didTapCopy.toggle()
                                delay(0.2) {
                                    didTapCopy.toggle()
                                }
                            }
                            .padding([.leading, .trailing], genericPad)
                        }
                    }
                    .frame(height: height * 0.2
                    )
                    
                    Divider()
                        .frame(height: 1.0)
                        .background(BrainwalletColor.content)
                        .frame(maxWidth: .infinity, alignment: .center)
                    HStack {
                        Image("moonpay_logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 60.0)
                            .opacity(0.8)
                    }
                    .padding([.leading, .trailing], genericPad)

                    Spacer()
                    
                    Button(action: {
                        if viewModel.receivingAddress != "" {
                            let timestamp = Int(Date().timeIntervalSince1970)
                            viewModel.urlString = APIServer.baseUrl + "moonpay/buy" + "?address=\(viewModel.receivingAddress)&idate=\(timestamp)&uid=\(viewModel.uuidString)&code=\(viewModel.selectedCode)"
                            self.shouldShowSafariVC = true
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                .foregroundColor(BrainwalletColor.surface)
                                .shadow(radius: 3, x: 3.0, y: 3.0)
                            
                            Text(S.BuyCenter.buyButtonTitle.localize() + " \(viewModel.selectedCode)")
                                .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                .font(largeButtonFont)
                                .foregroundColor(BrainwalletColor.content)
                                .overlay(
                                    RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                        .stroke(BrainwalletColor.content, lineWidth: 2.0)
                                )
                        }
                    }
                    .padding([.top, .bottom], 30.0)
                    .padding([.leading, .trailing], genericPad)
                    .sheet(isPresented: $shouldShowSafariVC) {
                        if let url = URL(string: viewModel.urlString) {
                            MoonpaySafariView(url: url)
                        }
                    }
                }
            }
        }
    }
}

struct MoonpaySafariView: UIViewControllerRepresentable {
	let url: URL

	func makeUIViewController(context _: UIViewControllerRepresentableContext<MoonpaySafariView>) -> SFSafariViewController {
		return SFSafariViewController(url: url)
	}

	func updateUIViewController(_: SFSafariViewController, context _: UIViewControllerRepresentableContext<MoonpaySafariView>) {}
}

#Preview {
	BuyView(viewModel: BuyViewModel())
}
