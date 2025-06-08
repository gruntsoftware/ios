//
//  NewReceiveView.swift
//  brainwallet
//
//  Created by Kerry Washington on 28/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI

let defaultLaunchAmount = 210
let maxLaunchAmount = 20000

struct NewReceiveView: View {
    
    @ObservedObject
    var viewModel: NewReceiveViewModel
      
    @State
    private var isExpanded: Bool = false
    
    @State
    private var showError: Bool = false
    
    @State
    private var pickedCurrency: SupportedFiatCurrencies = .USD
    
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
    private var canUserBuyLTC = false

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
    let ginormousFont: Font = .barlowSemiBold(size: 22.0)
    let subHeaderFont: Font = .barlowSemiBold(size: 17.0)
    let detailFont: Font = .barlowSemiBold(size: 15.0)
    let subDetailFont: Font = .barlowRegular(size: 14.0)
    let lightDetailFont: Font = .barlowLight(size: 15.0)

    let textFieldFont: Font = .barlowRegular(size: 15.0)
    
    let buyVStackFactor: CGFloat = 0.0

    init(viewModel: NewReceiveViewModel) {
        self.viewModel = viewModel
        
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
            
            let modalReceiveViewHeight = height * 0.4
            let modalBuyViewHeight = height * 0.95
            
            ZStack {
                
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
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
                        .overlay {
                            RoundedRectangle(cornerRadius: modalCorner/2)
                                .stroke(BrainwalletColor.content, lineWidth: 2)
                                .frame(width: width * 0.95, height: height * 0.95, alignment: .top)
                                .padding(.bottom, 5.0)
                            
                        }
                        .padding(.bottom, 5.0)
                    } else {
                        VStack {
                            /// Header Group
                            HStack {
                                Text(canUserBuyLTC ? "BUY / RECEIVE" : "RECEIVE")
                                    .font(headerFont)
                                    .foregroundColor(BrainwalletColor.content)
                                    .padding(.all, 4.0)
                                
                            }
                            .frame(width: modalWidth, height: 44.0, alignment: .top)
                            .padding([.leading, .trailing,.top], 8.0)
                            /// Header Group
                            
                            /// Receive Address Group
                            ReceiveAddressView(viewModel: viewModel,
                                               newAddress: $newAddress,
                                               qrPlaceholder: $qrPlaceholder,
                                               keyboardFocused: $keyboardFocused)
                                .frame(width: modalWidth, height: keyboardFocused ? height * 0.01 : height * 0.3, alignment: .top)
                                .opacity(keyboardFocused ? 0 : 1)
                            /// Receive Address Group
                        
                            Divider()
                                .background(BrainwalletColor.nearBlack)
                                .padding([.leading, .trailing], 12.0)
                            
                            /// Set Amount Group
                            ZStack {
                                VStack {
                                    HStack {
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
                                        .frame(height: 85, alignment: .leading)
                                        
                                        VStack {
                                            
                                            Text(String(format: "%.3f Ł", quotedLTCAmount))
                                                .font(ginormousFont)
                                                .kerning(0.3)
                                                .foregroundColor(BrainwalletColor.content)
                                            
                                            Text("\(quotedTimestamp)")
                                                .font(lightDetailFont)
                                                .kerning(0.4)
                                                .foregroundColor(BrainwalletColor.content)
                                        }
                                        .frame(height: 85, alignment: .center)
                                        .padding(.trailing, 20.0)
                                        .onChange(of: viewModel.quotedTimestamp) { newValue in
                                            quotedTimestamp = newValue
                                            quotedLTCAmount = viewModel.quotedLTCAmount
                                        }
                                    }
                                    HStack {
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
                                        .tint(.orange)
                                        .padding(.all, 10.0)
                                        
                                    }
                                    .frame(width: modalWidth, height: 35.0)
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
                                    .frame(width: modalWidth, height: 35.0)
                                    .padding(.bottom, 5.0)
                                }
                                .frame(width: modalWidth, height: 155.0)
                                .blur(radius: didFetchData ? 3.0 : 0.0)
                                .padding(.bottom, 5.0)
                                HStack {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: BrainwalletColor.content))
                                        .frame(width: 50, height: 50)
                                }
                                .frame(width: modalWidth, height: 155.0)
                                .background(.white.opacity(0.3))
                                .padding(.bottom, 5.0)
                                .opacity(didFetchData ? 1.0 : 0.0)
                            }
                            .opacity(viewModel.canUserBuyLTC ? 1.0 : 0.0)
                            /// Set Amount Group
                            
                            Divider()
                                .background(BrainwalletColor.nearBlack)
                                .padding([.leading, .trailing], 12.0)
                            
                            Spacer()
                            
                            /// Buy LTC Button Group
                            Button(action: {
                                userIsBuying.toggle()
                                let signingData = viewModel.buildUnsignedMoonPayUrl()
                                viewModel.fetchMoonpaySignedUrl(signingData: signingData)
                            }) {
                                VStack {
                                    Text("BUY LTC")
                                        .frame(width: width * 0.85, alignment: .center)
                                        .font(ginormousFont)
                                        .foregroundColor(BrainwalletColor.content)
                                    
                                    Image("mp-lockup")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: width * 0.85, height: 18, alignment: .top)
                                }
                                .frame(height: buyButtonSize)
                                .background(BrainwalletColor.background)
                                .cornerRadius(modalCorner/2)
                                .padding(.all, 10.0)
                                .disabled(keyboardFocused ? true : false)
                            }
                            .padding(.all, 10.0)
                            .opacity(viewModel.canUserBuyLTC ? 1.0 : 0.0)
                            /// Buy LTC Button Group
                            
                            /// Set Amount Button
                            if keyboardFocused {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        pickedAmount = Int(pickedAmountString) ?? fiatTenXAmount
                                        updateFiatAmounts()
                                        keyboardFocused = false
                                    }) {
                                        HStack {
                                            Text(" Done ")
                                                .font(subHeaderFont)
                                                .foregroundColor(BrainwalletColor.surface)
                                                .padding(.all, 8.0)
                                            Text(pickedAmountString + " \(pickedCurrency.code)")
                                                .font(subHeaderFont)
                                                .foregroundColor(BrainwalletColor.surface)
                                                .padding(.all, 8.0)
                                            
                                        }
                                        .frame(width: width * 0.3)
                                        .background(BrainwalletColor.content)
                                        .cornerRadius(setAmountSize/2)
                                    }
                                    .onAppear {
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            self.keyboardFocused = true
                                            pickedAmountString = "\(fiatMinAmount)"
                                        }
                                    }
                                }
                                .frame(height: keyboardFocused ? setAmountSize : 0, alignment: .bottom)
                                .opacity(keyboardFocused ? 1 : 0)
                                .padding(.all, 8.0)
                            }
                            /// Set Amount Button
                            
                        }
                        .frame(width: width * 0.95,
                               height: (viewModel.canUserBuyLTC && isExpanded) ? modalBuyViewHeight : modalReceiveViewHeight,
                               alignment: .top)
                        .opacity(isExpanded ? 1.0 : 0.0)
                        .background(BrainwalletColor.surface)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                self.isExpanded = true
                            }
                        }
                        .cornerRadius(modalCorner/2)
                        .overlay {
                            RoundedRectangle(cornerRadius: modalCorner/2)
                                .stroke(BrainwalletColor.content, lineWidth: 2)
                                .frame(width: width * 0.95, height: viewModel.canUserBuyLTC ? modalBuyViewHeight : modalReceiveViewHeight, alignment: .top)
                                .padding(.bottom, 5.0)
                        }
                        .padding(.bottom, 5.0)
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
                    canUserBuyLTC = viewModel.canUserBuyLTC
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
            }
        }
    }
}
