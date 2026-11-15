//
//  SetSixthEmojiView.swift
//  brainwallet
//
//  Created by Kerry Washington on 10/24/26.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct SetSixthEmojiView: View {
    
    @ObservedObject
    var newMainViewModel: NewMainViewModel
    
    @ObservedObject
    var gameHubViewModel: GameHubViewModel
    
    @State
    private var fourthEmojiString: String = ""
    
    @State
    private var fifthEmojiString: String = ""
    
    @State
    private var sixthEmojiString: String = ""
    
    @State
    private var selectedField: SetField? = .fourthField

    @State
    private var shouldShowSeedWords: Bool = false
    
    @State
    private var userEnteredCorrectPin: Bool = false
    
    @State
    private var enteredPin: String = ""
    
    
    @State
    private var seedPhrase: String = ""
    
    private
    var walletManager: WalletManager?
    
    /// Seed words 4 - 6, available once the PIN has fetched the seed phrase.
    private var secondTriplet: [String] {
        let words = seedPhrase.split(separator: " ").map(String.init)
        let triplet = Array(words.dropFirst(3).prefix(3))
        return triplet.count == 3 ? triplet : ["", "", ""]
    }
    
    private var fourthWord: String { secondTriplet[0] }
    
    private var fifthWord: String { secondTriplet[1] }
    
    private var sixthWord: String { secondTriplet[2] }
    
    @State
    private var allUniqueEmojisSelected = false
    
    @FocusState
    var keyboardFocused: Bool
    
    private let setPinLabelText = "Enter your PIN to set emojis 4 - 6"
    private let setEmojisLabelText = "Just like the first 3, match the next 3 seed words. Tap the eye to show seed words."
    
    init(gameHubViewModel: GameHubViewModel,
         viewModel: NewMainViewModel) {
        newMainViewModel = viewModel
        self.gameHubViewModel = gameHubViewModel
        self.walletManager = newMainViewModel.walletManager
    }
    
    private func areUniqueEmojisSelected() -> Bool {
        let emojis = [fourthEmojiString, fifthEmojiString, sixthEmojiString]
        let allUnique = emojis.allSatisfy { !$0.isEmpty } && Set(emojis).count == emojis.count

        // Deselecting the field drops the emoji keyboard
        if allUnique {
            selectedField = nil
        }
        return allUnique
    }
    
    private func emojiFieldSelection(for field: SetField) -> Binding<Bool> {
        Binding(get: { selectedField == field },
                set: { isOn in
            if isOn { selectedField = field }
            else if selectedField == field { selectedField = nil }
        })
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            
            let emojiRowFactor = 130.0
            let setEmojiFactor = 160.0
            let setFactor = 0.275
            
            VStack(alignment: .center) {
                Text("Level up to 6 emojis!")
                    .modifier(BWIPSSemiBold(size: 22.0,
                                            lineLimit: 2))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing], 40.0)
                    .padding(.top, 44.0)
                    .accessibilityIdentifier("levelUpViewTitle")
                
                Text(userEnteredCorrectPin ?  setEmojisLabelText : setPinLabelText)
                    .modifier(BWIPSRegular(size: 16, lineLimit: 3))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing], 50.0)
                    .padding(.top, 20.0)
                    .padding(.bottom, 15.0)
                    .accessibilityIdentifier("levelUpViewDescription")
                
                if userEnteredCorrectPin {
                    HStack {
                        SetEmojiView(isSelected: emojiFieldSelection(for: .fourthField),
                                     seedWord: fourthWord,
                                     emojiString: $fourthEmojiString,
                                     shouldShowWord: $shouldShowSeedWords,
                                     viewIndex: 4,
                                     isActive: true)
                        .frame(width: width * setFactor)
                        .frame(height: emojiRowFactor)
                        .background(emojisFieldGradient)
                        .cornerRadius(16.0)
                        
                        SetEmojiView(isSelected: emojiFieldSelection(for: .fifthField),
                                     seedWord: fifthWord,
                                     emojiString: $fifthEmojiString,
                                     shouldShowWord: $shouldShowSeedWords,
                                     viewIndex: 5,
                                     isActive: true)
                        .frame(width: width * setFactor)
                        .frame(height: emojiRowFactor)
                        .background(emojisFieldGradient)
                        .cornerRadius(16.0)
                        
                        SetEmojiView(isSelected: emojiFieldSelection(for: .sixthField),
                                     seedWord: sixthWord,
                                     emojiString: $sixthEmojiString,
                                     shouldShowWord: $shouldShowSeedWords,
                                     viewIndex: 6,
                                     isActive: true)
                        .frame(width: width * setFactor)
                        .frame(height: emojiRowFactor)
                        .background(emojisFieldGradient)
                        .cornerRadius(16.0)
                        
                    }
                    .frame(width: width * 0.95)
                    .frame(height: setEmojiFactor)
                    .background(emojisSectionGradient)
                    .cornerRadius(16.0)
                    
                    HStack {
                        Button(action: {
                            withAnimation {
                                shouldShowSeedWords.toggle()
                            }
                        }) {
                            Image(systemName: shouldShowSeedWords ? "eye.slash" : "eye")
                                .font(.system(size: 25, weight: .light))
                                .foregroundColor(Color.white)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(height: 44.0)
                    .padding([.top,.bottom], 10.0)
                    
                } else {
                    SecureField(String(localized:"Enter PIN"),
                                text: $enteredPin)
                    .font(.ibmPlexSansRegular(size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .keyboardType(.numberPad)
                    .textFieldStyle(TranslucentWhiteTextFieldStyle())
                    .frame(width: width * 0.4, alignment: .center)
                    .onChange(of: enteredPin) { _,newValue in
                        if newValue.count == 4 {
                            if let walletManager = self.walletManager,
                               let phrase = walletManager.seedPhrase(pin: newValue) {
                                seedPhrase = phrase
                                userEnteredCorrectPin = true
                                keyboardFocused = false
                            }
                        }
                    }
                    .focused($keyboardFocused)
                    .onAppear {
                        // Wait for the sheet to finish presenting, focus is ignored before that
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            keyboardFocused = true
                        }
                    }
                    .accessibilityIdentifier("enterPINFetchSeedTextField")
                }
                Spacer()
                
                Button(action: {
                    
                    if (gameHubViewModel.setSecondEmojiTriplet(fourth: fourthEmojiString, fifth: fifthEmojiString, sixth: sixthEmojiString)) {
                        gameHubViewModel.checkEmojiCount()
                        // Close the sheet, NewMainView launches the game on didJustCompleteEmojiSetup
                        newMainViewModel.shouldShowGameSDK = false
                        gameHubViewModel.didJustCompleteEmojiSetup = true
                    }
                    
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white)
                        Text(allUniqueEmojisSelected ? "Let's Play!" : "")
                            .modifier(BWIPSSemiBold(size: 19.0))
                            .foregroundColor(allUniqueEmojisSelected ?
                                             BrainwalletColor.midnight :
                                                BrainwalletColor.midnight.opacity(0.3))
                    }
                }
                .frame(width: width * 0.9, height: 50.0)
                .cornerRadius(11.0)
                .padding( [.leading,.trailing], 16.0)
                .padding( .bottom, 16.0)
                .disabled(!allUniqueEmojisSelected)
                .opacity(userEnteredCorrectPin ? 1.0 : 0.0)
                
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(emojisBackgroundGradient.ignoresSafeArea())
        .ignoresSafeArea(.keyboard)
        .onChange(of: fourthEmojiString) { _, _ in allUniqueEmojisSelected = areUniqueEmojisSelected() }
        .onChange(of: fifthEmojiString) { _, _ in allUniqueEmojisSelected = areUniqueEmojisSelected() }
        .onChange(of: sixthEmojiString) { _, _ in allUniqueEmojisSelected = areUniqueEmojisSelected() }
    }
}

#Preview {
    let walletManager = MockSeeds.walletManager
    SetSixthEmojiView(gameHubViewModel: GameHubViewModel(walletManager: walletManager),
                      viewModel: NewMainViewModel(store: Store(), walletManager: walletManager))
}
