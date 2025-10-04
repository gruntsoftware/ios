//
//  UtilityHeaderView.swift
//  brainwallet
//
//  Created by Kerry Washington on 07/10/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct UtilityHeaderView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @State
    var shouldShowSettings: Bool = false

    @State
    var filterMode: TransactionFilterState = .allTransactions

    private var modeState = TransactionFilterState.allCases

    private let buttonSize: CGFloat = 20.0

    private let buttonPlatformFactor: CGFloat = 2.1

    init(viewModel: NewMainViewModel) {
        newMainViewModel = viewModel
    }
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            ZStack {
                Color.clear.edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Button(action: {
                            newMainViewModel.shouldShowSettings.toggle()
                            shouldShowSettings = newMainViewModel.shouldShowSettings
                        }) {
                            ZStack {
                                Ellipse()
                                    .frame(width: buttonSize * buttonPlatformFactor,
                                           height: buttonSize * buttonPlatformFactor,
                                           alignment: .center)
                                    .foregroundColor(BrainwalletColor.surface)
                                    .overlay(
                                        Ellipse()
                                            .stroke(BrainwalletColor.content.opacity(0.3), lineWidth: 0.5)
                                            .frame(width: buttonSize * buttonPlatformFactor,
                                                   height: buttonSize * buttonPlatformFactor,
                                                   alignment: .center)
                                    )

                                Image(systemName: "line.3.horizontal")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: buttonSize, height: buttonSize,
                                           alignment: .center)
                                    .foregroundColor(BrainwalletColor.content)
                            }

                        }
                        .frame(width: buttonSize, height: buttonSize,
                               alignment: .leading)

                        Spacer()

                        ZStack {
                            Capsule()
                                .frame(width: buttonSize * buttonPlatformFactor * 2,
                                       height: buttonSize * buttonPlatformFactor,
                                       alignment: .center)
                                .foregroundColor(BrainwalletColor.surface)
                                .overlay(
                                    Capsule()
                                        .stroke(BrainwalletColor.content.opacity(0.3), lineWidth: 0.5)
                                        .frame(width: buttonSize * buttonPlatformFactor * 2,
                                               height: buttonSize * buttonPlatformFactor,
                                               alignment: .center)
                                )
                            HStack {
                                Button(action: {
                                    /// Activate Gear Settings
                                }) {
                                    Image(systemName: "gearshape")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: buttonSize, height: buttonSize,
                                               alignment: .topLeading)
                                        .foregroundColor(BrainwalletColor.content)
                                }
                                .frame(width: buttonSize, height: buttonSize,
                                       alignment: .leading)
                                .padding(4)

                                Button(action: {
                                    /// Activate Notification Settings 
                                }) {
                                    Image(systemName: "bell")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: buttonSize, height: buttonSize,
                                               alignment: .topLeading)
                                        .foregroundColor(BrainwalletColor.content)
                                }
                                .frame(width: buttonSize, height: buttonSize,
                                       alignment: .leading)
                                .padding(4)
                            }
                            .frame(width: buttonSize * buttonPlatformFactor * 2,
                                   height: buttonSize * buttonPlatformFactor,
                                   alignment: .center)

                        }

                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: utilityHeaderHeight, alignment: .center)

        }
    }
}
// struct UtilityHeaderView_Previews: PreviewProvider {
//
//    static let store = Store()
//    static let walletManager: WalletManager = try! WalletManager(store: store, dbPath: nil)
//
//    static var previews: some View {
//        UtilityHeaderView(viewModel: NewMainViewModel(store: store, walletManager: walletManager))
//    }
// }
