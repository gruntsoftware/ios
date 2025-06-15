//
//  SimpleHeaderView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct SimpleHeaderView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @State
    var shouldShowSettings: Bool = false

    @State
    private var formattedTimestamp = ""

    init(viewModel: NewMainViewModel) {
        newMainViewModel = viewModel
    }
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            newMainViewModel.shouldShowSettings.toggle()
                            shouldShowSettings = newMainViewModel.shouldShowSettings
                        }) {
                            Image(systemName: "line.3.horizontal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30.0, height: 30.0,
                                       alignment: .center)
                                .foregroundColor(BrainwalletColor.content)
                        }
                        .frame(width: 30.0, height: 30.0,
                               alignment: .leading)

                        Spacer()
                        VStack {
                            Spacer()
                            Text(newMainViewModel.currentFiatValue)
                                .font(.barlowSemiBold(size: 22.0))
                                .frame(width: width * 0.4,
                                       alignment: .bottomTrailing)
                                .foregroundColor(BrainwalletColor.content)

                            Text(formattedTimestamp)
                                .font(.barlowLight(size: 15.0))
                                .frame(width: width * 0.4,
                                       alignment: .bottomTrailing)
                                .foregroundColor(BrainwalletColor.content)
                                .padding(.bottom, 6.0)
                        }
                        .padding(.bottom, 8.0)
                    }
                    .frame(height: 88.0, alignment: .center)
                    .frame(maxWidth: .infinity)
                    .padding([.leading, .trailing], 8.0)
                    .onChange(of: newMainViewModel.currentFiatValue) { _ in
                         formattedTimestamp = newMainViewModel.dateFormatter?.string(from: Date()) ?? ""
                    }
                }
            }
        }
    }
}
