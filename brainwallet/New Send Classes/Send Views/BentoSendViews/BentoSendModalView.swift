//
//  BentoSendModalView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
import FirebaseAnalytics

struct BentoSendModalView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @Binding
    var userPrefersDarkTheme: Bool

    @Binding
    var userWalletIsEmpty: Bool

    @Binding
    var shouldShowView: Bool

    @State
    private var selectedSendPage: Int = 0

    @State
    private var shouldShowEmptyWalletAlert: Bool = false

    @State
    private var sendLTCAddress: String = ""

    @State
    private var sendAmount: Double = 0.0

    @State
    private var sentTextColor: Color = .black

    @State
    private var continueTextColor: Color = .black

    @State
    private var sendMemo: String = ""

    @State
    private var didTapPaste = false

    @State
    private var didTapScan = false

    @State
    private var isLTCValueShown = false

    @State
    private var isValidAddress = false

    @State
    private var shouldShowError = false

    @State
    private var errorMessage = ""

    @State
    private var isAmountValid = false

    @State
    private var pasteboardString = ""

    @State
    private var scannedText = ""

    let darkModeColor = LinearGradient(colors: [BentoColor.sendTopPurple,
                                                BentoColor.sendBottomPurple],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
    let lightModeColor = LinearGradient(colors: [.white], startPoint: .topLeading,
                                        endPoint: .bottomTrailing)
    @State
    private var backgroundColor: LinearGradient = LinearGradient(colors: [.white],
                                                                 startPoint: .topLeading,
                                                                 endPoint: .bottomTrailing)

    init(viewModel: NewMainViewModel,
         userPrefersDarkTheme: Binding<Bool>,
         userWalletIsEmpty: Binding<Bool>,
         shouldShowView: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        _userWalletIsEmpty = userWalletIsEmpty
        _shouldShowView = shouldShowView
        newMainViewModel = viewModel
    }

    private func verifyAddressInPasteboard() -> Bool {

        if let pasteboard = UIPasteboard.general.string?.lowercased(),
            pasteboard.isValidAddress {
            pasteboardString = pasteboard
            self.isValidAddress = true
            return true
        }
        return false
    }

    private func isSendInformationValid() -> Bool {
        return isValidAddress && isAmountValid && !sendLTCAddress.isEmpty
    }

    var body: some View {
        GeometryReader { geometry in
            let subViewPad = 20.0
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)

                TabView(selection: $selectedSendPage) {
                    BentoSendInitialView(viewModel: newMainViewModel,
                                         userPrefersDarkTheme: $userPrefersDarkTheme,
                                         userWalletIsEmpty: $userWalletIsEmpty,
                                         shouldShowView: $shouldShowView,
                                         currentIndex: $selectedSendPage)
                        .padding(.bottom, subViewPad)
                        .tag(0)
                    BentoSendPrepView(viewModel: newMainViewModel,
                                      userPrefersDarkTheme: $userPrefersDarkTheme,
                                      currentIndex: $selectedSendPage)
                        .padding(.bottom, subViewPad)
                        .tag(1)
                    BentoSendCompletedView(viewModel: newMainViewModel,
                                           userPrefersDarkTheme: $userPrefersDarkTheme,
                                           shouldDismissModal: $shouldShowView)
                        .padding(.bottom, subViewPad)
                        .tag(2)
                    }
                .tabViewStyle(.page(indexDisplayMode: .never))
                VStack {
                    SendProgressBarView(stepIndex: $selectedSendPage,
                                        userPrefersDarkTheme:  $userPrefersDarkTheme)
                    .frame(height: 60)

                    Spacer()
                }

            }
        }
        .onAppear {
            backgroundColor = userPrefersDarkTheme ? darkModeColor : lightModeColor
            sentTextColor = userPrefersDarkTheme ? .white : .black
            continueTextColor = userPrefersDarkTheme ? .black : .white
            isLTCValueShown = newMainViewModel.isLTCValueShown
            userWalletIsEmpty = (newMainViewModel.walletBalanceLitecoinDouble > 0.0 ) ? false : true

            Analytics.logEvent("user_did_tap_send_sheet",
                parameters: nil)
        }
        .onChange(of: didTapPaste) { _,_ in

            guard let pasteboard = UIPasteboard.general.string, !pasteboard.utf8.isEmpty
            else {
                shouldShowError  = true
                return
            }
             sendLTCAddress = pasteboard
        }
        .onChange(of: isLTCValueShown) { _,newValue in
            newMainViewModel.isLTCValueShown = newValue
        }
        .onChange(of: shouldShowError) { _,newValue in
            newMainViewModel.isLTCValueShown = newValue
        }
        .onChange(of: scannedText) { _,_ in
            sendLTCAddress = scannedText
        }
        .onChange(of: userWalletIsEmpty) { _,_ in
            delay(0.4) {
                 shouldShowEmptyWalletAlert = userWalletIsEmpty
            }
        }
        .sheet(isPresented: $didTapScan) {
            DataScannerView(scannedText: $scannedText, isPresented: $didTapScan)
        }
        .alert(isPresented: $shouldShowEmptyWalletAlert) {
              Alert(title: Text("TOP UP NOW!"),
                      message: Text("You have no Litecoin. Tap Get/Recieve. Get LTC in 5 minutes with MoonPay!"),
                      dismissButton: .default(Text("Ok"),
                                              action: { shouldShowView = false }))
        }
    }
}
