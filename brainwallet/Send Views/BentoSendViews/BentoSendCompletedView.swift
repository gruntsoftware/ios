//
//  BentoSendCompletedView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

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
        self.url = URL(string: ExplorerURLs.blockchair + newMainViewModel.bwTransaction.txIDString)
    }

    var body: some View {
        GeometryReader { geometry in

            let sectionSpacer = 18.0
            let sectionSides = 15.0
            let detailRowHeight = 22.0
            let detailVertPadding = 15.0
            let detailSectionHeight = geometry.size.height * 0.4
            let shapeSize: CGFloat = 100.0

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
                    if shouldShowDetail {
                        Spacer()
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
                                    .frame(alignment: .center)
                                    .padding(.top, detailVertPadding)
                        Text(String(localized:"Transaction sent!"))
                            .modifier(SendCompletedTitleModifier(userPrefersDarkTheme: $userPrefersDarkTheme))
                            .padding([.top, .bottom], sectionSpacer)
                        Text(String(localized:"amount:"))
                            .modifier(SendCompletedSubTitleModifier(userPrefersDarkTheme: $userPrefersDarkTheme))
                        Text(localizedAmountSent)
                            .font(.system(size: 32, weight: .bold, design: .default))
                            .foregroundColor(userPrefersDarkTheme ? .white : .black)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(15.0)
                    }

                    Spacer()

                    HStack {
                        Image(systemName: "info.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15, height: 15, alignment: .leading)
                        .foregroundColor(userPrefersDarkTheme ? .white : .black)
                        VStack {
                            Text(String(localized: "Tap here to verify your published transaction:"))
                                .font(.system(size: 11, weight: .light, design: .default))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(userPrefersDarkTheme ? .white : .black)
                            Text(String(localized: "\(newMainViewModel.bwTransaction.txIDString)"))
                                .font(.system(size: 11, weight: .light, design: .default))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(userPrefersDarkTheme ? .white : .black)
                        }
                    }
                    .padding(.bottom, 2)
                    .padding([.leading, .trailing], sectionSides)
                    .onTapGesture {
                        shouldShowTXIDView.toggle()
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
                                    .font(.system(size: 18, weight: .semibold, design: .default))
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
                                    .font(.system(size: 18, weight: .semibold, design: .default))
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
