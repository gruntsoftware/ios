//
//  Utility.swift
//  brainwallet
//
//  Created by Kerry Washington on 08/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import Security

class Utility : NSObject {
    
    
    override init() {
        
    }
    
    func encryptMessageRSA2048(_ message: String) -> String {
        
        do {
            
            let pubkey = Partner.partnerKeyPath(name: .agentPubKey)
            var keyBytes: Data
                
                do {
                   
                    guard let pemBytes = Data(base64Encoded: pubkey) else {
                        debugPrint("::: ERROR: Invalid base64 public key format")
                        return "ERROR-CANNOT-KEYBYTES-DO-CONVERSION"
                    }
                    
                    guard let pemString = String(data: pemBytes, encoding: .utf8) else {
                        debugPrint("::: ERROR: Could not convert PEM bytes to string")
                        return "ERROR-CANNOT-KEYBYTES-DO-CONVERSION"
                    }
                    
                    let keyData = pemString
                        .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
                        .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
                        .replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
                    
                    guard let cleanKeyBytes = Data(base64Encoded: keyData) else {
                        debugPrint("::: ERROR: Invalid cleaned base64 key data")
                        return "ERROR-CANNOT-KEYBYTES-DO-CONVERSION"
                    }
                    
                    keyBytes = cleanKeyBytes
                    
                } catch let error {
                    debugPrint("::: ERROR: Invalid base64 public key format: \(error)")
                    return "ERROR-CANNOT-KEYBYTES-DO-CONVERSION"
                }
                
                let keyAttributes: [String: Any] = [
                    kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                    kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
                    kSecAttrKeySizeInBits as String: 2048
                ]
                
                var error: Unmanaged<CFError>?
                guard let publicKey = SecKeyCreateWithData(keyBytes as CFData, keyAttributes as CFDictionary, &error) else {
                    if let error = error?.takeRetainedValue() {
                        debugPrint("::: ERROR: Failed to create public key: \(error)")
                    }
                    return "ERROR-CANNOT-INVALID-PUBLIC-KEY-SPEC"
                }
                
                
                guard let messageData = message.data(using: .utf8) else {
                    debugPrint("::: ERROR: Could not convert message to data")
                    return "ERROR-MESSAGE-TO-DATA-CONVERSION"
                }
                
                var encryptError: Unmanaged<CFError>?
                guard let encryptedData = SecKeyCreateEncryptedData(
                    publicKey,
                    .rsaEncryptionPKCS1,
                    messageData as CFData,
                    &encryptError
                ) else {
                    if let encryptError = encryptError?.takeRetainedValue() {
                        let errorDescription = CFErrorCopyDescription(encryptError)
                        debugPrint("::: ERROR: Encryption failed: \(String(describing: errorDescription))")
                        
                        
                        let errorCode = CFErrorGetCode(encryptError)
                        switch errorCode {
                        case Int(errSecParam):
                            return "ERROR-ILLEGAL-BLOCK-SIZE"
                        default:
                            return "ERROR-BAD-PADDING-EXCEPTION"
                        }
                    }
                    return "ERROR-ENCRYPTION-FAILED"
                }
                
                // Convert encrypted data to base64 string
                let encryptedDataSwift = encryptedData as Data
                return encryptedDataSwift.base64EncodedString()
                
            } catch let error {
                // Catch any unexpected exceptions
                debugPrint("::: ERROR: Unexpected error during encryption: \(error)")
                return "ERROR-UNEXPECTED-DURING-ENCRYPTION"
            }
    }
    
}
