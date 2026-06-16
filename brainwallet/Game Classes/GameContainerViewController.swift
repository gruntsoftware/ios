//
//  GameContainerViewController.swift
//  brainwallet
//
//  Created by Kerry Washington on 6/15/26.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import UIKit
#if !targetEnvironment(simulator)
import BWIOSGdx
#endif
final class GameContainerViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
#if !targetEnvironment(simulator)

    var bwGameSDK: BwGameSdk?
 
#endif

    init() {
        super.init(nibName: nil, bundle: nil)
        #if !targetEnvironment(simulator)
        bwGameSDK = appDelegate.applicationController.bwGameSDK
        bwGameSDK?.setGameEndListener(self)
        #endif
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// Source of truth for whether libGDX is foregrounded + rendering.
    var isGameActive: Bool = false {
        didSet {
#if !targetEnvironment(simulator)
            guard isGameActive != oldValue, bwGameSDK != nil else { return }
            
            if isGameActive {
                bwGameSDK?.showGame()  // makeKeyAndVisible + didBecomeActive (resume)
            } else {
                bwGameSDK?.hideGame()   // willResignActive (pause + glFinish) + host reclaims key
            }
#endif
        }
    }
    
    // Example toggle
    @objc func toggleGame() {
        isGameActive.toggle()
    }
    
    // Safety: if this VC leaves the screen, never leave libGDX rendering behind it.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isGameActive { isGameActive = false }
    }
}
extension GameContainerViewController: BwGameEndListener {
    func onGameEnded(_ dictionary: [AnyHashable: Any]) {
       appDelegate.applicationController.shouldHideGameSDK(dictionary: dictionary)
        
        
    }
}
