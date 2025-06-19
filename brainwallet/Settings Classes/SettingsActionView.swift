//
//  SettingsActionView.swift
//  brainwallet
//
//  Created by Kerry Washington on 19/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SettingsActionView: View {

    private let title: String
    private let detailText: String
    let largeFont: Font = .barlowSemiBold(size: 19.0)
    let detailFont: Font = .barlowLight(size: 18.0)
    let action: SettingsAction
    @Binding
    var isSelected: Bool

    init(title: String, detailText: String, action: SettingsAction, isSelected: Binding<Bool>) {
        self.title = title
        self.detailText = detailText
        self.action = action
        _isSelected = isSelected
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
                                .padding(.leading, 16.0)
                            Text(detailText)
                                .font(detailFont)
                                .foregroundColor(BrainwalletColor.content)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding([.top, .bottom], 1.0)
                                .padding(.leading, 16.0)
                            Spacer()
                        }

                        Spacer()
                        VStack {
                            Button(action: { isSelected.toggle() }) {
                                VStack {
                                    Image(systemName: isSelected ? action.isOnSystemImage : action.isOffSystemImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30.0,
                                               height: 30.0)
                                        .foregroundColor(BrainwalletColor.content)
                                        .padding(20.0)
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
