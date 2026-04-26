//
//  ShopBentoView.swift
//  brainwallet
//
//  Created by Kerry Washington on 07/10/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct ShopBentoView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @State
    var shouldShowSettings: Bool = false

    @Binding
    var userPrefersDarkTheme: Bool

    @State
    private var mainGradientStyle: MainGradientStyle = .lightStyle

    private let buttonPlatformFactor: CGFloat = 2.1

    private let tagLabelWidth: CGFloat = 80.0

    init(viewModel: NewMainViewModel, userPrefersDarkTheme: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        newMainViewModel = viewModel
    }
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
 
            ZStack {
                ShopBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme,
                                     imageName: "shop_background_01").edgesIgnoringSafeArea(.all)
                HStack {
                    VStack(alignment: .leading) {
                        Text("Buy Gift Cards with LTC!")
                            .modifier(BWIPSSemiBold(size: 13.0, lineLimit: 3))
                            .padding(10)
                            .padding(.top, 2)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle( userPrefersDarkTheme ? .white : .black)
                            .accessibilityIdentifier("shopTagline")
                        Spacer()
                        Image(userPrefersDarkTheme ? "bitrefill_white" : "bitrefill_black")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(10)
                            .frame(width: width * 0.45)
                    }
                    .frame(width: width * 0.5)
                    VStack(alignment: .trailing) {
                        GiftCardsView()
                    }
                    .frame(maxWidth: width * 0.5)
                }
                .frame(width: width)
            }
            .cornerRadius(bentoCornerRadius)
            .onAppear {
                mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
            }
            .onTapGesture {
                newMainViewModel.shouldShowShop.toggle()
            }
                
        }
    }
}
