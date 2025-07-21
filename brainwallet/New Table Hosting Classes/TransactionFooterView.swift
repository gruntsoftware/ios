//
//  TransactionFooterView.swift
//  brainwallet
//
//  Created by Kerry Washington on 20/07/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct TransactionFooterView: View {

//    @Binding
//    var useDoesWantToExport: Bool
//    @Binding
//    var transactions: Int
    private let progressViewHeight: CGFloat = 55.0
    private let progressBarHeight: CGFloat = 14.0
    private let progressIconSize: CGFloat = 16.0

//    func useDoesWantToExport(userPrefersDarkMode: Bool) {
//        useDoesWantToExport?(userPrefersDarkMode)
//    }
//
//    func updateTransactionCount() {
//        useDoesWantToExport?(userPrefersDarkMode)
//    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width

            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
//                        ProgressView(value: viewModel.progress)
//                            .progressViewStyle(.linear)
//                            .accentColor(BrainwalletColor.grape)
//                            .frame(height: progressBarHeight)
//                            .padding([.leading,.trailing], 8.0)
                    }
                    .frame(height: progressBarHeight)
                    HStack {
                        VStack {
//                            Text(String(localized:"Timestamp: ") + viewModel.formattedTimestamp)
//                                .font(.caption)
//                                .frame(width: 230.0, alignment: .leading)
//                                .foregroundColor(BrainwalletColor.content)
//                            Text(String(localized:"Block: ") + viewModel.blockHeightString)
//                                .font(.caption)
//                                .frame(width: 230.0, alignment: .leading)
//                                .foregroundColor(BrainwalletColor.content)
                            Spacer()
                        }
                        .padding(.leading, 8.0)

                        Spacer()
                        VStack {
                            HStack {
                                Text("SEND")
                                    .font(.caption)
                                    .frame(width: 70.0, alignment: .trailing)
                                    .foregroundColor(BrainwalletColor.content)
                                Image(systemName: "nosign")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: progressIconSize,
                                           height: progressIconSize,
                                           alignment: .trailing)
                                    .foregroundColor(BrainwalletColor.error)
                            }
                            HStack {
                                Text("RECEIVE")
                                    .font(.caption)
                                    .frame(width: 70.0, alignment: .trailing)
                                    .foregroundColor(BrainwalletColor.content)

                                Image(systemName: "square.and.arrow.down")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: progressIconSize,
                                           height: progressIconSize,
                                           alignment: .trailing)
                                    .foregroundColor(BrainwalletColor.affirm)
                            }
                            Spacer()
                        }
                        .padding(.trailing, 8.0)
                    }
                    Divider()
                        .frame(height: 2.0)
                        .background(BrainwalletColor.midnight.opacity(0.8))
                }
                .frame(width: width, height: progressViewHeight)
            }
        }
    }
}
