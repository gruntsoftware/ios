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

    let addressFont: Font = .ibmPlexSansBold(size: 17.0)
    let labelFont: Font = .ibmPlexSansSemiBold(size: 14.0)
    let subDetailFont: Font = .ibmPlexSansRegular(size: 14.0)
    let lightDetailFont: Font = .ibmPlexSansLight(size: 18.0)
    let buttonFont: Font = .ibmPlexSansBold(size: 20.0)
    let buttonCorner: CGFloat = 26.0
    let toastFont: Font = .ibmPlexSansLight(size: 30.0)
    let opacityFactor: CGFloat = 0.8
    let padding = 18.0
    let minimumDragFactor: CGFloat = 250.0
    let copyIconSize: CGFloat = 34.0

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
            let qrWidth = geometry.size.width * 0.5
            ZStack {
                Button(action: {
                    UIPasteboard.general.string = viewModel.newReceiveAddress
                    didCopyAddress = true
                }) {
                    HStack(alignment: .top, spacing: 12.0) {

                        ZStack {
                            RoundedRectangle(cornerRadius: buttonCorner / 4)
                                .foregroundColor(.white)
                                .frame(width: abs(qrWidth - padding), height: abs(qrWidth - padding))
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: buttonCorner / 4))
                            Image(uiImage: viewModel.newReceiveAddressQR ?? qrPlaceholder)
                                .resizable()
                                .scaledToFit()
                                .frame(width: abs(qrWidth - padding))
                        }
                        .frame(width: qrWidth, alignment: .top)

                        VStack(alignment: .leading, spacing: 10.0) {
                            Text(newAddress)
                                .font(.ibmPlexSansSemiBold(size: 23.0))
                                .multilineTextAlignment(.leading)
                                .lineLimit(3)
                                .minimumScaleFactor(0.8)
                                .foregroundColor(BrainwalletColor.content)

                            Spacer(minLength: 4.0)
                            Text("COPY NEW ADDRESS")
                                .font(labelFont)
                                .kerning(0.5)
                                .foregroundColor(BrainwalletColor.content.opacity(opacityFactor * 0.8))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)

                            ZStack {
                                Ellipse()
                                    .stroke(BrainwalletColor.content.opacity(0.4), lineWidth: 1.0)
                                    .frame(width: copyIconSize, height: copyIconSize)
                                Image(systemName: "doc.on.doc")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 14.0, height: 14.0)
                                    .foregroundColor(BrainwalletColor.content)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            Spacer(minLength: 4.0)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onChange(of: viewModel.newReceiveAddress) { _,address in
                            newAddress = address
                        }
                    }
                    .padding(.horizontal, 4.0)
                    .frame(width: width, alignment: .top)
                    .opacity(keyboardFocused ? 0 : 1)
                }
                .buttonStyle(.plain)
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
                .onChange(of: didCopyAddress) { _,_ in
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
