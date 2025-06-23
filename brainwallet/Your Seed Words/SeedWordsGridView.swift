//
//  SeedWordsGridView.swift
//  brainwallet
//
//  Created by Kerry Washington on 26/04/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct SeedWordsGridView: View {

    @State private var seedWords: [String] = ["","","","","","","","","","","",""]

    private let isRestore: Bool
    let elementSpacing = 8.0
    let fieldHeight: CGFloat = 40.0

    init(isRestore: Bool) {
        self.isRestore = isRestore
    }

    var body: some View {
        GeometryReader { geometry in

            ZStack {
                VStack {

                        Grid(horizontalSpacing: elementSpacing, verticalSpacing: elementSpacing) {
                            GridRow {
                                SeedCapsuleView(index: 1, word: $seedWords[0])
                                SeedCapsuleView(index: 2, word: $seedWords[1])
                                SeedCapsuleView(index: 3, word: $seedWords[2])
                            }
                            .frame(minHeight: fieldHeight)

                            GridRow {
                                SeedCapsuleView(index: 4, word: $seedWords[3])
                                SeedCapsuleView(index: 5, word: $seedWords[4])
                                SeedCapsuleView(index: 6, word: $seedWords[5])
                            }
                            .frame(minHeight: fieldHeight)

                            GridRow {
                                SeedCapsuleView(index: 7, word: $seedWords[6])
                                SeedCapsuleView(index: 8, word: $seedWords[7])
                                SeedCapsuleView(index: 9, word: $seedWords[8])
                            }
                            .frame(minHeight: fieldHeight)
                            GridRow {
                                SeedCapsuleView(index: 10, word: $seedWords[9])
                                SeedCapsuleView(index: 11, word: $seedWords[10])
                                SeedCapsuleView(index: 12, word: $seedWords[11])
                            }
                            .frame(minHeight: fieldHeight)
                            HStack {
                                Button(action: {
                                    // path.append(.setPasscodeView(isRestore: isRestore))
                                }) {
                                    ZStack {
                                        GeometryReader { geometry in

                                            let width = geometry.size.width

                                            ZStack {
                                                Capsule()
                                                    .fill(BrainwalletColor.content.opacity(0.3))
                                                    .frame(height: fieldHeight)
                                                    .frame(width: width * 0.3)

                                                HStack {
                                                    Spacer()
                                                    Text("Clear")
                                                        .font(.footnote)
                                                        .fontWeight(.semibold)
                                                        .multilineTextAlignment(.center)
                                                        .foregroundColor(BrainwalletColor.content)
                                                    Spacer()
                                                }
                                                .frame(maxWidth: .infinity, alignment: .center)

                                            }
                                            .frame(minHeight:fieldHeight)
                                        }
                                    }
                                }
                            }
                        }
                }
                .frame(maxHeight: .infinity)
                .padding(5.0)
            }
        }
    }
}

struct SeedCapsuleView: View {
    let buttonSize = 70.0
    let detailFont: Font = .barlowRegular(size: 28.0)
    var index: Int
    let fieldHeight: CGFloat = 40.0

    @Binding var word: String

    init (index: Int, word: Binding<String>) {
        _word = word
        self.index = index
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width

            ZStack {
                Capsule()
                    .fill(BrainwalletColor.content.opacity(0.3))
                    .frame(height: fieldHeight)
                    .frame(width: width)

                HStack {
                    Text("\(index)")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(BrainwalletColor.content)
                        .padding(.leading, 8.0)
                        .frame(width: 24.0)
                    TextField("",text: $word) // DEV12345678
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(BrainwalletColor.content)
                        .frame(minHeight: fieldHeight)
                        .disableAutocorrection(true)
                 }

            }
            .frame(minHeight:fieldHeight)

        }
    }

}

struct SeedWordsGridView_Previews: PreviewProvider {
    static var previews: some View {
        SeedWordsGridView(isRestore: true)
    }
}

//        TextField("", text: .constant(""))
//            .opacity(0.0)
//            .frame(width: 0, height: 0)
//        Button {
//
//
//
//        } label: {
//            ZStack {
//                Capsule()
//                .frame(width: buttonSize)
//                .foregroundColor(BrainwalletColor.error.opacity(0.2))
//
//                    Text("\(index)")
//                        .font(detailFont)
//                        .foregroundColor(BrainwalletColor.content)
//                        .frame(maxWidth: .infinity,
//                               maxHeight: .infinity)
//                        .padding()
//
//            }
//        }
//        .padding(.all, 5.0)
//        .disabled(index == -1)
