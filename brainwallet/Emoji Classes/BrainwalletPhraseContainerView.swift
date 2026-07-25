//
//  BrainwalletPhraseContainerView.swift
//  brainwallet
//
//  Created by Kerry Washington on 22/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct BrainwalletPhraseContainerView: View {

    let generalPad: CGFloat = 10.0
    let largePad: CGFloat = 80.0
    let wordPad: CGFloat = 10.0
    let secureFieldHeight: CGFloat = 45.0

    let seedWordCount: Int = kSeedPhraseLength

    @State
    private var viewColumns = [GridItem]()

    @State
    private var wordViewWidthRoot = 3

    @State
    private var enteredPIN = ""

    @State
    private var fetchedEmojisArray: [String] = [""]

    @State
    private var shouldShowEmojis = false

    @Binding
    var shouldShow: Bool

    @State
    private var didEnterPINCode = false

    var walletManager: WalletManager

    init(shouldShow: Binding<Bool>, walletManager: WalletManager) {
        _shouldShow = shouldShow
        self.walletManager = walletManager
    }
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height
            let wordViewWidth = width / CGFloat(wordViewWidthRoot) - wordPad
            ZStack {

                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Text("Enter your PIN to view your Brainwallet phrase")
                            .modifier(BWIPSSemiBold(size: 24.0, lineLimit: 2))
                            .foregroundColor(BrainwalletColor.content)
                    }
                    .padding(20)
                    
                    HStack {
                        Text("It's your emojis you use to remember your 12 seed words.")
                            .modifier(BWIPSSemiBold(size: 24.0, lineLimit: 2))
                            .foregroundColor(BrainwalletColor.content)
                    }
                    .padding(20)
                    if shouldShowEmojis {
                        LazyVGrid(columns: viewColumns, spacing: 1.0) {
                            ForEach(0 ..< fetchedEmojisArray.count, id: \.self) { index in
                                EmojiPhraseView(emojiItem: fetchedEmojisArray[index], emojiNumber: index+1)
                                .frame(width: wordViewWidth,
                                       height: height * 0.1)
                            }
                        }
                        Spacer()
                        Button(action: {
                            if walletManager.deleteEmojiString(pin: enteredPIN) {
                                fetchedEmojisArray = [""]
                                shouldShow.toggle()
                            }
                        }) {
                            Text("Delete my Emojis")
                                .modifier(BWIPSBold(size: 24.0))
                                .foregroundColor(BrainwalletColor.content.opacity(0.6))
                                .frame(width: width * 0.7, height: largeButtonHeight, alignment: .center)

                        }
                        .padding(.all, 8.0)
                        .accessibilityIdentifier("BrainwalletPhraseContainerView.DeleteEmojis")

                    } else {
                        HStack {
                            SecureField("Enter PIN",
                                        text: $enteredPIN)
                            .keyboardType(.numberPad)
                            .textFieldStyle(TranslucentWhiteTextFieldStyle())
                            .multilineTextAlignment(.center)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Done") {
                                        didEnterPINCode.toggle()
                                    }
                                    .foregroundColor(BrainwalletColor.content)
                                    .frame(width: width * 0.25, alignment: .trailing)
                                }
                            }
                            .frame(width: width * 0.3,
                                   height: secureFieldHeight, alignment: .center)
                            .background(BrainwalletColor.surface)
                        }
                        .frame(height: secureFieldHeight, alignment: .top)
                        .padding(.top, 32.0)
                    }
                    Spacer()
                }
            }
            .padding(.all, 10)
            .onAppear {
                viewColumns = [GridItem](repeating: GridItem(.flexible()),
                                         count: wordViewWidthRoot)
            }
            .onChange(of: didEnterPINCode) { _,_ in
                if let fetchedEmojis =  walletManager.emojiString(pin: enteredPIN) {
                    fetchedEmojisArray = fetchedEmojis.map { String($0) }
                    shouldShowEmojis = true
                }
            }
        }
    }
}
