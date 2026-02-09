//
//  GridWaveContentView.swift
//  brainwallet
//
//  Created by Kerry Washington on 15/10/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
ContentView class that returns a `CIImage` for the current time.
*/

import SwiftUI
import CoreImage.CIFilterBuiltins

/// - Tag: ContentView
struct GridWaveContentView: View {

    let renderWidth: CGFloat
    let renderHeight: CGFloat

    @State
    private var colorStyle: MainGradientStyle = .lightStyle

    private let colorTriplet: (CIColor, CIColor, CIColor) =
            (.init(red: 15/255, green: 8/255, blue: 83/255), // #0F0853
            .init(red: 64/255, green: 45/255, blue: 174/255),  // #402DAE
            .init(red: 21/255, green: 21/255, blue: 21/255)) // #151515

    @Binding
    var userPrefersDarkTheme: Bool

    init(renderWidth: CGFloat, renderHeight: CGFloat, userPrefersDarkTheme: Binding <Bool>) {
        self.renderWidth = renderWidth
        self.renderHeight = renderHeight
        _userPrefersDarkTheme = userPrefersDarkTheme
    }
    // Helper function for color interpolation
    func interpolateColor(fromColor: CIColor, toColor: CIColor, progress: CGFloat) -> CIColor {
        let rColor = fromColor.red + (toColor.red - fromColor.red) * progress
        let gColor = fromColor.green + (toColor.green - fromColor.green) * progress
        let bColor = fromColor.blue + (toColor.blue - fromColor.blue) * progress
        return CIColor(red: rColor, green: gColor, blue: bColor)
    }

    var body: some View {

        // Create a Metal view with its own renderer.
        let renderer = Renderer(imageProvider: { (time: CFTimeInterval, scaleFactor: CGFloat, _: CGFloat) -> CIImage in

            var image: CIImage

            let color1 = self.colorTriplet.0
            let color2 = self.colorTriplet.1
            let color3 = self.colorTriplet.2

            // Animate through the colors using time
            let cycleTime = fmod(time * 0.5, 3.0) // Adjust 0.3 to control animation speed

            var startColor: CIColor
            var endColor: CIColor

            // Cycle through color pairs
            if cycleTime < 1.0 {
                startColor = interpolateColor(fromColor: color1, toColor: color2, progress: cycleTime)
                endColor = interpolateColor(fromColor: color2, toColor: color3, progress: cycleTime)
            } else if cycleTime < 2.0 {
                let progress = cycleTime - 1.0
                startColor = interpolateColor(fromColor: color2, toColor: color3, progress: progress)
                endColor = interpolateColor(fromColor: color3, toColor: color1, progress: progress)
            } else {
                let progress = cycleTime - 2.0
                startColor = interpolateColor(fromColor: color3, toColor: color1, progress: progress)
                endColor = interpolateColor(fromColor: color1, toColor: color2, progress: progress)
            }

            // Create animated gradient
            let angle = 135.0 * (.pi / 180.0) + time * 0.1 // Rotate gradient over time
            let gradient = CIFilter.linearGradient()
            gradient.color0 = startColor
            gradient.color1 = endColor

            // Animate gradient position
            let centerX = renderWidth * 0.5 * scaleFactor
            let centerY = renderHeight * 0.5 * scaleFactor
            let radius = max(renderWidth, renderHeight) * scaleFactor

            gradient.point0 = CGPoint(
                x: centerX + cos(angle) * radius,
                y: centerY + sin(angle) * radius
            )
            gradient.point1 = CGPoint(
                x: centerX - cos(angle) * radius,
                y: centerY - sin(angle) * radius
            )

            image = gradient.outputImage ?? CIImage.empty()

            // Optional: Add blur for smoother gradient
            let blur = CIFilter.gaussianBlur()
            blur.inputImage = image
            blur.radius = 40
            image = blur.outputImage ?? image

            return image.cropped(to: CGRect(x: 0, y: 0,
                                            width: renderWidth * scaleFactor,
                                            height: renderHeight * scaleFactor))
        })

        MetalView(renderer: renderer)
            .onChange(of: userPrefersDarkTheme) { _,newValue in
                colorStyle = newValue ? .darkStyle : .lightStyle
            }
    }
}
