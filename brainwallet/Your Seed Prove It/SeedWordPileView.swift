//
//  SeedWordPileView.swift
//  brainwallet
//
//  Created by Kerry Washington on 08/07/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SeedWordPileView: View {

    @ObservedObject
    var seedViewModel = SeedViewModel(enteredPIN: .constant(""))

    @State
    private var viewColumns = [GridItem]()

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

    @State
    private var shuffledSeedWords : [DraggableSeedWord] = []

    let elementSpacing = 8.0
    let fieldHeight: CGFloat = 40.0
    let arrowSize: CGFloat = 60.0
    let userPrefersDarkTheme = UserDefaults.userPreferredDarkTheme
    private let columns = Array(repeating: GridItem(.flexible(minimum: 80)), count: 3)
    init(viewModel: NewMainViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { _ in
            ZStack {
//                LazyVGrid(columns: columns) {
//                    ForEach(shuffledSeedWords, id: \.id) { draggableItem in
//                        SeedWordDragView(seedWord: draggableItem.word,
//                            wordNumber: draggableItem.tagNumber)
//                        .draggable(draggableItem, preview: {
//                            SeedWordDragView(seedWord: draggableItem.word,
//                                wordNumber: draggableItem.tagNumber)
//                                .frame(width: 100, height: 30)
//                                .contentShape(.dragPreview, Capsule())
//                                .padding(.bottom, 24.0)
//                        })
//                        .padding([.top, .bottom], 16.0)
//                        .padding([.leading, .trailing], 2.0)
//                        .opacity(draggableItem.doesMatch ? 0 : 1)
//                        .animation(.easeInOut(duration: 0.25), value: draggableItem.doesMatch)
//                    }
//                }
//                .onAppear {
//                    #if DEBUG
//                    shuffledSeedWords = mockDraggableArray.shuffled()
//                    #else
//                    shuffledSeedWords = self.viewModel.loadDraggableSeedWords().shuffled()
//                    #endif
//                }
            }
        }
    }
}
