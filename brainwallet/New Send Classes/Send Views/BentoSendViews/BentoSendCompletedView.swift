//
//  BentoSendCompletedView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
import FirebaseAnalytics

struct BentoSendCompletedView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @Binding
    var userPrefersDarkTheme: Bool

    @Binding
    var shouldDismissModal: Bool

    @State
    private var shouldShowDetail: Bool = false

    @State
    private var shouldShowTXIDView: Bool = false

    @State
    private var sendLTCAddress: String = ""

    @State
    private var preferredFiatCode: String = ""

    @State
    private var sendAmountFiat: Double = 0.0

    @State
    private var networkFees: UInt64 = 0

    @State
    private var serviceFees: UInt64 = 0

    @State
    private var sendAmountLTC: Double = 0.0

    @State
    private var memoString: String = ""

    @State
    private var backgroundColor: LinearGradient = LinearGradient(colors: [.white],
                                                                 startPoint: .topLeading,
                                                                 endPoint: .bottomTrailing)

    private var url: URL?

    init(viewModel: NewMainViewModel,
         userPrefersDarkTheme: Binding<Bool>,
         shouldDismissModal: Binding<Bool>,) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        _shouldDismissModal = shouldDismissModal
        newMainViewModel = viewModel
        self.url = URL(string: (explorerURLs.randomElement() ?? "") + newMainViewModel.bwTransaction.txIDString)
    }

    var body: some View {
        GeometryReader { geometry in

            let sectionSpacer = 18.0
            let sectionSides = 15.0
            let detailRowHeight = 22.0
            let detailVertPadding = 15.0
            let detailSectionHeight = geometry.size.height * 0.4
            let shapeSize: CGFloat = 60.0

            let localizedAmount = String(localized: "Amount")
            let localizedNetworkFees = String(localized: "Network fees")
            let localizedServiceFees = String(localized: "Service fees")
            let localizedFiatCode = String(localized: "Amount in \(preferredFiatCode)")
            let localizedRecipient = String(localized: "Receipient")
            let localizedMemo = String(localized: "Memo")
            let localizedAmountSent = String(localized: "\(newMainViewModel.bwTransaction.amount.rawValue) ŁTC")

            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    if shouldShowDetail {

                        HStack {
                            VStack {
                                HStack {
                                    Text(localizedAmount)
                                        .modifier(SendTextLeaderModifier(userPrefersDarkTheme: $userPrefersDarkTheme,
                                                                         dataValue: $newMainViewModel.bwTransaction.amount))
                                }
                                .padding([.leading, .trailing], detailVertPadding)
                                .frame(height: detailRowHeight)

                                HStack {
                                    Text(localizedNetworkFees)
                                        .modifier(SendTextLeaderModifier(userPrefersDarkTheme: $userPrefersDarkTheme,
                                                                         dataValue: $newMainViewModel.bwTransaction.networkFee))
                                }
                                .padding([.leading, .trailing], detailVertPadding)
                                .frame(height: detailRowHeight)

                                HStack {
                                    Text(localizedServiceFees)
                                        .modifier(SendTextLeaderModifier(userPrefersDarkTheme:
                                                                            $userPrefersDarkTheme,
                                                                         dataValue: $newMainViewModel.bwTransaction.serviceFee))
                                }
                                .padding([.leading, .trailing], detailVertPadding)
                                .frame(height: detailRowHeight)

                                HStack {
                                    Text(localizedFiatCode)
                                        .modifier(SendTextLeaderModifier(userPrefersDarkTheme: $userPrefersDarkTheme,
                                                                         dataValue: $newMainViewModel.bwTransaction.amount))
                                }
                                .padding([.leading, .trailing], detailVertPadding)
                                .frame(height: detailRowHeight)

                                Spacer()
                                Divider().padding(10)
                                Spacer()
                                Text(localizedRecipient)
                                    .modifier(SendTextPrepTitleModifier(userPrefersDarkTheme: $userPrefersDarkTheme))
                                    .padding([.leading, .trailing], detailVertPadding)
                                Text(newMainViewModel.bwTransaction.sendAddress)
                                    .modifier(SendTextPrepDataModifier(userPrefersDarkTheme: $userPrefersDarkTheme))
                                    .padding([.leading, .trailing], detailVertPadding)
                                    .padding(.top, 1)
                                if !newMainViewModel.bwTransaction.memoString.isEmpty {
                                    Text(localizedMemo)
                                        .modifier(SendTextPrepTitleModifier(userPrefersDarkTheme: $userPrefersDarkTheme))
                                        .padding([.leading, .trailing], detailVertPadding)

                                    Text(newMainViewModel.bwTransaction.memoString)
                                        .modifier(SendTextPrepDataModifier(userPrefersDarkTheme: $userPrefersDarkTheme))
                                        .padding([.leading, .trailing], detailVertPadding)
                                        .padding(.top, 1)
                                }
                            }
                            .frame(height: detailSectionHeight)
                            .padding([.top, .bottom], sectionSpacer)
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(userPrefersDarkTheme ? .white : BentoColor.grayBorder,
                                            lineWidth: 0.5)
                            }
                        }
                        .padding([.leading, .trailing], sectionSides)
                        .padding(.bottom, sectionSpacer)
                    } else {
                        Spacer()
                        BrainwallePulseEllipse(shapeSize: .constant(shapeSize))
                            .frame(width: shapeSize * 2, height: shapeSize * 2, alignment: .center)
                                    .padding(.top, 45.0)

                        Text(String(localized:"Transaction sent!"))
                            .modifier(BWIPSBold(size: 32.0))
                            .foregroundColor(userPrefersDarkTheme ? .white : .black)
                            .frame(height: 24.0, alignment: .center)
                        Text(localizedAmountSent)
                            .modifier(BWIPSBold(size: 32.0))
                            .foregroundColor(userPrefersDarkTheme ? .white : .black)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(height: 34.0, alignment: .center)

                        Spacer()
                    }

                    HStack(alignment: .center) {
                        Image(systemName: "info.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                            .foregroundColor(userPrefersDarkTheme ? .white : .black)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tap here to verify your published transaction:")
                                .modifier(BWIPSLight(size: 13.0))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(userPrefersDarkTheme ? .white : .black)

                            Text("\(newMainViewModel.bwTransaction.txIDString)")
                                .modifier(BWIPSLight(size: 13.0))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(userPrefersDarkTheme ? .white : .black)
                        }
                    }
                    .padding(8)
                    .background(userPrefersDarkTheme ? BentoColor.grayBackground.opacity(0.2) : BentoColor.grayBackground)
                    .cornerRadius(12.0)
                    .padding([.leading, .trailing], 24.0)
                    .padding(.bottom, 20)
                    .onTapGesture {
                        shouldShowTXIDView.toggle()
                        Analytics
                            .logEvent("did_check_completed_txid",
                                      parameters: [
                                        "explorer_url": url?.absoluteString ?? "unknown explorer url"
                                      ])
                    }

                    HStack {
                        Button(action: {
                            shouldShowDetail.toggle()
                        }) {
                            ZStack {

                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(userPrefersDarkTheme ? .white : BentoColor.grayBorder,
                                            lineWidth: 0.5)
                                    .frame(height: 48)

                                Text(shouldShowDetail ? "Completed transaction" : "Transactions details")
                                    .modifier(BWIPSSemiBold(size: 18.0))
                                    .foregroundColor(userPrefersDarkTheme ? .white : .black)
                            }
                        }
                        .frame(height: 48)
                        .padding([.leading, .trailing], sectionSides)
                        .padding([.top, .bottom], 20)
                    }

                    HStack {
                        Button(action: {
                            shouldDismissModal.toggle()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(userPrefersDarkTheme ? .white : BentoColor.nearNearBlack)
                                    .frame(height: 48)

                                Text("Done")
                                    .modifier(BWIPSSemiBold(size: 18.0))
                                    .foregroundColor(userPrefersDarkTheme ? .black : .white)

                            }
                        }
                        .frame(height: 48)
                        .padding([.leading, .trailing], sectionSides)
                        .padding(.bottom, sectionSides * 0.5)
                    }
                }
            }
        }
        .sheet(isPresented: $shouldShowTXIDView, content: {

            WebView(url: self.url!, scrollToSignup: .constant(false))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(8.0)
                .padding(.top, 12.0)
                .padding(8.0)
        })
        .onAppear {
            backgroundColor = userPrefersDarkTheme ? BentoColor.darkModeColor1 : BentoColor.lightModeColor1
        }
    }
}
