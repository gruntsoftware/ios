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
    let largeFont: Font = .barlowSemiBold(size: 19.0)
    let detailFont: Font = .barlowSemiBold(size: 14.0)

    init(title: String, viewModel: NewMainViewModel, shouldExpandCurrency: Binding <Bool>) {
        self.title = title
        _shouldExpandCurrency = shouldExpandCurrency
        self.viewModel = viewModel
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
                                    .padding(.bottom, 1.0)
                                    .padding(.top, 8.0)

                                Text("\(pickedCurrency.fullCurrencyName) (\(pickedCurrency.symbol))")
                                    .font(detailFont)
                                    .kerning(0.6)
                                    .foregroundColor(BrainwalletColor.content)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom, 1.0)
                            }

                            Spacer()

                            VStack {
                                Button(action: {
                                    shouldExpandCurrency.toggle()
                                    let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
                                    impactRigid.impactOccurred()
                                }) {
                                    VStack {
                                        HStack {
                                            Image(systemName: "chevron.right")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: expandArrowSize, height: expandArrowSize)
                                                .foregroundColor(BrainwalletColor.content)
                                                .rotationEffect(Angle(degrees: shouldExpandCurrency ? 90 : 0))

                                        }

                                    }
                                    .frame(width: 30.0, height: 30.0, alignment: .top)
                                    .padding(.top, 8.0)

                                }
                                .frame(width: 30.0, height: 30.0)
                            }

                        }
                        .padding(.top, 1.0)
                        CurrencyPickerView(viewModel: viewModel, pickedCurrency: $pickedCurrency)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: shouldExpandCurrency)
                            .frame(height: shouldExpandCurrency ? pickerViewHeight : 0.1)
                            .padding(.top, 1.0)
                        Spacer()
                    }.onAppear {
                        pickedCurrency = viewModel.currentGlobalFiat
                    }
                }
            }
        }
    }
}
