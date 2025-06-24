//
//  SettingsRowExpandableView.swift
//  brainwallet
//
//  Created by Kerry Washington on 20/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct SettingsRowExpandableView: View {

    @Binding
    var expandedHeight: CGFloat

    @State
    private var shouldBeExpanded: Bool = false

    private let titleText: String
    private let detailText: String
    private var backgroundColor = BrainwalletColor.surface

    let titleFont: Font = .barlowSemiBold(size: 22.0)
    let detailFont: Font = .barlowLight(size: 14.0)
    let buttonSize = 22.0

    init(title: String, detail: String, expandedHeight: Binding<CGFloat>) {
        self.titleText = title
        self.detailText = detail
        _expandedHeight = expandedHeight
    }

    var body: some View {

        GeometryReader { _ in
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                            Text(titleText)
                                .font(titleFont)
                                .foregroundColor( BrainwalletColor.content)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    shouldBeExpanded.toggle()
                                    expandedHeight = (shouldBeExpanded ? 200 : 44.0)
                                }
                            }) {
                                Image(systemName:"chevron.right")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: buttonSize, height: buttonSize,
                                           alignment: .center)
                                    .foregroundColor(BrainwalletColor.content)
                                    .tint(BrainwalletColor.surface)
                                    .rotationEffect(shouldBeExpanded ? .degrees(90) : .degrees(0))
                            }
                            .frame(height: 44.0, alignment: .trailing)
                            .padding(.trailing, 16.0)

                    }
                    .padding(.trailing, 16.0)
                    Spacer()
                    Divider()
                }
                .frame(height: expandedHeight)
            }
        }
    }
}
