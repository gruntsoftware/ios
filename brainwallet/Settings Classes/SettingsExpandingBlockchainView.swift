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

    /// Height of the detail panel when expanded; total expanded row = closedRowHeight + this.
    private let detailExpandedHeight: CGFloat = 340.0

    init(title: String, viewModel: NewMainViewModel,
         shouldExpandBlockchain: Binding <Bool>) {
        self.title = title
        _shouldExpandBlockchain = shouldExpandBlockchain
        self.viewModel = viewModel
    }

    @ViewBuilder
    private var blockchainDetail: some View {
        SettingsLitecoinDetailView(willSync: $willSync,
                                   fees: viewModel.currentFees,
                                   currentRate: viewModel.exchangeRate)
            .frame(maxWidth: .infinity)
            .environmentObject(viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            Divider()
                .frame(height: 1)
                .overlay(Color.white)
            Text(title)
                .modifier(BWIPSSemiBold(size: 15.0))
                .foregroundColor(BrainwalletColor.content)
                .frame(maxWidth: .infinity, alignment: .leadingFirstTextBaseline)
                .frame(height: closedRowHeight)
                .overlay(alignment: .trailing) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            shouldExpandBlockchain.toggle()
                        }
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                    }) {
                        Image(systemName: "chevron.down")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: expandArrowSize, height: expandArrowSize)
                            .foregroundColor(BrainwalletColor.content)
                            .rotationEffect(Angle(degrees: shouldExpandBlockchain ? 180 : 0))
                    }
                    .frame(width: 30.0, height: 30.0)
                    .contentShape(Rectangle())
                }

            ScrollView(.vertical) {
                blockchainDetail
            }
            .frame(height: shouldExpandBlockchain ? detailExpandedHeight : 0.0, alignment: .top)
            .clipped()
            .opacity(shouldExpandBlockchain ? 1.0 : 0.0)
            .allowsHitTesting(shouldExpandBlockchain)
            .scrollIndicators(.visible)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .fixedSize(horizontal: false, vertical: true)
        .alert(String(localized: "Sync with Blockchain?"),
               isPresented: $willSync,
               actions: {
            Button(String(localized: "Cancel"), role: .cancel) { }
            Button( String(localized: "Ok"), role: .destructive) {
                viewModel.userWillSyncBlockchain()
            }
        },
               message: {
            Text("You will not be able to send Litecoin while syncing. It may take a while.")
        })
    }
}
