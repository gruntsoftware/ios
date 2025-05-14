//
//  LockScreenFooterView.swift
//  brainwallet
//
//  Created by Kerry Washington on 04/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
  
struct LockScreenFooterView: View {
    
    @ObservedObject
    var viewModel: LockScreenViewModel

    init(viewModel: LockScreenViewModel) {
        self.viewModel = viewModel
    } 
    
    var body: some View {
        GeometryReader { geometry in
            
            let width = geometry.size.width
            
            let buttonSize = 30.0
            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            viewModel.userPrefersDarkMode.toggle()
                        }) {
                            Image(systemName: viewModel.userPrefersDarkMode ? "sun.max.circle" : "moon.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: buttonSize, height: buttonSize,
                                       alignment: .center)
                                .foregroundColor(BrainwalletColor.content)
                                
                        }
                        .frame(minWidth: width * 0.20, minHeight: 40.0,
                               alignment: .center)

                        VStack {
                            Spacer()
                            Button(action: {
                                viewModel.userWantsToDelete.toggle()
                            }) {
                                Text("Forgot seed phrase?")
                                    .font(.barlowSemiBold(size: 19.0))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(width: width * 0.4,
                                           alignment: .center)
                                    .foregroundColor(BrainwalletColor.content)
                            }
                            .frame(minWidth: width * 0.20, minHeight: 40.0,
                                   alignment: .center)
                            .padding(.top, 8.0)

                            Text(AppVersion.string)
                                .font(.barlowLight(size: 11.0))
                                .frame(width: width * 0.4,
                                       alignment: .center)
                                .foregroundColor(BrainwalletColor.content)
                                .padding(.all, 4.0)
                        }
                        
                        Button(action: {
                            viewModel.userDidTapQR = true
                        }) {
                            Image(systemName:"qrcode")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: buttonSize, height: buttonSize,
                                       alignment: .center)
                                .foregroundColor(BrainwalletColor.content)
                                .tint(BrainwalletColor.surface)
                        }
                        .frame(minWidth: width * 0.20, minHeight: 40.0,
                               alignment: .center) 
                    }
                    .frame(height: 60.0, alignment: .center)
                    .frame(maxWidth: .infinity)
                    .padding([.leading, .trailing], 8.0)
                }
            }
        }
    }
}
struct LockScreenFooterView_Previews: PreviewProvider {
    static let viewModel = LockScreenViewModel(store: Store())
    static var previews: some View {
        LockScreenFooterView(viewModel: viewModel)
    }
}
