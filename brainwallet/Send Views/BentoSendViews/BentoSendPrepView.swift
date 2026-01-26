//
//  BentoSendPrepView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct BentoSendPrepView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @Binding
    var userPrefersDarkTheme: Bool

    @Binding
    var currentIndex: Int

    @State
    private var preferredFiatCode: String = ""

    @State
    private var userCanAttemptToSend = false

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
         currentIndex: Binding<Int>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        _currentIndex = currentIndex
        newMainViewModel = viewModel
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let detailSectionHeight = geometry.size.height * 0.4
            let detailRowHeight = 22.0
            let sectionSpacer = 18.0
            let sectionSides = 15.0
            let detailVertPadding = 15.0

            let localizedAmount = String(localized: "Amount")
            let localizedNetworkFees = String(localized: "Network fees")
            let localizedServiceFees = String(localized: "Service fees")
            let localizedAmountInFiat = String(localized: "Amount in Fiat")
            let localizedRecipient = String(localized: "Recipient")
            let localizedMemo = String(localized: "Memo")

            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                VStack {
                    Text(String(localized: "Confirm send details"))
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                        .foregroundColor(userPrefersDarkTheme ? .white : .black)
                        .padding(.top, sectionSpacer * 2)
                        .padding(.bottom, sectionSpacer)

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
                                Text(localizedAmountInFiat)
                                    .modifier(SendFiatAmountLeaderModifier(userPrefersDarkTheme: $userPrefersDarkTheme,
                                                                           fiatValue: $newMainViewModel.currentFiatAmount,
                                                                           currencyCode: $newMainViewModel.currentGlobalFiat))
                            }
                            .padding([.leading, .trailing], detailVertPadding)
                            .frame(height: detailRowHeight)

                            Spacer()
                            Divider()
                                .frame(minHeight: 1)
                                .overlay(BrainwalletColor.lightgray)
                                .padding(10)
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

                    Spacer()

                    HStack {
                        Button(action: {
                            currentIndex = 0
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(userPrefersDarkTheme ? .white : BentoColor.grayBorder,
                                            lineWidth: 0.5)
                                    .frame(height: 48)
                                Text("Edit")
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
                            userCanAttemptToSend.toggle()
                            // currentIndex = 2

                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(userPrefersDarkTheme ? .white : BentoColor.nearNearBlack)
                                    .frame(height: 48)

                                Text("Confirm")
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
        .sheet(isPresented: $userCanAttemptToSend) {
            BentoSendConfirmView(viewModel: SendPinLockModel(walletManager: newMainViewModel.walletManager ?? nil),
                                 newMainViewModel: newMainViewModel,
                                 userPrefersDarkTheme: $userPrefersDarkTheme,
                                 nextIndex: $currentIndex,
                                 shouldDismiss: $userCanAttemptToSend)
                .cornerRadius(bentoCornerRadius)
                .presentationDragIndicator(.hidden)
                .presentationDetents([.medium])
                .presentationBackground(.ultraThickMaterial)
                .ignoresSafeArea(edges: .bottom)
        }
        .onAppear {
            backgroundColor = userPrefersDarkTheme ? BentoColor.darkModeColor1 : BentoColor.lightModeColor1
            preferredFiatCode = newMainViewModel.currentGlobalFiat.code
        }
    }
}
