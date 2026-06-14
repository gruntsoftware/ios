//
//  GameContainerViewController.swift
//  brainwallet
//
//  Created by Kerry Washington on 6/15/26.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import UIKit

final class GameContainerViewController: UIViewController {
    
    /// Source of truth for whether libGDX is foregrounded + rendering.
//    var isGameActive: Bool = false {
////        didSet {
////            guard isGameActive != oldValue else { return }
////            if isGameActive {
////                IOSLauncher.showGame()   // makeKeyAndVisible + didBecomeActive (resume)
////            } else {
////                GdxEmbed.hideGame()   // willResignActive (pause + glFinish) + host reclaims key
////            }
////        }
//    }
//    
//    // Example toggle
//    @objc func toggleGame() {
//        isGameActive.toggle()
//    }
//    
//    // Safety: if this VC leaves the screen, never leave libGDX rendering behind it.
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        if isGameActive { isGameActive = false }
//    }
}
