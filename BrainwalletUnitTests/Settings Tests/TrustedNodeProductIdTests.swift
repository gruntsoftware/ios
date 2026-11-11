//
//  TrustedNodeProductIdTests.swift
//  brainwallet
//
//  Guards against the 3.10.0 App Review rejection (Guideline 2.1(b)): the app constant and the
//  product list shipped in BrainwalletiOSPrivateGeneralPurpose drifted apart, so the Trusted
//  Node IAP was filtered out of the purchase sheet.
//

import XCTest
@testable import brainwallet
import BrainwalletiOSPrivateGeneralPurpose

class TrustedNodeProductIdTests: XCTestCase {

    /// Product id configured in App Store Connect for the Trusted Litecoin Node IAP.
    private let appStoreConnectTrustedNodeId = "com.gruntsoftware.brainwallet.trusted_ltc_node_2"

    private func bundledProductIds() throws -> [String: String] {
        let bundle = Bundle(for: StoreKitManager.self)
        let url = try XCTUnwrap(bundle.url(forResource: "BWProductsList", withExtension: "plist"),
                                "BWProductsList.plist missing from the general-purpose bundle")
        let data = try Data(contentsOf: url)
        return try XCTUnwrap(try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String])
    }

    func testTrustedNodeConstantMatchesAppStoreConnect() {
        XCTAssertEqual(trustedLTCNodeProductId, appStoreConnectTrustedNodeId)
    }

    func testTrustedNodeConstantIsInBundledProductList() throws {
        let ids = try bundledProductIds()
        XCTAssertEqual(ids["Trusted LTC Node Feature"], trustedLTCNodeProductId,
                       "BWProductsList.plist and trustedLTCNodeProductId must use the same product id")
    }
}
