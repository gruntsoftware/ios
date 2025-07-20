//
//  SeedWordsGridView.swift
//  brainwallet
//
//  Created by Kerry Washington on 26/04/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct SeedWordsGridView: View {

    @Binding
    var seedWords: [SeedWord]

    @State
    private var seedWord1 = SeedWord(word: "", tagNumber: 1)
    @State
    private var seedWord2 = SeedWord(word: "", tagNumber: 2)
    @State
    private var seedWord3 = SeedWord(word: "", tagNumber: 3)
    @State
    private var seedWord4 = SeedWord(word: "", tagNumber: 4)
    @State
    private var seedWord5 = SeedWord(word: "", tagNumber: 5)
    @State
    private var seedWord6 = SeedWord(word: "", tagNumber: 6)
    @State
    private var seedWord7 = SeedWord(word: "", tagNumber: 7)
    @State
    private var seedWord8 = SeedWord(word: "", tagNumber: 8)
    @State
    private var seedWord9 = SeedWord(word: "", tagNumber: 9)
    @State
    private var seedWord10 = SeedWord(word: "", tagNumber: 10)
    @State
    private var seedWord11 = SeedWord(word: "", tagNumber: 11)
    @State
    private var seedWord12 = SeedWord(word: "", tagNumber: 12)

    let elementSpacing = 8.0
    let fieldHeight: CGFloat = 40.0

    init(seedWords: Binding<[SeedWord]>) {
        _seedWords = seedWords
    }

    var body: some View {
        GeometryReader { _ in

            ZStack {
                VStack {
                    Grid(horizontalSpacing: elementSpacing,
                         verticalSpacing: elementSpacing) {
                        GridRow {
                            SeedWordView(seedWord: seedWord1.word, wordNumber: seedWord1.tagNumber)
                            SeedWordView(seedWord: seedWord2.word, wordNumber: seedWord2.tagNumber)
                            SeedWordView(seedWord: seedWord3.word, wordNumber: seedWord3.tagNumber)
                        }
                        .frame(minHeight: fieldHeight)

                        GridRow {
                            SeedWordView(seedWord: seedWord4.word, wordNumber: seedWord4.tagNumber)
                            SeedWordView(seedWord: seedWord5.word, wordNumber: seedWord5.tagNumber)
                            SeedWordView(seedWord: seedWord6.word, wordNumber: seedWord6.tagNumber)
                        }
                        .frame(minHeight: fieldHeight)

                        GridRow {
                            SeedWordView(seedWord: seedWord7.word, wordNumber: seedWord7.tagNumber)
                            SeedWordView(seedWord: seedWord8.word, wordNumber: seedWord8.tagNumber)
                            SeedWordView(seedWord: seedWord9.word, wordNumber: seedWord9.tagNumber)
                        }
                        .frame(minHeight: fieldHeight)
                        GridRow {
                            SeedWordView(seedWord: seedWord10.word, wordNumber: seedWord10.tagNumber)
                            SeedWordView(seedWord: seedWord11.word, wordNumber: seedWord11.tagNumber)
                            SeedWordView(seedWord: seedWord12.word, wordNumber: seedWord12.tagNumber)
                        }
                        .frame(minHeight: fieldHeight)
                    }
                    .frame(height: fieldHeight * 4)
                    .padding(8.0)
                }
                .onChange(of: seedWords) { _ in

                    if seedWords.count == kSeedPhraseLength {

                        debugPrint(":::seedWords \(seedWords)")

                        seedWord1 = SeedWord(word: seedWords[0].word, tagNumber: seedWords[0].tagNumber)
                        seedWord2 = SeedWord(word: seedWords[1].word, tagNumber: seedWords[1].tagNumber)
                        seedWord3 = SeedWord(word: seedWords[2].word, tagNumber: seedWords[2].tagNumber)
                        seedWord4 = SeedWord(word: seedWords[3].word, tagNumber: seedWords[3].tagNumber)
                        seedWord5 = SeedWord(word: seedWords[4].word, tagNumber: seedWords[4].tagNumber)
                        seedWord6 = SeedWord(word: seedWords[5].word, tagNumber: seedWords[5].tagNumber)
                        seedWord7 = SeedWord(word: seedWords[6].word, tagNumber: seedWords[6].tagNumber)
                        seedWord8 = SeedWord(word: seedWords[7].word, tagNumber: seedWords[7].tagNumber)
                        seedWord9 = SeedWord(word: seedWords[8].word, tagNumber: seedWords[8].tagNumber)
                        seedWord10 = SeedWord(word: seedWords[9].word, tagNumber: seedWords[9].tagNumber)
                        seedWord11 = SeedWord(word: seedWords[10].word, tagNumber: seedWords[10].tagNumber)
                        seedWord12 = SeedWord(word: seedWords[11].word, tagNumber: seedWords[11].tagNumber)
                    }
                }
            }
        }
    }
}
