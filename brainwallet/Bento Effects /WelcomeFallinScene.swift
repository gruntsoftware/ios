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
import AVFAudio

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

    var boom: SKAudioNode!
    var baap: SKAudioNode!

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

        if let boomFile = Bundle.main.url(forResource: "215595__taira-komori__bomb", withExtension: "mp3"),
           let baapFile = Bundle.main.url(forResource: "807381__jean_filho__sci-fi-grenade-explosion", withExtension: "mp3") {
            baap = SKAudioNode(url: baapFile)
            boom = SKAudioNode(url: boomFile)
            baap.autoplayLooped = false
            boom.autoplayLooped = false
            baap.isPositional = false
            boom.isPositional = false
            addChild(baap)
            addChild(boom)
        }
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
                   explosion.fontSize = 70
                   explosion.physicsBody = SKPhysicsBody(circleOfRadius: 14.0)
                   explosion.physicsBody?.affectedByGravity = false
                   explosion.physicsBody?.isDynamic = true
                   explosion.physicsBody?.restitution = 0.8
                   explosion.physicsBody?.friction = 0.1
                   addChild(explosion)

                   let playAction = SKAction.play()
                   let volumeAction = SKAction.changeVolume(to: 0.06, duration: 0.2)
                   let boomOrBaap = Bool.random()
                   delay(0.1) {
                       boomOrBaap ? self.boom.run(SKAction.group([playAction, volumeAction])) :
                       self.baap.run(SKAction.group([playAction, volumeAction]))

                   explosion.removeFromParent()
                   self.counter += 1
                       label.removeFromParent()
                   }
                   break
               }
           }
    }

    private func buildScene() {

        background = SKSpriteNode(imageNamed: "welcome-bk")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.zPosition = -1
        addChild(background)
        addChild(boom)
        addChild(baap)
    }

    func startGame() {
        makeSprites()
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
            label.fontSize = 35
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
