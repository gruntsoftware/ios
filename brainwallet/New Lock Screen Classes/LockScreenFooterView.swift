//
//  LockScreenFooterView.swift
//  brainwallet
//
//  Created by Kerry Washington on 04/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct LockScreenFooterView: View {

    @ObservedObject
    var viewModel: LockScreenViewModel

    @State
    private var shoulShowWipeAlert: Bool = false

    init(viewModel: LockScreenViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width

            let buttonSize = 30.0
            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            viewModel.userPrefersDarkMode.toggle()
                        }) {
                            VStack {
                                Spacer()
                                Image(systemName: viewModel.userPrefersDarkMode ? "sun.max.circle" : "moon.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: buttonSize, height: buttonSize,
                                           alignment: .bottom)
                                    .foregroundColor(BrainwalletColor.content)
                            }

                        }
                        .frame(minWidth: width * 0.20, minHeight: 40.0,
                               alignment: .bottom)

                        Button(action: {
                            viewModel.userDidTapQR?()
                            viewModel.shouldShowQR.toggle()
                        }) {
                            VStack {
                                Spacer()
                                Image(systemName:"qrcode")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: buttonSize * 1.4, height: buttonSize * 1.4,
                                           alignment: .bottom)
                                    .foregroundColor(BrainwalletColor.content)
                                    .tint(BrainwalletColor.surface)
                            }
                        }
                        .frame(minWidth: width * 0.20, minHeight: 70.0,
                               alignment: .bottom)
                        .padding(8.0)

                        Button(action: {
                            shoulShowWipeAlert.toggle()
                        }) {
                            VStack {
                                Spacer()
                                Image(systemName:"trash")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: buttonSize, height: buttonSize,
                                           alignment: .bottom)
                                    .foregroundColor(BrainwalletColor.content)
                                    .tint(BrainwalletColor.surface)
                            }
                        }
                        .frame(minWidth: width * 0.20, minHeight: 40.0,
                               alignment: .bottom)
                    }
                    .frame(height: 55.0, alignment: .center)
                    .frame(maxWidth: .infinity)
                    .padding([.leading, .trailing], 8.0)
                    .sheet(isPresented: $shoulShowWipeAlert) {
                        WipeWalletView(viewModel: viewModel,
                                       shouldDismiss: $shoulShowWipeAlert,
                                       didCompleteWipe: $viewModel.didCompleteWipingWallet)
                    }
                    .onChange(of: viewModel.didCompleteWipingWallet) { _ in
                        shoulShowWipeAlert.toggle()
                    }
                }
            }
        }
    }
}
