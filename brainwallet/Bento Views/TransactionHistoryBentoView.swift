//
//  TransactionHistoryBentoView.swift
//  brainwallet
//
//  Created by Kerry Washington on 07/10/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct TransactionHistoryBentoView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @State
    var shouldShowSettings: Bool = false

    @State
    var filterMode: TransactionFilterState = .allTransactions

    private var modeState = TransactionFilterState.allCases

    private let buttonSize: CGFloat = 20.0

    private let buttonPlatformFactor: CGFloat = 2.1

    init(viewModel: NewMainViewModel) {
        newMainViewModel = viewModel
    }
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            ZStack {
                BrainwalletColor.gray.edgesIgnoringSafeArea(.all)
                Text("Transaction History View")
                    .font(.system(size: 16, weight: .ultraLight, design: .default))
            }
            .cornerRadius(bentoCornerRadius)
            .frame(height: transactionsBentoHeight, alignment: .center)
        }
    }
}
