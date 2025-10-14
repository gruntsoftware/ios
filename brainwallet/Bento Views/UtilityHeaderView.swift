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
    private var shouldShowSettings: Bool = false

    @State
    private var userPrefersDarkTheme: Bool = true

    @State
    private var shouldRing: Bool = false

    @State
    private var bellAngle: Double = 0.0

    private let buttonSize: CGFloat = 20.0

    private let buttonPlatformFactor: CGFloat = 2.1

    init(viewModel: NewMainViewModel) {
        newMainViewModel = viewModel
    }
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            /// Tidy the long name
            let content = BrainwalletColor.content
            let surface = BrainwalletColor.surface

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
                                    .foregroundColor(surface)
                                    .overlay(
                                        Ellipse()
                                            .stroke(content.opacity(0.3), lineWidth: 0.5)
                                            .frame(width: buttonSize * buttonPlatformFactor,
                                                   height: buttonSize * buttonPlatformFactor,
                                                   alignment: .center)
                                    )

                                Image(systemName: "line.3.horizontal")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: buttonSize, height: buttonSize,
                                           alignment: .center)
                                    .foregroundColor(content)
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
                                .foregroundColor(surface)
                                .overlay(
                                    Capsule()
                                        .stroke(content.opacity(0.3), lineWidth: 0.5)
                                        .frame(width: buttonSize * buttonPlatformFactor * 2,
                                               height: buttonSize * buttonPlatformFactor,
                                               alignment: .center)
                                )
                            HStack {
                                Button(action: {
                                    userPrefersDarkTheme.toggle()
                                }) {
                                    Image(systemName: userPrefersDarkTheme ?
                                          "sun.max.circle" : "moon.circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: buttonSize,
                                               height: buttonSize,
                                               alignment: .topLeading)
                                        .foregroundColor(content)
                                }
                                .frame(width: buttonSize, height: buttonSize,
                                       alignment: .leading)
                                .padding(4)

                                Button(action: {
                                    shouldRing.toggle()
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.3)) {
                                        bellAngle = shouldRing ? 30 : 0

                                    }

                                }) {
                                    Image(systemName: "bell")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: buttonSize, height: buttonSize,
                                               alignment: .topLeading)
                                        .foregroundColor(content)
                                        .rotationEffect(Angle(degrees: bellAngle))
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

        }.onAppear {
            userPrefersDarkTheme = newMainViewModel.userPrefersDarkMode
        }
        .onChange(of: userPrefersDarkTheme) { preference in
            newMainViewModel.userDidSetThemePreference(userPrefersDarkMode: preference)
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
