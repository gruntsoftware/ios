//
//  WebBuyView.swift
//  brainwallet
//
//  Created by Kerry Washington on 05/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI
  
struct WebBuyView: View {
    
    private var signedURL: String? = ""
    
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
    
    init(signedURL: String?, receiveAddress: String) {
        
        self.receiveAddress = receiveAddress
        
        ///TEMP USAGE:  After launch integrate api server
        let tempURL = mpPrefix + "?apiKey=" + APIServer.mp_pk_live + "&address=\(receiveAddress)&uid=\(UUID().uuidString)"
        
        if let url = URL(string: tempURL) {
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
                        .padding(4.0)
                }
                .frame(maxWidth: .infinity)
                .padding([.leading, .trailing], 8.0)
            }
        }
    }
}

