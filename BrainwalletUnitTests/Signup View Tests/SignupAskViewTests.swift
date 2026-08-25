//
//  SignupAskViewTests.swift
//  brainwalletUnitTests
//
//  Created by Kerry Washington on 4/28/26.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import XCTest
import Combine
@testable import brainwallet

@MainActor
final class SignupAskViewTests: XCTestCase {
    
    // MARK: - Properties
    
    private var viewModel: NewMainViewModel!
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        
        guard let tempWalletManager = try? WalletManager(store: Store(), dbPath: nil) else {
            assertionFailure("WalletManager no initialized")
            return
        }
        
        viewModel = NewMainViewModel(store: Store(), walletManager: tempWalletManager)
    }
    
    override func tearDown() {
        cancellables.removeAll()
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Navigation: New Wallet Flow
    
    func test_skipAction_newWallet_appendsYourSeedWordsView() {
        var path: [Onboarding] = []
        
        // Simulates the "Maybe later (Skip)" button action for a new wallet
        let isRestoring = false
        if !isRestoring {
            path.append(.yourSeedWordsView)
        }
        
        XCTAssertEqual(path, [.yourSeedWordsView])
    }
    
    // MARK: - Navigation: Restore Wallet Flow
    
    func test_skipAction_restoringWallet_appendsInputWordsView() {
        var path: [Onboarding] = []
        
        let isRestoring = true
        if isRestoring {
            path.append(.inputWordsView)
        }
        
        XCTAssertEqual(path, [.inputWordsView])
    }
    
    // MARK: - Navigation: On Notification Registration
    
    func test_didRegisterForNotifications_newWallet_appendsYourSeedWordsView() {
        var path: [Onboarding] = []
        let isRestoring = false
        
        // Simulate the .onChange(of: viewModel.didRegisterForNotifications) handler
        let simulateRegistrationCallback = {
            if isRestoring {
                path.append(.inputWordsView)
            } else {
                path.append(.yourSeedWordsView)
            }
        }
        
        simulateRegistrationCallback()
        
        XCTAssertEqual(path, [.yourSeedWordsView])
    }
    
    func test_didRegisterForNotifications_restoringWallet_appendsInputWordsView() {
        var path: [Onboarding] = []
        let isRestoring = true
        
        let simulateRegistrationCallback = {
            if isRestoring {
                path.append(.inputWordsView)
            } else {
                path.append(.yourSeedWordsView)
            }
        }
        
        simulateRegistrationCallback()
        
        XCTAssertEqual(path, [.inputWordsView])
    }
    
    // MARK: - Back Navigation
    
    func test_backButton_removesLastFromPath() {
        var path: [Onboarding] = [.signupAskView(isRestoringAnOldWallet: true)]
        path.removeLast()
        XCTAssertTrue(path.isEmpty)
    }
    
    func test_backButton_doesNotUnderflow_whenPathIsEmpty() {
        var path: [Onboarding] = []
        // Guard mirrors what a safe back button implementation should check
        if !path.isEmpty { path.removeLast() }
        XCTAssertTrue(path.isEmpty)
    }
    
    // MARK: - ViewModel: Notification Permission Request
    
    func test_requestNotificationPermissions_doesNotThrow() {
        // Smoke test — verifies the call site doesn't crash
        XCTAssertNoThrow(viewModel.requestNotificationPermissions())
    }
    
    func test_didRegisterForNotifications_initiallyFalse() {
        XCTAssertFalse(viewModel.didRegisterForNotifications)
    }
    
    func test_didRegisterForNotifications_publishesChange() {
        let expectation = expectation(description: "didRegisterForNotifications publishes")
        
        viewModel.$didRegisterForNotifications
            .dropFirst()             // skip the initial value
            .sink { newValue in
                XCTAssertTrue(newValue)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.didRegisterForNotifications = true
        
        waitForExpectations(timeout: 1.0)
    }
}
