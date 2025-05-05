//
//  WebBuyView.swift
//  brainwallet
//
//  Created by Kerry Washington on 05/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI
  
struct WebBuyView: View {
    
    private var receiveAddress: String = ""
    
    @State
    private var shouldScroll: Bool = false
    
    @State
    private var shouldShowCopied: Bool = false
    
    private var uuidString = UUID().uuidString
    
    private var urlString = ""
    private var url: URL?
    private var mpPrefix = {
        #if DEBUG
            return APIServer.mp_widget_debug_prefix
        #else
            return APIServer.mp_widget_prod_prefix
        #endif
    }()
    
    init(receiveAddress: String) {
        
        ///TEMP USAGE:  After launch integrate api server
        self.urlString = "https://brainwallet.co/mobile-top-up.html"
        
        self.receiveAddress = receiveAddress
        
        ///TBD:  After launch integrate api server
        let signUrlString = mpPrefix + "?apiKey=" + APIServer.mp_pk_live + "&address=\(receiveAddress)&uid=\(UUID().uuidString)"

        if let url = URL(string: urlString) {
            self.url = url
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                VStack {
                    WebView(url: url!, scrollToSignup: $shouldScroll)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Button(action: {
                        UIPasteboard.general.string = receiveAddress
                        shouldShowCopied.toggle()
                    }) {
                        HStack {
                            Image(systemName: "doc.on.clipboard")
                                .foregroundColor(BrainwalletColor.content)
                            
                            
                            VStack {
                                
                                Text(S.BuyCenter.depositAddress.localize())
                                    .font(.caption)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(BrainwalletColor.content)
                                Text(receiveAddress)
                                    .font(.footnote)
                                    .multilineTextAlignment(.leading)
                                    .truncationMode(.middle)
                                    .frame(maxWidth: width * 0.8, alignment: .leading)
                                    .foregroundColor(BrainwalletColor.content)
                            }
                            if shouldShowCopied {
                                Text(S.Receive.copied.localize())
                                    .font(.footnote)
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: 60.0, alignment: .trailing)
                                    .foregroundColor(BrainwalletColor.content).onAppear {
                                        delay(2.0) {
                                            self.shouldShowCopied = false
                                        }
                                    }
                            }
                        }
                        .padding(10.0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 44.0)
                }
                .frame(maxWidth: .infinity)
                .padding([.leading, .trailing], 8.0)
            }
        }
    }
}
struct WebBuyView_Previews: PreviewProvider {
    static var previews: some View {
        WebBuyView(receiveAddress: "")
    }
}
