//
//  SendAddressCellViewModelTests.swift
//  brainwallet
//
//  Created by Kerry Washington on 30/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import XCTest
import Combine
@testable import brainwallet

final class SendAddressCellViewModelTests: XCTestCase {
    
    var viewModel: SendAddressCellViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        viewModel = SendAddressCellViewModel()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        cancellables = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        // Given & When
        let viewModel = SendAddressCellViewModel()
        
        // Then
        XCTAssertNotNil(viewModel)
        XCTAssertTrue(viewModel.addressString.isEmpty)
        XCTAssertNil(viewModel.shouldPasteAddress)
        XCTAssertNil(viewModel.shouldScanAddress)
    }
    
    func testInitialAddressStringIsEmpty() {
        // Given & When
        let viewModel = SendAddressCellViewModel()
        
        // Then
        XCTAssertEqual(viewModel.addressString, "")
    }
    
    func testInitialClosuresAreNil() {
        // Given & When
        let viewModel = SendAddressCellViewModel()
        
        // Then
        XCTAssertNil(viewModel.shouldPasteAddress)
        XCTAssertNil(viewModel.shouldScanAddress)
    }
    
    // MARK: - Published Property Tests
    
    func testAddressStringIsPublished() {
        // Given
        let expectation = XCTestExpectation(description: "AddressString published")
        var receivedValues: [String] = []
        
        // When
        viewModel.$addressString
            .sink { value in
                receivedValues.append(value)
                if receivedValues.count == 2 { // Initial value + changed value
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.addressString = "test-address"
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedValues.count, 2)
        XCTAssertEqual(receivedValues[0], "") // Initial value
        XCTAssertEqual(receivedValues[1], "test-address") // Changed value
    }
    
    func testAddressStringPublisherEmitsOnChange() {
        // Given
        let expectation = XCTestExpectation(description: "Publisher emits on change")
        let testAddress = "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"
        var publishedValue: String?
        
        // When
        viewModel.$addressString
            .dropFirst() // Skip initial empty value
            .sink { value in
                publishedValue = value
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.addressString = testAddress
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(publishedValue, testAddress)
    }
    
    func testMultipleAddressStringChangesArePublished() {
        // Given
        let expectation = XCTestExpectation(description: "Multiple changes published")
        expectation.expectedFulfillmentCount = 3
        let testAddresses = ["address1", "address2", "address3"]
        var publishedValues: [String] = []
        
        // When
        viewModel.$addressString
            .dropFirst() // Skip initial empty value
            .sink { value in
                publishedValues.append(value)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        testAddresses.forEach { address in
            viewModel.addressString = address
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(publishedValues, testAddresses)
    }
    
    // MARK: - Address String Property Tests
    
    func testAddressStringCanBeSet() {
        // Given
        let testAddress = "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh"
        
        // When
        viewModel.addressString = testAddress
        
        // Then
        XCTAssertEqual(viewModel.addressString, testAddress)
    }
    
    func testAddressStringCanBeEmpty() {
        // Given
        viewModel.addressString = "some-address"
        
        // When
        viewModel.addressString = ""
        
        // Then
        XCTAssertEqual(viewModel.addressString, "")
        XCTAssertTrue(viewModel.addressString.isEmpty)
    }
    
    func testAddressStringCanHandleSpecialCharacters() {
        // Given
        let specialAddress = "test@#$%^&*()_+-={}[]|\\:;\"'<>?,./"
        
        // When
        viewModel.addressString = specialAddress
        
        // Then
        XCTAssertEqual(viewModel.addressString, specialAddress)
    }
    
    func testAddressStringCanHandleUnicodeCharacters() {
        // Given
        let unicodeAddress = "тест地址🏠"
        
        // When
        viewModel.addressString = unicodeAddress
    }
}
