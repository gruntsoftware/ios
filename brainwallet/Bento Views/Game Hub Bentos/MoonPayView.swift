//
//  MoonPayView.swift
//  brainwallet
//
//  Created by Kerry Washington on 07/10/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct MoonPayView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel
    
    @Binding
    var selectedStep: Int

    @State
    private var shouldShowGameMode: Bool = false
    

    init(viewModel: NewMainViewModel, selectedStep: Binding<Int>) {
        _selectedStep = selectedStep
        newMainViewModel = viewModel
    }
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            let labelBackground = Color.white.opacity(0.1)
            let labelForeground = Color.white

            ZStack {
                StaticBackgroundView(userPrefersDarkTheme: .constant(false),
                                     imageName: "moonPay_background_1")
                    .edgesIgnoringSafeArea(.all)
                VStack(alignment: .center) {
                    HStack {

                        Button(action: {
                            newMainViewModel.shouldShowBuyReceive.toggle()
                        }) {

                            HStack {
                                VStack {
                                    Text("Top up in 5 minutes with our partner")
                                        .modifier(BWIPSSemiBold(size: 16.0, lineLimit: 2))
                                        .padding(.leading, 16)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(2)
                                        .foregroundStyle( .black)
                                        .frame(width: width * 0.4, alignment: .leading)
                                }
                                .fixedSize(horizontal: true, vertical: false)
                                .padding(.top, 5)
                                Spacer()
                            }
                        }
                        .accessibilityIdentifier("launchesBuyRecieveView")
                    }
                }  
            }
            .cornerRadius(bentoCornerRadius)
            .frame(minHeight: gameBentoHeight * 0.9, idealHeight: gameBentoHeight * 1.4, maxHeight: gameBentoHeight * 2, alignment: .center)
        }
    }
}
