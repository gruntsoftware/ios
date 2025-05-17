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
    private var showError: Bool = false
    
    @State private var scannedCode: String?

        
    let qrImageSize: CGFloat = 35.0
    let squareImageSize: CGFloat = 25.0
    let themeBorderSize: CGFloat = 44.0
    let largeButtonHeight: CGFloat = 65.0
    let fieldHeight: CGFloat = 50.0
    let headerFont: Font = .barlowBold(size: 24.0)
    let subHeaderFont: Font = .barlowSemiBold(size: 19.0)
    let detailFont: Font = .barlowRegular(size: 17.0)
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
                    
                    Text("Send View")
                        .foregroundColor(BrainwalletColor.content)
                        .font(headerFont)
                        .padding(.all, 10.0)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Divider()
                        .frame(minHeight: 2.0)
                        .background(BrainwalletColor.nearBlack)
                    
                    HStack {
                        Text("Enter LTC Address:")
                            .frame(width: width * 0.3, height: fieldHeight, alignment: .leading)
                            .font(subHeaderFont)
                            .foregroundColor(BrainwalletColor.content)
                            .padding(.top, 1.0)
                            
                        Spacer()
                        
                        VStack {
                            TextField("", text: $viewModel.sendAddress)
                                .textFieldStyle(.roundedBorder)
                                .foregroundColor(BrainwalletColor.content)
                                .font(textFieldFont)
                                .truncationMode(.middle)
                                .frame(maxWidth: .infinity)
                                .frame(alignment: .leading)
                                .focused($fieldIsFocused)
                                .padding(.top, 1.0)
                                .tint(BrainwalletColor.content)
                                .keyboardType(.namePhonePad)
                        }
                        .frame(height: fieldHeight, alignment: .trailing)
                        .padding(.top, 1.0)
                        
                    }
                    .padding([.leading,.trailing], 16.0)
                    
                    HStack {
                        Text("Send amount:")
                            .frame(width: width * 0.3, height: fieldHeight, alignment: .leading)
                            .font(subHeaderFont)
                            .foregroundColor(BrainwalletColor.content)
                            .padding(.top, 1.0)
                        Spacer()
                        
                        VStack {
                            TextField("", value: $viewModel.sendAmount,
                                      formatter: NumberFormatter())
                            .foregroundColor(BrainwalletColor.content)
                            .font(textFieldFont)
                            .frame(maxWidth: .infinity)
                            .frame(alignment: .trailing)
                            .textFieldStyle(.roundedBorder)
                            .focused($fieldIsFocused)
                            .padding(.top, 1.0)
                            .tint(BrainwalletColor.content)
                            .keyboardType(.decimalPad)
                            
                        }
                        .frame(height: fieldHeight, alignment: .leading)
                        .padding(.top, 1.0)
                    }
                    .padding([.leading,.trailing], 10.0)
                    
                    HStack {
                        Text("Send details:")
                            .frame(width: width * 0.3, height: fieldHeight, alignment: .leading)
                            .frame(maxHeight: .infinity, alignment: .top)
                            .font(subHeaderFont)
                            .foregroundColor(BrainwalletColor.content)
                        Spacer()
                        
                        VStack {
                            Text("Network + Service Fee:")
                                .font(detailFont)
                                .foregroundColor(BrainwalletColor.content)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(height: fieldHeight / 2)
                            Text("$0.04 + $0.34")
                                .font(detailFont)
                                .foregroundColor(BrainwalletColor.content)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(height: fieldHeight / 2)
                            Spacer()
                        }
                        .frame(height: fieldHeight, alignment: .leading)
                    }
                    .padding([.leading,.trailing], 16.0)
                    
                    HStack {
                        Text("Memo:")
                            .frame(width: width * 0.3, height: fieldHeight, alignment: .leading)
                            .font(subHeaderFont)
                            .foregroundColor(BrainwalletColor.content)
                        Spacer()
                        VStack {
                            TextField("", value: $viewModel.memo,
                                      formatter: NumberFormatter())
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
                    
                    HStack {
                        Button(action: {
                            viewModel.userDidTapPaste()
                        }) {
                            VStack {
                                Image(systemName: "document.on.document")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: qrImageSize,
                                           height: qrImageSize,
                                           alignment: .center)
                                    .foregroundColor(BrainwalletColor.content)
                                Text("PASTE")
                                    .foregroundColor(BrainwalletColor.content)
                                    .font(subHeaderFont)
                                    .frame(width: 140, alignment: .center)
                                    .padding(.top, 2.0)
                                    .padding([.leading,.trailing], 10.0)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: qrImageSize + 5.0)
                        .padding([.leading,.trailing], 10.0)
                        
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
                            VStack {
                                Image(systemName: "qrcode.viewfinder")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: qrImageSize,
                                           height: qrImageSize,
                                           alignment: .center)
                                    .foregroundColor(BrainwalletColor.content)
                                
                                Text("SCAN")
                                    .foregroundColor(BrainwalletColor.content)
                                    .font(subHeaderFont)
                                    .frame(width: 140, alignment: .center)
                                    .padding(.top, 2.0)
                                    .padding([.leading,.trailing], 10.0)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: qrImageSize + 10.0)
                        .padding(.all, 10.0)
                        .padding([.leading,.trailing], 10.0)
                    }
                    .padding([.bottom], 24.0)
                    .opacity(fieldIsFocused ? 0.0 : 1.0)
                    
                    Button(action: {
                        if viewModel.validateSendData() {
                           ////Send
                        }
                        else {
                            self.showError.toggle()
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                .frame(width: width * 0.6, height: largeButtonHeight, alignment: .center)
                                .foregroundColor(BrainwalletColor.surface)
                            
                            Text("Send LTC")
                                .frame(width: width * 0.6, height: largeButtonHeight, alignment: .center)
                                .font(subHeaderFont)
                                .foregroundColor(BrainwalletColor.content)
                                .overlay(
                                    RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                        .stroke(BrainwalletColor.content, lineWidth: 2.0)
                                )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: largeButtonHeight)
                    .padding(.all, 10.0)
                    
                    
                }
                .frame(width: width * 0.9, height: isExpanded ? height * 0.8 : height * 0.1, alignment: .top)
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
                            if viewModel.validateSendAddressWith(address: rawCode) {
                                viewModel.sendAddress = rawCode
                                didTapScan.toggle()
                            }
                        }
                    }
                }
            }
        }
    }
}



struct SendView_Previews: PreviewProvider {
    static let viewModel = SendViewModel(store: Store())

    static var previews: some View {
        SendView(viewModel: viewModel)
    }
}
