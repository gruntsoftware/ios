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
                    .padding(.top, 10.0)
                    .opacity(0.0)

                    Text("Your seed words")
                         .modifier(BWIPSSemiBold(size: 32.0))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: height * 0.05)
                        .foregroundColor(BrainwalletColor.content)
                        .padding(.top, 5.0)

                    Text("Just for you.\nIs it the private key that lets you send.")
                        .modifier(BWIPSLight(size: 18.0))
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
                        .modifier(BWIPSRegular(size: 20.0))
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
                                .modifier(BWIPSRegular(size: 20.0))
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                        .stroke(BrainwalletColor.grape, lineWidth: 2.0)
                                )
                        }
                        .padding(.all, 8.0)
                    }

                }
                .onChange(of: viewModel.isSeedPhraseFilled) { _,_ in
                    seedViewModel.loadSeedWords(seedPhrase: viewModel.seedPhrase)
                }
                .ignoresSafeArea(.keyboard)
            }
        }
    }
}
