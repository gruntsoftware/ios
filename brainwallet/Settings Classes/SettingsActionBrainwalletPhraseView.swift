//
//  SettingsActionBrainwalletPhraseView.swift
//  brainwallet
//
//  Created by Kerry Washington on 19/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SettingsActionBrainwalletPhraseView: View {

    private let title: String
    private let detailText: String
    let emojiFont: Font = .barlowBold(size: 34.0)
    let largeFont: Font = .barlowSemiBold(size: 19.0)
    let detailFont: Font = .barlowLight(size: 18.0)
    let randoMojis: [String] = ["😄", "🚨", "🚫", "😂", "🤣", "💕", "😅", "🦺", "😂", "✅"]

    @Binding
    var willShowBrainwalletPhrase: Bool

    @State
    private var  fetchedEmoji = ""

    init(title: String, detailText: String, willShowBrainwalletPhrase: Binding<Bool>) {
        self.title = title
        self.detailText = detailText
        _willShowBrainwalletPhrase = willShowBrainwalletPhrase
    }

    func createRandomEmoji() -> String {
        let randomIndex = Int.random(in: 0..<randoMojis.count)
        return randoMojis[randomIndex]
    }

    var body: some View {
        NavigationStack {
            GeometryReader { _ in
                ZStack {
                    HStack {
                        VStack {
                            Text(title)
                                .font(largeFont)
                                .foregroundColor(BrainwalletColor.content)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 4.0)
                            Text(detailText)
                                .font(detailFont)
                                .foregroundColor(BrainwalletColor.content)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding([.top, .bottom], 1.0)
                            Spacer()
                        }

                        Spacer()
                        VStack {
                            Button(action: {
                                willShowBrainwalletPhrase.toggle()
                            }) {
                                VStack {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8.0)
                                            .foregroundColor(.white.opacity(0.1))
                                            .frame(width: 44.0,
                                                   height: 44.0)
                                            .background(.thinMaterial,
                                                in: RoundedRectangle(cornerRadius: 8.0))
                                                .shadow(radius: 1.0, x: 2.0, y: 2.0)
                                        Text(createRandomEmoji())
                                            .font(emojiFont)
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(BrainwalletColor.content)
                                            .frame(width: 30.0,
                                                   height: 30.0)
                                    }
                                    Spacer()
                                }
                            }
                            .frame(width: 30.0, height: 30.0)
                        }
                    }
                }
            }
        }
    }
}
