//
//  BrainwalletPhraseContainerView.swift
//  brainwallet
//
//  Created by Kerry Washington on 22/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct BrainwalletPhraseContainerView: View {

    let wordPad: CGFloat = 10.0

    @State
    private var viewColumns = [GridItem]()

    @State
    private var wordViewWidthRoot = 3

    @State
    private var fetchedEmojisArray: [String] = [""]

    @Binding
    var shouldShow: Bool

    var walletManager: WalletManager

    // Already verified by SecurityListView before this sheet is shown
    let pin: String

    init(shouldShow: Binding<Bool>, walletManager: WalletManager, pin: String) {
        _shouldShow = shouldShow
        self.walletManager = walletManager
        self.pin = pin
    }
    var body: some View {
        ZStack {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height
            let wordViewWidth = width / CGFloat(wordViewWidthRoot) - wordPad

                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
            VStack {
                    LazyVGrid(columns: viewColumns, spacing: 1.0) {
                        ForEach(0 ..< fetchedEmojisArray.count, id: \.self) { index in
                            EmojiPhraseView(emojiItem: fetchedEmojisArray[index], emojiNumber: index+1)
                            .frame(width: wordViewWidth,
                                   height: height * 0.1)
                        }
                    }
                    .padding(15)
                    Spacer()
                    Button(action: {
                        if walletManager.deleteEmojiString(pin: pin) {
                            fetchedEmojisArray = [""]
                            shouldShow.toggle()
                        }
                    }) {

                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(BentoColor.grayBorder,
                                        lineWidth: 0.5)
                                .frame(height: 48)
                            Text("Delete my Emojis")
                                .modifier(BWIPSBold(size: 24.0))
                                .multilineTextAlignment(.center)
                                .foregroundColor(BrainwalletColor.content.opacity(0.6))
                                .frame(width: width * 0.7, height: largeButtonHeight, alignment: .center)
                        }

                    }
                    .frame(height: 48)
                    .padding([.leading, .trailing], 20)
                    .padding([.top, .bottom], 20)
                    .accessibilityIdentifier("EmojisSettingsView.deleteButton")

                    HStack {
                        Text("It's your emojis you use to remember your 12 seed words.")
                            .modifier(BWIPSRegular(size: 16.0, lineLimit: 2))
                            .multilineTextAlignment(.center)
                            .foregroundColor(BrainwalletColor.content)
                    }
                    .padding(.top, 32.0)
                    Spacer()
                }
            }
            .onAppear {
                viewColumns = [GridItem](repeating: GridItem(.flexible()),
                                         count: wordViewWidthRoot)
                if let fetchedEmojis = walletManager.emojiString(pin: pin) {
                    fetchedEmojisArray = fetchedEmojis.map { String($0) }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

        }

    }
}
