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

    /// When true, every emoji drops in from the top edge at a random x and is removed
    /// after falling 90% of the scene height. SpriteKit's y-axis points up, so the top is y = size.height.
    var spawnsFromTop: Bool = false

    private let dotRadius: CGFloat = 15.0

    override func didMove(to _: SKView) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.affectedByGravity = true
        physicsBody?.density = 0.002
        makeDot()
    }

    override func update(_ currentTime: TimeInterval) {
        guard spawnsFromTop else { return }
        // Remove once a dot has fallen 99% of the scene (y points up), before it can reach the floor and bounce
        let removalY = size.height * 0.01
        children
            .filter { $0.position.y <= removalY }
            .forEach { $0.removeFromParent() }
    }

    func makeDot() {

        let emojiArray = ["😬","🇮🇹","😂", "😭","❤️","🤣","🔥",
                          "😍","🥺","🥰","🙏","✨","👀","👠",
                          "🍑","🌴","🖼️","🛀🏿","🍌","🧄","📻",
                          "🏖️","🎨", "💍", "🍋", "🧛🏻‍♀️", "📡"]
        let label = SKLabelNode(text: emojiArray.randomElement() ?? "")
            label.position = spawnPoint()
            label.physicsBody = SKPhysicsBody(circleOfRadius: dotRadius)
            label.physicsBody?.affectedByGravity = true
            label.physicsBody?.isDynamic = true
            label.physicsBody?.restitution = 0.5
            label.physicsBody?.friction = 0.01

         addChild(label)

        delay(2.0) { [weak self] in
            guard let self else { return }
            if self.children.count < 12 {
                self.makeDot()
            } else {
                self.removeAllChildren()
                self.makeDot()
            }

        }
    }

    private func spawnPoint() -> CGPoint {
        if spawnsFromTop {
            // Inset by the radius so the body starts inside the edge loop instead of overlapping it
            let x = CGFloat.random(in: dotRadius ... max(dotRadius, size.width - dotRadius))
            return CGPoint(x: x, y: size.height - dotRadius)
        }
        let randX = Double.random(in: 0 ... 1.0)
        let randY = Double.random(in: 0 ... 1.0)
        return CGPoint(x: (size.width / 2) * randX, y: size.height * randY)
    }
}
