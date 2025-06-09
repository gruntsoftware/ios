//
//  SecurityCenterNavigationDelegate.swift
//  brainwallet
//
//  Created by Kerry Washington on 08/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import Foundation
import UIKit

class SecurityCenterNavigationDelegate: NSObject, UINavigationControllerDelegate {
    func navigationController(_ navigationController:
                              UINavigationController,
                              willShow viewController: UIViewController,
                              animated _: Bool) {
        guard let coordinator = navigationController
            .topViewController?
            .transitionCoordinator else { return }

        if coordinator.isInteractive {
            coordinator.notifyWhenInteractionChanges { context in
                if !context.isCancelled {
                    self.setStyle(navigationController: navigationController, viewController: viewController)
                }
            }
        } else {
            setStyle(navigationController: navigationController, viewController: viewController)
        }
    }

    func setStyle(navigationController: UINavigationController,
                  viewController: UIViewController) {
        if viewController is SecurityCenterViewController {
            navigationController.isNavigationBarHidden = true
        } else {
            navigationController.isNavigationBarHidden = false
        }

        if viewController is BiometricsSettingsViewController {
            navigationController.setWhiteStyle()
        } else {
            navigationController.setDefaultStyle()
        }
    }
}
