//
//  GameHubViewModelEmojiTests.swift
//  BrainwalletUnitTests
//
//  Created by Kerry Washington on 10/24/26.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import XCTest
@testable import brainwallet

@MainActor
final class GameHubViewModelEmojiTests: XCTestCase {

    // Matches WalletSecAttrService and KeychainKey.emoji in WalletManager+Auth.swift
    private let service = "ltd.gruntsoftware.brainwallet"
    private let account = "emoji"

    private var walletManager: WalletManager!
    private var sut: GameHubViewModel!
    private var originalEmojiData: Data?

    override func setUp() {
        super.setUp()
        originalEmojiData = storedEmojiData()
        deleteStoredEmojis()
        walletManager = try! WalletManager(store: Store(), dbPath: nil)
        sut = GameHubViewModel(walletManager: walletManager)
    }

    override func tearDown() {
        deleteStoredEmojis()
        if let originalEmojiData {
            let item = [kSecClass as String: kSecClassGenericPassword as String,
                        kSecAttrService as String: service,
                        kSecAttrAccount as String: account,
                        kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String,
                        kSecValueData as String: originalEmojiData] as [String: Any]
            SecItemAdd(item as CFDictionary, nil)
        }
        sut = nil
        walletManager = nil
        super.tearDown()
    }

    // MARK: - Second Triplet

    func testSecondTripletAppendsToFirstAndKeepsEmojisSet() {
        XCTAssertTrue(sut.setFirstEmojiTriplet(first: "🍋", second: "🚀", third: "🐶"))
        sut.checkEmojiCount()
        XCTAssertTrue(sut.userEmojisAreSet)

        XCTAssertTrue(sut.setSecondEmojiTriplet(fourth: "🌙", fifth: "🎸", sixth: "🍕"))
        sut.checkEmojiCount()

        XCTAssertEqual(walletManager.emojiStringResult(), "🍋🚀🐶🌙🎸🍕")
        XCTAssertEqual(walletManager.emojiStringCount(), 6)
        XCTAssertTrue(sut.userEmojisAreSet)
    }

    func testSecondTripletRejectedBeforeFirstTriplet() {
        XCTAssertFalse(sut.setSecondEmojiTriplet(fourth: "🌙", fifth: "🎸", sixth: "🍕"))
        XCTAssertEqual(walletManager.emojiStringCount(), 0)
    }

    func testSecondTripletRejectedWhenAlreadySet() {
        XCTAssertTrue(sut.setFirstEmojiTriplet(first: "🍋", second: "🚀", third: "🐶"))
        XCTAssertTrue(sut.setSecondEmojiTriplet(fourth: "🌙", fifth: "🎸", sixth: "🍕"))

        XCTAssertFalse(sut.setSecondEmojiTriplet(fourth: "🌵", fifth: "🎈", sixth: "🧩"))
        XCTAssertEqual(walletManager.emojiStringCount(), 6)
    }

    func testSecondTripletRejectedWithEmptyEmoji() {
        XCTAssertTrue(sut.setFirstEmojiTriplet(first: "🍋", second: "🚀", third: "🐶"))

        XCTAssertFalse(sut.setSecondEmojiTriplet(fourth: "🌙", fifth: "", sixth: "🍕"))
        XCTAssertEqual(walletManager.emojiStringCount(), 3)
    }

    // MARK: - Helpers

    private func storedEmojiData() -> Data? {
        let query = [kSecClass as String: kSecClassGenericPassword as String,
                     kSecAttrService as String: service,
                     kSecAttrAccount as String: account,
                     kSecReturnData as String: true] as [String: Any]
        var result: CFTypeRef?
        SecItemCopyMatching(query as CFDictionary, &result)
        return result as? Data
    }

    private func deleteStoredEmojis() {
        let query = [kSecClass as String: kSecClassGenericPassword as String,
                     kSecAttrService as String: service,
                     kSecAttrAccount as String: account] as [String: Any]
        SecItemDelete(query as CFDictionary)
    }
}
