//
//  SettingsLitecoinDetailView.swift
//  brainwallet
//
//  Created by Kerry Washington on 24/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SettingsLitecoinDetailView: View {

    let largeFont: Font = .barlowSemiBold(size: 19.0)
    let detailFont: Font = .barlowLight(size: 15.0)
    let largeButtonHeight: CGFloat = 45.0
    let dotSize: CGFloat = 12.0

    let litecoinSyncDetailA: String = "Syncing is a process where Brainwallet scans the Litecoin blockchain to see if any transactions that match your seed words (private keys) are in any transactions."
    let litecoinSyncDetailB: String = "Found transactions are added to your databases and added or subtracted from your balance. There is no Litecoin in any wallet. Litecoin is only found on the network.  Your balance is a simple way to check your transaction history."
    let litecoinSyncDetailC: String = "This process can take 20 - 45 mins depending on your connectivty to the Litecoin network."

    @Binding
    var willSync: Bool

    init(willSync: Binding<Bool>) {
        _willSync = willSync
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height

                ZStack {
                    List {
                        HStack {
                            Text(String(localized: "Sync Litecoin"))
                                .font(largeFont)
                                .foregroundColor(BrainwalletColor.content)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                        }
                        .frame(height: height * 0.1)
                        .padding(.top, 1.0)
                        .background(BrainwalletColor.background)
                        .listRowBackground(BrainwalletColor.background)
                        .listRowSeparator(.hidden)

                        HStack {
                            Text(litecoinSyncDetailA)
                                .font(detailFont)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(BrainwalletColor.content)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                        }
                        .padding(.top, 1.0)
                        .background(BrainwalletColor.background)
                        .listRowBackground(BrainwalletColor.background)
                        .listRowSeparator(.hidden)

                        HStack {

                            Text(litecoinSyncDetailB)
                                .font(detailFont)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(BrainwalletColor.content)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                        }
                        .padding(.top, 1.0)
                        .background(BrainwalletColor.background)
                        .listRowBackground(BrainwalletColor.background)
                        .listRowSeparator(.hidden)

                        HStack {

                            Text(litecoinSyncDetailC)
                                .font(detailFont)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(BrainwalletColor.content)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                        }
                        .padding(.top, 1.0)
                        .background(BrainwalletColor.background)
                        .listRowBackground(BrainwalletColor.background)
                        .listRowSeparator(.hidden)
                        .background(BrainwalletColor.background)
                        HStack {
                            Button(action: {
                                willSync.toggle()
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                        .frame(width: width * 0.9, height: largeButtonHeight,
                                            alignment: .center)
                                        .frame(height: largeButtonHeight, alignment: .center)
                                        .foregroundColor(BrainwalletColor.surface)

                                    Text("Sync")
                                        .frame(width: width * 0.9, height: largeButtonHeight,
                                            alignment: .center)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .font(largeFont)
                                        .foregroundColor(BrainwalletColor.content)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                                .stroke(BrainwalletColor.content, lineWidth: 1.0)
                                        )
                                }
                            }
                        }
                        .frame(height: height * 0.2)
                        .background(BrainwalletColor.background)
                        .listRowBackground(BrainwalletColor.background)
                        .listRowSeparator(.hidden)
                        .padding(.bottom, 32.0)
                        Spacer()

                    }
                    .background(BrainwalletColor.background)
                    .listRowBackground(BrainwalletColor.background)
                    .listRowSeparator(.hidden)
                }
            }
        }
    }
}
