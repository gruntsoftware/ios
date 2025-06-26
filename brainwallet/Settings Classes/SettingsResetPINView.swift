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
    let dotSize: CGFloat = 12.0

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
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height

                ZStack {
                    VStack {
                        HStack {
                            Text(title)
                                .font(largeFont)
                                .foregroundColor(BrainwalletColor.content)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                        }
                        .frame(height: height * 0.1)
                        .padding(.top, 1.0)

                        HStack {
                            Text(detailText)
                                .font(detailFont)
                                .kerning(0.6)
                                .foregroundColor(BrainwalletColor.content)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 1.0)
                            Spacer()

                                HStack {
                                    Image(systemName: "circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: dotSize,
                                               height: dotSize)
                                        .foregroundColor(BrainwalletColor.content)

                                    Image(systemName: "circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: dotSize,
                                               height: dotSize)
                                        .foregroundColor(BrainwalletColor.content)

                                    Image(systemName: "circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: dotSize,
                                               height: dotSize)
                                        .foregroundColor(BrainwalletColor.content)

                                    Image(systemName: "circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: dotSize,
                                               height: dotSize)
                                        .foregroundColor(BrainwalletColor.content)

                                }
                                .frame(height: 25.0)

                        }
                        .frame(height: height * 0.2)

                        HStack {
                            Button(action: {
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                        .frame(width: width * 0.9, height: largeButtonHeight,
                                            alignment: .center)
                                        .frame(height: largeButtonHeight, alignment: .center)
                                        .foregroundColor(BrainwalletColor.background)

                                    Text("Change PIN")
                                        .frame(width: width * 0.9, height: largeButtonHeight,
                                            alignment: .center)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .font(largeFont)
                                        .foregroundColor(BrainwalletColor.content)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                                .stroke(BrainwalletColor.content, lineWidth: 1.0)
                                        )
                                }
                            }
                        }
                        .frame(height: height * 0.2)
                        .padding(.top, 16.0)
                        .padding(.bottom, 16.0)

                    }
                }
            }
        }
    }
}
