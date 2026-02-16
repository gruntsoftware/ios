//
//  LockReceiveModalView.swift
//  brainwallet
//
//  Created by Kerry Washington on 28/01/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct LockReceiveModalView: View {

    @ObservedObject
    var viewModel: LockScreenViewModel

    @Binding
    var shouldShowAddressModal: Bool

    @Binding
    var userPrefersDarkMode: Bool

    @State
    private var newAddress = ""

    init(viewModel: LockScreenViewModel,
         shouldShowAddressModal: Binding<Bool>,
         userPrefersDarkMode: Binding<Bool>) {
        self.viewModel = viewModel
        _userPrefersDarkMode = userPrefersDarkMode
        _shouldShowAddressModal = shouldShowAddressModal
    }

    func generateQR(newAddress: String) -> UIImage {

        if let data = newAddress.data(using: .utf8),
           let image = UIImage
            .qrCode(data: data, color: .gray)?
            .resize(CGSize(width: kQRImageSide,
                           height: kQRImageSide)) {
            return image
        }
        return UIImage()
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height
            let qrWidth = geometry.size.width * 0.35
            let padding = 18.0

            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)

                Button(action: {
                    UIPasteboard.general.string =  newAddress
                }) {

                    VStack {
                        Text(String(localized: "New LTC Address"))
                            .modifier(BWIPSSemiBold(size: 15.0))
                            .frame(alignment: .center)
                            .foregroundColor(BrainwalletColor.content)
                            .padding(3.0)
                        ZStack {
                           RoundedRectangle(cornerRadius: 16)
                               .foregroundColor(.white)
                               .frame(width: abs(qrWidth * 0.8 + padding),
                                      height: abs(qrWidth * 0.8 + padding))
                               .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            Image(uiImage: generateQR(newAddress: newAddress))
                               .resizable()
                               .scaledToFit()
                               .frame(width: qrWidth * 0.8)
                       }

                        Text(newAddress)
                            .modifier(BWIPSLight(size: 11.0))
                            .frame(alignment: .center)
                            .foregroundColor(BrainwalletColor.content)
                            .padding(3.0)
                    }
                    .frame(width: width * 0.75,
                           height: height * 0.85)
                    .background(BrainwalletColor.content.opacity(0.1))
                    .cornerRadius(16)
                    .padding(8)
                }
            }
            .onAppear {
                newAddress = viewModel.freshReceiveAddress
            }
        }
    }
}
