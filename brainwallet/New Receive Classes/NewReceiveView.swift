//
//  NewReceiveView.swift
//  brainwallet
//
//  Created by Kerry Washington on 28/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI


enum PresetMultiples : Int, CaseIterable {
    case minValue = 0
    case texXMinValue
    case maxValue
}


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
    private var pickedPreset = 0
    
    @State
    private var pickedSymbol = "$"
    
    @State
    private var pickedAmount: Int = 20
    
    @State
    private var scannedCode: String?
    
    @State
    private var userIsBuying = false
    
    @State
    private var canUserBuyLTC = false

    @State
    private var newAddress = ""
    
    @State
    private var fetchedTimestamp = ""
    
    @State
    private var symbol = "Ł"

    let buyButtonSize: CGFloat = 80.0
    let squareImageSize: CGFloat = 16.0
    let themeBorderSize: CGFloat = 44.0
    let modalCorner: CGFloat = 60.0
    let buttonCorner: CGFloat = 26.0
    let headerFont: Font = .barlowBold(size: 26.0)
    let ginormousFont: Font = .barlowSemiBold(size: 22.0)
    let subHeaderFont: Font = .barlowSemiBold(size: 17.0)
    let detailFont: Font = .barlowSemiBold(size: 15.0)
    let subDetailFont: Font = .barlowRegular(size: 14.0)
    let lightDetailFont: Font = .barlowLight(size: 15.0)


    let presetAmounts  = ["22", "210", "230542"]

    let textFieldFont: Font = .barlowRegular(size: 15.0)
    
    let qrPlaceholder: UIImage = UIImage(systemName: "qrcode")!
    
    let buyVStackFactor: CGFloat = 0.0

    init(viewModel: NewReceiveViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let width = geometry.size.width
            let height = geometry.size.height
            
            let modalWidth = geometry.size.width * 0.9
            let modalHeight = geometry.size.height * 0.9
            
            let modalReceiveViewHeight = height * 0.4
            let modalBuyViewHeight = height * 0.95

            ZStack {
                
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    if userIsBuying {
                        VStack {
                            WebBuyView(signedURL: "", receiveAddress: viewModel.newReceiveAddress)
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
                    }
                    else {
                        VStack {
                            
                            HStack {
                                Text(canUserBuyLTC ? "BUY / RECEIVE" : "RECEIVE")
                                        .font(headerFont)
                                        .foregroundColor(BrainwalletColor.content)
                                        .padding(.all, 4.0)

                            }
                            .frame(width: modalWidth, height: 44.0, alignment: .top)
                            .padding([.leading, .trailing,.top], 8.0)
                            
                            HStack {
                                VStack {
                                    Image(uiImage: viewModel.newReceiveAddressQR ?? qrPlaceholder)
                                        .resizable()
                                        .scaledToFit()
                                    Spacer()
                                }
                                .frame(alignment: .top)
                                VStack {
                                    Text(newAddress)
                                        .font(ginormousFont)
                                        .kerning(0.3)
                                        .lineLimit(3)
                                        .multilineTextAlignment(.leading)
                                        .frame(height: 100)
                                        .foregroundColor(BrainwalletColor.content)
                                    
                                    VStack {
                                    HStack {
                                        
                                            Text("Brainwallet generates a new address after each transaction sent")
                                                .font(subDetailFont)
                                                .lineLimit(3)
                                                .multilineTextAlignment(.leading)
                                                .foregroundColor(BrainwalletColor.content)

                                            Button(action: {
                                                UIPasteboard.general.string = viewModel.newReceiveAddress
                                            }) {
                                                ZStack {
                                                    Ellipse()
                                                        .frame(width: 40,
                                                               height: 40)
                                                        .overlay (
                                                            Ellipse()
                                                                .stroke(BrainwalletColor.content, lineWidth: 1)
                                                                .frame(width: 40,
                                                                       height: 40)
                                                        )
                                                    
                                                    Image(systemName: "document.on.document")
                                                        .resizable()
                                                        .frame(width: 23, height: 23)
                                                        .foregroundColor(BrainwalletColor.content)
                                                }
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                    Spacer()
                                }
                                .frame(alignment: .top)

                            }
                            .frame(width: modalWidth, height: height * 0.3, alignment: .top)
                            Divider()
                                .background(BrainwalletColor.nearBlack)
                                .padding([.leading, .trailing], 12.0)

                          
                            HStack {
                                Picker("", selection: $pickedAmount) {
                                    ForEach(viewModel.fiatAmounts, id: \.self) { amount in
                                        Text("\(amount)")
                                            .font(subHeaderFont)
                                            .foregroundColor(BrainwalletColor.content)
                                            .padding(4.0)
                                        
                                    }
                                }
                                .onChange(of: $pickedAmount.wrappedValue) { _ in
                                    viewModel.pickedAmount = pickedAmount
                                    viewModel.fetchRates()
                                }
                                .pickerStyle(.wheel)
                                .frame(width: modalWidth * 0.3 , height: 80, alignment: .leading)

                                Picker("", selection: $pickedCurrency) {
                                    ForEach(viewModel.currencies, id: \.self) {
                                        Text("\($0.code) (\($0.symbol))")
                                            .font(subHeaderFont)
                                            .foregroundColor(BrainwalletColor.content)
                                            .padding(4.0)
                                    }
                                }
                                .onChange(of: $pickedCurrency.wrappedValue) { _ in
                                    viewModel.currentFiatCode = pickedCurrency.code
                                    viewModel.setCurrencyAndRate(code: pickedCurrency.code)
                                    viewModel.fetchRates()
                                }
                                .pickerStyle(.wheel)
                                .frame(width: modalWidth * 0.3 , height: 80, alignment: .leading)

                                VStack {
                                    Text("\(pickedAmount) Ł")
                                        .font(headerFont)
                                        .kerning(0.3)
                                        .foregroundColor(BrainwalletColor.content)

                                    Text("\(fetchedTimestamp)")
                                        .font(lightDetailFont)
                                        .kerning(0.4)
                                        .foregroundColor(BrainwalletColor.content)
                                }
                                .frame(width: modalWidth * 0.4 , height: 80, alignment: .trailing)
                                .padding(.trailing, 8.0)


                            }
                            .frame(width: modalWidth, height: 60.0)
                            .padding(.bottom, 5.0)
                            Divider()
                                .background(BrainwalletColor.nearBlack)
                                .padding([.leading, .trailing], 12.0)
                            
                            Spacer()

                                Button(action: {
                                    userIsBuying.toggle()
                                }) {
                                    VStack {
                                            Text("BUY LTC")
                                            .frame(width: width * 0.9, alignment: .center)
                                                .font(ginormousFont)
                                                .foregroundColor(BrainwalletColor.content)
                                                
                                        
                                            Image("mp-lockup")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: width * 0.9, height: 18, alignment: .top)
                                    }
                                    
                                    .frame(height: buyButtonSize)
                                    .background(BrainwalletColor.background)
                                    .cornerRadius(buttonCorner/2)
                                    .padding(.all, 10.0)

                                }
                                .padding(.all, 10.0)
                                .opacity(viewModel.canUserBuyLTC ? 1.0 : 0.0)
                       
                            
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
                .onReceive(viewModel.$pickedAmount) { newAmount in
                    pickedAmount = newAmount
                }
                .onReceive(viewModel.$canUserBuyLTC) { canBuy in
                    canUserBuyLTC = canBuy
                }
                .onReceive(viewModel.$newReceiveAddress) { newAdd in
                    newAddress = newAdd
                }
                .onReceive(viewModel.$fetchedTimestamp) { time in
                    fetchedTimestamp = time
                }
            }
        }
    }
}
