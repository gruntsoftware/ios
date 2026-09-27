//
//  SettingsLitecoinDetailView.swift
//  brainwallet
//
//  Created by Kerry Washington on 24/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI
import FirebaseAnalytics
import BrainwalletiOSPrivateGeneralPurpose

struct SettingsLitecoinDetailView: View {
    
    @EnvironmentObject
    var viewModel: NewMainViewModel

    @Binding
    var willSync: Bool

    @StateObject
    private var storeKitManager = StoreKitManager()

    @State
    private var userPrefersMainnetVsTrusted: Bool = UserDefaults.userPrefersUsingTrustedNode

    let fees: Fees
    
    let rate: Rate

    @State
    private var feesPerFiat = ""
    
    @State
    private var nodeLabel: String = String(localized: "Set IP Address")
    
    @State
    private var selectedNetworkFeeIndex = 1
     
    private let syncButtonHeight: CGFloat = 40.0
    private let syncButtonWidth: CGFloat = 180.0
    
    init(willSync: Binding<Bool>,
         fees: Fees,
         currentRate: Rate?) {
        _willSync = willSync
        self.fees = fees
        self.rate = currentRate ?? Rate(code: "", name: "", rate: 0.0, lastTimestamp: Date())

        let prefersTrustedNode = UserDefaults.userPrefersUsingTrustedNode
        _nodeLabel = State(initialValue: Self.nodeLabel(prefersTrustedNode: prefersTrustedNode))
    }

    private static func nodeLabel(prefersTrustedNode: Bool) -> String {
        if prefersTrustedNode {
            if let trustedIpAddress = UserDefaults.userTrustedNodeIpAddress,
               let trustedPort = UserDefaults.userTrustedNodePort {
                return "\(trustedIpAddress):\(trustedPort)"
            } else {
                return String(localized: "Set IP Address")
            }
        } else {
            return String(localized: "Litecoin Mainnet")
        }
    }
     
    private func purchaseTrustedNodeOrEditIPAddress() {
        if storeKitManager.isPurchasedNonConsumable(trustedLTCNodeProductId) {
            viewModel.shouldShowEditTrustedIPAddress = true
        } else {
            viewModel.shouldShowTrustedNodeSheet = true
        }
    }

    /// Litoshis (fee-per-kb) for the currently selected Picker tag (0 = economy, 1 = regular, 2 = luxury).
    /// Fee tier math lives in `NetworkFeeTier` (FeeManager.swift) so it's unit-testable on its own.
    private func feeInLitoshis(forTag tag: Int) -> UInt64 {
        (NetworkFeeTier(rawValue: tag) ?? .regular).litoshis(from: fees)
    }

    /// Converts the selected fee from litoshis to fiat and persists it as the user's
    /// preferred network fee.
    private func updateFeesPerFiat(litoshis: UInt64) {
        feesPerFiat = NetworkFeeTier.formattedFiatAmount(litoshis: litoshis, rate: rate)
        UserDefaults.userSetPreferredNetworkFee = Int(litoshis)
    }

    /// Finds which of the 3 fee tiers (economy/regular/luxury -> 0/1/2) is numerically
    /// closest to a previously stored litoshi fee value.
    private func closestFeeIndex(toLitoshis storedFee: Int) -> Int {
        NetworkFeeTier.closest(to: storedFee, in: fees).rawValue
    }

    var body: some View {
            VStack(alignment: .leading, spacing: 20.0) {
                
                // MARK: - Peer sync mode
                VStack(alignment: .leading, spacing: 6.0) {
                    Divider()
                        .frame(height: 1)
                        .overlay(Color.white)
                    
                    Text(String(localized: "Peer sync mode"))
                        .modifier(BWIPSSemiBold(size: 15.0))
                        .foregroundColor(BrainwalletColor.content)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(String(localized: "Set from spv peers in the Litecoin mainnet or a trusted peer to sync with the blockchain"))
                        .modifier(BWIPSRegular(size: 14.0, lineLimit: 2))
                        .foregroundColor(BrainwalletColor.content)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 10.0) {
                            Text(String(localized: "Toggle mode"))
                                .modifier(BWIPSSemiBold(size: 14.0))
                                .foregroundColor(BrainwalletColor.content)
                            
                            Toggle(isOn: $userPrefersMainnetVsTrusted) {
                                
                            }
                            .labelsHidden()
                            .toggleStyle(.switch)
                            .onChange(of: userPrefersMainnetVsTrusted) { _, newValue in
                                UserDefaults.userPrefersUsingTrustedNode = newValue
                                nodeLabel = Self.nodeLabel(prefersTrustedNode: newValue)
                            }
                        }
                         
                        Spacer()
                        
                        Button(action: {
                            purchaseTrustedNodeOrEditIPAddress()
                        }) {
                            Text(nodeLabel)
                                .frame(width: syncButtonWidth, height: syncButtonHeight,
                                       alignment: .center)
                                .modifier(BWIPSSemiBold(size: 15.0))
                                .foregroundStyle(.white)
                                .background(
                                    RoundedRectangle(cornerRadius: syncButtonHeight/2)
                                        .fill(BrainwalletColor.background)
                                        
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 6.0)
                }
                
                // MARK: - Sync duration
                VStack(alignment: .leading, spacing: 0.0) {
                    Divider()
                        .frame(height: 1)
                        .overlay(Color.white)
                    
                    HStack(alignment: .center) {
                        GeometryReader { geo in
                            VStack(alignment: .center, spacing: 12.0) {
                                Text(String(localized: "Full Blockchain sync:"))
                                    .modifier(BWIPSSemiBold(size: 15.0))
                                    .foregroundColor(BrainwalletColor.content)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(String(localized: "If transactions are missing you can run a blockchain sync. This can take >3 hours."))
                                    .modifier(BWIPSRegular(size: 14.0, lineLimit: 3))
                                    .foregroundColor(BrainwalletColor.content)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(height: 90.0)
                        .padding(.top, 2.0)
                        
                        Button(action: {
                            willSync.toggle()
                            Analytics.logEvent("did_start_resync",
                                               parameters: nil)
                        }) {
                            Text("Sync")
                                .frame(width: syncButtonWidth, height: syncButtonHeight,
                                       alignment: .center)
                                .modifier(BWIPSSemiBold(size: 15.0))
                                .foregroundStyle(.white)
                                .background(
                                    RoundedRectangle(cornerRadius: syncButtonHeight/2)
                                        .fill(BrainwalletColor.background)
                                )
                        }
                        .frame(height: 44.0)
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 4.0)
                }
                
                // MARK: - Network fee
                VStack(alignment: .leading, spacing: 6.0) {
                    Divider()
                        .frame(height: 1)
                        .overlay(Color.white)
                    
                    Text(String(localized: "Network Fee (per kb):"))
                        .modifier(BWIPSSemiBold(size: 15.0))
                        .foregroundColor(BrainwalletColor.content)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(String(localized: "A higher value means the transaction completes sooner"))
                        .modifier(BWIPSRegular(size: 14.0, lineLimit: 2))
                        .foregroundColor(BrainwalletColor.content)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    GeometryReader { geo in
                        let height = geo.size.height
                        HStack(alignment: .center, spacing: 8.0) {
                            Text(String(localized: "Choose preferred fee:"))
                                .modifier(BWIPSSemiBold(size: 15.0, lineLimit: 1))
                                .foregroundColor(BrainwalletColor.content)
                            
                            Picker("", selection: $selectedNetworkFeeIndex) {
                                Text("\(fees.economy) ł").modifier(BWIPSSemiBold(size: 14.0)).tag(0)
                                Text("\(fees.regular) ł").modifier(BWIPSSemiBold(size: 14.0)).tag(1)
                                Text("\(fees.luxury) ł").modifier(BWIPSSemiBold(size: 14.0)).tag(2)
                            }
                            .pickerStyle(.wheel)
                            .frame(width: geo.size.width * 0.4, height: 80.0)
                            .clipped()
                            .onAppear {
                                let fetchedFee = UserDefaults.userSetPreferredNetworkFee
                                selectedNetworkFeeIndex = closestFeeIndex(toLitoshis: fetchedFee)
                                updateFeesPerFiat(litoshis: feeInLitoshis(forTag: selectedNetworkFeeIndex))
                            }
                            .onChange(of: selectedNetworkFeeIndex) { _, _ in
                                switch selectedNetworkFeeIndex {
                                    case 0: updateFeesPerFiat(litoshis: fees.economy)
                                    case 1: updateFeesPerFiat(litoshis: fees.regular)
                                    case 2: updateFeesPerFiat(litoshis: fees.luxury)
                                    default: updateFeesPerFiat(litoshis: fees.luxury)
                                }
                            }
                            
                            Text(feesPerFiat)
                                .modifier(BWIPSRegular(size: 14.0, lineLimit: 1))
                                .foregroundColor(BrainwalletColor.content)
                        } 
                    }
                    .frame(height: 80.0)
                    .padding(.top, 2.0)
                }
                .padding(.bottom, 12.0)
            }.onChange(of: viewModel.shouldShowEditTrustedIPAddress) { _,newValue in
                debugPrint("||||shouldShowEditTrustedIPAddress \(newValue)")
                nodeLabel = Self.nodeLabel(prefersTrustedNode: true)
            }
    }
}
