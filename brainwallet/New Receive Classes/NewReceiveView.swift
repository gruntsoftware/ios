//
//  NewReceiveView.swift
//  brainwallet
//
//  Created by Kerry Washington on 28/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI

struct NewReceiveView: View {
    
    @ObservedObject
    var viewModel: NewReceiveViewModel
      
    @State
    private var isExpanded: Bool = false
    
    @State
    private var showError: Bool = false
    
    @State
    private var pickedCurrency: CurrencySelection = .USD
    
    @State
    private var pickedSymbol = "$"
    
    @State
    private var pickedAmount: Int = 20
    
    @State
    private var scannedCode: String?
    
    @State
    private var canUserBuyLTC = false
    
    @State
    private var symbol = "Ł"

    let qrImageSize: CGFloat = 80.0
    let squareImageSize: CGFloat = 16.0
    let themeBorderSize: CGFloat = 44.0
    let largeButtonHeight: CGFloat = 45.0
    let fieldHeight: CGFloat = 30.0
    let headerFont: Font = .barlowBold(size: 28.0)
    let subHeaderFont: Font = .barlowSemiBold(size: 17.0)
    let detailFont: Font = .barlowSemiBold(size: 15.0)
    let subDetailFont: Font = .barlowRegular(size: 14.0)

    let textFieldFont: Font = .barlowRegular(size: 15.0)
    
    let qrPlaceholder: UIImage = UIImage(systemName: "qrcode")!
    
    
    init(viewModel: NewReceiveViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                
                    VStack {
                        HStack {
                            Image(uiImage: viewModel.newReceiveAddressQR ?? qrPlaceholder)
                                .resizable()
                                .scaledToFit()
                                .frame(width: width * 0.35, height: width * 0.35)
                                .padding(.all, 5.0)
                            
                            Text(viewModel.newReceiveAddress)
                                .font(headerFont)
                                .tracking(2)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .frame(width: width * 0.35, height: width * 0.35)
                                .foregroundColor(BrainwalletColor.nearBlack)
                                .padding(.all, 5.0)
                        }
                        .frame(height: width * 0.4)

                                
                        HStack {
                            Picker("", selection: $pickedAmount) {
                                ForEach(viewModel.fiatAmounts, id: \.self) { amount in
                                    Text("\(amount)")
                                        .font(.subheadline)
                                        .foregroundColor(BrainwalletColor.content)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 70.0, alignment: .top)
                            .onChange(of: $pickedAmount.wrappedValue) { _ in
                                viewModel.pickedAmount = pickedAmount
                            }
                            .padding(.trailing, 1.0)
                            
                            Picker("", selection: $pickedCurrency) {
                                ForEach(viewModel.currencies, id: \.self) { currency in
                                    Text(currency.code)
                                        .font(.subheadline)
                                        .foregroundColor(BrainwalletColor.content)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 70.0, alignment: .top)
                            .onChange(of: $pickedCurrency.wrappedValue) { _ in
                                viewModel.currentFiat = pickedCurrency.code
                                pickedSymbol = pickedCurrency.symbol
                            }
                            .padding(.leading, 1.0)
                            VStack {
                                Text("\(viewModel.convertedLTC) Ł")
                                    .font(headerFont)
                                    .foregroundColor(BrainwalletColor.content)
                                    .frame(width: width * 0.4, alignment: .leading)
                                    .padding(.all, 3.0)
                                
                                Text(viewModel.fetchedTimestamp)
                                    .font(.footnote)
                                    .foregroundColor(BrainwalletColor.content)
                                    .frame(width: width * 0.4, alignment: .leading)
                                    .padding(.all, 3.0)
                                
                                Button(action: {
                                    ///
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                            .frame(height: largeButtonHeight, alignment: .center)
                                            .frame(width: width * 0.4 + squareImageSize)
                                            .foregroundColor(BrainwalletColor.surface)
                                        
                                        HStack {
                                            Text("Buy LTC from MoonPay")
                                                .frame(height: largeButtonHeight, alignment: .center)
                                                .frame(width: width * 0.4)
                                                .font(subHeaderFont)
                                                .foregroundColor(BrainwalletColor.content)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                                        .stroke(BrainwalletColor.content)
                                                )
                                                .padding(.all, 10.0)
                                        }
                                    }
                                }
                                .frame(width: width * 0.4)
                                .frame(height: largeButtonHeight)
                                .padding(.all, 10.0)
                                .opacity(canUserBuyLTC ? 1.0 : 0.0)
                            }
                            .frame(height: height * 0.2, alignment: .top)
                        }
                        .opacity(canUserBuyLTC ? 1.0 : 0.0)
                        .frame(height: canUserBuyLTC ? height * 0.2 : 0.0, alignment: .top)

                        
                        Spacer()
                        HStack {
                            VStack {

                                
                                
                                Button(action: {
                                    UIPasteboard.general.string = viewModel.newReceiveAddress
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                            .frame(width: width * 0.6, height: largeButtonHeight, alignment: .center)
                                            .foregroundColor(BrainwalletColor.surface)
                                        HStack {
                                            Text("Copy LTC Address")
                                                .frame(width: width * 0.6, height: largeButtonHeight, alignment: .center)
                                                .font(subHeaderFont)
                                                .foregroundColor(BrainwalletColor.content)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                                        .stroke(BrainwalletColor.content)
                                                )
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .frame(height: largeButtonHeight)
                                .padding(.all, 10.0)
                            }
                        }
                        .frame(height: height * 0.3)
                        .padding(.bottom, 5.0)

                    }
                    .frame(width: width * 0.9, height: canUserBuyLTC ? height * 0.75 : height * 0.6, alignment: .top)
                    .opacity(isExpanded ? 1.0 : 0.0)
                    .background(BrainwalletColor.surface)
                    .onAppear {
                        
                        /// To show all more compex state (Buyt or Receive)
                        #if targetEnvironment(simulator)
                        canUserBuyLTC = true
                        #else
                        canUserBuyLTC = UserDefaults.standard.object(forKey: userCurrentLocaleMPApprovedKey) as? Bool ?? false
                        #endif
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.isExpanded = true
                        }
                    }
                    .cornerRadius(largeButtonHeight/2)
                    .overlay {
                        RoundedRectangle(cornerRadius: largeButtonHeight/2)
                            .stroke(BrainwalletColor.content, lineWidth: 2)
                    }
                    .onChange(of: viewModel.newReceiveAddress, perform: { _ in
                    })
                    .onChange(of: viewModel.newReceiveAddressQR, perform: { _ in
                        
                    })
            }
        }
    }
}
