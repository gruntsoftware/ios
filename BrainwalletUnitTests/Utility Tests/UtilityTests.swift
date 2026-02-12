//
//  UtilityTests.swift
//  BrainwalletUnitTests
//
//  Created by Kerry Washington on 11/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import XCTest
import Security
@testable import brainwallet
 
//
//class UtilityTests: XCTestCase {
//    
////    var sut: Utility!
////    
////    override func setUpWithError() throws {
////        try super.setUpWithError()
////        sut = Utility()
////    }
////    
////    override func tearDownWithError() throws {
////        sut = nil
////        try super.tearDownWithError()
////    }
//    
//    // MARK: - Helper Methods
//    
////    /// Generates a valid RSA 2048-bit key pair for testing
////    private func generateTestKeyPair() throws -> (publicKey: SecKey, privateKey: SecKey) {
////        let attributes: [String: Any] = [
////            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
////            kSecAttrKeySizeInBits as String: 2048
////        ]
////        
////        var error: Unmanaged<CFError>?
////        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
////            throw error!.takeRetainedValue() as Error
////        }
////        
////        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
////            throw NSError(domain: "TestError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to extract public key"])
////        }
////        
////        return (publicKey, privateKey)
////    }
////    
////    /// Converts a SecKey to PEM format string
////    private func secKeyToPEM(_ key: SecKey) throws -> String {
////        var error: Unmanaged<CFError>?
////        guard let keyData = SecKeyCopyExternalRepresentation(key, &error) as Data? else {
////            throw error!.takeRetainedValue() as Error
////        }
////        
////        let base64Key = keyData.base64EncodedString(options: [.lineLength64Characters, .endLineWithLineFeed])
////        return "-----BEGIN PUBLIC KEY-----\n\(base64Key)\n-----END PUBLIC KEY-----"
////    }
////    
////    /// Creates a mock Partner class for testing
////    private func mockPartnerKeyPath(pemString: String) -> String {
////        let pemData = pemString.data(using: .utf8)!
////        return pemData.base64EncodedString()
////    }
////    
////    // MARK: - Success Cases
////    
////    func testEncryptMessageRSA2048_ValidInput_ReturnsBase64String() throws {
////        // Given
////        let keyPair = try generateTestKeyPair()
////        let pemString = try secKeyToPEM(keyPair.publicKey)
////        let message = "Test message"
////        
////        // Mock Partner.partnerKeyPath - you'll need to implement this based on your Partner class
////        // This is a conceptual test showing what should be tested
////        
////        // When
////        let result = sut.encryptMessageRSA2048(message)
////        
////        // Then
////        XCTAssertFalse(result.hasPrefix("ERROR"), "Encryption should succeed for valid input")
////        XCTAssertNotNil(Data(base64Encoded: result), "Result should be valid base64 string")
////    }
////    
////    func testEncryptMessageRSA2048_EmptyMessage_EncryptsSuccessfully() throws {
////        // Given
////        let message = ""
////        
////        // When
////        let result = sut.encryptMessageRSA2048(message)
////        
////        // Then
////        // Empty messages should still encrypt successfully
////        XCTAssertFalse(result.hasPrefix("ERROR"), "Empty message should encrypt successfully")
////    }
////    
////    func testEncryptMessageRSA2048_ShortMessage_EncryptsSuccessfully() throws {
////        // Given
////        let message = "Hi"
////        
////        // When
////        let result = sut.encryptMessageRSA2048(message)
////        
////        // Then
////        XCTAssertFalse(result.hasPrefix("ERROR"), "Short message should encrypt successfully")
////    }
////    
////    func testEncryptMessageRSA2048_SpecialCharacters_EncryptsSuccessfully() throws {
////        // Given
////        let message = "Special chars: !@#$%^&*(){}[]|\\:;\"'<>,.?/~`"
////        
////        // When
////        let result = sut.encryptMessageRSA2048(message)
////        
////        // Then
////        XCTAssertFalse(result.hasPrefix("ERROR"), "Message with special characters should encrypt successfully")
////    }
////    
////    func testEncryptMessageRSA2048_UnicodeCharacters_EncryptsSuccessfully() throws {
////        // Given
////        let message = "Unicode: 你好世界 🌍 Привет мир"
////        
////        // When
////        let result = sut.encryptMessageRSA2048(message)
////        
////        // Then
////        XCTAssertFalse(result.hasPrefix("ERROR"), "Unicode message should encrypt successfully")
////    }
////    
////    func testEncryptMessageRSA2048_DifferentMessagesProduceDifferentCiphertext() throws {
////        // Given
////        let message1 = "Message 1"
////        let message2 = "Message 2"
////        
////        // When
////        let result1 = sut.encryptMessageRSA2048(message1)
////        let result2 = sut.encryptMessageRSA2048(message2)
////        
////        // Then
////        XCTAssertNotEqual(result1, result2, "Different messages should produce different ciphertext")
////    }
////    
////    func testEncryptMessageRSA2048_SameMessageProducesDifferentCiphertext() throws {
////        // Given
////        let message = "Same message"
////        
////        // When
////        let result1 = sut.encryptMessageRSA2048(message)
////        let result2 = sut.encryptMessageRSA2048(message)
////        
////        // Then
////        // RSA with PKCS1 padding includes randomness, so same plaintext should produce different ciphertext
////        XCTAssertNotEqual(result1, result2, "Same message encrypted twice should produce different ciphertext due to padding")
////    }
////    // MARK: - Error Cases - Message Size
////    
////    func testEncryptMessageRSA2048_MessageTooLarge_ReturnsIllegalBlockSizeError() throws {
////        // Given
////        // RSA 2048 with PKCS1 padding can encrypt max 245 bytes
////        let largeMessage = String(repeating: "A", count: 300)
////        
////        // When
////        let result = sut.encryptMessageRSA2048(largeMessage)
////        
////        // Then
////        XCTAssertEqual(result, "ERROR-ILLEGAL-BLOCK-SIZE", "Message too large for RSA 2048 should return block size error")
////    }
////    
////    func testEncryptMessageRSA2048_MessageAtMaxSize_EncryptsSuccessfully() throws {
////        // Given
////        // RSA 2048 with PKCS1 padding can encrypt max 245 bytes
////        let maxMessage = String(repeating: "A", count: 245)
////        
////        // When
////        let result = sut.encryptMessageRSA2048(maxMessage)
////        
////        // Then
////        XCTAssertFalse(result.hasPrefix("ERROR"), "Message at max size should encrypt successfully")
////    }
////    
////    func testEncryptMessageRSA2048_MessageJustOverMaxSize_ReturnsError() throws {
////        // Given
////        // Just 1 byte over the limit
////        let overMaxMessage = String(repeating: "A", count: 246)
////        
////        // When
////        let result = sut.encryptMessageRSA2048(overMaxMessage)
////        
////        // Then
////        XCTAssertEqual(result, "ERROR-ILLEGAL-BLOCK-SIZE", "Message just over max size should return block size error")
////    }
////    
////    // MARK: - Edge Cases
////    
////    func testEncryptMessageRSA2048_WhitespaceOnlyMessage_EncryptsSuccessfully() throws {
////        // Given
////        let message = "   \n\t  "
////        
////        // When
////        let result = sut.encryptMessageRSA2048(message)
////        
////        // Then
////        XCTAssertFalse(result.hasPrefix("ERROR"), "Whitespace-only message should encrypt successfully")
////    }
////    
////    func testEncryptMessageRSA2048_NewlineCharacters_EncryptsSuccessfully() throws {
////        // Given
////        let message = "Line 1\nLine 2\rLine 3\r\nLine 4"
////        
////        // When
////        let result = sut.encryptMessageRSA2048(message)
////        
////        // Then
////        XCTAssertFalse(result.hasPrefix("ERROR"), "Message with newlines should encrypt successfully")
////    }
////    
////    func testEncryptMessageRSA2048_BinaryData_EncryptsSuccessfully() throws {
////        // Given
////        let binaryData = Data([0x00, 0x01, 0x02, 0xFF, 0xFE])
////        let message = String(data: binaryData, encoding: .utf8) ?? ""
////        
////        // When
////        let result = sut.encryptMessageRSA2048(message)
////        
////        // Then
////        // This might fail if binary data can't be converted to UTF-8 string
////        // The test validates the behavior
////        if message.isEmpty {
////            XCTAssertEqual(result, "ERROR-MESSAGE-TO-DATA-CONVERSION")
////        } else {
////            XCTAssertFalse(result.hasPrefix("ERROR"))
////        }
////    }
////    
////    // MARK: - Integration Tests
////    
////    func testEncryptMessageRSA2048_EncryptedDataCanBeDecrypted() throws {
////        // Given
////        let keyPair = try generateTestKeyPair()
////        let message = "Integration test message"
////        
////        // This would require proper setup of Partner.partnerKeyPath
////        // When
////        let encrypted = sut.encryptMessageRSA2048(message)
////        
////        // Then - decrypt and verify
////        guard let encryptedData = Data(base64Encoded: encrypted) else {
////            XCTFail("Encrypted result should be valid base64")
////            return
////        }
////        
////        var error: Unmanaged<CFError>?
////        guard let decryptedData = SecKeyCreateDecryptedData(
////            keyPair.privateKey,
////            .rsaEncryptionPKCS1,
////            encryptedData as CFData,
////            &error
////        ) as Data? else {
////            XCTFail("Decryption should succeed")
////            return
////        }
////        
////        let decryptedMessage = String(data: decryptedData, encoding: .utf8)
////        XCTAssertEqual(decryptedMessage, message, "Decrypted message should match original")
////    }
////    
////    // MARK: - Performance Tests
////    
////    func testEncryptMessageRSA2048_Performance() {
////        // Given
////        let message = "Performance test message"
////        
////        // When/Then
////        measure {
////            _ = sut.encryptMessageRSA2048(message)
////        }
////    }
////    
////    func testEncryptMessageRSA2048_PerformanceWithLargeMessage() {
////        // Given
////        let message = String(repeating: "A", count: 200)
////        
////        // When/Then
////        measure {
////            _ = sut.encryptMessageRSA2048(message)
////        }
////    }
////    
////    // MARK: - Thread Safety Tests
////    
////    func testEncryptMessageRSA2048_ConcurrentCalls_ThreadSafe() throws {
////        // Given
////        let message = "Concurrent test"
////        let expectation = self.expectation(description: "Concurrent encryption")
////        expectation.expectedFulfillmentCount = 10
////        
////        // When
////        DispatchQueue.concurrentPerform(iterations: 10) { _ in
////            let result = self.sut.encryptMessageRSA2048(message)
////            XCTAssertFalse(result.hasPrefix("ERROR"), "Concurrent encryption should succeed")
////            expectation.fulfill()
////        }
////        
////        // Then
////        waitForExpectations(timeout: 5.0)
////    }
////    
////    // MARK: - Memory Tests
////    
////    func testEncryptMessageRSA2048_DoesNotLeakMemory() {
////        // Given
////        let message = "Memory test"
////        
////        // When
////        autoreleasepool {
////            for _ in 0..<1000 {
////                _ = sut.encryptMessageRSA2048(message)
////            }
////        }
////        
////        // Then
////        // Use Instruments or Memory Graph Debugger to verify no leaks
////        // This is a structural test to catch obvious leaks
////        XCTAssertNotNil(sut)
////    }
//}

// MARK: - Mock Partner Class for Testing

/// Mock implementation of Partner class for testing
/// Replace this with your actual Partner class or use a mocking framework
class PartnerMock {
    enum PartnerKey {
        case agentPubKey
    }
    
    static func partnerKeyPath(name: PartnerKey) -> String {
        // Return a base64-encoded PEM public key for testing
        // You'll need to generate a test key pair and provide the public key here
        return ""
    }
}
