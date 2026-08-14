//
//  BrainwalletShapes.swift
//  brainwallet
//
//  Created by Kerry Washington on 29/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

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
        GeometryReader { _ in

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

                    } else if shapeCorner.index == 1 {

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

// Extension for the default tint color
extension Color {
    static var defaultTint: Color {
        // Replace with your C.defaultTintColor equivalent
        Color.blue // or your actual color
    }
}
