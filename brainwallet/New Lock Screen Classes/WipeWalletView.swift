//
//  WipeWalletView.swift
//  brainwallet
//
//  Created by Kerry Washington on 04/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct WipeWalletView: View {

    @ObservedObject
    var viewModel: LockScreenViewModel

    @Binding
     var shouldDismiss: Bool

    @State
     var isWipingWallet: Bool = false

    let squareImageSize: CGFloat = 25.0
    let themeBorderSize: CGFloat = 44.0

    init(viewModel: LockScreenViewModel,
         shouldDismiss: Binding<Bool>,
         didCompleteWipe: Binding<Bool>,) {
        self.viewModel = viewModel
        _shouldDismiss = shouldDismiss
    }

    var body: some View {

        GeometryReader { geometry in

            let width = geometry.size.width

            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)

                VStack {
                    Capsule().foregroundColor(BrainwalletColor.gray)
                        .frame(width: 50.0, height: 5.0, alignment: .center)
                        .padding(.all, 20.0)

                    Text("Wipe Brainwallet")
                        .modifier(BWIPSBold(size: 32.0))
                        .foregroundColor(BrainwalletColor.content)
                        .frame(alignment: .center)
                        .padding(.bottom, 10.0)

                    Spacer()

                    if !isWipingWallet {
                        Text("This will erase your PIN, data & memos. This cannot be undone.")
                            .modifier(BWIPSRegular(size: 24.0, lineLimit: 2))
                            .foregroundColor(BrainwalletColor.content)
                            .frame(alignment: .center)
                            .padding(.all, 20.0)

                        Text("This will allow you to send and receive from your previous balance. You will need to set a new PIN")
                            .modifier(BWIPSRegular(size: 24.0, lineLimit: 3))
                            .foregroundColor(BrainwalletColor.content)
                            .frame(alignment: .center)
                            .padding(.all, 20.0)

                        Image(systemName:"trash")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: largeButtonHeight, height: largeButtonHeight,
                                   alignment: .center)
                            .foregroundColor(BrainwalletColor.content)
                            .tint(BrainwalletColor.surface)
                            .padding(.all, 20.0)
                    } else {
                        Text("Wallet is deleted")
                            .modifier(BWIPSRegular(size: 24.0))
                            .foregroundColor(BrainwalletColor.content)
                            .frame(alignment: .center)
                            .padding(.all, 20.0)

                        Text("Start over by swiping up and restarting the app.")
                            .modifier(BWIPSRegular(size: 24.0, lineLimit: 2))
                            .foregroundColor(BrainwalletColor.content)
                            .frame(alignment: .center)
                            .padding(.all, 20.0)
                    }

                    Spacer()
                    Button(action: {
                        isWipingWallet.toggle()
                        delay(4.0) {
                            viewModel.startWipeProcess()
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                .padding([.leading, .trailing], 8.0)
                                .foregroundColor(BrainwalletColor.surface)

                            Text(String(localized: "Wipe my Brainwallet & Data"))
                                .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                .modifier(BWIPSBold(size: 24.0))
                                .padding([.leading, .trailing], 8.0)
                                .foregroundColor(BrainwalletColor.chili)
                                .overlay(
                                    RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                        .stroke(BrainwalletColor.chili, lineWidth: 1.0)
                                        .padding([.leading, .trailing], 8.0)

                                )
                        }
                        .padding(.all, 8.0)
                    }
                    .accessibilityIdentifier("Wipe Button")

                    Button(action: {
                        shouldDismiss.toggle()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                .foregroundColor(BrainwalletColor.surface)

                            Text("Cancel")
                                .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                 .modifier(BWIPSBold(size: 24.0))
                                .foregroundColor( isWipingWallet ? BrainwalletColor.content.opacity(0.2) : BrainwalletColor.content)
                                .overlay(
                                    RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                        .stroke(isWipingWallet ? BrainwalletColor.content.opacity(0.2) : BrainwalletColor.content, lineWidth: 2.0)
                                )
                        }
                        .padding(.all, 8.0)
                        .disabled(isWipingWallet)
                        .accessibilityIdentifier("Cancel")
                    }
                }
            }
        }
    }
}
