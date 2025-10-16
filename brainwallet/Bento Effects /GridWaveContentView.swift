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
    func interpolateColor(from: CIColor, to: CIColor, progress: CGFloat) -> CIColor {
        let rColor = from.red + (to.red - from.red) * progress
        let gColor = from.green + (to.green - from.green) * progress
        let bColor = from.blue + (to.blue - from.blue) * progress
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
                startColor = interpolateColor(from: color1, to: color2, progress: cycleTime)
                endColor = interpolateColor(from: color2, to: color3, progress: cycleTime)
            } else if cycleTime < 2.0 {
                let progress = cycleTime - 1.0
                startColor = interpolateColor(from: color2, to: color3, progress: progress)
                endColor = interpolateColor(from: color3, to: color1, progress: progress)
            } else {
                let progress = cycleTime - 2.0
                startColor = interpolateColor(from: color3, to: color1, progress: progress)
                endColor = interpolateColor(from: color1, to: color2, progress: progress)
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

// Draft design
// [[ stitchable ]] half4 aurora(float2 position, float time) {
//    float2 uv = position / 1000.0;
//    
//    float wave1 = sin(uv.x * 3.0 + time * 0.5) * 0.5 + 0.5;
//    float wave2 = sin(uv.x * 2.0 - time * 0.3 + 1.0) * 0.5 + 0.5;
//    float wave3 = sin(uv.x * 4.0 + time * 0.7 + 2.0) * 0.5 + 0.5;
//    
//    float intensity = (wave1 + wave2 + wave3) / 3.0;
//    intensity *= smoothstep(0.8, 0.2, abs(uv.y - 0.3));
//    
//    half3 green = half3(0.2, 1.0, 0.4) * wave1;
//    half3 cyan = half3(0.3, 0.9, 1.0) * wave2;
//    half3 blue = half3(0.2, 0.4, 1.0) * wave3;
//    
//    half3 color = (green + cyan + blue) * intensity;
//    
//    return half4(color, intensity);
// }
