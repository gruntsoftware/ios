//
//  InputWordsGridView.swift
//  brainwallet
//
//  Created by Kerry Washington on 26/04/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct InputWordsGridView: View {
    @ObservedObject var viewModel: NewMainViewModel
    @State
    private var filteredSeedWords: [String] = []
    @State
    private var words: [String] = Array(repeating: "", count: 12)
    @State
    private var wordSettingState: [Bool] = Array(repeating: false, count: 12)
    @State
    private var activeWordIndex = 0
    @Binding
    var phraseIsVerified: Bool

    let elementSpacing = 8.0
    let fieldHeight: CGFloat = 40.0
    let maxSearchWordCount = 12
    private let columns = Array(repeating: GridItem(.flexible(minimum: 70)), count: 3)
    let searchFont: Font = .barlowSemiBold(size: 20.0)

    private var bip39SeedWords: [String]? {
        guard let path = Bundle.main.path(forResource: "BIP39Words", ofType: "plist") else { return nil }
        return NSArray(contentsOfFile: path) as? [String]
    }

    init(viewModel: NewMainViewModel, phraseIsVerified: Binding<Bool>) {
        _phraseIsVerified = phraseIsVerified
        self.viewModel = viewModel
    }

    private func setSearchedWord(word: String) {
        words[activeWordIndex] = word.lowercased()
        wordSettingState[activeWordIndex] = true
        delay(0.1) {
            if wordSettingState.allSatisfy({$0}) &&
                 words.allSatisfy({$0.count > 2}) {
                 viewModel.restoredPhrase = words.map({$0}).joined(separator: " ")
                 phraseIsVerified = viewModel.verifySeedPhrase(phrase: viewModel.restoredPhrase)
            }
        }
    }

    private func searchingSeed(word: String) {
        filteredSeedWords = bip39SeedWords?.lazy
            .filter { $0.lowercased().starts(with: word.lowercased()) }
            .prefix(maxSearchWordCount)
            .map { $0 } ?? []
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                VStack {
                    Grid(horizontalSpacing: elementSpacing, verticalSpacing: elementSpacing) {
                        ForEach(0..<4) { gridRow in
                            GridRow {
                                ForEach(0..<3) { column in
                                    let index = gridRow * 3 + column
                                    InputSeedWordView(
                                        seedWord: Binding(
                                            get: { words[index] },
                                            set: { newValue in
                                                words[index] = newValue
                                                activeWordIndex = index
                                                searchingSeed(word: newValue)
                                            }
                                        ),
                                        wordIsSet: Binding(
                                            get: { wordSettingState[index] },
                                            set: { newValue in
                                                wordSettingState[index] = newValue
                                            }
                                        ),
                                        wordNumber: index + 1
                                    )
                                }
                            }
                            .frame(minHeight: fieldHeight)
                        }
                    }
                    .frame(height: fieldHeight * 4)
                    .padding(8.0)

                    ZStack {
                        Text("Tap a field above.\nEnter the a few letters.\nTap the word that matches")
                            .font(searchFont)
                            .lineLimit(3)
                            .multilineTextAlignment(.center)
                            .foregroundColor(BrainwalletColor.content.opacity(0.4))
                            .opacity(filteredSeedWords.isEmpty ? 1 : 0)

                        LazyVGrid(columns: columns) {
                            ForEach(filteredSeedWords, id: \.self) { word in
                                Button(action: {
                                    setSearchedWord(word: word)
                                }) {
                                    Text(word)
                                        .frame(width: 90.0, alignment: .center)
                                        .font(searchFont)
                                        .padding(3.0)
                                        .foregroundColor(BrainwalletColor.content)
                                        .background(BrainwalletColor.background)
                                        .cornerRadius(8.0)
                                        .shadow(radius: 2, x: 1, y: 1)
                                        .padding(2.0)
                                }
                                .frame(width: 75.0, alignment: .center)
                            }
                        }
                        .frame(width: width * 0.9, height: height * 0.45, alignment: .top)
                        .padding(.top, 16.0)
                        .opacity(filteredSeedWords.isEmpty ? 0 : 1)
                    }
                }
            }
        }
    }
}
