//
//  SettingsExpandingGamesView.swift
//  brainwallet
//
//  Created by Kerry Washington on 19/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SettingsExpandingGamesView: View {

    @ObservedObject
    var viewModel: NewMainViewModel
    @Binding
    var shouldExpandSecurity: Bool

    @State
    private var rotationAngle: Double = 0

    private var title: String
    let largeFont: Font = .barlowSemiBold(size: 19.0)
    let detailFont: Font = .barlowLight(size: 18.0)

    var securityListView: SecurityListView

    init(title: String, viewModel: NewMainViewModel, shouldExpandSecurity: Binding <Bool>) {
        self.title = title
        _shouldExpandSecurity = shouldExpandSecurity
        self.viewModel = viewModel
        self.securityListView = SecurityListView(viewModel: viewModel)
    }

    var body: some View {
        NavigationStack {
            GeometryReader { _ in
                ZStack {
                    VStack {
                        HStack {
                            VStack {
                                Text(title)
                                    .font(largeFont)
                                    .foregroundColor(BrainwalletColor.content)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 16.0)
                                Spacer()
                            }

                            Spacer()

                                Button(action: {
                                    shouldExpandSecurity.toggle()
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        if shouldExpandSecurity {
                                            rotationAngle -= 90
                                        } else {
                                            rotationAngle += 90
                                        }
                                    }

                                }) {
                                        Image(systemName: "chevron.left")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 30.0,
                                                   height: 30.0)
                                            .foregroundColor(BrainwalletColor.content)
                                }
                                .rotationEffect(Angle(degrees: rotationAngle))
                                .frame(width: 30.0, height: 30.0)
                        }
                        .frame(height: closedRowHeight, alignment: .top)
                        if shouldExpandSecurity {
                            securityListView
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}
