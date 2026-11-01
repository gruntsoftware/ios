//
//  SecurityListView.swift
//  brainwallet
//
//  Created by Kerry Washington on 08/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
//
import SwiftUI

struct SecurityListView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @State
    private var willChangePIN: Bool = false

    @State
    private var willShowSeedPhrase: Bool = false

    @State
    private var userTappedForBrainwalletPhrase: Bool = false

    @State
    private var shouldShowPINAlert: Bool = false

    @State
    private var brainwalletPhrasePIN: String = ""

    @State
    private var willShareData: Bool = false

    @State
    private var userPrefersDarkMode: Bool = true
    
    @State
    private var emojiCount: Int = 0

    let footerRowHeight: CGFloat = 55.0

    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let themeBorderSize: CGFloat = 44.0

    let rowBackground: Color = BrainwalletColor.background
    init(viewModel: NewMainViewModel) {
        self.newMainViewModel = viewModel
        willShareData = UserDefaults.hasAquiredShareDataPermission
    }

    var body: some View {

        NavigationStack {
            GeometryReader { _ in

                ZStack {
                    BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                        List {
                            SettingsResetPINView(title: String(localized: "Update PIN"),
                                detailText: String(localized: "PIN"),
                                action: .toggle, isOn: $willChangePIN)
                                .frame(height: updatePINRowHeight)
                                .background(BrainwalletColor.background)
                                .listRowBackground(BrainwalletColor.background)
                                .listRowSeparatorTint(BrainwalletColor.content)
                            SettingsActionSeedPhraseView(title:
                                String(localized: "Seed Phrase"),
                                detailText: String(localized: "Show my seed phrase"),
                                willShowSeedPhrase: $willShowSeedPhrase)
                                .frame(height: phraseRowHeight)
                                .background(BrainwalletColor.background)
                                .listRowBackground(BrainwalletColor.background)
                                .listRowSeparatorTint(BrainwalletColor.content)
                            if (emojiCount >= 3) {
                                SettingsActionBrainwalletPhraseView(title:
                                                                        String(localized: "Brainwallet Phrase"),
                                                                    detailText: String(localized: "Show my emojis"),
                                                                    userTappedForBrainwalletPhrase: $shouldShowPINAlert)
                                .frame(height: phraseRowHeight)
                                .background(BrainwalletColor.background)
                                .listRowBackground(BrainwalletColor.background)
                                .listRowSeparatorTint(BrainwalletColor.content)
                            }
                            SettingsActionShareView(title:
                                String(localized: "Share Anonymous Data"),
                                detailText: "to improve Brainwallet",
                                action: .shareData, willShareData: $willShareData)
                                .frame(height: toggleRowHeight)
                                .background(BrainwalletColor.background)
                                .listRowBackground(BrainwalletColor.background)
                                .listRowSeparatorTint(BrainwalletColor.content)
                                .padding(.bottom, 44.0)
                        }
                        .listStyle(.plain)
                        .scrollIndicators(.hidden)
                        .onChange(of: willChangePIN) { _,_ in
                            newMainViewModel.userWillChangePIN()
                        }
                        .onChange(of: willShareData) { _,_ in
                            newMainViewModel.userWillShareData()
                        }
                        .sheet(isPresented: $willShowSeedPhrase) {
                            if let walletManager = newMainViewModel.walletManager {
                                // Sheets don't inherit a NavigationStack; without one the keyboard toolbar (Done) isn't shown
                                NavigationStack {
                                    SeedWordContainerView(walletManager: walletManager)
                                        .toolbar(.hidden, for: .navigationBar)
                                }
                            }

                        }
                        .alert(Text("Enter your PIN to view your Brainwallet phrase"),
                               isPresented: $shouldShowPINAlert) {
                            SecureField("Enter PIN", text: $brainwalletPhrasePIN)
                                .keyboardType(.numberPad)
                            Button("Cancel", role: .cancel) {
                                brainwalletPhrasePIN = ""
                            }
                            Button("Enter") {
                                if newMainViewModel.walletManager?.emojiString(pin: brainwalletPhrasePIN) != nil {
                                    userTappedForBrainwalletPhrase = true
                                } else {
                                    brainwalletPhrasePIN = ""
                                }
                            }
                        }
                        .sheet(isPresented: $userTappedForBrainwalletPhrase,
                               onDismiss: { brainwalletPhrasePIN = "" }) {
                            if let walletManager = newMainViewModel.walletManager {
                                NavigationStack {
                                    BrainwalletPhraseContainerView(shouldShow: $userTappedForBrainwalletPhrase,
                                                                   walletManager: walletManager,
                                                                   pin: brainwalletPhrasePIN)
                                        .toolbar(.hidden, for: .navigationBar)
                                }
                            }
                        }
                        .onAppear(perform: updateEmojiCount)
                        .onReceive(NotificationCenter
                            .default.publisher(for: .emojiStringDidChangeNotification)
                            .receive(on: DispatchQueue.main)) { _ in
                            updateEmojiCount()
                        }
                }
            }
        }
    }

    private func updateEmojiCount() {
        emojiCount = newMainViewModel.walletManager?.emojiStringCount() ?? 0
    }
}
