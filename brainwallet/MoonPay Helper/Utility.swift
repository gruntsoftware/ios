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
    
    override init() {}
    let keySize = 2048
    func encryptMessageRSA2048(_ message: String) -> String {
        
        do {
            let pubkey = Partner.partnerKeyPath(name: .agentPubKey)
            var keyBytes: Data
                
                do {
                    guard let pemBytes = Data(base64Encoded: pubkey) else {
                        return "ERROR-CANNOT-KEYBYTES-DO-CONVERSION"
                    }
                    
                    guard let pemString = String(data: pemBytes, encoding: .utf8) else {
                        return "ERROR-CANNOT-KEYBYTES-DO-CONVERSION"
                    }
                    
                    let keyData = pemString
                        .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
                        .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
                        .replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
                    
                    guard let cleanKeyBytes = Data(base64Encoded: keyData) else {
                        return "ERROR-CANNOT-KEYBYTES-DO-CONVERSION"
                    }
                    keyBytes = cleanKeyBytes
                }
                
                let keyAttributes: [String: Any] = [
                    kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                    kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
                    kSecAttrKeySizeInBits as String: keySize
                ]
                
                var error: Unmanaged<CFError>?
                guard let publicKey = SecKeyCreateWithData(keyBytes as CFData, keyAttributes as CFDictionary, &error) else {
                    if let error = error?.takeRetainedValue() {
                        debugPrint("::: ERROR: Failed to create public key: \(error)")
                    }
                    return "ERROR-CANNOT-INVALID-PUBLIC-KEY-SPEC"
                }
                
                guard let messageData = message.data(using: .utf8) else {
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
                let encryptedDataSwift = encryptedData as Data
                return encryptedDataSwift.base64EncodedString()
            }
    }
}
