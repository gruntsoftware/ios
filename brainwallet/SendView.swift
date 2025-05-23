//
//  SendView.swift
//  brainwallet
//
//  Created by Kerry Washington on 17/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
 
import SwiftUI

struct SendView: View {
    
    @ObservedObject
    var viewModel: SendViewModel
    
    @FocusState
    private var fieldIsFocused: Bool
    
    @State
    private var isExpanded: Bool = false
    
    @State
    private var didTapScan: Bool = false
    
    @State
    private var userCanSend: Bool = false
    
    @State
    private var showError: Bool = false
    
    @State
    private var scannedCode: String?
    
    @State
    private var symbol = "Ł"

    let qrImageSize: CGFloat = 22.0
    let squareImageSize: CGFloat = 25.0
    let themeBorderSize: CGFloat = 44.0
    let largeButtonHeight: CGFloat = 45.0
    let fieldHeight: CGFloat = 30.0
    let headerFont: Font = .barlowBold(size: 24.0)
    let subHeaderFont: Font = .barlowSemiBold(size: 17.0)
    let detailFont: Font = .barlowSemiBold(size: 15.0)
    let subDetailFont: Font = .barlowRegular(size: 14.0)

    let textFieldFont: Font = .barlowRegular(size: 15.0)
    
    
    init(viewModel: SendViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                
                BrainwalletColor.content.edgesIgnoringSafeArea(.all)
                
                VStack {
                    
                    Text("Send Litecoin")
                        .foregroundColor(BrainwalletColor.content)
                        .font(headerFont)
                        .padding(.all, 8.0)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Divider()
                        .frame(minHeight: 2.0)
                        .background(BrainwalletColor.nearBlack)
                    
                    HStack {
                        Text("Address:")
                            .frame(width: width * 0.2, height: fieldHeight, alignment: .leading)
                            .font(subHeaderFont)
                            .foregroundColor(BrainwalletColor.content)
                       Spacer()
                        
                        VStack {
                            TextField("ltc1... or L... or M...", text: $viewModel.sendAddress)
                                .textFieldStyle(.roundedBorder)
                                .foregroundColor(BrainwalletColor.content)
                                .font(textFieldFont)
                                .truncationMode(.middle)
                                .focused($fieldIsFocused)
                                .tint(BrainwalletColor.content)
                                .keyboardType(.namePhonePad)
                        }
                    }
                    .padding([.leading,.trailing], 16.0)
                    .frame(height: fieldHeight)
                    .padding([.top,.bottom], 4.0)

                    
                    HStack {
                        Spacer()
                        Button(action: {
                            viewModel.userDidTapPaste()
                        }) {
                            ZStack {
                                Capsule()
                                    .stroke(BrainwalletColor.content, lineWidth: 1.5)
                                    .background(BrainwalletColor.surface)
                                    .frame(width: width * 0.15,
                                           height: fieldHeight,
                                           alignment: .center)
                                    .clipShape(Capsule())
                                    .shadow(color: BrainwalletColor.gray, radius: 0.5, x: 2, y: 2)
                                
                                Text("PASTE")
                                    .foregroundColor(BrainwalletColor.content)
                                    .font(detailFont)
                                    .frame(width: width * 0.15,
                                           height: fieldHeight,
                                           alignment: .center)
                                    .padding(.all, 5.0)
                                    .clipShape(Capsule())
                            }
                        }
                        .frame(width: 45.0, height: fieldHeight, alignment: .center)
                        .padding(.trailing, 20.0)

                        Button(action: {
                            #if targetEnvironment(simulator)
                                debugPrint(" No camera in simulator")
                            #else
                            CameraPermission.checkCameraAuthorization { granted in
                                               if granted {
                                                       didTapScan.toggle()
                                               }
                                           }
                            
                            #endif
                        }) {
                            ZStack {
                                Capsule()
                                    .stroke(BrainwalletColor.content, lineWidth: 1.5)
                                    .background(BrainwalletColor.surface)
                                    .frame(width: width * 0.15,
                                           height: fieldHeight,
                                           alignment: .center)
                                    .clipShape(Capsule())
                                    .shadow(color: BrainwalletColor.gray, radius: 0.5, x: 2, y: 2)
                                
                                Text("SCAN")
                                    .foregroundColor(BrainwalletColor.content)
                                    .font(detailFont)
                                    .frame(width: width * 0.15,
                                           height: fieldHeight,
                                           alignment: .center)
                                    .clipShape(Capsule())

                            }
                        }
                        .frame(width: 45.0, height: fieldHeight, alignment: .center)

                    }
                    .padding([.leading,.trailing], 16.0)
                    .frame(height: fieldHeight)
                    .padding([.top,.bottom], 4.0)


                    HStack {
                        Text("Amount:")
                            .frame(width: width * 0.25, height: fieldHeight, alignment: .leading)
                            .font(subHeaderFont)
                            .foregroundColor(BrainwalletColor.content)
                            .padding(.top, 1.0)
                        Spacer()
                        
                        VStack {
                            TextField("", text: $viewModel.sendAmountString)
                            .foregroundColor(BrainwalletColor.content)
                            .font(textFieldFont)
                            .frame(width: width * 0.35, alignment: .trailing)
                            .frame(alignment: .trailing)
                            .padding(.trailing, 20.0)
                            .textFieldStyle(.roundedBorder)
                            .focused($fieldIsFocused)
                            .tint(BrainwalletColor.content)
                            .keyboardType(.decimalPad)
                            
                        }
                        .frame(height: fieldHeight, alignment: .leading)
                        
                        Button(action: {
                            viewModel.userPrefersToShowLTC.toggle()
                            viewModel.updateAmountValue()
                            
                        }) {
                            ZStack {
                                
                                Capsule()
                                    .stroke(BrainwalletColor.content, lineWidth: 1.5)
                                    .background(BrainwalletColor.surface)
                                    .frame(width: width * 0.15,
                                           height: fieldHeight,
                                           alignment: .center)
                                    .clipShape(Capsule())
                                    .shadow(color: BrainwalletColor.gray, radius: 0.5, x: 2, y: 2)
                                
                                Text(viewModel.currencyCodeString)
                                    .foregroundColor(BrainwalletColor.content)
                                    .font(detailFont)
                                    .frame(width: width * 0.15,
                                           height: fieldHeight,
                                           alignment: .center)
                                    .padding(.all, 9.0)
                                    .clipShape(Capsule())
                            }
                            
                        }
                        .frame(width: 45.0, height: fieldHeight, alignment: .center)
                    }
                    .padding([.leading,.trailing], 16.0)
                    .frame(height: fieldHeight)
                    .padding([.top,.bottom], 4.0)


                    HStack {
                            VStack {
                                Text("Network + Service Fees:")
                                    .font(subDetailFont)
                                    .foregroundColor(BrainwalletColor.content)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("Total sending:")
                                    .font(subDetailFont)
                                    .foregroundColor(viewModel.isOverBalance ? BrainwalletColor.error : BrainwalletColor.content)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("Remaining:")
                                    .font(subDetailFont)
                                    .foregroundColor(viewModel.isOverBalance ? BrainwalletColor.error : BrainwalletColor.content)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                            }
                            .frame(width: width * 0.4, alignment: .topLeading)
                           
                            VStack {
                                Text(viewModel.totalFees)
                                    .font(subDetailFont)
                                    .foregroundColor(BrainwalletColor.content)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(viewModel.totalAmountToSend)
                                    .font(subDetailFont)
                                    .foregroundColor(viewModel.isOverBalance ? BrainwalletColor.error : BrainwalletColor.content)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(viewModel.remainingBalance)
                                    .font(subDetailFont)
                                    .foregroundColor(viewModel.isOverBalance ? BrainwalletColor.error : BrainwalletColor.content)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                            }
                            .frame(width: width * 0.4, alignment: .topLeading)
                        
                            Spacer()
                    }
                    .padding([.leading,.trailing], 16.0)
                    
                    HStack {
                        Text("Memo:")
                            .frame(width: width * 0.3, height: fieldHeight, alignment: .leading)
                            .font(subHeaderFont)
                            .foregroundColor(BrainwalletColor.content)
                        Spacer()
                        VStack {
                            TextField("", text: $viewModel.memo)
                            .foregroundColor(BrainwalletColor.content)
                            .font(textFieldFont)
                            .frame(maxWidth: .infinity)
                            .frame(alignment: .leading)
                            .textFieldStyle(.roundedBorder)
                            .focused($fieldIsFocused)
                            .keyboardType(.default)
                        }
                    }
                    .padding([.leading,.trailing], 16.0)
                    
                    Spacer()
                    
                    
                    Button(action: {
                        viewModel.sendLTC()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                .frame(width: width * 0.6, height: largeButtonHeight, alignment: .center)
                                .foregroundColor(BrainwalletColor.surface)
                            
                            Text("Send")
                                .frame(width: width * 0.6, height: largeButtonHeight, alignment: .center)
                                .font(subHeaderFont)
                                .foregroundColor(userCanSend ? BrainwalletColor.content : BrainwalletColor.content.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                        .stroke(userCanSend ? BrainwalletColor.content : BrainwalletColor.content.opacity(0.2), lineWidth: 2.0)
                                )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: largeButtonHeight)
                    .padding(.all, 10.0)
                    .disabled(!userCanSend)
                    
                    
                }
                .frame(width: width * 0.9, height: isExpanded ? height * 0.75 : height * 0.1, alignment: .top)
                .opacity(isExpanded ? 1.0 : 0.0)
                .background(BrainwalletColor.surface)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.isExpanded = true
                    }
                }
                .cornerRadius(largeButtonHeight/2)
                .onTapGesture {
                    if fieldIsFocused {
                        fieldIsFocused = false
                    }
                }
                .alert("Send Error", isPresented: $showError, actions: {
                    Button("OK") {
                    }
                }, message: {
                    Text(" Make sure the send address is valid, the amount is not zero, & you have enough LTC in your Brainwallet")
                })
                .sheet(isPresented: $didTapScan) {
                    
                    NewCameraScannerView { code in
                        if code.split(separator: ":").count == 2 {
                            let rawCode = String(code.split(separator: ":")[1])
                            if viewModel.validateLitecoinAddress(rawCode) {
                                viewModel.sendAddress = rawCode
                                didTapScan.toggle()
                            }
                        }
                    }
                }
                .onChange(of: viewModel.sendAmountString, perform: { _ in
                    viewModel.updateAmountValue()
                    
                    let amountGreaterThanZero: Bool = (Double(viewModel.sendAmountString) ?? 0.0) > 0 ? true : false
                    if (!viewModel.isOverBalance && amountGreaterThanZero && viewModel.validateLitecoinAddress(viewModel.sendAddress)) {
                        userCanSend = true
                    }
                    else {
                        userCanSend = false
                    }
                    debugPrint("||| userCanSend |  sendAmountString \(userCanSend)")
                })
                .onChange(of: viewModel.sendAddress, perform: { _ in
                    let amountGreaterThanZero: Bool = (Double(viewModel.sendAmountString) ?? 0.0) > 0 ? true : false
                    if (!viewModel.isOverBalance && amountGreaterThanZero && viewModel.validateLitecoinAddress(viewModel.sendAddress)) {
                        userCanSend = true
                    }
                    else {
                        userCanSend = false
                    }
                    debugPrint("||| userCanSend |  sendAddress \(userCanSend)")
                })
            }
        }
    }
}
