//
//  ExportButtonView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/09/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
import BrainwalletiOSGames

struct ExportButtonView: View {
    let buttonHeight =  45.0
    @ObservedObject
    var viewModel: ExportButtonViewModel

    @State
    private var shouldExpand: Bool = false

    @State
    private var didBuy: Bool = false
    init(viewModel: ExportButtonViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {

        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            VStack {

                if shouldExpand {
                    Divider()
                        .frame(height: 2.0)
                        .background(BrainwalletColor.content)
                    WalletProductsModalView(data: viewModel.transactions)
                    /// data: [[String : Any]]
                }
                Spacer()

                HStack {
                    Spacer()

                    Button(action: {
                        viewModel.didTapExport?()
                        shouldExpand.toggle()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: buttonHeight/2)
                                .frame(width: width * 0.55, height: buttonHeight, alignment: .center)
                                .foregroundColor(BrainwalletColor.surface)
                                .shadow(color: BrainwalletColor.nearBlack.opacity(0.35),
                                        radius: 3.0, x: 4.0, y: 4.0)
                            Text("Export Transaction Data")
                                .frame(width: width * 0.55, height: buttonHeight, alignment: .center)
                                .font(Font(UIFont.barlowRegular(size: 15.0)))
                                .foregroundColor(BrainwalletColor.content)
                                .overlay(
                                    RoundedRectangle(cornerRadius: buttonHeight/2)
                                        .stroke(BrainwalletColor.content, lineWidth: 2.0)
                                )
                        }
                    }

                    Spacer()
                }
                .padding(.bottom, 5.0)

            }
        }
    }
}
