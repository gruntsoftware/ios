//
//  SettingsExpandingSecurityView.swift
//  brainwallet
//
//  Created by Kerry Washington on 19/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SettingsExpandingSecurityView: View {

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
                            Text(title)
                                .font(largeFont)
                                .foregroundColor(BrainwalletColor.content)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, rowLeadingPad)
                            Spacer()

                            VStack {
                                Button(action: {
                                    shouldExpandSecurity.toggle()
                                }) {
                                    VStack {
                                        HStack {
                                            Image(systemName: "chevron.right")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: expandArrowSize, height: expandArrowSize)
                                                .foregroundColor(BrainwalletColor.content)
                                                .rotationEffect(Angle(degrees: shouldExpandSecurity ? 90 : 0))
                                        }
                                    }
                                    .frame(width: 30.0, height: 30.0)
                                }
                                .frame(width: 30.0, height: 30.0)
                            }
                        }
                        .frame(height: 44.0)
                        .padding(.top, 1.0)
                        SecurityListView(viewModel: viewModel)
                            .transition(.opacity)
                            .transition(.move(edge: .top))
                            .animation(.easeInOut(duration: 0.3))
                            .frame(height: shouldExpandSecurity ? 110.0 : 0.1)
                        Spacer()
                    }

                }
            }
        }
    }
}
