//
//  BrainwalletShapes.swift
//  brainwallet
//
//  Created by Kerry Washington on 29/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct BrainwalletHexagon: Shape {

    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let centerX = rect.midX
        let centerY = rect.midY

        // Calculate hexagon points (flat-top orientation)
        // system shape: hexagon.fill
        let radius = min(width, height) / 2

        var path = Path()

        // Start from top vertex and go clockwise (pointy-top orientation)
        path.move(to: CGPoint(x: centerX, y: centerY - radius))
        path.addLine(to: CGPoint(x: centerX + radius * sin(π/3), y: centerY - radius * cos(π/3)))
        path.addLine(to: CGPoint(x: centerX + radius * sin(π/3), y: centerY + radius * cos(π/3)))
        path.addLine(to: CGPoint(x: centerX, y: centerY + radius))
        path.addLine(to: CGPoint(x: centerX - radius * sin(π/3), y: centerY + radius * cos(π/3)))
        path.addLine(to: CGPoint(x: centerX - radius * sin(π/3), y: centerY - radius * cos(π/3)))
        path.closeSubpath()
        return path

    }
}

struct BrainwallePulseEllipse: View {

    @Binding
    var shapeSize: CGFloat

    @State private var circleOpacity: Double = 0
    @State private var checkStrokeEnd: CGFloat = 0

    @State
    private var scaleEllipse: CGFloat = 1.0

    private let animationDuration: TimeInterval = 0.4
    private let originalCheckSize: CGFloat = 96.0

    var body: some View {
        GeometryReader { _ in
            HStack {
                Spacer()
                ZStack {
                    Ellipse()
                        .fill(.green.opacity(0.2))
                        .frame(width: shapeSize,
                               height: shapeSize,
                               alignment: .center)
                        .scaleEffect(scaleEllipse)
                                    .onAppear {
                                        let baseAnimation = Animation.easeInOut(duration: 1.0)
                                        let repeated = baseAnimation.repeatForever(autoreverses: true)
                                        withAnimation(repeated) {
                                            scaleEllipse = 1.1
                                        }
                        }
                    Ellipse()
                        .fill(.green)
                        .frame(width: shapeSize * 0.8,
                               height: shapeSize * 0.8,
                               alignment: .center)
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: shapeSize * 0.3,
                               height: shapeSize * 0.3,
                               alignment: .center)
                        .foregroundStyle(.white)
                }
                Spacer()

            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    func show() {
        withAnimation(.easeIn(duration: animationDuration)) {
            circleOpacity = 1.0
            checkStrokeEnd = 1.0
        }
    }
}

struct CheckmarkShape: Shape {
    let scaleFactor: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: 32.5 * scaleFactor, y: 47.0 * scaleFactor))
        path.addLine(to: CGPoint(x: 43.0 * scaleFactor, y: 57.0 * scaleFactor))
        path.addLine(to: CGPoint(x: 63 * scaleFactor, y: 37.4 * scaleFactor))

        return path
    }
}

// Extension for the default tint color
extension Color {
    static var defaultTint: Color {
        // Replace with your C.defaultTintColor equivalent
        Color.blue // or your actual color
    }
}

struct TestShapeView: View {

       @State
       private var progress = 0.0

    var body: some View {
        GeometryReader { _ in

            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)

                VStack {

                    ZStack {
                        BrainwalletHexagon()
                            .fill(BrainwalletColor.affirm)

                        BrainwalletHexagon()
                            .trim(from: 0, to: progress)
                            .stroke(BrainwalletColor.affirm.opacity(0.5),
                                    style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    }
                    .frame(width: 30, height: 30)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: false)) {
                            progress = 1.0
                        }
                    }

                    BrainwalletHexagon()
                        .fill(.red)
                        .overlay(
                            BrainwalletHexagon()
                                .stroke(Color.blue, lineWidth: 2)
                        )

                    ZStack {
                        BrainwalletHexagon()
                            .fill(BrainwalletColor.background)

                        BrainwalletHexagon()
                            .trim(from: 0, to: progress)
                            .stroke(BrainwalletColor.content.opacity(0.5),
                                    style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    }
                    .frame(width: 100, height: 100)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: false)) {
                            progress = 1.0
                        }
                    }

                }

            }
        }
    }
}
