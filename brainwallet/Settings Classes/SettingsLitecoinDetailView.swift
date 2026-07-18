//
//  SettingsLitecoinDetailView.swift
//  brainwallet
//
//  Created by Kerry Washington on 24/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI
import FFirebaseAnalytics

struct SettingsLitecoinDetailView: View {

    let detailFont: Font = .ibmPlexSansLight(size: 15.0)
    let dotSize: CGFloat = 12.0

    let litecoinSyncDetailA: String = String(localized: "Syncing is a process where Brainwallet scans the Litecoin blockchain to see if any transactions that match your seed words (private keys) are in any transactions.")
    let litecoinSyncDetailB: String = String(localized: "Found transactions are added to the device's database and added or subtracted creating your Brainwallet's balance. There is no Litecoin in any wallet. Litecoin is only found on the network.  Brainwallet is a simple way to check your transaction history and it stores your private keys")
    let litecoinSyncDetailC: String = String(localized: "This process can take 5 - 45 mins depending on your connectivty to the Litecoin network.")

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
                            Text(String(localized: "Sync to the Litecoin Blockchain"))
                                .modifier(BWIPSSemiBold(size: 19.0))
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
                                .modifier(BWIPSLight(size: 18.0))
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
                                .modifier(BWIPSLight(size: 18.0))
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
                                .modifier(BWIPSLight(size: 18.0))
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
                                Analytics.logEvent("did_start_resync",
                                                   parameters: nil)
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
                                        .modifier(BWIPSSemiBold(size: 19.0))
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
