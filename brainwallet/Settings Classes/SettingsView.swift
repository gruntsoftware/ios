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
      
    
    let infoRowHeight = 44.0
    let accessoryRowHeight = 44.0
    let expandableRowHeight = 100.0
    
    init(viewModel: SettingsViewModel) {
        self.settingsViewModel = viewModel
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let width = geometry.size.width
            
                ScrollView {
                    VStack {
                        SettingsRowExpandableView(title: "Security", detail: "", expandedHeight: $securityRowHeight)
                            .frame(height: securityRowHeight)
                        SettingsRowExpandableView(title: "Currency", detail: "", expandedHeight: $currencyRowHeight)
                            .frame(height: currencyRowHeight)
                        SettingsRowExpandableView(title: "Games", detail: "", expandedHeight: $gamesRowHeight)
                            .frame(height: gamesRowHeight)
                        SettingsRowExpandableView(title: "Blockchain: Litecoin", detail: "", expandedHeight: $blockchainRowHeight)
                            .frame(height: blockchainRowHeight)
                        SettingsRowInfoView(title: "Support", detail: BrainwalletSupport.dashboard, rowHeight: infoRowHeight)
                            .frame(height: infoRowHeight)
                        SettingsRowInfoView(title: "Social", detail: BrainwalletSocials.linktree, rowHeight: infoRowHeight)
                            .frame(height: infoRowHeight)
                        SettingsRowAccessoryView(title: "Lock", detail: "", rowHeight: accessoryRowHeight, accessoryEnum: .lock, didActivate: $didActivateLock)
                            .frame(height: accessoryRowHeight)
                        SettingsRowAccessoryView(title: "Theme", detail: "", rowHeight: accessoryRowHeight, accessoryEnum: .themeMode, didActivate: $didActivateTheme)
                            .frame(height: accessoryRowHeight)
                        SettingsRowInfoView(title: "App Version", detail: AppVersion.string, rowHeight: infoRowHeight, nearBlackStyle: true)
                            .frame(height: infoRowHeight)
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
