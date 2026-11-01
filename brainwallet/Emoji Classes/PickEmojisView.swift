//
//  PickEmojisView.swift
//  brainwallet
//
//  Created by Kerry Washington on 7/19/26.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

enum SetField : Int {
    case firstField = 1
    case secondField = 2
    case thirdField = 3
    case fourthField = 4
    case fifthField = 5
    case sixthField = 6
}

struct PickEmojisView: View {
    @ObservedObject
    var gameHubViewModel: GameHubViewModel
    
    @ObservedObject
    var newMainViewModel: NewMainViewModel
    
    @State
    private var firstEmojiString: String = ""
    
    @State
    private var secondEmojiString: String = ""
    
    @State
    private var thirdEmojiString: String = ""
    
    @State
    private var selectedField: SetField? = .firstField
    
    @State
    private var shouldShowSeedWords: Bool = false
    
    @Binding
    var selectedPage: Int
    
    private func emojiFieldSelection(for field: SetField) -> Binding<Bool> {
        Binding(get: { selectedField == field },
                set: { isOn in
                    if isOn { selectedField = field }
                    else if selectedField == field { selectedField = nil }
                })
    }
    
    private let seedPhrase: String
    
    private var firstTriplet = [String]()
    
    
    private var firstWord = ""
    
    
    private var secondWord = ""

   
    private var thirdWord = ""
    
    @State
    private var uniqueEmojisSelected = false
    
    init(gameHubViewModel: GameHubViewModel,
         viewModel: NewMainViewModel,
         seedPhrase: String,
         selectedPage: Binding<Int>) {
        _selectedPage = selectedPage
        self.gameHubViewModel = gameHubViewModel
        self.seedPhrase = seedPhrase
        newMainViewModel = viewModel
        
        let words = seedPhrase.split(separator: " ").map(String.init)
        firstTriplet = Array(words.prefix(3))
        if firstTriplet.count == 3 {
            firstWord = firstTriplet[0]
            secondWord = firstTriplet[1]
            thirdWord = firstTriplet[2]
        }
    }
    
    private func areUniqueEmojisSelected() -> Bool {
        let emojis = [firstEmojiString, secondEmojiString, thirdEmojiString]
        return emojis.allSatisfy { !$0.isEmpty } && Set(emojis).count == emojis.count
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            let width = geometry.size.width 
            let emojiRowFactor = 130.0
            let setEmojiFactor = 160.0
            let setFactor = 0.275
            
            VStack {
                ZStack {
                    HStack {
                        Button(action: {
                            withAnimation {
                                selectedPage = 0
                            }
                        }) {
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.top, 30.0)
                    .padding(.leading, 24.0)
                    .frame(height: 50.0)
                    
                    HStack {
                        
                        Text("Pick 3 Emojis")
                            .modifier(BWIPSSemiBold(size: 22.0,
                                                    lineLimit: 1))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .accessibilityIdentifier("howItWorksViewTitle")
                    }
                    .padding(.top, 30.0)
                }
                Text("Tap a box. Show or hide words to choose your emojis. Tap an emoji. Each emoji must be different.")
                    .modifier(BWIPSRegular(size: 20, lineLimit: 3))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(height: 60.0)
                    .padding([.leading, .trailing], 30.0)
                    .padding(.top, 10.0)
                    .padding(.bottom, 10.0)
                    .accessibilityIdentifier("howItWorksViewDescription")
                
                HStack {
                    SetEmojiView(isSelected: emojiFieldSelection(for: .firstField),
                                 seedWord: firstWord,
                                 emojiString: $firstEmojiString,
                                 shouldShowWord: $shouldShowSeedWords,
                                 viewIndex: 1,
                                 isActive: selectedPage == 2)
                    .frame(width: width * setFactor)
                    .frame(height: emojiRowFactor)
                    .background(emojisFieldGradient)
                    .cornerRadius(16.0)
                    
                    SetEmojiView(isSelected: emojiFieldSelection(for: .secondField),
                                 seedWord: secondWord,
                                 emojiString: $secondEmojiString,
                                 shouldShowWord: $shouldShowSeedWords,
                                 viewIndex: 2,
                                 isActive: selectedPage == 2)
                    .frame(width: width * setFactor)
                    .frame(height: emojiRowFactor)
                    .background(emojisFieldGradient)
                    .cornerRadius(16.0)
                    
                    SetEmojiView(isSelected: emojiFieldSelection(for: .thirdField),
                                 seedWord: thirdWord,
                                 emojiString: $thirdEmojiString,
                                 shouldShowWord: $shouldShowSeedWords,
                                 viewIndex: 3,
                                 isActive: selectedPage == 2)
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
                
                Spacer()
                
                Button(action: {
                    if (gameHubViewModel.setFirstEmojiTriplet(first: firstEmojiString,
                                                         second: secondEmojiString,
                                                         third: thirdEmojiString)) {
                        gameHubViewModel.checkEmojiCount()
                        gameHubViewModel.didJustCompleteEmojiSetup = true
                    }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white)
                            Text(uniqueEmojisSelected ? "Let's Go!" : "Pick 3 Unique Emojis")
                                .modifier(BWIPSSemiBold(size: 19.0))
                                .foregroundColor( uniqueEmojisSelected ?
                                                  BrainwalletColor.midnight :
                                                    BrainwalletColor.midnight.opacity(0.3))
                        }
                    }
                        .frame(width: width * 0.9, height: 50.0)
                        .cornerRadius(11.0)
                        .padding( .bottom, 16.0)
                        .disabled(!uniqueEmojisSelected)
                }
                .background(emojisBackgroundGradient.ignoresSafeArea())
            }
            .ignoresSafeArea(.keyboard)
            .onChange(of: firstEmojiString) { _, _ in uniqueEmojisSelected = areUniqueEmojisSelected() }
            .onChange(of: secondEmojiString) { _, _ in uniqueEmojisSelected = areUniqueEmojisSelected() }
            .onChange(of: thirdEmojiString) { _, _ in uniqueEmojisSelected = areUniqueEmojisSelected() }
        }
}

#Preview {
    @Previewable @State var selectedPage = 0
    let walletManager = MockSeeds.walletManager
    PickEmojisView(gameHubViewModel: GameHubViewModel(walletManager: walletManager),
                   viewModel: NewMainViewModel(store: Store(), walletManager: walletManager),
                   seedPhrase: MockSeeds.twelveWords.map(\.word).joined(separator: " "),
                   selectedPage: $selectedPage)
}
