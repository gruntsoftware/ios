//
//  BuyReceiveView.swift
//  brainwallet
//
//  Created by Kerry Washington on 09/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI

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
    let headerFont: Font = .barlowBold(size: 26.0)
    let liveQuoteFont: Font = .barlowSemiBold(size: 25.0)
    let subHeaderFont: Font = .barlowSemiBold(size: 17.0)
 
    let detailFont: Font = .barlowSemiBold(size: 15.0)
    let subDetailFont: Font = .barlowRegular(size: 14.0)
    let lightDetailFont: Font = .barlowLight(size: 15.0)

    let textFieldFont: Font = .barlowRegular(size: 15.0)
    
    let buyVStackFactor: CGFloat = 0.0
    let minimumDragFactor: CGFloat = 400.0
    let opacityFactor: CGFloat = 0.8
    init(viewModel: NewReceiveViewModel, isModalMode: Bool?) {
        self.viewModel = viewModel
        self.isModalMode = isModalMode ?? false
        
        UISegmentedControl.appearance().selectedSegmentTintColor = BrainwalletUIColor.surface
        UISegmentedControl.appearance().backgroundColor = BrainwalletUIColor.background
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.primary)], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.secondary)], for: .normal)
    }
    
    func updateFiatAmounts() {
        viewModel.fetchBuyQuoteLimits(buyAmount: pickedAmount, baseCurrencyCode: pickedCurrency)
        quotedLTCAmount = viewModel.quotedLTCAmount
        fiatMinAmount = viewModel.fiatMinAmount
        fiatTenXAmount = viewModel.fiatTenXAmount
        fiatMaxAmount = viewModel.fiatMaxAmount
    }
    
    var body: some View {
             
        GeometryReader { geometry in
            
            let width = geometry.size.width
            let height = geometry.size.height
            
            let modalWidth = geometry.size.width * 0.9
            
            let modalReceiveViewHeight = height * 0.9
            let modalBuyViewHeight = height * 0.95
            
            ZStack {
                
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                VStack {
                    if userIsBuying {
                        VStack {
                            HStack {
                                Capsule()
                                    .frame(width: 100.0, height: 2.0, alignment: .top)
                                    .foregroundColor(BrainwalletColor.content.opacity(0.5))
                            }
                            .frame(height: 20.0, alignment: .top)
                            .padding(8.0)
                            .onTapGesture {
                                viewModel.shouldDismissTheView()
                            }
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
                            HStack {
                                Capsule()
                                    .frame(width: 100.0, height: 2.0, alignment: .top)
                                    .foregroundColor(BrainwalletColor.content.opacity(0.5))
                            }
                            .frame(height: 20.0, alignment: .top)
                            .padding(8.0)
                            .onTapGesture {
                                viewModel.shouldDismissTheView()
                            }
                            /// Receive Address Group
                            ReceiveAddressView(viewModel: viewModel,
                                               newAddress: $newAddress,
                                               qrPlaceholder: $qrPlaceholder,
                                               keyboardFocused: $keyboardFocused)
                                .frame(width: modalWidth, height: keyboardFocused ? height * 0.01 : height * 0.3, alignment: .top)
                                .opacity(keyboardFocused ? 0 : 1)
                                .padding(.top, 1.0)
                            /// Receive Address Group
                            
                            /// Set Amount Group
                            HStack {
                                Spacer()

                                Picker("", selection: $pickedCurrency) {
                                    ForEach(viewModel.currencies, id: \.self) {
                                        Text("\($0.code) (\($0.symbol))")
                                            .font(subHeaderFont)
                                            .foregroundColor(BrainwalletColor.content)
                                            .padding(4.0)
                                    }
                                }
                                .onChange(of: pickedCurrency) { _ in
                                    updateFiatAmounts()
                                }
                                .pickerStyle(.wheel)
                                .frame(width: width * 0.3, height: 70, alignment: .center)
                                
                                VStack {
                                    Spacer()
                                    Text(String(format: "%.3f Ł", quotedLTCAmount))
                                        .font(liveQuoteFont)
                                        .kerning(0.3)
                                        .foregroundColor(BrainwalletColor.content)
                                        .frame(alignment: .leading)
                                    
                                    Text("\(quotedTimestamp)")
                                        .font(lightDetailFont)
                                        .foregroundColor(BrainwalletColor.content)
                                        .frame(alignment: .leading)

                                }
                                .frame(height: 70, alignment: .center)
                                .padding(.trailing, 20.0)
                                .onChange(of: viewModel.quotedTimestamp) { newValue in
                                    quotedTimestamp = newValue
                                    quotedLTCAmount = viewModel.quotedLTCAmount
                                }
                            }
                            .frame(height: 85, alignment: .center)
                            .blur(radius: didFetchData ? 3.0 : 0.0)
                            HStack {
                                Spacer()
                                Picker("", selection: $pickedSegment) {
                                    Text("\(pickedCurrency.symbol) \(fiatMinAmount)")
                                        .font(lightDetailFont)
                                        .padding(8.0)
                                        .tag(0)
                                    Text("\(pickedCurrency.symbol) \(fiatTenXAmount)")
                                        .font(lightDetailFont)
                                        .padding(8.0)
                                        .tag(1)
                                    Text("\(pickedCurrency.symbol) \(fiatMaxAmount)")
                                        .font(lightDetailFont)
                                        .padding(8.0)
                                        .tag(2)
                                }
                                .pickerStyle(.segmented)
                                .onChange(of: pickedSegment) { segmentTag in
                                    
                                    if segmentTag == 0 {
                                        pickedAmount = fiatMinAmount
                                    } else if segmentTag == 1 {
                                        pickedAmount = fiatTenXAmount
                                    } else {
                                        pickedAmount = fiatMaxAmount
                                    }
                                    
                                    updateFiatAmounts()
                                    pickedAmountString = String(format: "%d", pickedAmount)
                                    keyboardFocused = false
                                }
                                .frame(height: 85, alignment: .center)
                                .padding(.all, 10.0)
                                
                            }
                            .frame(height: 44.0, alignment: .center)
                            .blur(radius: didFetchData ? 3.0 : 0.0)
                            HStack {
                                Spacer()
                                Text("Set custom amount:")
                                    .font(subHeaderFont)
                                    .foregroundColor(BrainwalletColor.content)
                                    .padding(4.0)
                                TextField(String(localized:" \(pickedCurrency.symbol) "),
                                          text: $pickedAmountString)
                                .font(subHeaderFont)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .focused($keyboardFocused)
                                .frame(width: 120, alignment: .center)
                                .onChange(of: pickedAmountString) { newValue in
                                    if newValue.count > 6 {
                                        pickedAmountString = "\(fiatMaxAmount)"
                                    }
                                }
                            }
                            .frame(height: 40.0, alignment: .center)
                            .padding(.bottom, 5.0)
                            .blur(radius: didFetchData ? 3.0 : 0.0)
                            HStack {
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
                                        Text(pickedAmountString + " \(pickedCurrency.code)")
                                            .font(subHeaderFont)
                                            .foregroundColor(BrainwalletColor.surface)
                                            .padding(.all, 8.0)
                                    }
                                    .frame(width: width * 0.4)
                                    .background(BrainwalletColor.content)
                                    .cornerRadius(8.0)
                                }
                                .onAppear {
                                    pickedAmountString = "\(fiatMinAmount)"
                                }
                            }
                            .frame(height: 40.0, alignment: .center)
                            .blur(radius: didFetchData ? 3.0 : 0.0)
                            /// Set Amount Group
                            
                            Spacer()
                            
                            /// Buy LTC Button Group
                            Button(action: {
                                userIsBuying.toggle()
                                let signingData = viewModel.buildUnsignedMoonPayUrl()
                                viewModel.fetchMoonpaySignedUrl(signingData: signingData)
                            }) {
                                HStack {
                                    Text("BUY LTC")
                                        .frame(width: 120, alignment: .center)
                                        .font(liveQuoteFont)
                                        .foregroundColor(BrainwalletColor.content)
                                        .padding(10.0)
                                    Spacer()
                                    Image("moonpay-logo-type")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 120, alignment: .center)
                                        .padding(10.0)

                                }
                                .frame(width: 300, height: modalCorner)
                                .background(BrainwalletColor.background)
                                .cornerRadius(modalCorner/4)
                                .padding(10.0)
                                .disabled(keyboardFocused ? true : false)
                            }
                            .frame(width: width * 0.4, height: modalCorner, alignment: .bottom)
                            .padding(.all, 10.0)
                            /// Buy LTC Button Group
                        }
                        .frame(width: width * 0.95,
                               height: (viewModel.canUserBuy && isExpanded) ? modalBuyViewHeight : modalReceiveViewHeight,
                               alignment: .top)
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
                .onChange(of: viewModel.didFetchData) { newValue in
                    didFetchData = newValue
                }
                .onChange(of: viewModel.pickedCurrency) { _ in
                    viewModel.updatePublishables()
                    pickedCurrency = viewModel.pickedCurrency
                }
                .onAppear {
                    newAddress = viewModel.newReceiveAddress
                    canUserBuy = viewModel.canUserBuy
                    pickedCurrency = viewModel.pickedCurrency
                    updateFiatAmounts()
                }
                .alert("Address Copied", isPresented: $didCopyAddress,
                       actions: {
                    HStack {
                        Button("Ok" , role: .cancel) {
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
