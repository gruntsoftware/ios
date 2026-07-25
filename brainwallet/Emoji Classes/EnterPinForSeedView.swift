//
//  EnterPinForSeedView.swift
//  brainwallet
//
//  Created by Kerry Washington on 7/24/26.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
 
import SwiftUI

struct EnterPinForSeedView: View {
 
    @Binding
    var selectedPage: Int

    @Binding
    var enteredPin: String
    
    @Binding
    var seedPhrase: String
    
    var walletManager: WalletManager?
    
    
    @State
    private var pinWasEnteredCorrectly: Bool = false
    
    @FocusState
    var keyboardFocused: Bool

    let backgroundGradient: LinearGradient
    
    init(backgroundGradient: LinearGradient,
         enteredPin: Binding<String>,
         seedPhrase: Binding<String>,
         viewModel: NewMainViewModel,
         selectedPage: Binding<Int>) {
        self.backgroundGradient = backgroundGradient
        _enteredPin = enteredPin
        _selectedPage = selectedPage
        _seedPhrase = seedPhrase
        if let walletManager = viewModel.walletManager {
            self.walletManager = walletManager
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            
            VStack(alignment: .center) {
                Text("Enter your PIN to fetch the seed words")
                    .modifier(BWIPSSemiBold(size: 22.0,
                                            lineLimit: 2))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing], 40.0)
                    .padding([.top, .bottom], 44.0)
                    .accessibilityIdentifier("enterPINFetchSeedTitle")
                
               
                
                TextField(String(localized:"Enter PIN"),
                          text: $enteredPin)
                .font(.ibmPlexSansRegular(size: 20))
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .textFieldStyle(TranslucentWhiteTextFieldStyle())
                .frame(width: width * 0.4, alignment: .center)
                .onChange(of: enteredPin) { _,newValue in
                    if newValue.count == 4 {
                        if let walletManager = walletManager,
                        let phrase = walletManager.seedPhrase(pin: newValue) {
                            seedPhrase = phrase
                            pinWasEnteredCorrectly  = true
                            keyboardFocused = false
                        }
                    }
                }
                .focused($keyboardFocused)
                .accessibilityIdentifier("enterPINFetchSeedTextField")


                Spacer()
                
                Button(action: {
                    if pinWasEnteredCorrectly {
                        selectedPage += 1
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white)
                        Text("Continue")
                            .modifier(BWIPSSemiBold(size: 19.0))
                            .foregroundColor(enteredPin.isEmpty ?
                                             BrainwalletColor.midnight.opacity(0.5) : BrainwalletColor.midnight)
                    }
                }
                .frame(width: width * 0.9, height: 50.0, alignment: .center)
                .cornerRadius(11.0)
                .padding( .bottom, 16.0)
                .disabled(!pinWasEnteredCorrectly)
                
            }
            .frame(width: width, height: height, alignment: .center)
            .onDisappear {
                enteredPin = ""
            }
        }
        .background(backgroundGradient)
    }
}
