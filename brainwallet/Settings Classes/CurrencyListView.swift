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
                                        .padding(16.0)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: width * 0.82, height: 100.0, alignment: .leading)
                            .onChange(of: pickedCurrency) { _ in
                               selectedFiat = false
                                delay(0.4) {
                                    selectedFiat = true
                                    viewModel.userDidSetCurrencyPreference(currency: pickedCurrency)
                                }
                            }
                            .padding(.top, rowLeadingPad)
                        }
                        Spacer()
                        VStack {
                            ZStack {
                                Ellipse()
                                    .frame(width: checkSize * 2,
                                       height: checkSize * 2)
                                    .foregroundColor(selectedFiat ? BrainwalletColor.grape.opacity(0.9) : BrainwalletColor.grape.opacity(0.1))
                                    .overlay(
                                        Ellipse()
                                            .stroke(selectedFiat ? BrainwalletColor.midnight.opacity(0.9) : BrainwalletColor.grape, lineWidth: 2.0)
                                            .frame(width: checkSize * 2,
                                               height: checkSize * 2)
                                    )
                                Image(systemName: "checkmark")
                                    .frame(width: checkSize,
                                           height: checkSize)
                                    .foregroundColor(selectedFiat ? .white : BrainwalletColor.gray)
                            }
                        }
                        .frame(width: width * 0.1, height: 100.0, alignment: .leading)
                        .padding(.top, rowLeadingPad)
                    }

                }.background(.red)
            }
        }
    }
}
