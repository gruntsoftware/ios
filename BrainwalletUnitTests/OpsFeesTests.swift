//
//  OpsFeesTests.swift
//  brainwallet
//
//  Created by Kerry Washington on 29/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

@testable import brainwallet
import XCTest

class OpsFeesTests: XCTestCase {

    override func setUpWithError() throws {
       
    }

    override func tearDownWithError() throws {
    }

    func testOpsFees() throws {
        let amountToSend1: UInt64 = 1_000_000
        XCTAssertTrue(Satoshis(rawValue: tieredOpsFee(amount: amountToSend1)) == 100_000 , "Ops fee output should be 100_000")
        let amountToSend2: UInt64 = 1_900_000
        XCTAssertTrue(Satoshis(rawValue: tieredOpsFee(amount: amountToSend2)) == 120_000 , "Ops fee output should be 120_000")
        let amountToSend3: UInt64 = 9_000_000
        XCTAssertTrue(Satoshis(rawValue: tieredOpsFee(amount: amountToSend3)) == 300_000 , "Ops fee output should be 300_000")
        let amountToSend4: UInt64 = 123_000_000
        XCTAssertTrue(Satoshis(rawValue: tieredOpsFee(amount: amountToSend4)) == 800_000 , "Ops fee output should be 800_000")
        let amountToSend5: UInt64 = 180_000_000
        XCTAssertTrue(Satoshis(rawValue: tieredOpsFee(amount: amountToSend5)) == 1_200_000 , "Ops fee output should be 1_200_000")
        let amountToSend6: UInt64 = 320_000_000
        XCTAssertTrue(Satoshis(rawValue: tieredOpsFee(amount: amountToSend6)) == 2_000_000 , "Ops fee output should be 2_000_000")
        let amountToSend7: UInt64 = 500_200_000_000
        XCTAssertTrue(Satoshis(rawValue: tieredOpsFee(amount: amountToSend7)) == 3_000_000 , "Ops fee output should be 3_000_000")
        let amountToSend8: UInt64 = 1_000_200_000_000
        XCTAssertTrue(Satoshis(rawValue: tieredOpsFee(amount: amountToSend8)) == 3_000_000 , "Ops fee output should be 2_000_000")
    }
 
}

