//
//  BrainwalletShapes.swift
//  brainwallet
//
//  Created by Kerry Washington on 28/05/2025.
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

struct TestShapeView: View {

       @State
       private var progress = 0.0

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

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
