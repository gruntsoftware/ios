//
//  ExportButtonView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/09/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
import BrainwalletiOSPrivateGeneralPurpose

struct ExportButtonView: View {
    let buttonHeight =  45.0
    @ObservedObject
    var viewModel: ExportButtonViewModel

    @State
    private var shouldShowProducts: Bool = false

    @Binding
    var userPrefersDarkTheme: Bool

    @State
    private var didBuy: Bool = false
    init(userPrefersDarkTheme: Binding<Bool>, viewModel: ExportButtonViewModel) {
        self.viewModel = viewModel
        _userPrefersDarkTheme = userPrefersDarkTheme
    }

    var body: some View {

        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                BentoBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme).edgesIgnoringSafeArea(.all)

                HStack {
                    Button(action: {
                        // viewModel.didTapExport?()
                        shouldShowProducts.toggle()
                    }) {
                        Text("Export Transaction Data")
                            .font(.system(size: 22, weight: .semibold, design: .default))
                            .lineLimit(1)
                            .minimumScaleFactor(0.3)// Shrinks to 30% of original
                            .foregroundColor(userPrefersDarkTheme ? .purple: .green)
                    }
                }
            }
        }
        .cornerRadius(bentoCornerRadius)
    }
}
