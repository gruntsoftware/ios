//
//  FallinMojiDemoView.swift
//  brainwallet
//
//  Created by Kerry Washington on 31/01/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import SpriteKit
import SwiftUI

struct FallinMojiDemoView: View {

    var width: CGFloat = 0.0
    var height: CGFloat = 0.0

    init(width: CGFloat,
         height: CGFloat) { 
        self.height = height
        self.width = width
    }

    var scene: SKScene {
        let scene = FallinScene()
         scene.size = CGSize(width: width, height: height)
         scene.scaleMode = .fill
         scene.width = width
         scene.height = height
         scene.backgroundColor = .clear
         return scene
    }

    var body: some View {

        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                VStack {
                    SpriteView(scene: scene,
                               options: [.allowsTransparency])
                    .frame(width: 1.2 * width,
                           height: 1.2 * height)
                                       .clipped()
                                       .ignoresSafeArea()
                    Spacer()
                }
            }
        }
    }
}
