//
//  SettingsResetPINView.swift
//  brainwallet
//
//  Created by Kerry Washington on 24/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SettingsResetPINView: View {

    private let title: String
    private let detailText: String
    let largeFont: Font = .barlowSemiBold(size: 19.0)
    let detailFont: Font = .barlowLight(size: 15.0)
    let action: SettingsAction
    let largeButtonHeight: CGFloat = 45.0

    @Binding
    var isOn: Bool

    init(title: String, detailText: String, action: SettingsAction, isOn: Binding<Bool>) {
        self.title = title
        self.detailText = detailText
        self.action = action
        _isOn = isOn
    }

    var body: some View {
        NavigationStack {
            GeometryReader { _ in
                ZStack {
                    HStack {
                        Text(title)
                            .font(largeFont)
                            .foregroundColor(BrainwalletColor.content)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 4.0)
                        Spacer()
                    }
                    HStack {

                        Text(detailText)
                            .font(detailFont)
                            .kerning(0.6)
                            .foregroundColor(BrainwalletColor.content)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 1.0)
                        Spacer()
                        VStack {
                            StaticPasscodeView()
                            Spacer()
                        }
                    }
                    HStack {
                        Button(action: {
                                // path.append(.restoreView)
                                // path.append(.yourSeedWordsView)
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                    .frame(height: largeButtonHeight, alignment: .center)
                                    .foregroundColor(BrainwalletColor.surface)

                                Text("Change PIN")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .font(largeFont)
                                    .foregroundColor(BrainwalletColor.content)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                            .stroke(BrainwalletColor.content, lineWidth: 1.0)
                                    )
                            }
                            .padding(.all, 8.0)
                        }
                    }
                }
            }
        }
    }
}

// VStack {
//    Text(title)
//        .font(largeFont)
//        .foregroundColor(BrainwalletColor.content)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding(.bottom, 1.0)
//        .padding(.top, 8.0)
//
//    Text("\(pickedCurrency.fullCurrencyName) (\(pickedCurrency.symbol))")
//        .font(detailFont)
//        .kerning(0.6)
//        .foregroundColor(BrainwalletColor.content)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding(.bottom, 1.0)
// }
