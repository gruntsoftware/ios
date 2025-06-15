//
//  NewReceiveView.swift
//  brainwallet
//
//  Created by Kerry Washington on 28/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI

let modalCorner: CGFloat = 55.0

struct NewReceiveView: View {

    @ObservedObject
    var viewModel: NewReceiveViewModel

    @State
    private var isExpanded: Bool = false

    @State
    private var showError: Bool = false

    @State
    private var scannedCode: String?

    @State
    private var newAddress = ""

    @State
    private var didCopyAddress = false

    @State
    private var isModalMode: Bool = false

    @FocusState
     var keyboardFocused: Bool

    @State
    private var qrPlaceholder: UIImage = UIImage(systemName: "qrcode")!

    let buyButtonSize: CGFloat = 80.0
    let squareImageSize: CGFloat = 16.0
    let setAmountSize: CGFloat = 60.0
    let buttonCorner: CGFloat = 26.0
    let buttonFont: Font = .barlowBold(size: 20.0)
    let toastFont: Font = .barlowLight(size: 30.0)
    let lightDetailFont: Font = .barlowLight(size: 15.0)

    let minimumDragFactor: CGFloat = 250.0
    let opacityFactor: CGFloat = 0.8

    init(viewModel: NewReceiveViewModel, isModalMode: Bool?) {
        self.viewModel = viewModel
        self.isModalMode = isModalMode ?? false
    }

    var body: some View {

        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            let modalWidth = geometry.size.width * 0.9

            ZStack {

                    BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                    VStack {
                        
                        Button(action: {
                            UIPasteboard.general.string = viewModel.newReceiveAddress
                            didCopyAddress = true
                        }) {
                            VStack {
                                Image(systemName: "arrow.down.app")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(BrainwalletColor.content
                                        .opacity(opacityFactor))
                                    .frame(width: 35, height: 35)
                                    .padding([.top,.bottom], 10)

                                ZStack {
                                    RoundedRectangle(cornerRadius: buttonCorner / 4)
                                        .foregroundColor(.white)
                                        .frame(width: width * 0.42, height: width * 0.42)
                                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: buttonCorner / 4))
                                    Image(uiImage: viewModel.newReceiveAddressQR ?? UIImage())
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: width * 0.4, height: width * 0.4)
                                }

                                Text("\(viewModel.newReceiveAddress)")
                                   .font(lightDetailFont)
                                   .multilineTextAlignment(.center)
                                   .lineLimit(2)
                                   .foregroundColor(BrainwalletColor.content.opacity(opacityFactor))
                                   .frame(width: width * 0.4, height: height * 0.1)
                                   .padding(.all, 8.0)

                                Text("COPY / SHARE")
                                   .font(buttonFont)
                                   .foregroundColor(BrainwalletColor.content.opacity(opacityFactor))
                                   .padding([.bottom, .top], 20)
                            }
                        }
                        .frame(width: modalWidth * 0.75)
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

                    }
                    .frame(width: modalWidth * 0.75)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: buttonCorner))
                    .blur(radius: didCopyAddress ? 3.0 : 0.0)
                    .gesture(
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
                                    .opacity(opacityFactor))
                                .frame(width: modalWidth * 0.75)

                            Text("New address copied")
                                .font(toastFont)
                                .kerning(2.0)
                                .foregroundColor(BrainwalletColor.content)
                         }
                    }
                    .opacity(didCopyAddress ? 1.0 : 0.0)
                    .onChange(of: didCopyAddress) { _ in
                        withAnimation(.easeIn(duration: 1.0)) {
                            delay(2.0) {
                                didCopyAddress = false
                            }
                        }
                    }

                }
                .onAppear {
                    newAddress = viewModel.newReceiveAddress
                    keyboardFocused = false
                }
        }
    }
}
