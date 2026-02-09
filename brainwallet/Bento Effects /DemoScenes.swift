//
//  DemoScenes.swift
//  brainwallet
//
//  Created by Kerry Washington on 31/01/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI
import SpriteKit

class FallinScene: SKScene, SKPhysicsContactDelegate {

    var width: CGFloat = 0.0
    var height: CGFloat = 0.0

    override func didMove(to _: SKView) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.affectedByGravity = true
        physicsBody?.density = 0.002
        makeDot()
    }

    func makeDot() {
        let randX = Double.random(in: 0 ... 1.0)
        let randY = Double.random(in: 0 ... 1.0)

        let emojiArray = ["😬","🇮🇹","😂", "😭","❤️","🤣","🔥",
                          "😍","🥺","🥰","🙏","✨","👀","👠",
                          "🍑","🌴","🖼️","🛀🏿","🍌","🧄","📻",
                          "🏖️","🎨", "💍", "🍋", "🧛🏻‍♀️", "📡"]
        let label = SKLabelNode(text: emojiArray.randomElement() ?? "")
            label.position = CGPoint(x: (width / 2) * randX, y: height * randY)
            label.physicsBody = SKPhysicsBody(circleOfRadius: 15.0)
            label.physicsBody?.affectedByGravity = true
            label.physicsBody?.isDynamic = true
            label.physicsBody?.restitution = 0.5
            label.physicsBody?.friction = 0.01

         addChild(label)

        delay(2.0) {
            if self.children.count < 12 {
                self.makeDot()
            } else {
                self.removeAllChildren()
                self.makeDot()
            }

        }
    }
}
