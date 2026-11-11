//
//  SettingsExpandingCurrencyView.swift
//  brainwallet
//
//  Created by Kerry Washington on 19/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SettingsExpandingCurrencyView: View {

    @ObservedObject
    var viewModel: NewMainViewModel
    @Binding
    var shouldExpandCurrency: Bool

    @State
    private var selectedFiat: Bool = false

    @State
    private var rotationAngle: Double = 0

    @State
    private var pickedCurrency: GlobalCurrency = .USD

    private var title: String
    
    /// Height of the detail panel when expanded; total expanded row = closedRowHeight + this.
    private let detailExpandedHeight: CGFloat = 120.0
    
    //let pickerViewHeight: CGFloat = 160.0


    init(title: String, viewModel: NewMainViewModel, shouldExpandCurrency: Binding <Bool>) {
        self.title = title
        _shouldExpandCurrency = shouldExpandCurrency
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            Divider()
                .frame(height: 1)
                .overlay(Color.white)
            Text("\(title) (\(pickedCurrency.symbol))")
                .modifier(BWIPSSemiBold(size: 15.0))
                .foregroundColor(BrainwalletColor.content)
                .frame(maxWidth: .infinity, alignment: .leadingFirstTextBaseline)
                .frame(height: closedRowHeight)
                .overlay(alignment: .trailing) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            shouldExpandCurrency.toggle()
                        }
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                    }) {
                        Image(systemName: "chevron.down")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: expandArrowSize, height: expandArrowSize)
                            .foregroundColor(BrainwalletColor.content)
                            .rotationEffect(Angle(degrees: shouldExpandCurrency ? 180 : 0))
                    }
                    .frame(width: 30.0, height: 30.0)
                    .contentShape(Rectangle())
                }
            
            CurrencyPickerView(viewModel: viewModel, pickedCurrency: $pickedCurrency)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: shouldExpandCurrency)
                .frame(height: shouldExpandCurrency ? detailExpandedHeight : 0.0)
                .opacity(shouldExpandCurrency ? 1.0 : 0.0)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .fixedSize(horizontal: false, vertical: true)
    }
}
