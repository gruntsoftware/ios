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
    private var userIsBuying = false
    
    @State
    private var symbol = "Ł"

    let qrImageSize: CGFloat = 80.0
    let squareImageSize: CGFloat = 16.0
    let themeBorderSize: CGFloat = 44.0
    let modalCorner: CGFloat = 60.0
    let fieldHeight: CGFloat = 30.0
    let headerFont: Font = .barlowBold(size: 26.0)
    let ginormousFont: Font = .barlowSemiBold(size: 22.0)
    let subHeaderFont: Font = .barlowSemiBold(size: 17.0)
    let detailFont: Font = .barlowSemiBold(size: 15.0)
    let subDetailFont: Font = .barlowRegular(size: 14.0)

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
            
            let modalReceiveViewHeight = height * 0.35
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
                                Text(viewModel.canUserBuyLTC ? "BUY / RECEIVE" : "RECEIVE")
                                        .font(headerFont)
                                        .foregroundColor(BrainwalletColor.content)
                                        .padding(.all, 4.0)

                            }
                            .frame(width: modalWidth, height: 40.0, alignment: .top)
                            .padding([.leading, .trailing,.top], 8.0)
                            
                            HStack {
                                VStack {
                                    Image(uiImage: viewModel.newReceiveAddressQR ?? qrPlaceholder)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: width * 0.4, height: width * 0.4)
                                    Spacer()
                                }
                                .frame(height: height * 0.3)

                                Spacer()
                                VStack {
                                    Text(viewModel.newReceiveAddress)
                                        .font(ginormousFont)
                                        .kerning(0.3)
                                        .lineLimit(3)
                                        .multilineTextAlignment(.leading)
                                        .frame(width: width * 0.35, height: width * 0.2)
                                        .foregroundColor(BrainwalletColor.content)
                                    
                                    HStack {
                                        Text("Brainwallet generates a new address after each transaction sent")
                                            .font(subDetailFont)
                                            .kerning(0.3)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .frame(width: width * 0.25)
                                            .foregroundColor(BrainwalletColor.content)
                                        Button(action: {
                                            UIPasteboard.general.string = viewModel.newReceiveAddress
                                        }) {
                                            ZStack {
                                                Ellipse()
                                                    .foregroundColor(BrainwalletColor.background)
                                                    .frame(width: 38, height: 38)
                                                    .padding(10.0)

                                                Image(systemName: "document.on.document")
                                                    .resizable()
                                                    .frame(width: 23, height: 23)
                                                    .foregroundColor(BrainwalletColor.content)
                                            }
                                        }
                                        .frame(width: width * 0.1)
                                    }
                                    Spacer()
                                }
                                .frame(height: height * 0.3, alignment: .top)
                            }
                            .frame(width: modalWidth, height: height * 0.3, alignment: .top)
                            .foregroundColor(.red)


                            HStack {
                                
                                Button(action: {
                                    userIsBuying.toggle()
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: modalCorner/2)
                                            .frame(height: modalCorner, alignment: .center)
                                            .frame(width: width * 0.25)
                                            .foregroundColor(BrainwalletColor.surface)
                                        
                                        HStack {
                                            Text("Buy LTC")
                                                .frame(height: modalCorner, alignment: .center)
                                                .frame(width: width * 0.25)
                                                .font(subHeaderFont)
                                                .foregroundColor(BrainwalletColor.content)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: modalCorner/2)
                                                        .stroke(BrainwalletColor.content)
                                                )
                                                .padding(.all, 8.0)
                                        }
                                    }
                                }
                                .frame(width: width * 0.25)
                                .frame(height: modalCorner)
                                .padding(.all, 10.0)
                                .opacity(viewModel.canUserBuyLTC ? 1.0 : 0.0)
                                .background(.pink)
                            }
                            .frame(height: viewModel.canUserBuyLTC ? height * 0.3 : 0.0, alignment: .top)
                            .opacity(viewModel.canUserBuyLTC ? 1.0 : 0.0)
                            .background(.red)
//
//                            Spacer()
//                            HStack {
//
//                            }
//                            .frame(width: modalWidth, height: 60.0)
//                            .padding(.bottom, 5.0)
                            
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
            }
        }
    }
}
