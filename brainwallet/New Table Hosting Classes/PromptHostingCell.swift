//
//  PromptHostingCell.swift
//  brainwallet
//
//  Created by Kerry Washington on 05/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI

final class PromptHostingCell<Content: View>: UITableViewCell {
    // MARK: - Private
    var didTapClose: (() -> Void)?
    
    var didTapContinue: (() -> Void)?
    
    var promptType: PromptType? = .recommendRescan
    
    var promptCellViewModel: PromptCellViewModel?
    
   
    
    private let hostingController = UIHostingController<Content?>(rootView: nil)
 
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        hostingController.view.backgroundColor = .clear
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        viewModelCallbacks()
    }
    
    func viewModelCallbacks() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .userTapsClosePromptNotification,
                                            object: nil,
                                            userInfo: nil)
            
            
            
        }
        
  
        
        NotificationCenter.default.post(name: .userTapsContinuePromptNotification,
                                        object: nil,
                                        userInfo: nil)
        
        guard let promptType = self.promptType else { return }
        promptCellViewModel = PromptCellViewModel(promptType: promptType)
    }
         
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(rootView: Content, parentController: UIViewController) {
        hostingController.rootView = rootView
        hostingController.view.invalidateIntrinsicContentSize()

        let requiresControllerMove = hostingController.parent != parentController
        if requiresControllerMove {
            parentController.addChild(hostingController)
        }

        if !contentView.subviews.contains(hostingController.view) {
            contentView.addSubview(hostingController.view)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        }

        if requiresControllerMove {
            hostingController.didMove(toParent: parentController)
        }
    } 
}
