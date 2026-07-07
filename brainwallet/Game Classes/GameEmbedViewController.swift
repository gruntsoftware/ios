//
//  GameEmbedViewController.swift
//  brainwallet
//
//  Created by Kerry Washington on 6/17/26.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
import UIKit

// MARK: -

struct GameEmbedView: UIViewControllerRepresentable {
    
    init( ) {
    }
    
    func makeUIViewController(context: Context) -> GameContainerViewController {
        let controller = GameContainerViewController()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: GameContainerViewController, context: Context) { }
}
