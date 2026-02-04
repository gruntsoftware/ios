//
//  YourSeedProveItView.swift
//  brainwallet
//
//  Created by Kerry Washington on 20/04/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct YourSeedProveItView: View {
    @Binding var path: [Onboarding]
    @ObservedObject var viewModel: NewMainViewModel

    @State private var seedWords: [Int: [DraggableSeedWord]] = [:]
    @State private var shuffledDraggableWords: [DraggableSeedWord] = []
    @State private var targetedSlots: Set<Int> = []

    // Constants
    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let themeBorderSize: CGFloat = 44.0

    let detailFont: Font = .ibmPlexSansRegular(size: 22.0)
    let detailerFont: Font = .ibmPlexSansRegular(size: 20.0)
    let regularButtonFont: Font = .ibmPlexSansRegular(size: 20.0)
    let elementSpacing = 4.0
    let fieldHeight: CGFloat = 40.0
    let arrowSize: CGFloat = 60.0
    let userPrefersDarkTheme = UserDefaults.userPreferredDarkTheme
    let canUserBuy: Bool = UserDefaults.userCanBuyInCurrentLocale

    private let columns = Array(repeating: GridItem(.flexible(minimum: 80)), count: 3)

    init(viewModel: NewMainViewModel, path: Binding<[Onboarding]>) {
        self.viewModel = viewModel
        _path = path

        // Initialize seed words dictionary
        var initialSeedWords: [Int: [DraggableSeedWord]] = [:]
        for counter in 1...12 {
            initialSeedWords[counter] = [DraggableSeedWord(id: UUID(), tagNumber: counter, word: "", doesMatch: false)]
        }
        _seedWords = State(initialValue: initialSeedWords)
    }

    private func removeMatchedWord(draggable: DraggableSeedWord) {
        shuffledDraggableWords = shuffledDraggableWords.filter { $0.id != draggable.id }
    }

    private func resetWords() {
        shuffledDraggableWords = viewModel.draggableSeedPhrase.shuffled()
        for counter in 1...12 {
            seedWords[counter] = [DraggableSeedWord(id: UUID(), tagNumber: counter, word: "", doesMatch: false)]
        }
        targetedSlots.removeAll()
    }

    private func playAffirm() {
        SoundsHelper().play(filename: "clicksound", type: "mp3")
    }

    private func playError() {
        SoundsHelper().play(filename: "errorsound", type: "mp3")
    }

    private func playCoin() {
        SoundsHelper().play(filename: "coinflip", type: "mp3")
    }

    private func isPhraseMatched() -> Bool {
        return (1...12).allSatisfy { seedWords[$0]?.first?.word.isEmpty == false }
    }

    private func createWordBucket(for wordNumber: Int) -> some View {
        WordBucketView(seedWord: seedWords[wordNumber] ?? [], wordNumber: wordNumber)
            .overlay(
                Capsule()
                    .stroke(targetedSlots.contains(wordNumber) ? BrainwalletColor.affirm.opacity(0.9) : .clear, lineWidth: 2.0)
            )
            .dropDestination(for: DraggableSeedWord.self) { droppedSeedWords, _ in
                let droppedWord = droppedSeedWords.first
                if let matchedWord = droppedWord?.word,
                   matchedWord == viewModel.draggableSeedPhrase[wordNumber - 1].word {
                    seedWords[wordNumber] = droppedSeedWords
                    removeMatchedWord(draggable: seedWords[wordNumber]!.first!)
                    let impact = UIImpactFeedbackGenerator(style: .heavy)
                    impact.impactOccurred()
                    playAffirm()
                    return true
                } else {
                    playError()
                    return false
                }
            } isTargeted: { targeted in
                if targeted && !targetedSlots.contains(wordNumber) {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }

                if targeted {
                    targetedSlots.insert(wordNumber)
                } else {
                    targetedSlots.remove(wordNumber)
                }
            }
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)

                VStack {
                    // Back button
                    HStack {
                        Button(action: {
                            path.removeLast()
                        }) {
                            HStack {
                                Image(systemName: "arrow.backward")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: squareImageSize, height: squareImageSize)
                                    .foregroundColor(BrainwalletColor.content)
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: squareImageSize)
                    .padding([.leading, .trailing], 20.0)
                    .padding(.top, 10.0)

                    // Title
                    Text("You saved it, right?")
                         .modifier(BWIPSSemiBold(size: 32.0))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: height * 0.05)
                        .foregroundColor(BrainwalletColor.content)
                        .padding(.top, 5.0)

                    // Subtitle
                    Text("Place the words in the correct order!")
                        .modifier(BWIPSLight(size: 18.0))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 22.0)
                        .foregroundColor(BrainwalletColor.content)
                        .padding([.leading, .trailing], 20.0)
                        .padding([.top, .bottom], 6.0)

                    // Word buckets grid
                    Grid(horizontalSpacing: elementSpacing, verticalSpacing: elementSpacing) {
                        ForEach(0..<4) { wordRow in
                            GridRow {
                                ForEach(1...3, id: \.self) { column in
                                    let wordNumber = wordRow * 3 + column
                                    createWordBucket(for: wordNumber)
                                }
                            }
                            .frame(minHeight: fieldHeight)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: height * 0.25, alignment: .center)
                    .padding([.leading, .trailing], 20.0)
                    Spacer()
                    Text("Long press & drag a word into place")
                        .modifier(BWIPSLight(size: 18.0))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: height * 0.05)
                        .foregroundColor(BrainwalletColor.content)
                        .padding([.leading, .trailing], 20.0)
                    Spacer()
                    // Draggable words
                    LazyVGrid(columns: columns) {
                        ForEach(shuffledDraggableWords, id: \.id) { draggableItem in

                            Group {
                                SeedWordDragView(seedWord: [draggableItem])
                                    .draggable(draggableItem, preview: {
                                        SeedWordDragView(seedWord: [draggableItem])
                                            .frame(width: 110, height: 40)
                                            .contentShape(.dragPreview, Capsule())
                                            .padding(.bottom, 24.0)
                                    })
                                     .padding([.top, .bottom], 16.0)
                                    .padding([.leading, .trailing], 2.0)
                            }
                            .simultaneousGesture(
                                TapGesture().onEnded {
                                    let impact = UIImpactFeedbackGenerator(style: .heavy)
                                    impact.impactOccurred()
                                }
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 200, alignment: .center)
                    .padding([.leading, .trailing], 20.0)
                    Spacer()
                    Button(action: {
                        if isPhraseMatched() {
                            playCoin()

                            if let store = viewModel.store {
                                store.trigger(name: .didCreateOrRecoverWallet)
                                store.perform(action: SimpleReduxAlert.Show(.paperKeySet(callback: {})))
                                NotificationCenter.default.post(name: .didCompleteOnboardingNotification,
                                                                    object: nil,
                                                                    userInfo: nil)
                            }
                        } else {
                            resetWords()
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                .foregroundColor(BrainwalletColor.grape)
                            Text(isPhraseMatched() ? String(localized:"Game & Sync") : String(localized:"RESET / START OVER"))
                                .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                .font(regularButtonFont)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                        .stroke(BrainwalletColor.grape, lineWidth: 2.0)
                                )
                                .animation(.easeInOut(duration: 0.4), value: isPhraseMatched())
                        }
                    }
                    .padding(.all, 10.0)
                }
            }
            .onAppear {
                shuffledDraggableWords = viewModel.draggableSeedPhrase.shuffled()
            }
        }
    }
}
