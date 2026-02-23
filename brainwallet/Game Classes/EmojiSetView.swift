//
//  EmojiSetView.swift
//  brainwallet
//
//  Created by Kerry Washington on 18/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
import FirebaseAnalytics

struct EmojiSetView: View {

    enum SetField {
       case firstField
       case secondField
       case thirdField
    }

    @EnvironmentObject
    var gameHubViewModel: GameHubViewModel

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @State
    private var firstEmojiString: String = ""

    @State
    private var secondEmojiString: String = ""

    @State
    private var thirdEmojiString: String = ""

    @State
    private var uniqueEmojisSelected = false

    @Binding
    var shouldShowView: Bool

    @Binding
    var userPrefersDarkTheme: Bool

    @FocusState
    private var focusedField: SetField?

    let darkModeColor = LinearGradient(colors: [.white,
                                                BentoColor.purple2],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
    let lightModeColor = LinearGradient(colors: [.white, BentoColor.purple1], startPoint: .topLeading,
                                        endPoint: .bottomTrailing)

    let backgroundColor = LinearGradient(colors: [.clear, BentoColor.purple4], startPoint: .topLeading,
                                        endPoint: .bottomTrailing)

    init(viewModel: NewMainViewModel,
         shouldShowView: Binding<Bool>,
         userPrefersDarkTheme: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        _shouldShowView = shouldShowView
        newMainViewModel = viewModel

    }

    private func areUniqueEmojisSelected() -> Bool {
        return firstEmojiString.isEmpty == false
            && secondEmojiString.isEmpty == false
            && thirdEmojiString.isEmpty == false
            && firstEmojiString != secondEmojiString
            && firstEmojiString != thirdEmojiString
            && secondEmojiString != thirdEmojiString
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height
            let boxHeight = width * 0.7 * 0.33
            let innerRadii = 12.0

            ZStack {
                VStack {
                    HStack {
                        VStack {
                            Text(gameHubViewModel.currentEmojiTriplet.guideTitle)
                                .modifier(BWIPSBold(size: 26.0))
                                .frame(alignment: .center)
                                .foregroundStyle( userPrefersDarkTheme ? .white : BentoColor.purple3)
                                .accessibilityIdentifier("emojiPickerViewTitle")
                            Text(gameHubViewModel.currentEmojiTriplet.guideDetail)
                                .modifier(BWIPSSemiBold(size: 20.0, lineLimit: 2))
                                .frame(alignment: .topLeading)
                                .foregroundStyle( userPrefersDarkTheme ? .white : BentoColor.purple3)
                                .accessibilityIdentifier("emojiPickerViewDescription")
                                .padding(.top, 8.0)
                                .padding([.leading, .trailing], 32.0)
                            Spacer()
                        }

                    }
                    .frame(height: height * 0.26, alignment: .center)
                    .padding([.leading, .trailing], 16.0)
                    .padding(.top, 8.0)

                    HStack {
                        EmojiTextField(text: $firstEmojiString, userPrefersDarkTheme: $userPrefersDarkTheme)
                            .onChange(of: firstEmojiString) { _,_ in

                                if !firstEmojiString.isEmpty {
                                    let firstCharIndex = firstEmojiString.index(firstEmojiString.startIndex, offsetBy: 1)
                                    let firstChar = String(firstEmojiString[..<firstCharIndex])
                                    firstEmojiString = firstChar
                                    focusedField = .secondField
                                }
                            }
                            .focused($focusedField, equals: .firstField)
                            .overlay(
                                RoundedRectangle(cornerRadius: innerRadii)
                                    .stroke(userPrefersDarkTheme ? .white.opacity(0.6) : BentoColor.purple3.opacity(0.6), lineWidth: 1)
                            )
                            .frame(width: boxHeight, height: boxHeight)
                        EmojiTextField(text: $secondEmojiString, userPrefersDarkTheme: $userPrefersDarkTheme)
                            .onChange(of: secondEmojiString) { _,_ in

                                if !secondEmojiString.isEmpty {
                                    let firstCharIndex = secondEmojiString.index(secondEmojiString.startIndex, offsetBy: 1)
                                    let firstChar = String(secondEmojiString[..<firstCharIndex])
                                    secondEmojiString = firstChar
                                    focusedField = .thirdField
                                }
                            }
                            .focused($focusedField, equals: .secondField)
                            .overlay(
                                RoundedRectangle(cornerRadius: innerRadii)
                                    .stroke(userPrefersDarkTheme ? .white.opacity(0.6) : BentoColor.purple3.opacity(0.6), lineWidth: 1)
                            )
                            .frame(width: boxHeight, height: boxHeight)
                        EmojiTextField(text: $thirdEmojiString, userPrefersDarkTheme: $userPrefersDarkTheme)
                            .onChange(of: thirdEmojiString) { _,_ in

                                if !thirdEmojiString.isEmpty {
                                    let firstCharIndex = thirdEmojiString.index(thirdEmojiString.startIndex, offsetBy: 1)
                                    let firstChar = String(thirdEmojiString[..<firstCharIndex])
                                    thirdEmojiString = firstChar
                                }
                            }
                            .focused($focusedField, equals: .thirdField)
                            .overlay(
                                RoundedRectangle(cornerRadius: innerRadii)
                                    .stroke(userPrefersDarkTheme ? .white.opacity(0.6) : BentoColor.purple3.opacity(0.6), lineWidth: 1)
                            )
                            .frame(width: boxHeight, height: boxHeight)

                    }
                    .frame(height: boxHeight * 1.3, alignment: .center)
                    .frame(width: width * 0.8, alignment: .center)
                    .background(backgroundColor.opacity(0.4))
                    .cornerRadius(20.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20.0)
                            .stroke(userPrefersDarkTheme ? .white.opacity(0.6) : BentoColor.purple3.opacity(0.6), lineWidth: 1)

                    )
                    .padding([.leading, .trailing], 16.0)
                    .padding(.top, 1.0)

                    Text(gameHubViewModel.currentEmojiTriplet.guideDetail2)
                        .modifier(BWIPSSemiBold(size: 20.0, lineLimit: 2))
                        .frame(alignment: .topLeading)
                        .foregroundStyle( userPrefersDarkTheme ? .white : BentoColor.purple3)
                        .accessibilityIdentifier("emojiPickerViewDescription2")
                        .padding(.top, 4.0)
                        .padding([.leading, .trailing], 32.0)

                    Text(String(localized:" Each emoji must be different."))
                        .modifier(BWIPSSemiBold(size: 18.0))
                        .frame(alignment: .topLeading)
                        .foregroundStyle( userPrefersDarkTheme ? .white : BentoColor.purple3)
                        .accessibilityIdentifier("emojiPickerViewDescription3")
                        .padding([.top, .bottom], 1.0)
                        .padding([.leading, .trailing], 16.0)
                        .opacity(uniqueEmojisSelected ? 0.0 : 1.0)

                    Button(action: {
                        if newMainViewModel.setEmojiTriplet() {
                            delay(0.4) {
                                shouldShowView.toggle()
                            }

                        }
                    }) {
                        Text("Ready, Set, Go!")
                            .modifier(BWIPSBold(size: 24.0))
                            .foregroundStyle( userPrefersDarkTheme ? .white : BentoColor.purple3)
                            .frame(width: width * 0.7, height: largeButtonHeight, alignment: .center)
                            .overlay(
                                RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                    .stroke(userPrefersDarkTheme ? .white.opacity(0.6) : BentoColor.purple3.opacity(0.6), lineWidth: 1)
                            )
                    }
                    .padding(.all, 8.0)
                    .disabled(!areUniqueEmojisSelected())
                    .accessibilityIdentifier("SetThreeEmojisView.ReadyToPlay")
                    .opacity(uniqueEmojisSelected ? 1.0 : 0.0)

                    Spacer()

                }
                .frame(width: width)
                .onChange(of: firstEmojiString) { _,_ in
                    uniqueEmojisSelected = areUniqueEmojisSelected()
                    newMainViewModel.tripletDictionary[1] = firstEmojiString
                }
                .onChange(of: secondEmojiString) { _,_ in
                    uniqueEmojisSelected = areUniqueEmojisSelected()
                    newMainViewModel.tripletDictionary[2] = secondEmojiString
                }
                .onChange(of: thirdEmojiString) { _,_ in
                    uniqueEmojisSelected = areUniqueEmojisSelected()
                    newMainViewModel.tripletDictionary[3] = thirdEmojiString
                }
                .onChange(of: newMainViewModel.didSelectTriplet) { _,_ in
                    shouldShowView = !newMainViewModel.didSelectTriplet
                }
                .onAppear {
                    delay(0.4) {
                        focusedField = .firstField
                    }
                        Analytics
                            .logEvent("user_was_shown_emoji_set_view",
                            parameters: nil)
                }
            }
        }
    }
}
