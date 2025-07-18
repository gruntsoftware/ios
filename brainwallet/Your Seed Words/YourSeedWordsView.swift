//
//  YourSeedWordsView.swift
//  brainwallet
//
//  Created by Kerry Washington on 20/04/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct YourSeedWordsView: View {

    @Binding var path: [Onboarding]

    @ObservedObject
    var viewModel: NewMainViewModel

    @ObservedObject
    var seedViewModel = SeedViewModel(enteredPIN: .constant(""))

    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let themeBorderSize: CGFloat = 44.0
    let largeButtonHeight: CGFloat = 65.0
    let largeButtonFont: Font = .barlowBold(size: 24.0)
    let subTitleFont: Font = .barlowSemiBold(size: 32.0)
    let detailFont: Font = .barlowRegular(size: 22.0)
    let detailerFont: Font = .barlowRegular(size: 20.0)
    let regularButtonFont: Font = .barlowRegular(size: 20.0)

    let arrowSize: CGFloat = 60.0
    let userPrefersDarkTheme = UserDefaults.userPreferredDarkTheme

    init(viewModel: NewMainViewModel, path: Binding<[Onboarding]>) {
        self.viewModel = viewModel
        _path = path
        self.viewModel.generateNewWallet()
    }

    var body: some View {

        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)

                VStack {
                    HStack {
                        Button(action: {
                        }) {
                            HStack {
                                Image(systemName: "arrow.backward")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: squareImageSize,
                                           height: squareImageSize,
                                           alignment: .center)
                                    .foregroundColor(BrainwalletColor.content)
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: squareImageSize)
                    .padding([.leading, .trailing], 20.0)
                    .padding(.bottom, 0.0)
                    .opacity(0.0)

                    Text("Your seed words")
                        .font(subTitleFont)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: height * 0.05)
                        .foregroundColor(BrainwalletColor.content)
                        .padding(.top, 5.0)

                    Text("Just for you.\nIs it the private key that lets you send.")
                        .font(detailFont)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: height * 0.1)
                        .foregroundColor(BrainwalletColor.content)
                        .padding([.leading, .trailing], 20.0)
                        .padding(.bottom, 20.0)

                    SeedWordsGridView(seedWords: $seedViewModel.seedWords)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: height * 0.3, alignment: .center)
                        .padding([.leading, .trailing], 20.0)

                    Spacer()

                    Text("Blockchain: Litecoin")
                        .font(detailerFont)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: height * 0.04, alignment: .center)
                        .foregroundColor(BrainwalletColor.content)
                        .padding(.all, 5.0)

                    Spacer()

                    Button(action: {
                        path.append(.yourSeedProveView)
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                .foregroundColor(BrainwalletColor.grape)

                            Text("I saved it on paper or metal")
                                .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                .font(regularButtonFont)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                        .stroke(BrainwalletColor.grape, lineWidth: 2.0)
                                )
                        }
                        .padding(.all, 8.0)
                    }

                }
                .onChange(of: viewModel.isSeedPhraseFilled) { _ in
                    seedViewModel.loadSeedWords(seedPhrase: viewModel.seedPhrase)
                }
                .ignoresSafeArea(.keyboard)
            }
        }
    }
}
