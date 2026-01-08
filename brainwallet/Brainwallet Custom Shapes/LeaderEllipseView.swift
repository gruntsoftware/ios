//
//  LeaderEllipseView.swift
//  brainwallet
//
//  Created by Kerry Washington on 09/01/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct LeaderEllipseView: View {

    @Binding
    var userPrefersDarkTheme: Bool

    let dotsize: CGFloat = 2
    let dotSpace: CGFloat = 5

    var body: some View {
        HStack {
            Color.clear
                .overlay(
                    GeometryReader { geometry in
                        Path { path in
                            let totalWidth = geometry.size.width
                            let totalSpacing = dotsize + dotSpace
                            let dotCount = Int(totalWidth / totalSpacing)

                            for index in 0..<dotCount {
                                let xCounter = CGFloat(index) * totalSpacing + dotsize / 2
                                let rect = CGRect(x: xCounter, y: (geometry.size.height / 2) - (dotsize / 2), width: dotsize, height: dotsize)
                                path.addEllipse(in: rect)
                            }
                        }
                        .fill(userPrefersDarkTheme ? .white.opacity(0.4) : .black.opacity(0.4))
                    }
                )
                .frame(minWidth: 10, idealWidth: .infinity, maxWidth: .infinity)
        }
    }
}
