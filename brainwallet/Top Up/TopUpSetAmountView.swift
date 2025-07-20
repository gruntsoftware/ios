//
//  TopUpSetAmountView.swift
//  brainwallet
//
//  Created by Kerry Washington on 20/04/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct TopUpSetAmountView: View {

    @Binding var path: [Onboarding]

    @State
    private var pickedCurrency: SupportedFiatCurrency = .USD

    @ObservedObject
    var viewModel: NewMainViewModel

    @ObservedObject
    var receiveViewModel: NewReceiveViewModel

    @State
    private var newDepositAddress: String = ""
    @State
    private var purchaseAmount: String = "200"
    @State
    private var purchaseAmountInt: Int = 200
    @State
    private var amountQuoted: Double = 0.0
    @State
    private var userIsBuying = false
    @State
    private var shouldAnimateMPLogo = false
    @State
    private var showMPLogo = true

    @FocusState var keyboardFocused: Bool

    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let themeBorderSize: CGFloat = 44.0
    let largeButtonHeight: CGFloat = 65.0
    let largeButtonFont: Font = .barlowBold(size: 24.0)
    let selectorFont: Font = .barlowSemiBold(size: 16.0)
    let detailFont: Font = .barlowRegular(size: 28.0)
    let amountSetFont: Font = .barlowBold(size: 35.0)
    let versionFont: Font = .barlowSemiBold(size: 16.0)
    let verticalPadding: CGFloat = 20.0
    let themeButtonSize: CGFloat = 28.0

    let arrowSize: CGFloat = 60.0
    let userPrefersDarkTheme = UserDefaults.userPreferredDarkTheme

    let currencies: [SupportedFiatCurrency] = SupportedFiatCurrency.allCases

    init(viewModel: NewMainViewModel, path: Binding<[Onboarding]>) {
        self.viewModel = viewModel
        guard let store = viewModel.store,
              let walletManager = viewModel.walletManager
        else {
            fatalError("Invalid dependencies")
        }
        self.receiveViewModel = NewReceiveViewModel(store: store, walletManager: walletManager, canUserBuy: true)
        _path = path
    }

    func updateAmountQuoted() {
        purchaseAmountInt = Int(purchaseAmount) ?? 0
        receiveViewModel.fetchBuyQuoteLimits(buyAmount: purchaseAmountInt, baseCurrencyCode: pickedCurrency)
        amountQuoted = receiveViewModel.quotedLTCAmount
    }

    var body: some View {

        GeometryReader { geometry in

            let width = geometry.size.width

            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Button(action: {
                            path.removeLast()
                        }) {
                            HStack {
                                Image(systemName: "arrow.backward")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: squareImageSize,
                                           height: squareImageSize,
                                           alignment: .center)

                                    .foregroundColor(BrainwalletColor.content)
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                    .padding(.all, 20.0)

                    Text("Buy Litecoin")
                        .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                        .font(detailFont)
                        .foregroundColor(BrainwalletColor.content)

                    Spacer()
                    ZStack {
                        Capsule()
                            .frame(width: width * 0.55, height: largeButtonHeight, alignment: .center)
                            .foregroundColor(BrainwalletColor.grape)
                        TextField(
                            "Amount",
                            text: $purchaseAmount
                        )
                        .textFieldStyle(.plain)
                        .font(amountSetFont)
                        .frame(width: width * 0.35, alignment: .center)
                        .padding([.leading, .trailing], 20.0)
                        .keyboardType(.numberPad)
                        .focused($keyboardFocused)
                    }
                    HStack {
                        Spacer()
                        Picker("", selection: $pickedCurrency) {
                            ForEach(currencies, id: \.self) {
                                Text("\($0.code) (\($0.symbol))")
                                    .font(detailFont)
                                    .foregroundColor(BrainwalletColor.content)
                                    .padding(4.0)
                            }
                        }
                        .onChange(of: pickedCurrency) { _ in
                            updateAmountQuoted()
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 120, alignment: .leading)
                        Text(String(format: "~%.2f Ł", amountQuoted))
                            .font(detailFont)
                            .foregroundColor(userPrefersDarkTheme ? .white.opacity(0.5) : BrainwalletColor.nearBlack.opacity(0.5))
                            .frame(width: 120, alignment: .leading)
                        Spacer()

                    }
                    .frame(width: width * 0.9, alignment: .center)

                    Spacer()
                    Text("To be deposited to your LTC address")
                        .frame(width: width * 0.6, alignment: .center)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .font(detailFont)
                        .foregroundColor(BrainwalletColor.content)

                    Text(newDepositAddress)
                        .frame(width: width * 0.6, alignment: .center)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .font(detailFont)
                        .foregroundColor(userPrefersDarkTheme ? .white.opacity(0.5) : BrainwalletColor.nearBlack.opacity(0.5))
                        .padding(.all, 20.0)
                    Spacer()
                    Button(action: {
                        userIsBuying.toggle()
                        let signingData = receiveViewModel.buildUnsignedMoonPayUrl()
                        receiveViewModel.fetchMoonpaySignedUrl(signingData: signingData)
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                .foregroundColor(BrainwalletColor.grape)
                            Text("Buy with MoonPay")
                                .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                .font(largeButtonFont)
                                .foregroundColor(.white)
                        }
                        .padding(.all, 8.0)
                    }
                }
                .ignoresSafeArea(.keyboard)
                .onAppear {
                    newDepositAddress = receiveViewModel.newReceiveAddress
                    updateAmountQuoted()
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            keyboardFocused = false
                            updateAmountQuoted()
                        }
                    }
                }
                .sheet(isPresented: $userIsBuying) {
                    VStack {
                        ZStack {
                            WebBuyView(signingData: receiveViewModel.buildUnsignedMoonPayUrl(),
                                       viewModel: receiveViewModel)
                            Image("moonpay-symbol-prp")
                                .resizable()
                                .frame(width: 50.0, height: 50.0)
                                .offset(x: shouldAnimateMPLogo ? 20 : 0, y: shouldAnimateMPLogo ? -20 : 0)
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                        shouldAnimateMPLogo = true
                                    }
                                    delay(2.0) {
                                        showMPLogo = false
                                    }
                                }
                                .opacity(showMPLogo ? 1.0 : 0.0)
                        }
                    }
                    .background(BrainwalletColor.surface)
                    .cornerRadius(modalCorner/2)
                    .padding(.bottom, 5.0)
                }
            }
        }
    }
}
