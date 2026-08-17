//
//  SocialsBentoView.swift
//  brainwallet
//
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
import FirebaseAnalytics

struct SocialsBentoView: View {
    
    @ObservedObject
    var newMainViewModel: NewMainViewModel
    
    @Binding
    var selectedStep: Int

    @State
    private var shouldShowSocials: Bool = false

    init(viewModel: NewMainViewModel, selectedStep: Binding<Int>) {
        _selectedStep = selectedStep
        newMainViewModel = viewModel
    }
    var body: some View {
        GeometryReader { geometry in

            ZStack {
                StaticBackgroundView(userPrefersDarkTheme: .constant(false),
                                     imageName: "socials_background_1")
                    .edgesIgnoringSafeArea(.all)
               
                        Button(action: {
                            newMainViewModel.shouldShowSocials.toggle()
                            Analytics.logEvent("user_did_tap_linktree",
                                               parameters: nil)
                        }) {
                            
                            HStack {
                                VStack {
                                    Text("Click and follow us!")
                                        .modifier(BWIPSSemiBold(size: 18.0, lineLimit: 1))
                                        .padding(.top, 30)
                                        .frame(alignment: .center)
                                        .foregroundStyle( .white)
                                    Spacer()
                                }
                            }
                        }
                        .accessibilityIdentifier("socialsButtonView")
                    
            }
            .cornerRadius(bentoCornerRadius)
            .frame(minHeight: gameBentoHeight * 0.9, idealHeight: gameBentoHeight * 1.4, maxHeight: gameBentoHeight * 2, alignment: .center)
        }
    }
}
