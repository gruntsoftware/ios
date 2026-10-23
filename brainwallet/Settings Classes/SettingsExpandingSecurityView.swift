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

    var securityListView: SecurityListView

    /// Height of the detail panel when expanded; total expanded row = closedRowHeight + this.
    private let detailExpandedHeight: CGFloat = 250.0

    init(title: String, viewModel: NewMainViewModel, shouldExpandSecurity: Binding <Bool>) {
        self.title = title
        _shouldExpandSecurity = shouldExpandSecurity
        self.viewModel = viewModel
        self.securityListView = SecurityListView(viewModel: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            Divider()
                .frame(height: 1)
                .overlay(Color.white)
            Text(title)
                .modifier(BWIPSSemiBold(size: 15.0))
                .foregroundColor(BrainwalletColor.content)
                .frame(maxWidth: .infinity, alignment: .leadingFirstTextBaseline)
                .frame(height: closedRowHeight)
                .overlay(alignment: .trailing) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            shouldExpandSecurity.toggle()
                        }
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                    }) {
                        Image(systemName: "chevron.down")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: expandArrowSize, height: expandArrowSize)
                            .foregroundColor(BrainwalletColor.content)
                            .rotationEffect(Angle(degrees: shouldExpandSecurity ? 180 : 0))
                    }
                    .frame(width: 30.0, height: 30.0)
                    .contentShape(Rectangle())
                }

            SecurityListView(viewModel: viewModel)
                .frame(maxWidth: .infinity)
                .frame(height: shouldExpandSecurity ? detailExpandedHeight : 0.0, alignment: .top)
                .clipped()
                .opacity(shouldExpandSecurity ? 1.0 : 0.0)
                .allowsHitTesting(shouldExpandSecurity)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .fixedSize(horizontal: false, vertical: true)
    }
}
