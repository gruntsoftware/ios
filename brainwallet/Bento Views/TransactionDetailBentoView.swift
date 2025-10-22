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
    var cellViewModel: TransactionCellViewModel

    @ObservedObject
    var exportViewModel = ExportButtonViewModel()

    @State
    var copiedData: String = ""

    @State
    var shouldShowExportProducts: Bool = false

    @Binding
    var userPrefersDarkTheme: Bool

    @State
    private var mainGradientStyle: MainGradientStyle = .lightStyle

    @State
    var filterMode: TransactionFilterState = .allTransactions

    private var modeState = TransactionFilterState.allCases

    private let buttonSize: CGFloat = 20.0

    private let buttonPlatformFactor: CGFloat = 2.1

    init(cellViewModel: Binding<TransactionCellViewModel>,
         viewModel: NewMainViewModel,
         userPrefersDarkTheme: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        _cellViewModel = cellViewModel
        newMainViewModel = viewModel
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                BentoBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {

                                Text(String(localized: "Amount detail: "))
                                    .font(.system(size: 13, weight: .semibold, design: .default))
                                    .foregroundStyle( userPrefersDarkTheme ? .white.opacity(0.8): BrainwalletColor.nearBlack.opacity(0.8))
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                    .padding(.leading, 20.0)
                                Text(String(cellViewModel.feeText))
                                    .font(.system(size: 12, weight: .light, design: .default))
                                    .lineLimit(4)
                                    .minimumScaleFactor(0.8)
                                    .foregroundStyle( userPrefersDarkTheme ? .white.opacity(0.8): BrainwalletColor.nearBlack.opacity(0.8))
                                    .padding(.trailing, 20.0)

                            }
                            .padding(.top, 1.0)
                            HStack {
                                Text(String(localized: "Address: "))
                                    .font(.system(size: 13, weight: .semibold, design: .default))
                                    .foregroundStyle( userPrefersDarkTheme ? .white.opacity(0.8): BrainwalletColor.nearBlack.opacity(0.8))
                                    .padding(.leading, 20.0)
                                Text(cellViewModel.addressText)
                                    .font(.system(size: 12, weight: .light, design: .default))
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
                                    .foregroundStyle( userPrefersDarkTheme ? .white.opacity(0.8): BrainwalletColor.nearBlack.opacity(0.8))
                                    .padding(.trailing, 20.0)

                            }
                            .padding(.top, 1.0)
                            HStack {
                                Text(String(localized: "Transaction Hash: "))
                                    .font(.system(size: 13, weight: .semibold, design: .default))
                                    .foregroundStyle( userPrefersDarkTheme ? .white.opacity(0.8): BrainwalletColor.nearBlack.opacity(0.8))
                                    .padding(.leading, 20.0)
                                Text(cellViewModel.transaction.hash)
                                    .font(.system(size: 12, weight: .light, design: .default))
                                    .lineLimit(3)
                                    .minimumScaleFactor(0.8)
                                    .foregroundStyle( userPrefersDarkTheme ? .white.opacity(0.8): BrainwalletColor.nearBlack.opacity(0.8))
                                    .padding(.trailing, 20.0)

                            }
                            .padding(.top, 1.0)
                            HStack {
                                Text(String(localized: "Blockheight: "))
                                    .font(.system(size: 13, weight: .semibold, design: .default))
                                    .foregroundStyle( userPrefersDarkTheme ? .white.opacity(0.8): BrainwalletColor.nearBlack.opacity(0.8))
                                    .padding(.leading, 20.0)
                                Text(cellViewModel.transaction.blockHeight)
                                    .font(.system(size: 12, weight: .light, design: .default))
                                    .foregroundStyle( userPrefersDarkTheme ? .white.opacity(0.8): BrainwalletColor.nearBlack.opacity(0.8))
                                    .frame(alignment: .trailing)
                                    .padding(.trailing, 20.0)

                            }
                            .padding(.top, 1.0)

                            HStack {
                                Text(String(localized: "Memo: "))
                                    .font(.system(size: 13, weight: .semibold, design: .default))
                                    .minimumScaleFactor(0.8)// Shrinks to 30% of original
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle( userPrefersDarkTheme ? .white.opacity(0.8): BrainwalletColor.nearBlack.opacity(0.8))
                                    .padding(.leading, 20.0)

                                Spacer()
                            }
                            .padding(.top, 1.0)
                            HStack {
                                Text(cellViewModel.memoString)
                                    .font(.system(size: 12, weight: .light, design: .default))
                                    .lineLimit(4)
                                    .minimumScaleFactor(0.8)// Shrinks to 30% of original
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle( userPrefersDarkTheme ? .white.opacity(0.8): BrainwalletColor.nearBlack.opacity(0.8))
                                    .padding(.trailing, 20.0)

                                Spacer()
                            }
                            .padding(.top, 1.0)

                            // MARK: QR Image
                            HStack {
                                Spacer()
                                Image(uiImage: cellViewModel.qrImage)
                                    .resizable()
                                    .frame(width: kQRImageSide,
                                       height: kQRImageSide,
                                       alignment: .center)
                                .padding(.all, 2.0)
                                .tint(BrainwalletColor.content)
                                Spacer()
                            }

                            }

                    }
                    .frame(width: width, height: height * 0.85)
                    HStack {

                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                shouldShowExportProducts.toggle()
                            }
                        }, label: {
                            ZStack {
                                BentoBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme)
                                    .cornerRadius(bentoCornerRadius)
                                    .modifier(BentoShadow(userPrefersDarkTheme: $userPrefersDarkTheme))

                                VStack {
                                    Text("Export Transaction Data")
                                        .font(.system(size: 20, weight: .bold, design: .default))
                                        .foregroundStyle( userPrefersDarkTheme ? .white.opacity(0.8): BrainwalletColor.nearBlack.opacity(0.8))
                                }
                            }
                        })
                        .frame(width: width * 0.8, height: 44)
                        .padding(20.0)
                    }
                    .frame(width: width, height: height * 0.15)
                }
            }
            .cornerRadius(bentoCornerRadius)
            .onAppear {
                mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
            }
        }
    }
}
