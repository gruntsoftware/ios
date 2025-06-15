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
    
    @Binding
    var userPrefersDarkMode: Bool

    init(viewModel: LockScreenViewModel, userPrefersDarkMode: Binding<Bool>) {
        self.viewModel = viewModel
        _userPrefersDarkMode = userPrefersDarkMode
    }
    
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            
            let buttonSize = 35.0
            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            userPrefersDarkMode.toggle()
                        }) {
                            VStack {
                                Spacer()
                                Image(systemName: userPrefersDarkMode ? "sun.max.circle" : "moon.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: buttonSize, height: buttonSize,
                                        alignment: .center)
                                    .foregroundColor(BrainwalletColor.content)
                                Spacer()
                            }

                        }
                        .frame(minWidth: width * 0.20,
                            minHeight: 40.0,
                            alignment: .center)
                        
                        Button(action: {
                            viewModel.userDidTapQR?()
                            viewModel.shouldShowQR.toggle()
                        }) {
                            VStack {
                                Spacer()
                                Image(systemName:"qrcode")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: buttonSize * 1.2, height: buttonSize * 1.2,
                                        alignment: .center)
                                    .foregroundColor(BrainwalletColor.content)
                                    .tint(BrainwalletColor.surface)
                                Spacer()
                            }
                        }
                        .frame(minWidth: width * 0.20,
                            minHeight: 40.0,
                            alignment: .center)
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
                                        alignment: .center)
                                    .foregroundColor(BrainwalletColor.content)
                                    .tint(BrainwalletColor.surface)
                                Spacer()
                            }
                        }
                        .frame(minWidth: width * 0.20,
                            minHeight: 40.0,
                            alignment: .center)
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
