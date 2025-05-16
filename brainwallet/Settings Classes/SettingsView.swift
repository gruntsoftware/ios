//
//  SettingsView.swift
//  brainwallet
//
//  Created by Kerry Washington on 08/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
//
import SwiftUI

enum SettingsRowEnum {
    case lock
    case themeMode
    case toggleSwitch
}

struct SettingsView: View {
    
    @ObservedObject
    var settingsViewModel: SettingsViewModel
    
    @State
    private var securityRowHeight: CGFloat = 44.0
    
    @State
    private var currencyRowHeight: CGFloat = 44.0
    
    @State
    private var gamesRowHeight: CGFloat = 44.0
    
    @State
    private var blockchainRowHeight: CGFloat = 44.0
    
    @State
    private var didActivateLock: Bool = false
    
    @State
    private var didActivateTheme: Bool = false
    
    @State
    private var shouldShowWebView: Bool = false
      
    
    let infoRowHeight = 44.0
    let footerRowHeight = 40.0
    let accessoryRowHeight = 44.0
    let expandableRowHeight = 100.0
    
    init(viewModel: SettingsViewModel) {
        self.settingsViewModel = viewModel
    }
    
    var body: some View {
            GeometryReader { geometry in
                
                let width = geometry.size.width
                let height = geometry.size.height
                
                ScrollView {
                    HStack {
                        VStack {
                            SettingsRowExpandableView(title: "Security", detail: "", expandedHeight: $securityRowHeight)
                                .frame(height: securityRowHeight)
                            SettingsRowExpandableView(title: "Currency", detail: "", expandedHeight: $currencyRowHeight)
                                .frame(height: currencyRowHeight)
                            SettingsRowExpandableView(title: "Games", detail: "", expandedHeight: $gamesRowHeight)
                                .frame(height: gamesRowHeight)
                            SettingsRowExpandableView(title: "Blockchain: Litecoin", detail: "", expandedHeight: $blockchainRowHeight)
                                .frame(height: blockchainRowHeight)
                            SettingsRowWebView(title: "Support", detail: BrainwalletSupport.dashboard, rowHeight: infoRowHeight)
                                .frame(height: infoRowHeight)
                            SettingsRowWebView(title: "Social", detail: BrainwalletSocials.linktree, rowHeight: infoRowHeight)
                                .frame(height: infoRowHeight)
                            SettingsRowLockView(title: "Lock", detail: "", rowHeight: accessoryRowHeight, accessoryEnum: .lock, didActivate: $didActivateLock)
                                .frame(height: accessoryRowHeight)
                            SettingsRowThemeView(title: "Theme", rowHeight: accessoryRowHeight, accessoryEnum: .themeMode, didActivate: $didActivateTheme)
                                .frame(height: accessoryRowHeight)
                            SettingsRowFooterView(title: "App Version", detail: AppVersion.string, rowHeight: footerRowHeight)
                                .frame(height: footerRowHeight)
                        }
                    }
                }
                .frame(width: width * 0.9)
                .background(BrainwalletColor.surface)
                
            }
            .onChange(of: didActivateLock) { _ in
                delay(1.0) {
                    settingsViewModel.updateStatus(shouldLockBrainwallet: didActivateLock)
                }
            }
            .onChange(of: didActivateTheme) { _ in
                settingsViewModel.updateTheme(shouldBeDark: didActivateTheme)
            }
    }
}
