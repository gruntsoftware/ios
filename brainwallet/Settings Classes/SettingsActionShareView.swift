//
//  SettingsActionShareView.swift
//  brainwallet
//
//  Created by Kerry Washington on 19/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SettingsActionShareView: View {

    private let title: String
    private let detailText: String
    let largeFont: Font = .barlowSemiBold(size: 19.0)
    let detailFont: Font = .barlowLight(size: 18.0)
    let action: SettingsAction

    @Binding
    var willShareData: Bool

    init(title: String, detailText: String, action: SettingsAction, willShareData: Binding<Bool>) {
        self.title = title
        self.detailText = detailText
        self.action = action
        _willShareData = willShareData
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
                                willShareData.toggle()
                            }) {
                                VStack {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8.0)
                                            .foregroundColor(.white)
                                            .frame(width: 44.0,
                                                   height: 44.0)
                                            .background(.thinMaterial,
                                                in: RoundedRectangle(cornerRadius: 8.0))
                                                .shadow(radius: 1.0, x: 2.0, y: 2.0)

                                        Image(systemName: willShareData ? action.isOnSystemImage : action.isOffSystemImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 30.0,
                                                   height: 30.0)
                                            .foregroundColor(BrainwalletColor.content)
                                            .shadow(radius: 1.0, x: 2.0, y: 2.0)
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
