//
//  PasscodeGridView.swift
//  brainwallet
//
//  Created by Kerry Washington on 23/04/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI
struct PasscodeGridView: View {

    let detailFont: Font = .barlowRegular(size: 28.0)
    let elementSpacing = 5.0

    @Binding var digits: [Int]

    var body: some View {

        Grid(horizontalSpacing: elementSpacing, verticalSpacing: elementSpacing) {
            GridRow {
                CodeButton(index: 1, digits: $digits)
                CodeButton(index: 2, digits: $digits)
                CodeButton(index: 3, digits: $digits)
            }

            GridRow {
                CodeButton(index: 4, digits: $digits)
                CodeButton(index: 5, digits: $digits)
                CodeButton(index: 6, digits: $digits)
            }

            GridRow {
                CodeButton(index: 7, digits: $digits)
                CodeButton(index: 8, digits: $digits)
                CodeButton(index: 9, digits: $digits)
            }

            GridRow {
                CodeButton(index: -1, digits: $digits)
                CodeButton(index: 0, digits: $digits)
                CodeButton(index: -2, digits: $digits)
            }
        }
    }
}

struct CodeButton: View {
    let buttonSize = 70.0
    let detailFont: Font = .barlowRegular(size: 28.0)
    var index: Int

    @Binding var digits: [Int]

    init (index: Int, digits: Binding<[Int]>) {
        _digits = digits
        self.index = index
    }

    var body: some View {
        Button {

            if index >= 0 && digits.count < 4 {
                $digits.wrappedValue.append(index)
            } else if index == -2 && !digits.isEmpty {
                digits.removeLast()
            }

        } label: {
            ZStack {
                Ellipse()
                .frame(width: buttonSize,
                       height: buttonSize)
                    .foregroundColor(index >= 0 ? BrainwalletColor.content.opacity(0.2) : .clear)

                if index == -2 {
                    Image(systemName: "arrow.backward")
                        .resizable()
                        .foregroundColor(BrainwalletColor.content)
                        .frame(maxWidth: buttonSize * 0.25,
                               maxHeight: buttonSize * 0.25)
                        .padding()
                } else if index == -1 {
                    EmptyView()
                } else {
                    Text("\(index)")
                        .font(detailFont)
                        .foregroundColor(BrainwalletColor.content)
                        .frame(maxWidth: .infinity,
                               maxHeight: .infinity)
                        .padding()
                }
            }
        }
        .padding(.all, 5.0)
        .disabled(index == -1)
    }
}
