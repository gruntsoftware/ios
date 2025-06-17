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
    let largeButtonHeight: CGFloat = 65.0
    let buttonLightFont: Font = .barlowLight(size: 16.0)
    let regularFont: Font = .barlowRegular(size: 24.0)
    let largeButtonFont: Font = .barlowBold(size: 24.0)

    init(viewModel: LockScreenViewModel, shouldDismiss: Binding<Bool>, didCompleteWipe: Binding<Bool>,) {
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
                        .font(Font(UIFont.barlowBold(size: 32.0)))
                        .foregroundColor(BrainwalletColor.content)
                        .frame(alignment: .center)
                        .padding(.bottom, 10.0)

                    Spacer()

                    if !isWipingWallet {
                        Text("This will erase your PIN, data & memos. This cannot be undone.")
                            .font(regularFont)
                            .foregroundColor(BrainwalletColor.content)
                            .frame(alignment: .center)
                            .padding(.all, 20.0)

                        Text("You can start over by tapping RESTORE then entering your previously saved 12 seed words.")
                            .font(regularFont)
                            .foregroundColor(BrainwalletColor.content)
                            .frame(alignment: .center)
                            .padding(.all, 20.0)

                        Text("This will allow you to send and receive from your previous balance. You will need to set a new PIN")
                            .font(regularFont)
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
                            .font(regularFont)
                            .foregroundColor(BrainwalletColor.content)
                            .frame(alignment: .center)
                            .padding(.all, 20.0)

                        Text("Start over by swiping up and restarting the app.")
                            .font(regularFont)
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
                                .foregroundColor(BrainwalletColor.surface)

                            Text(String(localized: "Wipe my Brainwallet & Data"))
                                .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                .font(largeButtonFont)
                                .foregroundColor(BrainwalletColor.chili)
                                .overlay(
                                    RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                        .stroke(BrainwalletColor.chili, lineWidth: 1.0)
                                )
                        }
                        .padding(.all, 8.0)
                    }

                    Button(action: {
                        shouldDismiss.toggle()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                .foregroundColor(BrainwalletColor.surface)

                            Text("Cancel")
                                .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                .font(largeButtonFont)
                                .foregroundColor( isWipingWallet ? BrainwalletColor.content.opacity(0.2) : BrainwalletColor.content)
                                .overlay(
                                    RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                        .stroke(isWipingWallet ? BrainwalletColor.content.opacity(0.2) : BrainwalletColor.content, lineWidth: 2.0)
                                )
                        }
                        .padding(.all, 8.0)
                        .disabled(isWipingWallet)
                    }
                }
            }
        }
    }
}
