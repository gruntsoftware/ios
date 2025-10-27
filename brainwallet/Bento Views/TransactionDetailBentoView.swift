//
//  TransactionDetailBentoView.swift
//  brainwallet
//
//  Created by Kerry Washington on 14/10/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct TransactionDetailBentoView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @Binding
    var cellViewModel: TransactionCellViewModel?

    @ObservedObject
    var exportViewModel = ExportButtonViewModel()

    @State
    var copiedData: String = ""

    @State
    var shouldShowSettings: Bool = false

    @Binding
    var userPrefersDarkTheme: Bool

    @State
    private var mainGradientStyle: MainGradientStyle = .lightStyle

    @State
    var filterMode: TransactionFilterState = .allTransactions

    private var modeState = TransactionFilterState.allCases

    private let buttonSize: CGFloat = 20.0

    private let buttonPlatformFactor: CGFloat = 2.1

    init(cellViewModel: Binding<TransactionCellViewModel?>?,
         viewModel: NewMainViewModel,
         userPrefersDarkTheme: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        self._cellViewModel = cellViewModel ?? Binding.constant(nil)
        newMainViewModel = viewModel
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            ZStack {
                BentoBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme)
                    .edgesIgnoringSafeArea(.all)

               VStack {

                            // MARK: Amount data

                            Group {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(cellViewModel?.feeText ?? "")
                                            .font(Font(UIFont.barlowRegular(size: 15.0)))
                                            .lineLimit(3)
                                            .scaledToFill()
                                            .foregroundColor(BrainwalletColor.content)
                                            .padding(.leading, 20.0)
                                            .padding(.top, 10.0)

                                        Spacer()
                                    }
                                    .padding(.top, 1.0)

                                    Text(cellViewModel?.addressText ?? "")
                                        .font(Font(UIFont.barlowRegular(size: 15.0)))
                                        .foregroundColor(BrainwalletColor.content)
                                        .padding(.leading, 20.0)

                                    Text(cellViewModel?.transaction.hash ?? "")
                                        .font(Font(UIFont.barlowLight(size: 9.0)))
                                        .foregroundColor(BrainwalletColor.content)
                                        .padding(.leading, 20.0)
                                        .padding(.trailing, 40.0)

                                    Text(String(localized: "Memo: ") + (cellViewModel?.memoString ?? ""))
                                        .font(Font(UIFont.barlowRegular(size: 15.0)))
                                        .foregroundColor(BrainwalletColor.content)
                                        .padding(.leading, 20.0)

                                }
                                .padding(.bottom, 2.0)

                            }

                            // MARK: Transaction data

                            Group {

                                VStack(alignment: .leading, spacing: 1.0) {

                                    Text( String(localized: "Blockheight: ") + (cellViewModel?.transaction.blockHeight ?? ""))
                                        .font(Font(UIFont.barlowRegular(size: 15.0)))
                                        .foregroundColor(BrainwalletColor.content)
                                        .padding(.leading, 20.0)

                                }
                                .frame(height: 44)

                            }

                            // MARK: QR Image
                            Group {
                                Spacer()

                                VStack(alignment: .center, spacing: 1.0) {
                                    Image(uiImage: cellViewModel?.qrImage ?? UIImage())
                                        .frame(width: kQRImageSide,
                                               height: kQRImageSide,
                                               alignment: .center)
                                        .padding(.all, 2.0)
                                        .tint(BrainwalletColor.content)

                                    Text(cellViewModel?.addressText ?? "")
                                        .font(Font(UIFont.barlowLight(size: 13.0)))
                                        .foregroundColor(BrainwalletColor.content)
                                        .frame(alignment: .center).padding(.all, 2.0)
                                }
                                .padding(.all, 8.0)

                                Spacer()
                            }

                            Spacer()
                        }
                VStack {
                    Spacer()
                    ExportButtonView(userPrefersDarkTheme: $userPrefersDarkTheme, viewModel: exportViewModel)
                        .frame(width: width * 0.3, height: 35)
                }

                }
                .cornerRadius(bentoCornerRadius)
                .onAppear {
                    mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
                }
        }
    }
}
