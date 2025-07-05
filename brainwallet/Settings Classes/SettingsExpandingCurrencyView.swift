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

    private let actionButtonSize: CGFloat = 30.0

    init(title: String, viewModel: NewMainViewModel, shouldExpandCurrency: Binding <Bool>) {
        self.title = title
        _shouldExpandCurrency = shouldExpandCurrency
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in

                let width = geometry.size.width
                let factorWidth30 = geometry.size.width * 0.3

                let height = geometry.size.height
                ZStack {
                        VStack {
                            NavigationStack {
                                HStack {
                                    VStack {
                                        Text("\(title) (\(pickedCurrency.symbol))")
                                            .font(largeFont)
                                            .foregroundColor(BrainwalletColor.content)
                                            .padding(.bottom, 8.0)
                                            .padding(.top, 8.0)
                                    }
                                    .frame(width: factorWidth30 - actionButtonSize, alignment: .leading)

                                    List {
                                        ForEach(viewModel.filteredCurrencyCodes, id: \.self) { code in
                                            Text(code)
                                        }
                                    }
                                    .searchable(text: $viewModel.searchedCurrencyString)
                                    .navigationTitle("Search Example")}
                                    .frame(width: factorWidth30 - actionButtonSize, alignment: .leading)
                                    .background(BrainwalletColor.chili)

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
                                        .frame(width: actionButtonSize, height: actionButtonSize, alignment: .top)
                                        .padding(.top, 8.0)

                                    }
                                    .frame(width: actionButtonSize, height: actionButtonSize)
                                }
                                .frame(width: actionButtonSize, height: 50.0)
                            }

                            }
                            .padding(.top, 1.0)
                            .padding(.bottom, 8.0)
                            CurrencyPickerView(viewModel: viewModel, pickedCurrency: $pickedCurrency)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.3), value: shouldExpandCurrency)
                                .frame(height: shouldExpandCurrency ? pickerViewHeight : 0.1)
                            Spacer()
                        }
                    .onAppear {
                        pickedCurrency = viewModel.currentGlobalFiat
                    }
            }
        }
    }
}
