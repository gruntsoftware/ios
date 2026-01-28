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

    @State private var newAddress = ""

    let padding = 18.0

    init(viewModel: LockScreenViewModel,
         shouldShowAddressModal: Binding<Bool>,
         userPrefersDarkMode: Binding<Bool>) {
        self.viewModel = viewModel
        _userPrefersDarkMode = userPrefersDarkMode
        _shouldShowAddressModal = shouldShowAddressModal
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height
            let qrWidth = geometry.size.width * 0.4

            let buttonSize = 35.0
            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()

                    Button(action: {
                        UIPasteboard.general.string =  newAddress
                    }) {
                    }

                        HStack {
                            Spacer()
                            VStack {
                                Spacer()
                                Text(newAddress)
                                Text("COPY / SHARE")
                                    .multilineTextAlignment(.center)
                                    .padding(.all, 8.0)
                                Spacer()
                            }
                            .frame(width: qrWidth, alignment: .leading)
                        }
                        .frame(width: width, height: height, alignment: .top)
                }
            }.onAppear {
                newAddress = viewModel.freshReceiveAddress
                debugPrint(":::\(newAddress)")
            }
        }
    }
}
