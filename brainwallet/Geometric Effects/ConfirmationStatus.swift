//
//  ConfrtimationStatus.swift
//  brainwallet
//
//  Created by Kerry Washington on 4/26/26.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct ConfirmationStatus: View {
    var numberOfConfs: Int = 0
    
    private let initialStateColor = BrainwalletColor.info.opacity(0.6)
    private let medianStateColor  = BrainwalletColor.affirm.opacity(0.6)
    private let completeStateColor = BrainwalletColor.affirm
    
    private var filledColor: Color {
        switch numberOfConfs {
            case 3...4:          return medianStateColor
            case 5...:           return completeStateColor
            default:             return initialStateColor
        }
    }
    
    private var segmentColors: [Color] {
        let emptyColor = BrainwalletColor.info.opacity(0.1)
        let filled = min(max(numberOfConfs, 0), 6)
        return (0..<6).map { i in i < filled ? filledColor : emptyColor }
    }
    
    var body: some View {
        
        VStack {
            Canvas { context, size in
                let cx = size.width / 2
                let cy = size.height / 2
                let r  = size.width / 2 * 0.9
                
                let vertices: [CGPoint] = (0..<6).map { i in
                    let angle = Double(i) * 60.0 - 90.0  // degrees, top-centred
                    let radians = angle * .pi / 180.0
                    return CGPoint(
                        x: cx + r * cos(radians),
                        y: cy + r * sin(radians)
                    )
                }
                
                for i in 0..<6 {
                    let v    = vertices[i]
                    let next = vertices[(i + 1) % 6]
                    
                    var path = Path()
                    path.move(to: CGPoint(x: cx, y: cy))
                    path.addLine(to: v)
                    path.addLine(to: next)
                    path.closeSubpath()
                    
                    context.fill(path, with: .color(segmentColors[i]))
                    context.stroke(path, with: .color(.white.opacity(0.3)),
                                   lineWidth: 1)
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
    }
}
