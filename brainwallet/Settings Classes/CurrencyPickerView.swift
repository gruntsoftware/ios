//
//  CurrencyPickerView.swift
//  brainwallet
//
//  Created by Kerry Washington on 08/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
//
import SwiftUI

struct CurrencyPickerView: View {

    @ObservedObject
    var viewModel: NewMainViewModel

    @Binding
    var pickedCurrency: GlobalCurrency

    @State
    private var selectedFiat: Bool = false

    let selectorFont: Font = .barlowRegular(size: 16.0)
    let symbolFont: Font = .barlowLight(size: 16.0)

    let globalCurrencies: [GlobalCurrency] = GlobalCurrency.allCases
    let checkSize: CGFloat = 16.0
    let elementsHeight: CGFloat = 90.0
    init(viewModel: NewMainViewModel, pickedCurrency: Binding<GlobalCurrency>) {
        self.viewModel = viewModel
        _pickedCurrency = pickedCurrency
    }

    var body: some View {

        NavigationStack {
            GeometryReader { geometry in

                let width = geometry.size.width
                ZStack {
                    BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                    HStack {
                        VStack {
                            Picker("", selection: $pickedCurrency) {
                                ForEach(globalCurrencies, id: \.self) {
                                    Text("\($0.fullCurrencyName)   (\($0.code))")
                                        .font(selectorFont)
                                        .foregroundColor(BrainwalletColor.content)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(4.0)
                                }
                            }
                            .frame(height: elementsHeight)
                            .pickerStyle(.wheel)
                            .frame(width: width * 0.82, alignment: .leading)
                            .onChange(of: pickedCurrency) { _ in
                               selectedFiat = false
                                delay(0.4) {
                                    selectedFiat = true
                                    viewModel.userDidSetCurrencyPreference(currency: pickedCurrency)
                                }
                            }
                            Spacer()
                        }
                        Spacer()
                        VStack {
                            ZStack {
                                Ellipse()
                                    .frame(width: checkSize * 2,
                                       height: checkSize * 2)
                                    .foregroundColor(selectedFiat ? BrainwalletColor.affirm :
                                        BrainwalletColor.affirm.opacity(0.1))
                                    .overlay(
                                        Ellipse()
                                            .stroke(selectedFiat ? BrainwalletColor.affirm.opacity(0.9) :
                                                BrainwalletColor.gray, lineWidth: 1.5)
                                            .frame(width: checkSize * 2,
                                               height: checkSize * 2)
                                    )
                                Image(systemName: "checkmark")
                                    .font(.system(size: 20, weight: .bold))
                                    .frame(width: checkSize,
                                           height: checkSize)
                                    .foregroundColor(selectedFiat ? .white : BrainwalletColor.gray)
                            }
                            .frame(height: elementsHeight)
                            Spacer()
                        }
                        .frame(width: width * 0.1, alignment: .leading)
                        .background(BrainwalletColor.background)
                    }
                    .background(BrainwalletColor.background)

                }
            }
        }
    }
}
