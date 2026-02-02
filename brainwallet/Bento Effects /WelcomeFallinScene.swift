//
//  WelcomeFallinScene.swift
//  brainwallet
//
//  Created by Kerry Washington on 01/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import Foundation
import SwiftUI
import SpriteKit

class WelcomeFallinScene: SKScene, SKPhysicsContactDelegate {

    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    private var background: SKSpriteNode!

    @Binding
    var counter: Int

    @Binding
    var countdown: TimeInterval

    @Binding
    var didStartGame: Bool

    init(width: CGFloat,
         height: CGFloat,
         counter: Binding<Int>,
         countdown: Binding<TimeInterval>,
         didStartGame: Binding<Bool>) {
        self.width = width
        self.height = height
        _counter = counter
        _countdown = countdown
        _didStartGame = didStartGame

        super.init(size: CGSize(width: width, height: height))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to _: SKView) {

        physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        physicsWorld.speed = 0.9
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.affectedByGravity = true
        physicsBody?.density = 0.012
       // buildScene()
        startGame()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

           for node in touchedNodes {
               if let label = node as? SKLabelNode {
                   let explosion = SKLabelNode(text: "💥")
                   explosion.position = location
                   explosion.fontSize = 50
                   explosion.physicsBody = SKPhysicsBody(circleOfRadius: 14.0)
                   explosion.physicsBody?.affectedByGravity = false
                   explosion.physicsBody?.isDynamic = true
                   explosion.physicsBody?.restitution = 0.8
                   explosion.physicsBody?.friction = 0.1
                   addChild(explosion)

                   delay(0.3) {
                       self.playExplosion()
                       explosion.removeFromParent()
                       self.counter += 1
                       label.removeFromParent()
                   }

                   break
               }
           }
    }

    private func buildScene() {
        // let bumper = SKShapeNode(path: <#T##CGPath#>)

        background = SKSpriteNode(imageNamed: "welcome-bk")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.zPosition = -1
        addChild(background)

    }

    func startGame() {
        // buildScene()
        makeSprites()
    }

    private func playExplosion() {
        let soundArray = ["215595__taira-komori__bomb","807381__jean_filho__sci-fi-grenade-explosion"]
        SoundsHelper().play(filename: soundArray.randomElement() ?? "", type: "mp3")
    }

    func makeSprites() {
        let randX = Double.random(in: 0 ... 1.0)
        let randY = Double.random(in: 0 ... 1.0)

        let emojiFallArray = ["😬","🇮🇹","😂","😭","❤️","🤣","🔥","😍","🥺",
                       "🥰","🙏","✨","👀","👠","🍑","🌴","🖼️","🛀🏿",
                       "🍌","🧄","📻","🏖️","🎨","💍","🍋","🧛🏻‍♀️","📡",
                       "🌙","🎭","🦋","🌸","⚡","🎪","🍕","🎸","🌊",
                       "🦄","🍩","🎯","🌺","💫","🎲","🍉","🎬","🌈",
                       "🦊","🍓","🎹","🌻","💎","🦩","🍒","🎺","🌵",
                       "🐙","🎃"]
        let label = SKLabelNode(text: emojiFallArray.randomElement() ?? "")
            label.position = CGPoint(x: (width / 2) * randX, y: height)
            label.physicsBody = SKPhysicsBody(circleOfRadius: 14.0)
            label.physicsBody?.affectedByGravity = true
            label.physicsBody?.isDynamic = true
            label.physicsBody?.restitution = 0.8
            label.physicsBody?.friction = 0.1

         addChild(label)

        delay(1.0) {

            if self.countdown <= 0.0 {
                self.countdown = 30.0
                self.counter = 0
                self.removeAllChildren()
                self.didStartGame = false
            } else {
                self.countdown -= 1.0
                if self.children.count < 16 {
                    self.makeSprites()
                } else {

                    self.makeSprites()
                }
            }
        }
    }
}
