//
//  SettingsExpandingBlockchainView.swift
//  brainwallet
//
//  Created by Kerry Washington on 19/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SettingsExpandingBlockchainView: View {

    @ObservedObject
    var viewModel: NewMainViewModel
    @Binding
    var shouldExpandBlockchain: Bool

    @State
    private var rotationAngle: Double = 0

    @State
    private var willSync: Bool = false

    private var title: String
    let largeFont: Font = .barlowSemiBold(size: 19.0)
    let detailFont: Font = .barlowLight(size: 18.0)

    init(title: String, viewModel: NewMainViewModel, shouldExpandBlockchain: Binding <Bool>) {
        self.title = title
        _shouldExpandBlockchain = shouldExpandBlockchain
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                    let width = geometry.size.width
                    let height = geometry.size.height
                ZStack {
                    VStack {
                        HStack {
                            VStack {
                                Text(title)
                                    .font(largeFont)
                                    .foregroundColor(BrainwalletColor.content)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 8.0)
                                Text("")
                                    .font(detailFont)
                                    .kerning(0.6)
                                    .foregroundColor(BrainwalletColor.content)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom, 1.0)
                            }

                            Spacer()
                            VStack {
                                Button(action: {
                                    shouldExpandBlockchain.toggle()
                                }) {
                                    VStack {
                                        HStack {
                                            Image(systemName: "chevron.right")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: expandArrowSize, height: expandArrowSize)
                                                .foregroundColor(BrainwalletColor.content)
                                                .rotationEffect(Angle(degrees: shouldExpandBlockchain ? 90 : 0))
                                        }
                                    }
                                    .frame(width: 30.0, height: 30.0, alignment: .top)
                                    .padding(.top, 8.0)
                                }
                                .frame(width: 30.0, height: 30.0)
                            }
                        }
                        .padding(.top, 1.0)
                        SettingsLitecoinDetailView(willSync: $willSync)
                            .transition(.opacity)
                            .transition(.slide)
                            .animation(.easeInOut(duration: 0.3))
                            .frame(height: shouldExpandBlockchain ? 200 : 0.1)
                        Spacer()
                    }

                }
            }
        }
    }
}
