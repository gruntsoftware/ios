//
//  HowToSetEmojisView.swift
//  brainwallet
//
//  Created by Kerry Washington on 7/19/26.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct HowToSetEmojisView: View {
    @Binding var selectedPage: Int
    
    private let rowTitles = ["Pick your first 3 emojis",
                             "Emojis that have meaning",
                             "Seed to your memory"]
    private let rowDescriptions = ["There are 12 seed words in your seed phrase. Use the first 3 words to choose.",
                                   "Use matches to the word like lemon. Or, yellow. Or, not. It's up to you!",
                                   "See the emoji, you'll remember the seed word. Memorize your emoji...get POINTS!"]
    private let rowIcons = ["face.smiling.inverse",
                            "checkmark.square",
                            "lock"]
    

    let backgroundGradient: LinearGradient
    
    init(backgroundGradient: LinearGradient,
         selectedPage: Binding<Int>) {
        self.backgroundGradient = backgroundGradient
        _selectedPage = selectedPage
    }

    
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            let rowRatio = height * 0.5 * 0.33
            
            VStack(alignment: .center) {
                    Text("Choose your 3 emojis for the game")
                        .modifier(BWIPSSemiBold(size: 22.0,
                                                lineLimit: 2))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding([.leading, .trailing], 40.0)
                        .padding(.top, 44.0)

                        .accessibilityIdentifier("howItWorksViewTitle")
                    
                    Text("Here is where you build your real brainwallet. Memorize your seed phrase")
                        .modifier(BWIPSRegular(size: 16, lineLimit: 3))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding([.leading, .trailing], 50.0)
                        .padding(.top, 20.0)
                        .padding(.bottom, 15.0)
                        .accessibilityIdentifier("howItWorksViewDescription")
                    LazyVStack {
                        Spacer(minLength: 10.0)
                        ForEach(0..<rowTitles.count, id: \.self) { index in
                            RowHowToSetEmoji(rowTitle: rowTitles[index],
                                             rowDescription: rowDescriptions[index],
                                             iconName: rowIcons[index],
                                             rowIndex: index + 1)
                            .frame(width: width, height: rowRatio)
                            if index <= (rowTitles.count - 1) {
                                Divider().padding([.leading, .trailing], 20.0)
                            }
                        }
                    }
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16.0)
                    .padding( [.leading,.trailing], 16.0)
 
                    Spacer()
                   
                    Button(action: {
                        selectedPage += 1
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white)
                            Text("Next")
                                .modifier(BWIPSSemiBold(size: 19.0))
                                .foregroundColor(BrainwalletColor.midnight)
                        }
                    }
                    .frame(width: width * 0.9, height: 50.0)
                    .cornerRadius(11.0)
                    .padding( .bottom, 16.0)

                }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(backgroundGradient)
    }
}
