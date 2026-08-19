//
//  BuyReceiveView.swift
//  brainwallet
//
//  Created by Kerry Washington on 09/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI
import FirebaseAnalytics

let defaultLaunchAmount = 210
let maxLaunchAmount = 20000

struct BuyReceiveView: View {

    @ObservedObject
    var viewModel: NewReceiveViewModel

    @State
    private var isExpanded: Bool = false

    @State
    private var showError: Bool = false

    @State
    private var pickedCurrency: SupportedFiatCurrency = .USD

    @State
    private var pickedPreset = 0

    @State
    private var pickedSymbol = "$"

    @State
    private var pickedAmountString = ""

    @State
    private var pickedAmount: Int = defaultLaunchAmount

    @State
    private var fiatMinAmount: Int = Int(defaultLaunchAmount / 10)

    @State
    private var fiatTenXAmount: Int = defaultLaunchAmount

    @State
    private var fiatMaxAmount: Int = maxLaunchAmount

    @State
    private var scannedCode: String?

    @State
    private var userIsBuying = false

    @State
    private var canUserBuy = false

    @State
    private var newAddress = ""

    @State
    private var quotedTimestamp = "--------"

    @State
    private var didFetchData = false

    @State
    private var quotedLTCAmount = 0.0

    @State
    private var userWantsCustomAmount = false

    @State
    private var shouldAnimateMPLogo = false

    @State
    private var didCopyAddress = false

    @State
    private var showMPLogo = true

    @State
    private var isModalMode: Bool = false

    @FocusState
    var keyboardFocused: Bool

    @State
    private var pickedSegment = 1
     

    @State
    private var qrPlaceholder: UIImage = UIImage(systemName: "qrcode")!

    let buyButtonSize: CGFloat = 80.0
    let squareImageSize: CGFloat = 16.0
    let setAmountSize: CGFloat = 60.0
    let modalCorner: CGFloat = 55.0
    let buttonCorner: CGFloat = 26.0
    let presetCorner: CGFloat = 10.0
    let pickerRowHeight: CGFloat = 34.0
    let headerFont: Font = .ibmPlexSansBold(size: 26.0)
    let liveQuoteFont: Font = .ibmPlexSansSemiBold(size: 25.0)
    let subHeaderFont: Font = .ibmPlexSansSemiBold(size: 17.0)
    let detailFont: Font = .ibmPlexSansSemiBold(size: 15.0)
    let subDetailFont: Font = .ibmPlexSansRegular(size: 14.0)
    let lightDetailFont: Font = .ibmPlexSansLight(size: 15.0)

    let textFieldFont: Font = .ibmPlexSansRegular(size: 15.0)

    let buyVStackFactor: CGFloat = 0.0
    let minimumDragFactor: CGFloat = 400.0
    let opacityFactor: CGFloat = 0.8

    let viewName = "receive"

    init(viewModel: NewReceiveViewModel,
         isModalMode: Bool?) {
        self.viewModel = viewModel
        self.isModalMode = isModalMode ?? false
        UISegmentedControl.appearance().selectedSegmentTintColor = BrainwalletUIColor.surface
        UISegmentedControl.appearance().backgroundColor = BrainwalletUIColor.background
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.primary)], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.secondary)], for: .normal)
        /// The wheel currency picker's row/selection background is cleared by
        /// UIPickerView+Extension.swift, which reaches its internal subviews -
        /// the appearance proxy alone can't touch those.
    }

    func updateFiatAmounts() {
        viewModel.fetchBuyQuoteLimits(buyAmount: pickedAmount, baseCurrencyCode: pickedCurrency)
        quotedLTCAmount = viewModel.quotedLTCAmount
        fiatMinAmount = viewModel.fiatMinAmount
        fiatTenXAmount = viewModel.fiatTenXAmount
        fiatMaxAmount = viewModel.fiatMaxAmount
    }

    /// A single bordered, pill-style preset amount button (mirrors the Android layout's
    /// row of "$21 / $210 / $29849 / Custom" chips, with a checkmark on the selected one).
    @ViewBuilder
    func presetButton(title: String, tag: Int) -> some View {
        Button(action: {
            pickedSegment = tag
            userWantsCustomAmount = (tag == 3)

            if tag == 0 {
                pickedAmount = fiatMinAmount
            } else if tag == 1 {
                pickedAmount = fiatTenXAmount
            } else if tag == 2 {
                pickedAmount = fiatMaxAmount
            }

            if !userWantsCustomAmount {
                updateFiatAmounts()
            }
            pickedAmountString = String(format: "%d", pickedAmount)
            keyboardFocused = userWantsCustomAmount
        }) {
            HStack(spacing: 4.0) {
                if pickedSegment == tag {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11.0, weight: .bold))
                        .foregroundColor(BrainwalletColor.content)
                }
                Text(title)
                    .font(detailFont)
                    .foregroundColor(BrainwalletColor.content)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, 8.0)
            .padding(.vertical, 10.0)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: presetCorner)
                    .stroke(pickedSegment == tag ?
                            BrainwalletColor.content :
                            BrainwalletColor.content.opacity(0.25),
                            lineWidth: pickedSegment == tag ? 1.5 : 1.0)
            )
        }
    }

    var body: some View {

        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            let containerWidth = width * 0.9
            let containerHeight = height * 0.75
            let modalWidth = containerWidth * 0.94

            ZStack {

                /// Modal itself stays clear, lightly blurred over whatever sits behind the sheet.
                /// A dialed-down VariableBlurView instead of `.ultraThinMaterial` + opacity,
                /// since opacity fades the blur away entirely rather than thinning it.
                VariableBlurView(intensity: 0.01)
                    .edgesIgnoringSafeArea(Edge.Set.all)

                VStack {
                    if userIsBuying {
                        VStack {
                            ZStack {
                                WebBuyView(signingData: viewModel.buildUnsignedMoonPayUrl(), viewModel: viewModel)

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
                        .frame(width: width * 0.95,
                               height: height * 0.95,alignment: .top)
                        .opacity(isExpanded ? 1.0 : 0.0)
                        .background(BrainwalletColor.surface)
                        .cornerRadius(modalCorner/2)
                        .padding(.bottom, 5.0)
                    } else {
                        VStack {

                            /// Header Group
                            ZStack {
                                Text("BUY / RECEIVE")
                                    .font(.ibmPlexSansSemiBold(size: 16.0))
                                    .foregroundColor(BrainwalletColor.content)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(10.0)
                            }
                            .padding(.horizontal, 20.0)
                            .padding(.vertical, 10.0)
                            /// Header Group

                            /// Receive Address Group
                            ReceiveAddressView(viewModel: viewModel,
                                               newAddress: $newAddress,
                                               qrPlaceholder: $qrPlaceholder,
                                               keyboardFocused: $keyboardFocused)
                                .frame(width: modalWidth, height: keyboardFocused ?
                                    height * 0.01 :
                                        height * 0.22,
                                       alignment: .top)
                                .opacity(keyboardFocused ? 0 : 1)
                                .padding(.top, 1.0)

                            Divider()
                                .padding(.horizontal, 5.0)
                                .opacity(keyboardFocused ? 0 : 1)
                            /// Receive Address Group

                            /// Set Amount Group
                            HStack(alignment: .center) {

                                Picker("", selection: $pickedCurrency) {
                                    ForEach(viewModel.currencies, id: \.self) {
                                        Text($0.code)
                                            .font(.ibmPlexSansSemiBold(size: 19.0))
                                            .padding(4.0)
                                    }
                                }
                                .onChange(of: pickedCurrency) { _,_ in
                                    updateFiatAmounts()
                                }
                                .pickerStyle(.wheel)
                                .frame(width: width * 0.3, height: pickerRowHeight * 3, alignment: .center)
                                .overlay(
                                    /// Brackets the currently selected row with a hairline
                                    /// above and below it, centered on the wheel's frame.
                                    GeometryReader { pickerGeometry in
                                        let pickerWidth = pickerGeometry.size.width
                                        let centerY = pickerGeometry.size.height / 2.0

                                        ZStack {
                                            Rectangle()
                                                .fill(BrainwalletColor.content.opacity(0.25))
                                                .frame(width: pickerWidth, height: 1.0)
                                                .position(x: pickerWidth / 2.0, y: centerY - pickerRowHeight / 2.0)

                                            Rectangle()
                                                .fill(BrainwalletColor.content.opacity(0.25))
                                                .frame(width: pickerWidth, height: 1.0)
                                                .position(x: pickerWidth / 2.0, y: centerY + pickerRowHeight / 2.0)
                                        }
                                    }
                                    .allowsHitTesting(false)
                                )
                                .padding(10.0)

                                VStack {
                                    Spacer()
                                    Text(String(format: "%.3fŁ", quotedLTCAmount))
                                        .font(liveQuoteFont)
                                        .kerning(0.3)
                                        .foregroundColor(BrainwalletColor.content)
                                        .frame(alignment: .leading)

                                    Text("\(quotedTimestamp)")
                                        .font(lightDetailFont)
                                        .textCase(.uppercase)
                                        .foregroundColor(BrainwalletColor.content)
                                        .frame(alignment: .leading)

                                }
                                .frame(height: 70, alignment: .center)
                                .padding(10.0)
                                .onChange(of: viewModel.quotedTimestamp) { _,newValue in
                                    quotedTimestamp = newValue
                                    quotedLTCAmount = viewModel.quotedLTCAmount
                                }
                            }
                            .frame(height: pickerRowHeight * 5, alignment: .center)
                            .blur(radius: didFetchData ? 3.0 : 0.0)

                            /// Preset amount chips: min / 10x / max / Custom
                            HStack(spacing: 10.0) {
                                presetButton(title: "\(pickedCurrency.symbol)\(fiatMinAmount)", tag: 0)
                                presetButton(title: "\(pickedCurrency.symbol)\(fiatTenXAmount)", tag: 1)
                                presetButton(title: "\(pickedCurrency.symbol)\(fiatMaxAmount)", tag: 2)
                                presetButton(title: "Custom", tag: 3)
                            }
                            .padding(.horizontal, 20.0)
                            .blur(radius: didFetchData ? 3.0 : 0.0)

                            if userWantsCustomAmount {
                                HStack {
                                    TextField(String(localized:" \(pickedCurrency.symbol) "),
                                              text: $pickedAmountString)
                                    .font(subHeaderFont)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                                    .focused($keyboardFocused)
                                    .frame(width: 80, alignment: .center)
                                    .onChange(of: pickedAmountString) { _,newValue in
                                        if newValue.count > 6 {
                                            pickedAmountString = "\(fiatMaxAmount)"
                                        }
                                    }
                                    Spacer()
                                    Button(action: {
                                        pickedAmount = Int(pickedAmountString) ?? fiatTenXAmount
                                        updateFiatAmounts()
                                        keyboardFocused = false
                                    }) {
                                        HStack {
                                            Text("Done")
                                                .font(subHeaderFont)
                                                .foregroundColor(BrainwalletColor.surface)
                                                .padding(.all, 8.0)
                                            Text("\(pickedCurrency.symbol)" + pickedAmountString)
                                                .font(subHeaderFont)
                                                .foregroundColor(BrainwalletColor.surface)
                                                .padding(.all, 8.0)
                                        }
                                        .background(BrainwalletColor.content)
                                        .cornerRadius(8.0)
                                    }
                                }
                                .frame(height: 40.0, alignment: .center)
                                .padding(.all, 10.0)
                                .padding(.horizontal, 10.0)
                            }
                            /// Set Amount Group

                            Spacer()

                            /// Buy LTC Button Group
                            Button(action: {
                                userIsBuying.toggle()
                                viewModel.signAndFetchMoonPayUrl()
                            }) {
                                VStack(alignment: .center, spacing: 4.0) {

                                    Text("BUY LTC")
                                        .frame(width: 120, alignment: .center)
                                        .font(liveQuoteFont)
                                        .foregroundColor(BrainwalletColor.midnight)

                                    HStack(spacing: 6.0) {

                                        Text("POWERED BY MOONPAY")
                                            .font(subDetailFont)
                                            .foregroundColor(BrainwalletColor.midnight)


                                        Image("moonpay-symbol-prp")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 14.0, height: 14.0)
                                    }
                                }
                                .frame(width: width * 0.9, height: buyButtonSize, alignment: .center)
                                .background(BrainwalletColor.lavender)
                                .cornerRadius(buttonCorner)

                            }
                            .disabled(keyboardFocused ? true : false)
                            .frame(width: width, alignment: .bottom)
                            /// Buy LTC Button Group
                        }
                        .frame(width: containerWidth,
                               height: containerHeight,
                               alignment: .top)
                        .padding(.all, 16.0)
                        .opacity(isExpanded ? 1.0 : 0.0)
                        .background(BrainwalletColor.surface)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                self.isExpanded = true
                            }
                        }
                        .cornerRadius(modalCorner/2)
                    }
                }
                .onChange(of: viewModel.didFetchData) { _,newValue in
                    didFetchData = newValue
                }
                .onChange(of: viewModel.pickedCurrency) { _,_ in
                    viewModel.updatePublishables()
                    pickedCurrency = viewModel.pickedCurrency
                }
                .onAppear {
                    newAddress = viewModel.newReceiveAddress
                    canUserBuy = viewModel.canUserBuy
                    pickedCurrency = viewModel.pickedCurrency
                    updateFiatAmounts()
                    pickedAmountString = "\(fiatMinAmount)"

                    Analytics.logEvent("user_did_tap_buyreceive_sheet",
                                       parameters: nil)
                }
                .alert(String(localized:"Address Copied"), isPresented: $didCopyAddress,
                       actions: {
                    HStack {
                        Button( String(localized:"Ok"), role: .cancel) {
                            didCopyAddress.toggle()
                        }
                    }
                })
                .gesture(
                    DragGesture()
                        .onChanged { value in

                            /// Dismiss after 2 button sizes
                            let transX = value.translation.width
                            let transY = value.translation.height
                            let hypotenuse = sqrt(transX * transX + transY * transY)

                            if hypotenuse > minimumDragFactor {
                                viewModel.shouldDismissTheView()
                            }
                        }
                )

            }
        }
    }
}
