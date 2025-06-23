//
//  WebBuyView.swift
//  brainwallet
//
//  Created by Kerry Washington on 05/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct WebBuyView: View {

    @ObservedObject
    var viewModel: NewReceiveViewModel

    @State
    private var shouldScroll: Bool = false

    @State
    private var shouldShowCopied: Bool = false

    @State
    private var didFetchURLString: Bool = false

    private let signedURLString = ""

    @State
    private var url: URL?

    private var signingData: MoonpaySigningData

    init(signingData: MoonpaySigningData, viewModel: NewReceiveViewModel) {

        self.signingData = signingData
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { _ in

            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                VStack {
                    if didFetchURLString {
                        WebView(url: self.url!, scrollToSignup: $shouldScroll)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(4.0)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding([.leading, .trailing], 8.0)
            }
            .onChange(of: viewModel.didFetchURLString) { didFetchURL in

                if didFetchURL {

                     if let url = URL(string: viewModel.signedURLString) {
                         self.url = url
                         didFetchURLString = true
                     } else {
                         self.url = URL(string: "https://brainwallet.co/mobile-top-up.html")
                         let fetchError: [String: String] = ["error": "signed_url_invalid"]
                         BWAnalytics.logEventWithParameters(itemName: ._20191105_AL, properties: fetchError)
                         didFetchURLString = true
                     }

                }
            }
        }
    }
}
