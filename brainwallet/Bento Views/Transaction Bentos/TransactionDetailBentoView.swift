////
////  TransactionDetailBentoView.swift
////  brainwallet
////
////  Created by Kerry Washington on 14/10/2025.
////  Copyright © 2025 Grunt Software, LTD. All rights reserved.

import SwiftUI
import BrainwalletiOSPrivateGeneralPurpose

struct TransactionDetailBentoView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @ObservedObject
    var exportViewModel = ExportViewModel()

    @State
    private var currentTransaction: Transaction?

    @State
    var copiedData: String = ""

    @State
    var shouldShowSettings: Bool = false

    @Binding
    var userPrefersDarkTheme: Bool

    @State
    private var mainGradientStyle: MainGradientStyle = .lightStyle

    @State
    private var isLTCValueShown: Bool = false

    @State
    private var shouldShowExportSheet: Bool = false

    @State
    private var maxDigits: Int = 0

    @State
    private var amountText: String = ""

    @State
    private var amountValue: Int = 0

    @State
    private var convertedAmountValue = 0.0

    @State
    private var feeText: String = ""

    @State
    private var feesValue: UInt64 = 0

    @State
    private var directionImageText: String = ""

    @State
    private var directionArrowColor: Color = .clear

    @State
    private var addressText: String = ""

    @State
    private var memoString: String = ""

    @State
    private var timeStamp: String = ""

    @State
    private var qrImage = UIImage()

    private var productsTitle = "Products"

    init(viewModel: NewMainViewModel,
         userPrefersDarkTheme: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        newMainViewModel = viewModel

        if let transactions = newMainViewModel.transactions {
            exportViewModel.transactions = transactions
        }

    }
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height
            let labelWidth = geometry.size.width * 0.20
            let rowPadding: CGFloat = 1
            let fontSize = 12.0
            let convertedFeesValue = Double((Double(currentTransaction?.fee ?? UInt64(0))) / 100_000_000)

            // Double(feesValue) / Double(C.litoshis)

            let didSend = (currentTransaction?.direction == .sent) ? true : false
            let transactionLTCAddress = currentTransaction?.toAddress ?? ""
            let txHash = currentTransaction?.hash
            let memoString = currentTransaction?.memoString
            let blockHeight: String = currentTransaction?.blockHeight ?? ""
            let timeStamp: String = currentTransaction?.longTimestamp ?? ""

            let qrImage: UIImage = {
                if let address = currentTransaction?.toAddress,
                   let data = address.data(using: .utf8),
                   let image = UIImage
                    .qrCode(data: data, color: .gray)?
                    .resize(CGSize(width: kQRImageSide,
                                   height: kQRImageSide)) {
                    return image
                }
                return UIImage()
            }()

            ZStack {
                BentoBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme)
                    .edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading) {
                    VStack {
                        HStack {
                            Text(String(localized:"Amount:"))
                                .font(.system(size: fontSize, weight: .regular, design: .default))
                                .frame(width: labelWidth, alignment: .leading)
                                .foregroundColor(userPrefersDarkTheme ? .white : .black)
                                .padding( .top, rowPadding)
                            Text("Ł \(convertedAmountValue)")
                                .font(.system(size: fontSize, weight: .regular, design: .default))
                                .minimumScaleFactor(0.8)// Shrinks to 80% of original
                                .frame(alignment: .leading)
                                .foregroundColor(userPrefersDarkTheme ? .white : .black)
                                .padding( .leading, rowPadding)
                            Spacer()
                            Image(systemName: directionImageText)
                                .resizable()
                                .frame(width: 15, height: 15)
                                .foregroundColor(directionArrowColor)
                        }
                        .padding(rowPadding)

                        if didSend {
                            HStack {
                                Text(String(localized:"Fees:"))
                                    .font(.system(size: fontSize, weight: .regular, design: .default))
                                    .frame(width: labelWidth, alignment: .leading)
                                    .foregroundColor(userPrefersDarkTheme ? .white : .black)

                                Text("Ł \(convertedFeesValue)")
                                    .font(.system(size: fontSize, weight: .regular, design: .default))
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)// Shrinks to 80% of original
                                    .frame(alignment: .leading)
                                    .foregroundColor(userPrefersDarkTheme ? .white : .black)
                                    .padding( .leading, rowPadding)
                                Spacer()
                            }
                            .padding(rowPadding)

                        }

                        HStack {
                            Text(String(localized:"TX ID:"))
                                .font(.system(size: fontSize, weight: .regular, design: .default))
                                .frame(width: labelWidth, alignment: .leading)
                                .foregroundColor(userPrefersDarkTheme ? .white : .black)

                            Text(txHash ?? "")
                                .font(.system(size: fontSize, weight: .regular, design: .default))
                                .lineLimit(3)
                                .minimumScaleFactor(0.8)// Shrinks to 80% of original
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(alignment: .leading)
                                .foregroundColor(userPrefersDarkTheme ? .white : .black)
                                .padding( .leading, rowPadding)
                            Spacer()

                        }
                        .padding(rowPadding)

                        if ((memoString?.isEmpty) == nil) {
                            HStack {
                                Text(String(localized: "Memo: "))
                                    .font(.system(size: fontSize, weight: .regular, design: .default))
                                    .frame(width: labelWidth, alignment: .leading)
                                    .foregroundColor(userPrefersDarkTheme ? .white : .black)
                                Text(memoString  ?? "")
                                    .font(.system(size: fontSize, weight: .regular, design: .default))
                                    .frame(alignment: .leading)
                                    .foregroundColor(userPrefersDarkTheme ? .white : .black)
                                Spacer()
                            }
                            .padding(rowPadding)

                        }

                        HStack {
                            Text(String(localized: "Block: "))
                                .frame(width: labelWidth, alignment: .leading)
                                .font(.system(size: fontSize, weight: .regular, design: .default))
                                .foregroundColor(userPrefersDarkTheme ? .white : .black)
                            Text(blockHeight)
                                .font(.system(size: fontSize, weight: .light, design: .default))
                                .frame(alignment: .leading)
                                .foregroundColor(userPrefersDarkTheme ? .white : .black)
                            Spacer()
                        }
                        .padding(rowPadding)

                        HStack {
                            Text(String(localized: "Date: "))
                                .frame(width: labelWidth, alignment: .leading)
                                .font(.system(size: fontSize, weight: .regular, design: .default))
                                .foregroundColor(userPrefersDarkTheme ? .white : .black)
                            Text(timeStamp)
                                .font(.system(size: fontSize, weight: .light, design: .default))
                                .frame(alignment: .leading)
                                .foregroundColor(userPrefersDarkTheme ? .white : .black)
                            Spacer()
                        }
                        .padding(rowPadding)
                    }
                    .padding(12)
                    .background(userPrefersDarkTheme ? .white.opacity(0.07) : BentoColor.grayBackground)
                    .cornerRadius(8)

                    HStack {
                        Spacer()
                        Image(uiImage: qrImage)
                            .frame(width: kQRImageSide,
                                   height: kQRImageSide,
                                   alignment: .center)
                            .tint(BrainwalletColor.content)
                        Spacer()
                    }
                    .padding(5.0)

                    HStack {
                        Spacer()
                        Text(transactionLTCAddress)
                            .font(.system(size: 16, weight: .semibold, design: .default))
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                            .foregroundColor(userPrefersDarkTheme ? .white : .black)
                            .truncationMode(.middle)
                            .frame(width: width * 0.8, alignment: .center)
                        Spacer()
                    }

                   Spacer()

                    HStack {
                        Spacer()
                        Button(action: {
                                shouldShowExportSheet.toggle()
                        }) {
                           ZStack {
                               BentoBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme)
                                   .frame(height: 48)

                               Text("Export Transaction Data")
                                   .font(.system(size: 19, weight: .regular, design: .default))
                                   .lineLimit(1)
                                   .minimumScaleFactor(0.1)
                                   .frame(maxWidth: width * 0.5, alignment: .center)
                                   .foregroundStyle( userPrefersDarkTheme ? .white: BrainwalletColor.nearBlack.opacity(0.8))
                           }
                        }
                        .disabled(exportViewModel.transactions.isEmpty)
                        .accessibilityIdentifier("showExportSheetButton")

                        Spacer()
                    }
                   .frame(height: 48)
                }
                .padding(16)
            }
            .cornerRadius(bentoCornerRadius)
            .onChange(of: newMainViewModel.currentTransactionUUID) { oldValue,newValue in
                debugPrint(":::: oldValue \(oldValue)")
                debugPrint(":::: newValue \(newValue)")

                guard let transaction = newMainViewModel.currentTransaction,
                      let rate = newMainViewModel.exchangeRate else { return }
                currentTransaction = transaction

                amountText = transaction.descriptionString(isLTCValueShown: isLTCValueShown, rate: rate, maxDigits: maxDigits).string
                feeText = transaction.amountDetails(isLTCValueShown: isLTCValueShown, rate: rate, rates: [rate], maxDigits: maxDigits)
                amountValue = transaction.litoshis
                convertedAmountValue = Double(amountValue) / Double(C.litoshis)
                feesValue = transaction.fee

                debugPrint(":::: amountText \(amountText)")
                debugPrint(":::: feeText \(feeText)")
                debugPrint(":::: amountValue \(amountValue)")
                debugPrint(":::: convertedAmountValue \(convertedAmountValue)")
                debugPrint(":::: feesValue \(feesValue)")

                if transaction.direction == .sent {
                    directionImageText = "arrowtriangle.up.circle.fill"
                    directionArrowColor = BrainwalletColor.warn
                } else if transaction.direction == .received {
                    directionImageText = "arrowtriangle.down.circle.fill"
                    directionArrowColor =  BrainwalletColor.affirm
                }
            }
            .sheet(isPresented: $shouldShowExportSheet) {
                WalletProductsModalView(title: .constant(productsTitle), data: exportViewModel.transactionData)
              .background(BrainwalletColor.surface)
              .cornerRadius(bentoCornerRadius)
              .presentationDragIndicator(.hidden)
              .presentationDetents([.height(height * 0.5)])
              .presentationBackground(.ultraThickMaterial)
              .ignoresSafeArea(edges: .bottom)
            }
            .onAppear {
                mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
                guard let transaction = newMainViewModel.currentTransaction else { return }
                currentTransaction = transaction
            }
        }
    }
}
