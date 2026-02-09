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
    private var shouldShowWipeAlert: Bool = false

    @State
    private var shouldShowAddressModal: Bool = false

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
                                Image(systemName: userPrefersDarkMode ? "sun.max" : "moon.stars")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: buttonSize, height: buttonSize,
                                        alignment: .center)
                                    .foregroundColor(BrainwalletColor.content)
                                Spacer()
                            }

                        }
                        .frame(minWidth: width * 0.20,
                            minHeight: 30.0,
                            alignment: .center)

                        Button(action: {
                            viewModel.shouldShowReceiveAddress.toggle()
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
                            minHeight: 30.0,
                            alignment: .center)
                        .padding(8.0)

                        Button(action: {
                            shouldShowWipeAlert.toggle()
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
                            minHeight: 30.0,
                            alignment: .center)
                    }
                    .frame(height: 45.0, alignment: .center)
                    .frame(maxWidth: .infinity)
                    .padding([.leading, .trailing], 8.0)
                    .sheet(isPresented: $shouldShowWipeAlert) {
                        WipeWalletView(viewModel: viewModel,
                                       shouldDismiss: $shouldShowWipeAlert,
                                       didCompleteWipe: $viewModel.didCompleteWipingWallet)
                    }
                    .sheet(isPresented: $shouldShowAddressModal) {
                        LockReceiveModalView(viewModel: viewModel,
                                             shouldShowAddressModal: $shouldShowAddressModal,
                                             userPrefersDarkMode: $userPrefersDarkMode)
                        .cornerRadius(bentoCornerRadius)
                        .presentationDragIndicator(.hidden)
                        .presentationDetents([.medium])
                        .presentationBackground(.ultraThickMaterial)
                        .ignoresSafeArea(edges: .bottom)
                    }
                    .onChange(of: userPrefersDarkMode) { _,_ in
                        viewModel.userDidSetThemePreference(userPrefersDarkMode: userPrefersDarkMode)
                    }
                    .onChange(of: viewModel.didCompleteWipingWallet) { _,_ in
                        shouldShowWipeAlert.toggle()
                    }
                }
            }
        }
    }
}
