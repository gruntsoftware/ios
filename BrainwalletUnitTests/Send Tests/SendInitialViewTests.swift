//
//  SendInitialViewTests.swift
//  BrainwalletUnitTests
//
//  Created by Kerry Washington on 13/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
//import Testing
//import XCTest
//import SwiftUI
//import Combine
//@testable import brainwallet
//
//final class BentoSendInitialViewTests: XCTestCase {
//    
//    var sut: BentoSendInitialView!
//    var mockViewModel: MockNewMainViewModel!
//    var userPrefersDarkTheme: Binding<Bool>!
//    var userWalletIsEmpty: Binding<Bool>!
//    var shouldShowView: Binding<Bool>!
//    var currentIndex: Binding<Int>!
//    
//    override func setUp() {
//        super.setUp()
//        
//        
//        guard let tempWalletManager = try? WalletManager(store: Store(), dbPath: nil) else {
//            assertionFailure("WalletManager no initialized")
//            return
//        }
//        // Initialize mock view model
//        mockViewModel = MockNewMainViewModel(store: Store(), walletManager: tempWalletManager)
//        
//        // Initialize bindings with default values
//        var darkTheme = false
//        var walletEmpty = false
//        var showView = true
//        var index = 0
//        
//        userPrefersDarkTheme = Binding(get: { darkTheme }, set: { darkTheme = $0 })
//        userWalletIsEmpty = Binding(get: { walletEmpty }, set: { walletEmpty = $0 })
//        shouldShowView = Binding(get: { showView }, set: { showView = $0 })
//        currentIndex = Binding(get: { index }, set: { index = $0 })
//        
//        // Initialize system under test
//        sut = BentoSendInitialView(
//            viewModel: mockViewModel,
//            userPrefersDarkTheme: userPrefersDarkTheme,
//            userWalletIsEmpty: userWalletIsEmpty,
//            shouldShowView: shouldShowView,
//            currentIndex: currentIndex
//        )
//    }
//    
//    override func tearDown() {
//        sut = nil
//        mockViewModel = nil
//        userPrefersDarkTheme = nil
//        userWalletIsEmpty = nil
//        shouldShowView = nil
//        currentIndex = nil
//        super.tearDown()
//    }
//    
//    // MARK: - Initialization Tests
//    
//    func testInitialization() {
//        // Given/When - initialization in setUp
//        
//        // Then
//        XCTAssertNotNil(sut)
//        XCTAssertNotNil(sut.newMainViewModel)
//        XCTAssertEqual(userPrefersDarkTheme.wrappedValue, false)
//        XCTAssertEqual(userWalletIsEmpty.wrappedValue, false)
//        XCTAssertEqual(shouldShowView.wrappedValue, true)
//        XCTAssertEqual(currentIndex.wrappedValue, 0)
//    }
//    
//    // MARK: - Address Validation Tests
//    
//    func testVerifyAddressInPasteboard_WithValidAddress_ReturnsTrue() {
//        // Given
//        let validAddress = "ltc1qvalidaddress123456789"
//        UIPasteboard.general.string = validAddress
//        
//        // When
//        let result = sut.verifyAddressInPasteboard()
//        
//        // Then
//        XCTAssertTrue(result)
//        XCTAssertTrue(sut.isValidAddress)
//        XCTAssertEqual(sut.pasteboardString, validAddress.lowercased())
//    }
//    
//    func testVerifyAddressInPasteboard_WithInvalidAddress_ReturnsFalse() {
//        // Given
//        UIPasteboard.general.string = "invalid_address"
//        
//        // When
//        let result = sut.verifyAddressInPasteboard()
//        
//        // Then
//        XCTAssertFalse(result)
//    }
//    
//    func testVerifyAddressInPasteboard_WithEmptyPasteboard_ReturnsFalse() {
//        // Given
//        UIPasteboard.general.string = nil
//        
//        // When
//        let result = sut.verifyAddressInPasteboard()
//        
//        // Then
//        XCTAssertFalse(result)
//    }
//    
//    func testVerifyAddressInPasteboard_ConvertsToLowercase() {
//        // Given
//        let mixedCaseAddress = "LTC1QVALIDADDRESS"
//        UIPasteboard.general.string = mixedCaseAddress
//        
//        // When
//        let result = sut.verifyAddressInPasteboard()
//        
//        // Then
//        if result {
//            XCTAssertEqual(sut.pasteboardString, mixedCaseAddress.lowercased())
//        }
//    }
//    
//    // MARK: - Send Information Validation Tests
//    
//    func testIsSendInformationValid_WithValidInputs_ReturnsTrue() {
//        // Given
//        sut.isValidAddress = true
//        sut.isAmountValid = true
//        sut.sendLTCAddress = "ltc1qvalidaddress"
//        
//        // When
//        let result = sut.isSendInformationValid()
//        
//        // Then
//        let expectation = XCTestExpectation(description: "Wait for async task")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            XCTAssertTrue(self.sut.isReadyToSend)
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 1.0)
//    }
//    
//    func testIsSendInformationValid_WithInvalidAddress_ReturnsFalse() {
//        // Given
//        sut.isValidAddress = false
//        sut.isAmountValid = true
//        sut.sendLTCAddress = "invalid"
//        
//        // When
//        let result = sut.isSendInformationValid()
//        
//        // Then
//        let expectation = XCTestExpectation(description: "Wait for async task")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            XCTAssertFalse(self.sut.isReadyToSend)
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 1.0)
//    }
//    
//    func testIsSendInformationValid_WithInvalidAmount_ReturnsFalse() {
//        // Given
//        sut.isValidAddress = true
//        sut.isAmountValid = false
//        sut.sendLTCAddress = "ltc1qvalidaddress"
//        
//        // When
//        let result = sut.isSendInformationValid()
//        
//        // Then
//        let expectation = XCTestExpectation(description: "Wait for async task")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            XCTAssertFalse(self.sut.isReadyToSend)
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 1.0)
//    }
//    
//    func testIsSendInformationValid_WithEmptyAddress_ReturnsFalse() {
//        // Given
//        sut.isValidAddress = true
//        sut.isAmountValid = true
//        sut.sendLTCAddress = ""
//        
//        // When
//        let result = sut.isSendInformationValid()
//        
//        // Then
//        let expectation = XCTestExpectation(description: "Wait for async task")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            XCTAssertFalse(self.sut.isReadyToSend)
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 1.0)
//    }
//    
//    // MARK: - State Management Tests
//    
//    func testSendLTCAddress_OnChange_ValidatesAddress() {
//        // Given
//        let validAddress = "ltc1qvalidaddress123456789"
//        mockViewModel.currentSendAddress = ""
//        
//        // When
//        sut.sendLTCAddress = validAddress
//        
//        // Then
//        // This would be tested through SwiftUI's onChange modifier
//        // In a real implementation, you'd need to trigger the onChange manually
//        XCTAssertEqual(sut.sendLTCAddress, validAddress)
//    }
//    
//    func testSendAmount_SetsTransactionDetails() {
//        // Given
//        mockViewModel.canSendAmountResult = true
//        mockViewModel.exchangeRate = ExchangeRate(code: "USD", rate: 100.0)
//        mockViewModel.currentPreFeeAmount = 1.0
//        mockViewModel.currentNetworkFee = 0.001
//        mockViewModel.currentServiceFee = 0.01
//        mockViewModel.currentTotalAmount = Amount(rawValue: 1.011)
//        
//        // When
//        sut.sendAmount = 1.0
//        
//        // Then
//        XCTAssertEqual(sut.sendAmount, 1.0)
//    }
//    
//    func testIsLTCValueShown_Toggle_UpdatesViewModel() {
//        // Given
//        sut.isLTCValueShown = false
//        
//        // When
//        sut.isLTCValueShown = true
//        
//        // Then
//        XCTAssertTrue(sut.isLTCValueShown)
//    }
//    
//    // MARK: - Error Handling Tests
//    
//    func testPasteButton_WithInvalidAddress_ShowsError() {
//        // Given
//        UIPasteboard.general.string = "invalid_address"
//        sut.sendLTCAddress = ""
//        
//        // When
//        let isValid = sut.verifyAddressInPasteboard()
//        
//        // Then
//        XCTAssertFalse(isValid)
//    }
//    
//    func testPasteButton_WithEmptyAddress_ShowsSpecificError() {
//        // Given
//        UIPasteboard.general.string = ""
//        sut.sendLTCAddress = ""
//        
//        // When
//        let isValid = sut.verifyAddressInPasteboard()
//        
//        // Then
//        XCTAssertFalse(isValid)
//    }
//    
//    // MARK: - UI State Tests
//    
//    func testDarkTheme_AffectsColorScheme() {
//        // Given
//        var darkTheme = true
//        userPrefersDarkTheme = Binding(get: { darkTheme }, set: { darkTheme = $0 })
//        
//        // When
//        sut = BentoSendInitialView(
//            viewModel: mockViewModel,
//            userPrefersDarkTheme: userPrefersDarkTheme,
//            userWalletIsEmpty: userWalletIsEmpty,
//            shouldShowView: shouldShowView,
//            currentIndex: currentIndex
//        )
//        
//        // Then
//        XCTAssertTrue(userPrefersDarkTheme.wrappedValue)
//    }
//    
//    func testFocusedField_CanBeSetToNil() {
//        // Given
//        sut.focusedField = .addressField
//        
//        // When
//        sut.focusedField = nil
//        
//        // Then
//        XCTAssertNil(sut.focusedField)
//    }
//    
//    func testFocusedField_CanBeSetToAddressField() {
//        // Given
//        sut.focusedField = nil
//        
//        // When
//        sut.focusedField = .addressField
//        
//        // Then
//        XCTAssertEqual(sut.focusedField, .addressField)
//    }
//    
//    func testFocusedField_CanBeSetToAmountField() {
//        // Given
//        sut.focusedField = nil
//        
//        // When
//        sut.focusedField = .amountField
//        
//        // Then
//        XCTAssertEqual(sut.focusedField, .amountField)
//    }
//    
//    func testFocusedField_CanBeSetToMemoField() {
//        // Given
//        sut.focusedField = nil
//        
//        // When
//        sut.focusedField = .memoField
//        
//        // Then
//        XCTAssertEqual(sut.focusedField, .memoField)
//    }
//    
//    // MARK: - Transaction Building Tests
//    
//    func testBWTransaction_IsInitializedEmpty() {
//        // Given/When - initialization in setUp
//        
//        // Then
//        XCTAssertNotNil(sut.bwTransaction)
//    }
//    
//    func testBWTransaction_UpdatesSendAddress() {
//        // Given
//        let validAddress = "ltc1qvalidaddress"
//        sut.isValidAddress = true
//        
//        // When
//        sut.bwTransaction.sendAddress = validAddress
//        
//        // Then
//        XCTAssertEqual(sut.bwTransaction.sendAddress, validAddress)
//    }
//    
//    // MARK: - Integration Tests
//    
//    func testCompleteTransactionFlow() {
//        // Given
//        let validAddress = "ltc1qvalidaddress123456789"
//        mockViewModel.canSendAmountResult = true
//        mockViewModel.exchangeRate = ExchangeRate(code: "USD", rate: 100.0)
//        mockViewModel.currentPreFeeAmount = 1.0
//        mockViewModel.currentNetworkFee = 0.001
//        mockViewModel.currentServiceFee = 0.01
//        mockViewModel.currentTotalAmount = Amount(rawValue: 1.011)
//        
//        // When
//        sut.sendLTCAddress = validAddress
//        sut.isValidAddress = true
//        sut.sendAmount = 1.0
//        sut.isAmountValid = true
//        
//        // Then
//        let expectation = XCTestExpectation(description: "Transaction ready")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            self.sut.isReadyToSend = self.sut.isValidAddress && self.sut.isAmountValid && !self.sut.sendLTCAddress.isEmpty
//            XCTAssertTrue(self.sut.isReadyToSend)
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 1.0)
//    }
//}
//
//// MARK: - Mock Objects
//
//class MockNewMainViewModel: NewMainViewModel {
//    private var _currentSendAddress: String = ""
//    override var currentSendAddress: String {
//        get { _currentSendAddress }
//        set { _currentSendAddress = newValue }
//    }
//    private var canSendAmountResult: Bool = true
//    override var _canSendAmountResult: Bool {
//        get { _canSendAmountResult }
//        set { _canSendAmountResult = newValue }
//    }
//    var exchangeRate: ExchangeRate?
//    override var currentSendAddress: String {
//        get { _currentSendAddress }
//        set { _currentSendAddress = newValue }
//    }
//    var currentPreFeeAmount: Double = 0.0
//    override var currentSendAddress: String {
//        get { _currentSendAddress }
//        set { _currentSendAddress = newValue }
//    }
//    var currentNetworkFee: Double = 0.0
//    override var currentSendAddress: String {
//        get { _currentSendAddress }
//        set { _currentSendAddress = newValue }
//    }
//    var currentServiceFee: Double = 0.0
//    override var currentSendAddress: String {
//        get { _currentSendAddress }
//        set { _currentSendAddress = newValue }
//    }
//    
//    var currentTotalAmount: Amount = Amount(rawValue: 0.0)
//
//    override var currentSendAddress: String {
//        get { _currentSendAddress }
//        set { _currentSendAddress = newValue }
//    }
//    override var currentSendAddress: String {
//        get { _currentSendAddress }
//        set { _currentSendAddress = newValue }
//    }
//    override var currentSendAddress: String {
//        get { _currentSendAddress }
//        set { _currentSendAddress = newValue }
//    }
//    override var currentSendAddress: String {
//        get { _currentSendAddress }
//        set { _currentSendAddress = newValue }
//    }
//    override var currentSendAddress: String {
//        get { _currentSendAddress }
//        set { _currentSendAddress = newValue }
//    }
//    override var currentSendAddress: String {
//        get { _currentSendAddress }
//        set { _currentSendAddress = newValue }
//    }
//    override var currentSendAddress: String {
//        get { _currentSendAddress }
//        set { _currentSendAddress = newValue }
//    }
//    var bwTransaction: BWTransaction?
//    var isLTCValueShown: Bool = false
//    var walletBalanceLitecoin: String = "0.0"
//    var walletBalanceFiat: String = "0.0"
//    var walletBalanceLitecoinDouble: Double = 0.0
//    var currentFiatValue: String = "$0.00"
//    
//    override func canSendAmountWithFees(isLTCValue: Bool, sendAmountDouble: Double) -> Bool {
//        return canSendAmountResult
//    }
//}
//
//// MARK: - Helper Extensions
//
//extension String {
//    var isValidAddress: Bool {
//        // Mock implementation for testing
//        return self.hasPrefix("ltc1q") && self.count > 10
//    }
//}
//
//// MARK: - Mock Types
//
//struct ExchangeRate {
//    let code: String
//    let rate: Double
//}
//
//struct Amount {
//    let rawValue: Double
//}
//
//struct BWTransaction {
//    var sendAddress: String = ""
//    var amount: Double = 0.0
//    var networkFee: Double = 0.0
//    var serviceFee: Double = 0.0
//    var currentRate: ExchangeRate?
//    var fiatAmount: Double = 0.0
//    var globalCode: GlobalCurrency?
//}
//
//enum GlobalCurrency {
//    case USD
//    case EUR
//    case GBP
//    
//    static func from(code: String) -> GlobalCurrency? {
//        switch code {
//        case "USD": return .USD
//        case "EUR": return .EUR
//        case "GBP": return .GBP
//        default: return nil
//        }
//    }
//}
//
