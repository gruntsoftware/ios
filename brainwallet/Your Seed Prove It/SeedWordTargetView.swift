//
//  SeedWordTargetView.swift
//  brainwallet
//
//  Created by Kerry Washington on 08/07/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SeedWordTargetView: View {

    @ObservedObject
    var seedViewModel = SeedViewModel(enteredPIN: .constant(""))

    @State
    private var word1Bucket: DraggableSeedWord?
    @State
    private var word2Bucket: DraggableSeedWord?
    @State
    private var word3Bucket: DraggableSeedWord?
    @State
    private var word4Bucket: DraggableSeedWord?
    @State
    private var word5Bucket: DraggableSeedWord?
    @State
    private var word6Bucket: DraggableSeedWord?
    @State
    private var word7Bucket: DraggableSeedWord?
    @State
    private var word8Bucket: DraggableSeedWord?
    @State
    private var word9Bucket: DraggableSeedWord?
    @State
    private var word10Bucket: DraggableSeedWord?
    @State
    private var word11Bucket: DraggableSeedWord?
    @State
    private var word12Bucket: DraggableSeedWord?

    @ObservedObject
    var viewModel: NewMainViewModel
    let pileHeight: CGFloat = 190.0
    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let themeBorderSize: CGFloat = 44.0
    let largeButtonHeight: CGFloat = 65.0
    let largeButtonFont: Font = .barlowBold(size: 24.0)
    let subTitleFont: Font = .barlowSemiBold(size: 32.0)
    let detailFont: Font = .barlowRegular(size: 22.0)
    let detailerFont: Font = .barlowRegular(size: 20.0)
    let regularButtonFont: Font = .barlowRegular(size: 20.0)

    let elementSpacing = 8.0
    let fieldHeight: CGFloat = 40.0
    let arrowSize: CGFloat = 60.0
    let userPrefersDarkTheme = UserDefaults.userPreferredDarkTheme
    private let columns = Array(repeating: GridItem(.flexible(minimum: 80)), count: 3)
    init(viewModel: NewMainViewModel) {
        self.viewModel = viewModel
    }

    private func loadWordBuckets() {
        if self.viewModel.draggableSeedPhrase.count == kSeedPhraseLength {
            var draggableSeedPhrase = mockDraggableArray
            #if RELEASE
            draggableSeedPhrase = self.viewModel.draggableSeedPhrase
            #endif
            self.word1Bucket = DraggableSeedWord(id: UUID(), tagNumber: draggableSeedPhrase[0].tagNumber, word: draggableSeedPhrase[0].word, doesMatch: false)
            self.word2Bucket = DraggableSeedWord(id: UUID(), tagNumber: draggableSeedPhrase[1].tagNumber, word: draggableSeedPhrase[1].word, doesMatch: false)
            self.word3Bucket = DraggableSeedWord(id: UUID(), tagNumber: draggableSeedPhrase[2].tagNumber, word: draggableSeedPhrase[2].word, doesMatch: false)
            self.word4Bucket = DraggableSeedWord(id: UUID(), tagNumber: draggableSeedPhrase[3].tagNumber, word: draggableSeedPhrase[3].word, doesMatch: false)
            self.word5Bucket = DraggableSeedWord(id: UUID(), tagNumber: draggableSeedPhrase[4].tagNumber, word: draggableSeedPhrase[4].word, doesMatch: false)
            self.word6Bucket = DraggableSeedWord(id: UUID(), tagNumber: draggableSeedPhrase[5].tagNumber, word: draggableSeedPhrase[5].word, doesMatch: false)
            self.word7Bucket = DraggableSeedWord(id: UUID(), tagNumber: draggableSeedPhrase[6].tagNumber, word: draggableSeedPhrase[6].word, doesMatch: false)
            self.word8Bucket = DraggableSeedWord(id: UUID(), tagNumber: draggableSeedPhrase[7].tagNumber, word: draggableSeedPhrase[7].word, doesMatch: false)
            self.word9Bucket = DraggableSeedWord(id: UUID(), tagNumber: draggableSeedPhrase[8].tagNumber, word: draggableSeedPhrase[8].word, doesMatch: false)
            self.word10Bucket = DraggableSeedWord(id: UUID(),tagNumber: draggableSeedPhrase[9].tagNumber, word: draggableSeedPhrase[9].word, doesMatch: false)
            self.word11Bucket = DraggableSeedWord(id: UUID(), tagNumber: draggableSeedPhrase[10].tagNumber, word: draggableSeedPhrase[10].word, doesMatch: false)
            self.word12Bucket = DraggableSeedWord(id: UUID(), tagNumber: draggableSeedPhrase[11].tagNumber, word: draggableSeedPhrase[11].word, doesMatch: false)
        }
    }

    var body: some View {
        GeometryReader { _ in
            ZStack {
                VStack {
//                    Grid(horizontalSpacing: elementSpacing, verticalSpacing: elementSpacing) {
//                        GridRow {
//                            WordBucketView(seedWord: $word1Bucket, wordNumber: 1)
//                                .dropDestination(for: DraggableSeedWord.self) { droppedSeedWords, _ in
//                                    if droppedSeedWords.first?.word == word1Bucket?.word,
//                                    let matchedWord = droppedSeedWords.first?.word {
//                                        word1Bucket = droppedSeedWords.first
//                                        word1Bucket?.word = matchedWord
//                                        word1Bucket?.doesMatch = true
//                                        return true
//                                    } else {
//                                        return false
//                                    }
//                                }
//                            WordBucketView(seedWord: $word2Bucket, wordNumber: 2)
//                                .dropDestination(for: DraggableSeedWord.self) { droppedSeedWords, _ in
//                                    if droppedSeedWords.first?.word == word1Bucket?.word {
//                                        word1Bucket = droppedSeedWords.first
//                                        return true
//                                    } else {
//                                        return false
//                                    }
//                                }
//                            WordBucketView(seedWord: $word3Bucket, wordNumber: 3)
//                                .dropDestination(for: DraggableSeedWord.self) { droppedSeedWords, _ in
//                                    if droppedSeedWords.first?.word == word1Bucket?.word {
//                                        word1Bucket = droppedSeedWords.first
//                                        return true
//                                    } else {
//                                        return false
//                                    }
//                                }
//                        }
//                        .frame(minHeight: fieldHeight)
//
//                        GridRow {
//                            WordBucketView(seedWord: $word4Bucket, wordNumber: 4)
//                                .dropDestination(for: DraggableSeedWord.self) { droppedSeedWords, _ in
//                                    if droppedSeedWords.first?.word == word1Bucket?.word {
//                                        word1Bucket = droppedSeedWords.first
//                                        return true
//                                    } else {
//                                        return false
//                                    }
//                                }
//                            WordBucketView(seedWord: $word5Bucket, wordNumber: 5)
//                            WordBucketView(seedWord: $word6Bucket, wordNumber: 6)
//                        }
//                        .frame(minHeight: fieldHeight)
//
//                        GridRow {
//                            WordBucketView(seedWord: $word7Bucket, wordNumber: 7)
//                            WordBucketView(seedWord: $word8Bucket, wordNumber: 8)
//                            WordBucketView(seedWord: $word9Bucket, wordNumber: 9)
//                        }
//                        .frame(minHeight: fieldHeight)
//                        GridRow {
//                            WordBucketView(seedWord: $word10Bucket, wordNumber: 10)
//                            WordBucketView(seedWord: $word11Bucket, wordNumber: 11)
//                            WordBucketView(seedWord: $word12Bucket, wordNumber: 12)
//                        }
//                        .frame(minHeight: fieldHeight)
//                        }
//                         .frame(height: fieldHeight * 4)
//                         .padding(8.0)
                }.onAppear {
                    loadWordBuckets()
                }
            }
        }
    }
}
