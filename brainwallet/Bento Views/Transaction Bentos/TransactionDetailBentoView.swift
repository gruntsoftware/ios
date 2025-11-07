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
            let labelWidth = geometry.size.width * 0.20
            let valueWidth = geometry.size.width * 0.7
            let rowPadding: CGFloat = 2
            let feeInt = Int(cellViewModel?.feesValue ?? 0)
            let amountInt = Int(cellViewModel?.amountValue ?? 0)
            let convertedAmountValue = Double(amountInt) / Double(C.litoshis)
            let convertedFeesValue = Double(feeInt) / Double(C.litoshis)
            let didSend: Bool = cellViewModel?.transaction.direction == .sent
            let rawAddress: String = (cellViewModel?.addressText ?? "").components(separatedBy: " ").last ?? " "

            ZStack {
                BentoBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme)
                    .edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading) {
                    VStack {
                        HStack {
                            Text(String(localized:"Amount:"))
                                .font(.system(size: 12, weight: .regular, design: .default))
                                .frame(width: labelWidth, alignment: .leading)
                                .foregroundColor(userPrefersDarkTheme ? .white : .black)
                                .padding( .top, rowPadding)
                            Text("Ł \(convertedAmountValue)")
                                .font(.system(size: 12, weight: .regular, design: .default))
                                .minimumScaleFactor(0.8)// Shrinks to 80% of original
                                .frame(alignment: .leading)
                                .foregroundColor(userPrefersDarkTheme ? .white : .black)
                                .padding( .leading, rowPadding)
                            Spacer()
                        }
                        .padding(.top, 1)

                        if didSend {
                            HStack {
                                Text(String(localized:"Fees:"))
                                    .font(.system(size: 12, weight: .regular, design: .default))
                                    .frame(width: labelWidth, alignment: .leading)
                                    .foregroundColor(userPrefersDarkTheme ? .white : .black)

                                Text("Ł \(convertedFeesValue)")
                                    .font(.system(size: 12, weight: .regular, design: .default))
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)// Shrinks to 80% of original
                                    .frame(alignment: .leading)
                                    .foregroundColor(userPrefersDarkTheme ? .white : .black)
                                    .padding( .leading, rowPadding)
                                Spacer()
                            }
                        }

                        HStack {
                            Text(String(localized:"TX ID:"))
                                .font(.system(size: 12, weight: .regular, design: .default))
                                .frame(width: labelWidth, alignment: .leading)
                                .foregroundColor(userPrefersDarkTheme ? .white : .black)

                            Text(cellViewModel?.transaction.hash ?? "")
                                .font(.system(size: 12, weight: .regular, design: .default))
                                .lineLimit(3)
                                .minimumScaleFactor(0.8)// Shrinks to 80% of original
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(alignment: .leading)
                                .foregroundColor(userPrefersDarkTheme ? .white : .black)
                                .padding( .leading, rowPadding)
                            Spacer()

                        }

                        if ((cellViewModel?.memoString.isEmpty) == nil) {
                            HStack {
                                Text(String(localized: "Memo: "))
                                    .font(.system(size: 12, weight: .regular, design: .default))
                                    .frame(width: labelWidth, alignment: .leading)
                                    .foregroundColor(userPrefersDarkTheme ? .white : .black)
                                Text(cellViewModel?.memoString  ?? "")
                                    .font(.system(size: 12, weight: .regular, design: .default))
                                    .frame(alignment: .leading)
                                    .foregroundColor(userPrefersDarkTheme ? .white : .black)
                                Spacer()
                            }
                            .padding(.top, 1)
                        }
                        HStack {
                            Text(String(localized: "Block: "))
                                .frame(width: labelWidth, alignment: .leading)
                                .font(.system(size: 12, weight: .regular, design: .default))
                                .foregroundColor(userPrefersDarkTheme ? .white : .black)
                            Text(cellViewModel?.transaction.blockHeight ?? "")
                                .font(.system(size: 11, weight: .light, design: .default))
                                .frame(alignment: .leading)
                                .foregroundColor(userPrefersDarkTheme ? .white : .black)
                            Spacer()
                        }
                        .padding(.top, 1)
                    }
                    .padding(12)
                    .background(userPrefersDarkTheme ? .white.opacity(0.07) : BentoColor.grayBackground)
                    .cornerRadius(8)

                    HStack {
                        Spacer()
                        Image(uiImage: cellViewModel?.qrImage ?? UIImage())
                            .frame(width: kQRImageSide,
                                   height: kQRImageSide,
                                   alignment: .center)
                            .tint(BrainwalletColor.content)
                        Spacer()
                    }
                    .padding(.top, 1)

                    HStack {
                        Spacer()
                        Text(rawAddress)
                            .font(.system(size: 13, weight: .semibold, design: .default))
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(userPrefersDarkTheme ? .white : .black)
                            .truncationMode(.middle)
                            .frame(width: width * 0.5, alignment: .center)
                        Spacer()
                    }

                   Spacer()
                   ExportButtonView(userPrefersDarkTheme: $userPrefersDarkTheme,
                                       viewModel: exportViewModel)
                   .frame(height: 48)
                }
                .padding(16)
            }
            .cornerRadius(bentoCornerRadius)
            .onAppear {
                mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
            }
        }
    }
}
