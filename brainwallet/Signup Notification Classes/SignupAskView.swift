//
//  SignupAskView.swift
//  brainwallet
//
//  Created by Kerry Washington on 4/27/26.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
 

import SwiftUI

struct SignupAskView: View {
    
    @ObservedObject
    var viewModel: NewMainViewModel
    
    @Binding
    var path: [Onboarding]
    
    private var isRestoringAnOldWallet: Bool
    
    
    let selectorFont: Font = .ibmPlexSansSemiBold(size: 16.0)
    let buttonLightFont: Font = .ibmPlexSansLight(size: 16.0)
    let regularButtonFont: Font = .ibmPlexSansRegular(size: 20.0)
    let largeButtonFont: Font = .ibmPlexSansSemiBold(size: 24.0)
    let detailFont: Font = .ibmPlexSansRegular(size: 22.0)
    let billboardFont: Font = .ibmPlexSansSemiBold(size: 50.0)
    
    let versionFont: Font = .ibmPlexSansSemiBold(size: 16.0)
    let verticalPadding: CGFloat = 20.0
    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let themeButtonSize: CGFloat = 28.0
    let themeBorderSize: CGFloat = 44.0
    let arrowSize: CGFloat = 40.0
    
    let userPrefersDarkTheme = UserDefaults.userPreferredDarkTheme
    
    init(isRestoringAnOldWallet: Bool,
         viewModel: NewMainViewModel, path: Binding<[Onboarding]>) {
        self.viewModel = viewModel
        self.isRestoringAnOldWallet = isRestoringAnOldWallet
        _path = path
    }
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BrainwalletColor.midnight.edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    // Back button
                    Button(action: { path.removeLast() }) {
                        Image(systemName: "arrow.backward")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: squareImageSize, height: squareImageSize)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // Body text
                    Text("Sign up to updates, news and contests!\n\nPlease give us permission for our occasional push notifications.")
                        .modifier(BWIPSRegular(size: 22.0, lineLimit: 4))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    // Primary button
                    Button(action: {
                        viewModel.requestNotificationPermissions()
                    }) {
                        Text("Yes!  Send me updates!")
                            .modifier(BWIPSSemiBold(size: 20.0))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(height: largeButtonHeight)
                            .overlay(
                                RoundedRectangle(cornerRadius: largeButtonHeight / 2)
                                    .stroke(.white, lineWidth: 1.0)
                            )
                    }
                    
                    // Secondary button — now left-aligned to match VStack
                    Button(action: {
                        if isRestoringAnOldWallet {
                            path.append(.inputWordsView)
                        } else {
                            path.append(.yourSeedWordsView)
                        } 
                    }) {
                        Text("Maybe later (Skip)")
                            .modifier(BWIPSRegular(size: 15.0))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(32)
                }
                .padding(.horizontal, 24)
                .onChange(of: viewModel.didRegisterForNotifications) { _,_ in
                    if isRestoringAnOldWallet {
                        path.append(.inputWordsView)
                    } else {
                        path.append(.yourSeedWordsView)
                    } 
                }
            }
        }
    }
}


