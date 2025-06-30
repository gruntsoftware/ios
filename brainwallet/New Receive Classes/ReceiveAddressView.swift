//
//  ReceiveAddressView.swift
//  brainwallet
//
//  Created by Kerry Washington on 07/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI

struct ReceiveAddressView: View {

    @ObservedObject var viewModel: NewReceiveViewModel

    @Binding
    var newAddress: String

    @Binding
    var  qrPlaceholder: UIImage

    @FocusState.Binding
    var keyboardFocused: Bool

    @State
    private var didCopyAddress = false

    let ginormousFont: Font = .barlowSemiBold(size: 22.0)
    let subDetailFont: Font = .barlowRegular(size: 14.0)
    let lightDetailFont: Font = .barlowLight(size: 18.0)
    let buttonFont: Font = .barlowBold(size: 20.0)
    let buttonCorner: CGFloat = 26.0
    let toastFont: Font = .barlowLight(size: 30.0)
    let opacityFactor: CGFloat = 0.8
    let padding = 18.0
    let minimumDragFactor: CGFloat = 250.0

    init(viewModel: NewReceiveViewModel, newAddress: Binding<String>, qrPlaceholder: Binding<UIImage>, keyboardFocused: FocusState<Bool>.Binding) {
        self.viewModel = viewModel
        _newAddress = newAddress
        _qrPlaceholder = qrPlaceholder
        _keyboardFocused = keyboardFocused
    }
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let qrWidth = geometry.size.width * 0.4
            ZStack {
                HStack {
                    RoundedRectangle(cornerRadius: buttonCorner)
                        .foregroundColor(BrainwalletColor.content
                            .opacity(0.03))
                        .frame(width: width, height: height, alignment: .center)
                }
                .frame(width: width, height: height, alignment: .center)

                Button(action: {
                    UIPasteboard.general.string = viewModel.newReceiveAddress
                    didCopyAddress = true
                }) {

                    HStack {
                        VStack {
                            Spacer()

                             ZStack {
                                RoundedRectangle(cornerRadius: buttonCorner / 4)
                                    .foregroundColor(.white)
                                    .frame(width: qrWidth - padding,
                                           height: qrWidth - padding)
                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: buttonCorner / 4))
                                Image(uiImage: viewModel.newReceiveAddressQR ?? qrPlaceholder)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: qrWidth - padding)
                            }
                            Spacer()

                        }
                        .frame(width: qrWidth, alignment: .trailing)
                        Spacer()
                        VStack {
                            Spacer()
                            Text(newAddress)
                                .font(lightDetailFont)
                                .multilineTextAlignment(.center)
                                .truncationMode(.middle)
                                .foregroundColor(BrainwalletColor.content.opacity(opacityFactor))
                                .padding(.all, 8.0)
                            Text("COPY / SHARE")
                                .font(buttonFont)
                                .multilineTextAlignment(.center)
                                .foregroundColor(BrainwalletColor.content.opacity(opacityFactor))
                                .padding(.all, 8.0)
                            Spacer()
                        }
                        .frame(width: qrWidth, alignment: .leading)
                        .onChange(of: viewModel.newReceiveAddress) { address in
                            newAddress = address
                        }
                    }
                    .frame(width: width, height: height, alignment: .top)
                    .opacity(keyboardFocused ? 0 : 1)
                }
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in

                            /// Dismiss after 2 button sizes
                            let transX = value.translation.width
                            let transY = value.translation.height
                            let hypotenuse = sqrt(transX * transX + transY * transY)

                            if hypotenuse > minimumDragFactor {
                                viewModel.shouldDismissTheView()
                            }
                        }
                )
                VStack {

                    ZStack {
                        RoundedRectangle(cornerRadius: buttonCorner)
                            .foregroundColor(BrainwalletColor.surface
                                .opacity(0.95))
                            .frame(width: width, height: height, alignment: .center)

                        Text("New address copied")
                            .font(toastFont)
                            .kerning(0.4)
                            .foregroundColor(BrainwalletColor.content)
                     }
                }
                .opacity(didCopyAddress ? 1.0 : 0.0)
                .onChange(of: didCopyAddress) { _ in
                    withAnimation(.easeInOut(duration: 1.0)) {
                        delay(1.0) {
                            didCopyAddress = false
                        }
                    }
                }
            }
        }
    }
}
