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

public enum ShapeCorner {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    case none

    var index: Int {
        switch self {
        case .topLeft:
            return 0
        case .topRight:
            return 1
        case .bottomLeft:
            return 2
        case .bottomRight:
            return 3
        case .none:
            return -1
        }
    }
}

struct BentoCalloutShape: View {
    @Binding
    var shapeCorner: ShapeCorner

    @Binding
    var userPrefersDarkTheme: Bool

    init(shapeCorner: Binding<ShapeCorner>,
         userPrefersDarkTheme: Binding<Bool>) {
        _shapeCorner = shapeCorner
        _userPrefersDarkTheme = userPrefersDarkTheme
    }
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let triangleSize = 70.0

            let backgroundColor: Color = .white
            ZStack {

                HStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(backgroundColor)
                        .frame(alignment: .center)
                        .shadow(color: .black.opacity(0.6),
                                radius: 3.0, x: 0, y: 5)
                }

                if shapeCorner.index >= 0 {
                    if shapeCorner.index == 0 {
                        /// Top Left
                        ///  \
                        ///  \-------/
                        ///  |          |
                        ///  \--------/
                        HStack {
                            Spacer()
                            RightTriangle()
                                .foregroundColor(backgroundColor)
                                .frame(width: triangleSize,
                                       height: triangleSize,
                                       alignment: .trailing)
                                .scaleEffect(x: -1, y: 1)
                                .offset(y: -triangleSize * 0.5)
                        }

                    } else if shapeCorner.index == 1 {

                        /// Top Right
                        ///       /
                        ///   -------\
                        ///  |          |
                        ///  \--------/
                        HStack {
                            RightTriangle()
                                .foregroundColor(backgroundColor)
                                .frame(width: triangleSize,
                                       height: triangleSize,
                                       alignment: .leading)
                                .scaleEffect(x: 1, y: 1)
                                .offset(y: -triangleSize * 0.5)
                            Spacer()
                        }
                    } else if shapeCorner.index == 2 {
                        /// Bottom Left
                        ///  / -------\
                        ///  |          |
                        ///  \--------/
                        ///   /
                        HStack {
                            RightTriangle()
                                .foregroundColor(backgroundColor)
                                .frame(width: triangleSize,
                                       height: triangleSize,
                                       alignment: .leading)
                                .scaleEffect(x: 1, y: -1)
                                .offset(y: triangleSize * 0.5)
                            Spacer()
                        }
                    } else {
                        /// Bottom Right
                        ///  / -------\
                        ///  |          |
                        ///  --------/
                        ///       \
                        HStack {
                            Spacer()
                            RightTriangle()
                                .foregroundColor(backgroundColor)
                                .frame(width: triangleSize,
                                       height: triangleSize,
                                       alignment: .trailing)
                                .scaleEffect(x: -1, y: -1)
                                .frame(alignment: .trailing)
                                .offset(y: triangleSize * 0.5)
                        }
                    }
                }

            }
        }
        .onAppear {

        }
    }
}

struct RightTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        }
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
