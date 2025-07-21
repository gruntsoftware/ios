//
//  ExportModalView.swift
//  brainwallet
//
//  Created by Kerry Washington on 20/07/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct ExportModalView: View {

    @ObservedObject
    var viewModel = ExportModalViewModel(transactions: [])

    @State private var renderedImage: Image?

    @State
    private var didExportCSV = false

    @State
    private var didExportCSVAndPDF = false

    @State
    private var isGeneratingFile = false

    var shouldDismiss: ((Bool) -> Void)?

    let userPrefersDarkTheme = UserDefaults.userPreferredDarkTheme
    let regularFont: Font = .barlowRegular(size: 24.0)
    let lightFont: Font = .barlowLight(size: 20.0)
    let headerFont: Font = .barlowSemiBold(size: 30.0)
    let buttonFont: Font = .barlowRegular(size: 22.0)
    let boldFont: Font = .barlowBold(size: 22.0)

    let largeButtonHeight: CGFloat = 65.0

    let activityHeight: CGFloat = 44.0

    init(transactions: [Transaction]) {
        self.viewModel.transactions = transactions
    }

   func loadImage() {
       renderedImage = viewModel.renderedImage()
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            let imageHeight = geometry.size.height * 0.3
            let imageWidth = geometry.size.width * 0.8

            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                VStack {

                    Text("Export Transaction Data")
                        .frame(width: width * 0.9, alignment: .center)
                        .font(headerFont)
                        .foregroundColor(BrainwalletColor.content)
                        .padding(.top, 25)
                        .accessibilityLabel(Text("Export Transaction Data"))

                    Text("You can export all of your transaction data to include amount per transaction, date, category & memo.")
                        .frame(width: width * 0.9, alignment: .center)
                        .font(buttonFont)
                        .foregroundColor(BrainwalletColor.content)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .padding(.top, 25)
                        .padding([.leading, .trailing], 16)
                        .accessibilityLabel(
                            Text("You can export all of your transaction data to include amount per transaction, date, category & memo.")
                        )

                    Text("Great for tracking your activity or preparing for tax season!")
                        .frame(width: width * 0.9, alignment: .center)
                        .font(buttonFont)
                        .foregroundColor(BrainwalletColor.content)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .padding(.top, 12)
                        .padding([.leading, .trailing], 16)
                        .accessibilityLabel(Text("Great for tracking your activity or preparing for tax season!"))

                    Text("The Brainwallet team does not store this data and has no visibility into it.")
                        .frame(width: width * 0.9, alignment: .center)
                        .font(lightFont)
                        .foregroundColor(BrainwalletColor.content)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .padding(.top, 12)
                        .padding([.leading, .trailing], 16)
                        .accessibilityLabel(Text("The Brainwallet team does not store this data and has no visibility into it."))

                    Text("We do store the status of your purchase")
                        .frame(width: width * 0.9, alignment: .center)
                        .font(lightFont)
                        .foregroundColor(BrainwalletColor.content)
                        .padding(.top, 12)
                        .padding([.leading, .trailing], 16)
                        .accessibilityLabel(Text("We do store the status of your purchase"))

                    Spacer()

                    renderedImage?
                        .resizable()
                        .frame(width: imageWidth, height: imageHeight)
                        .padding()

                    ActivityIndicator
                        .init(isAnimating: $isGeneratingFile, style: .large)
                        .frame(width: activityHeight, height: activityHeight)
                        .padding()
                        .opacity(isGeneratingFile ? 1 : 0)

                    Button(action: {
                        isGeneratingFile.toggle()
                        delay(2.0) {
                            viewModel.userDidTapExportCSV()
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                .foregroundColor(BrainwalletColor.surface)

                            Text("Export CSV File" + String(format: " (%.2f)", viewModel.exportCSVPrice))
                                .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                .font(boldFont)
                                .foregroundColor(BrainwalletColor.content)
                                .overlay(
                                    RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                        .stroke(BrainwalletColor.content, lineWidth: 1.0)
                                )
                        }
                        .padding(.all, 8.0)
                    }

                    Button(action: {
                        isGeneratingFile.toggle()
                        delay(2.0) {
                            viewModel.userDidTapExportCSVAndPDF()
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                .foregroundColor(BrainwalletColor.surface)

                            Text("Export & PDF CSV File" + String(format: " (%.2f)",
                                viewModel.exportCSVPDFPrice))
                                .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                .font(boldFont)
                                .foregroundColor(BrainwalletColor.content)
                                .overlay(
                                    RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                        .stroke(BrainwalletColor.content, lineWidth: 1.0)
                                )
                        }
                        .padding(.all, 8.0)
                    }

                }
                .alert(
                    String(localized: "CSV Created"),
                    isPresented: $didExportCSV,
                    actions: {
                        Button( String(localized: "Ok"),
                    role: .destructive) {}
                    }, message: {
                        Text("The CSV was copied to your clipboard.")
                })
                .alert(
                    String(localized: "CSV and PDF Created"),
                    isPresented: $didExportCSVAndPDF,
                    actions: {
                        Button( String(localized: "Ok"),
                    role: .destructive) {}
                    }, message: {
                        Text("The CSV and PDF zip file was copied to your clipboard.")
                })
            }
        }
    }
}
