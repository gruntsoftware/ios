//
//  SettingsView.swift
//  brainwallet
//
//  Created by Kerry Washington on 08/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
//
import SwiftUI
import BrainwalletiOSPrivateGeneralPurpose

struct SettingsView: View {
    
    @ObservedObject
    var newMainViewModel: NewMainViewModel
    
    @Binding var path: [Onboarding]
    
    @State
    private var shouldLock: Bool = false
    
    @State
    private var didTriggerLock: Bool = false
    
    @State
    private var userPrefersDarkMode: Bool = true
    
    @State
    private var shouldExpandSecurity: Bool = false
    
    @State
    private var shouldExpandCurrency: Bool = false
    
    @State
    private var shouldExpandGames: Bool = false
    
    @State
    private var shouldExpandBlockchain: Bool = false
    
    @State
    private var shouldShowSocialSheet: Bool = false
    
    @State
    private var shouldShowSupportSheet: Bool = false
    
    let footerRowHeight: CGFloat = 55.0
    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let themeBorderSize: CGFloat = 44.0
    
    private let supportURL = URL(string: "https://brainwallet.co/support")!
    
    private let socialsURL = URL(string: BrainwalletSocials.linktree)!
    
    init(viewModel: NewMainViewModel, path: Binding<[Onboarding]>) {
        self.newMainViewModel = viewModel
        _path = path
        
        userPrefersDarkMode = UserDefaults.userPreferredDarkTheme
    }
    
    var body: some View {
        
        NavigationStack {
            GeometryReader { geometry in
                let width = geometry.size.width
                
                ZStack {
                    
                    if userPrefersDarkMode {
                        BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                    } else {
                        BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                            .padding(.trailing, 1.0)
                    }
                    
                    HStack {
                        VStack {
                            SettingsExpandingSecurityView(title: String(localized: "Security"),
                                                          viewModel: newMainViewModel, shouldExpandSecurity: $shouldExpandSecurity)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .animation(.easeInOut(duration: 0.3), value: shouldExpandSecurity)
                            .padding(.top, leadRowPad)
                            .padding(.leading, leadRowPad)
                            .padding(.trailing, trailRowPad)
                            SettingsExpandingCurrencyView(title: String(localized: "Fiat Currency"),
                                                          viewModel: newMainViewModel,
                                                          shouldExpandCurrency: $shouldExpandCurrency)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .animation(.easeInOut(duration: 0.3), value: shouldExpandCurrency)
                            .padding(.leading, leadRowPad)
                            .padding(.trailing, trailRowPad)
                            SettingsExpandingBlockchainView(title: String(localized: "Blockchain: Litecoin"),
                                                            viewModel: newMainViewModel,
                                                            shouldExpandBlockchain: $shouldExpandBlockchain)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .animation(.easeInOut(duration: 0.3), value: shouldExpandBlockchain)
                            .padding(.leading, leadRowPad)
                            .padding(.trailing, trailRowPad)
                            SettingsLabelView(title: String(localized: "Social"),
                                              detailText: "linktr.ee/brainwallet")
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .padding(.leading, leadRowPad)
                            .padding(.trailing, trailRowPad)
                            .onTapGesture {
                                shouldShowSocialSheet.toggle()
                            }
                            SettingsLabelView(title: String(localized: "Support"),
                                              detailText: "support.brainwallet.co")
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .padding(.leading, leadRowPad)
                            .padding(.trailing, trailRowPad)
                            .onTapGesture {
                                shouldShowSupportSheet.toggle()
                            }
                            SettingsActionThemeView(title:
                                                        userPrefersDarkMode ?
                                                    String(localized: "Dark Mode")
                                                    : String(localized: "Light Mode"),
                                                    action: .preferDarkMode,
                                                    userPrefersDark: $userPrefersDarkMode)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .padding(.leading, leadRowPad)
                            .padding(.trailing, trailRowPad)
                            
                            SettingsActionLockView(title: String(localized: "Lock"),
                                                   detailText: "", action: .lock, didTriggerLock: $didTriggerLock)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .padding(.leading, leadRowPad)
                            .padding(.trailing, trailRowPad)
                            
                            SettingsLabelView(title: String(localized: "App Version:"),
                                              detailText: "\(AppVersion.string)")
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .padding(.leading, leadRowPad)
                            .padding(.trailing, trailRowPad)
                            Divider()
                                .frame(height: 1)
                                .frame(width: width * 0.9)
                                .overlay(Color.white)
                            Spacer()
                            
                        }
                        .frame(width: width * 0.9)
                        .onChange(of: userPrefersDarkMode) { _,hasDarkPreference in
                            newMainViewModel.updateTheme(shouldBeDark: hasDarkPreference)
                        }
                        .onChange(of: didTriggerLock) { _,_ in
                            shouldLock = true
                            if shouldLock {
                                delay(0.9) {
                                    newMainViewModel.lockBrainwallet()
                                    delay(1.2) {
                                        didTriggerLock = false
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 1.0)
                }
            }
        }
        .simultaneousGesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
            .onEnded({ value in
                let didStartAtLeadingEdge = value.startLocation.x < 24.0
                if didStartAtLeadingEdge && value.translation.width < 0 {
                    newMainViewModel.userDidTapTheSettingsButton()
                }
            }))
        .sheet(isPresented: $shouldShowSocialSheet) {
            ZStack {
                BrainwalletColor.background.edgesIgnoringSafeArea(.all)
                WebView(url: socialsURL, scrollToSignup: .constant(false))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cornerRadius(8.0)
                    .padding(.top, 12.0)
                    .padding(8.0)
            }
        }
        .sheet(isPresented: $shouldShowSupportSheet) {
            ZStack {
                BrainwalletColor.background.edgesIgnoringSafeArea(.all)
                WebView(url: supportURL, scrollToSignup: .constant(false))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cornerRadius(8.0)
                    .padding(.top, 12.0)
                    .padding(8.0)
            }
        }
        .sheet(isPresented: $newMainViewModel.shouldShowTrustedNodeSheet) {
            TrustedNodeProductsModalView(userPrefersDarkTheme: userPrefersDarkMode) { didPurchase in
                Task(priority: .userInitiated) {
                    if didPurchase {
                        UserDefaults.userTrustedNodePurchased = didPurchase
                        newMainViewModel.shouldShowTrustedNodeSheet = false
                        delay(0.1) {
                            newMainViewModel.shouldShowEditTrustedIPAddress = true
                        }
                    }
                }
            }
            .padding(.bottom, 4)
            .presentationDetents([.medium])
            .presentationBackground(BrainwalletColor
                .modalBackground(userPrefersDarkTheme: userPrefersDarkMode))
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $newMainViewModel.shouldShowEditTrustedIPAddress) {
            SetTrustedNodeIPModalView(shouldPresent: $newMainViewModel.shouldShowEditTrustedIPAddress,
                                      userPrefersDarkTheme: userPrefersDarkMode)
            .padding(.bottom, 4)
            .presentationDetents([.medium])
            .presentationBackground(BrainwalletColor
                .modalBackground(userPrefersDarkTheme: userPrefersDarkMode))
            .presentationDragIndicator(.visible)
        }
    }
}


