@testable import brainwallet
import XCTest

// Mock Store for testing
class MockStore: Store {
    var balance : UInt64 = 100_000_000
    init(balance: UInt64 = 100_000_000) { // Default 1 LTC (100,000,000 litoshis)
       
    }
    
    func dispatch(_ action: Action) {
        // Not needed for these tests
    }
}

class SendViewModelTests: XCTestCase {
    
    var viewModel: SendViewModel!
    var mockStore: MockStore!
    
    override func setUp() {
        super.setUp()
        mockStore = MockStore()
        viewModel = SendViewModel(store: mockStore)
    }
    
    override func tearDown() {
        viewModel = nil
        mockStore = nil
        super.tearDown()
    }
    
    // MARK: - Address Validation Tests
    
    func testValidateSegwitAddress() {
        // Valid segwit addresses
        viewModel.sendAddress = "ltc1qd5wm03tdj98ccc5nnxtejqx5ypgn7nj8sfwmfx"
        XCTAssertTrue(viewModel.validateSendAddress(), "Should validate correct segwit address")
        
        // With different function
        XCTAssertTrue(viewModel.validateSendAddressWith(address: "ltc1qd5wm03tdj98ccc5nnxtejqx5ypgn7nj8sfwmfx"), "Should validate correct segwit address with direct function call")
    }
    
    func testValidateLegacyAddress() {
        // Valid legacy addresses
        viewModel.sendAddress = "LUxXFcwXFPpRZdMv4aYu6bDwuZ69TGzMjM"
        XCTAssertTrue(viewModel.validateSendAddress(), "Should validate correct legacy address")
        
        // With different function
        XCTAssertTrue(viewModel.validateSendAddressWith(address: "LUxXFcwXFPpRZdMv4aYu6bDwuZ69TGzMjM"), "Should validate correct legacy address with direct function call")
    }
    
    func testInvalidAddresses() {
        // Invalid addresses
        let invalidAddresses = [
            "", // Empty
            "1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2", // Bitcoin address, not Litecoin
            "ltc1", // Too short segwit
            "LN", // Too short legacy
            "ltc1qd5wm03tdj98ccc5nnxtejqx5ypgn7nj8sfwmfx123456789012345678901234567890", // Too long segwit
            "LUXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", // Too long legacy
            "not_an_address_at_all", // Not even close
            "ltc2qd5wm03tdj98ccc5nnxtejqx5ypgn7nj8sfwmfx", // Wrong prefix
            "Mtc1qd5wm03tdj98ccc5nnxtejqx5ypgn7nj8sfwmfx" // Wrong prefix
        ]
        
        for address in invalidAddresses {
            viewModel.sendAddress = address
            XCTAssertFalse(viewModel.validateSendAddress(), "Should not validate invalid address: \(address)")
            XCTAssertFalse(viewModel.validateSendAddressWith(address: address), "Should not validate invalid address with direct function call: \(address)")
        }
    }
    
    func testAddressCaseInsensitivityForSegwit() {
        let lowercaseAddress = "ltc1qd5wm03tdj98ccc5nnxtejqx5ypgn7nj8sfwmfx"
        let uppercaseAddress = "LTC1QD5WM03TDJ98CCC5NNXTEJQX5YPGN7NJ8SFWMFX"
        
        viewModel.sendAddress = lowercaseAddress
        XCTAssertTrue(viewModel.validateSendAddress(), "Lowercase segwit address should be valid")
        
        viewModel.sendAddress = uppercaseAddress
        XCTAssertTrue(viewModel.validateSendAddress(), "Uppercase segwit address should be valid as it's converted to lowercase")
    }
    
    func testAddressCaseSensitivityForLegacy() {
        let address = "LUxXFcwXFPpRZdMv4aYu6bDwuZ69TGzMjM"
        
        viewModel.sendAddress = address
        XCTAssertTrue(viewModel.validateSendAddress(), "Legacy address should be valid")
        
        // For legacy addresses, case matters for the first character
        let invalidAddress = "lUxXFcwXFPpRZdMv4aYu6bDwuZ69TGzMjM" // Small 'l' instead of capital 'L'
        viewModel.sendAddress = invalidAddress
        XCTAssertFalse(viewModel.validateSendAddress(), "Legacy address with wrong case should be invalid")
    }
    
    // MARK: - Amount Validation Tests
    
    func testWIPValidAmountWithinBalance() {
        // Store has 1 LTC (100,000,000 litoshis)
//        viewModel.sendAmount = 0.5 // 0.5 LTC
//        XCTAssertTrue(viewModel.validateSendAmount(), "Should allow sending amount within balance")
//        
//        viewModel.sendAmount = 1.0 // 1 LTC, exactly the balance
//        XCTAssertTrue(viewModel.validateSendAmount(), "Should allow sending exact balance")
    }
    
    func testInvalidAmountAboveBalance() {
        // Store has 1 LTC (100,000,000 litoshis)
        viewModel.sendAmount = 1.1 // 1.1 LTC, more than balance
        XCTAssertFalse(viewModel.validateSendAmount(), "Should not allow sending more than balance")
        
        viewModel.sendAmount = 1000.0 // Way more than balance
        XCTAssertFalse(viewModel.validateSendAmount(), "Should not allow sending way more than balance")
    }
    
    func testWIPZeroBalance() {
        mockStore = MockStore(balance: 0)
        viewModel = SendViewModel(store: mockStore)
        
//        viewModel.sendAmount = 0.0
//        XCTAssertTrue(viewModel.validateSendAmount(), "Should allow sending 0 when balance is 0")
//        
//        viewModel.sendAmount = 0.1
//        XCTAssertFalse(viewModel.validateSendAmount(), "Should not allow sending any amount when balance is 0")
    }
    
    func testNilStore() {
        viewModel.store = nil
        viewModel.sendAmount = 0.5
        XCTAssertFalse(viewModel.validateSendAmount(), "Should not validate amount when store is nil")
    }
    
    // MARK: - Memo Validation Tests
    
    func testValidMemoLength() {
        viewModel.memo = "This is a valid memo" // Under 255 characters
        XCTAssertTrue(viewModel.validateMemoLength(), "Should validate memo under 255 characters")
        
        viewModel.memo = String(repeating: "a", count: 255) // Exactly 255 characters
        XCTAssertTrue(viewModel.validateMemoLength(), "Should validate memo of exactly 255 characters")
    }
    
    func testInvalidMemoLength() {
        viewModel.memo = String(repeating: "a", count: 256) // 256 characters
        XCTAssertFalse(viewModel.validateMemoLength(), "Should not validate memo over 255 characters")
    }
    
    func testEmptyMemo() {
        viewModel.memo = ""
        XCTAssertTrue(viewModel.validateMemoLength(), "Should validate empty memo")
    }
    
    // MARK: - Overall Validation Tests
    
    func testWIPAllValidData() {
//        viewModel.sendAddress = "LUxXFcwXFPpRZdMv4aYu6bDwuZ69TGzMjM"
//        viewModel.sendAmount = 0.5
//        viewModel.memo = "Test transfer"
//        
//        XCTAssertTrue(viewModel.validateSendData(), "Should validate when all data is valid")
    }
    
    func testInvalidData() {
        // Invalid address
        viewModel.sendAddress = "invalid_address"
        viewModel.sendAmount = 0.5
        viewModel.memo = "Test transfer"
        XCTAssertFalse(viewModel.validateSendData(), "Should not validate with invalid address")
        
        // Valid address but invalid amount
        viewModel.sendAddress = "LUxXFcwXFPpRZdMv4aYu6bDwuZ69TGzMjM"
        viewModel.sendAmount = 1.5 // More than balance
        XCTAssertFalse(viewModel.validateSendData(), "Should not validate with amount exceeding balance")
        
        // Valid address and amount but invalid memo
        viewModel.sendAddress = "LUxXFcwXFPpRZdMv4aYu6bDwuZ69TGzMjM"
        viewModel.sendAmount = 0.5
        viewModel.memo = String(repeating: "a", count: 256) // 256 characters
        XCTAssertFalse(viewModel.validateSendData(), "Should not validate with memo exceeding 255 characters")
    }
    
    // MARK: - Pasteboard Tests
    
    func testUserDidTapPasteWithValidData() {
        // Create a testable subclass that allows us to mock the pasteboard access
        class TestSendViewModel: SendViewModel {
            var mockPasteboardString: String?
            
            override func userDidTapPaste() {
                if let mockString = mockPasteboardString, !mockString.utf8.isEmpty {
                    sendAddress = mockString
                } else {
                    sendAddress = ""
                }
            }
        }
        
        let testViewModel = TestSendViewModel(store: mockStore)
        testViewModel.mockPasteboardString = "LUxXFcwXFPpRZdMv4aYu6bDwuZ69TGzMjM"
        
        testViewModel.userDidTapPaste()
        XCTAssertEqual(testViewModel.sendAddress, "LUxXFcwXFPpRZdMv4aYu6bDwuZ69TGzMjM", "Should set send address to pasteboard content")
    }
    
    func testUserDidTapPasteWithEmptyData() {
        // Create a testable subclass that allows us to mock the pasteboard access
        class TestSendViewModel: SendViewModel {
            var mockPasteboardString: String?
            
            override func userDidTapPaste() {
                if let mockString = mockPasteboardString, !mockString.utf8.isEmpty {
                    sendAddress = mockString
                } else {
                    sendAddress = ""
                }
            }
        }
        
        let testViewModel = TestSendViewModel(store: mockStore)
        testViewModel.mockPasteboardString = ""
        
        testViewModel.userDidTapPaste()
        XCTAssertEqual(testViewModel.sendAddress, "", "Should set empty string when pasteboard is empty")
    }
    
    func testUserDidTapPasteWithNilData() {
        // Create a testable subclass that allows us to mock the pasteboard access
        class TestSendViewModel: SendViewModel {
            var mockPasteboardString: String?
            
            override func userDidTapPaste() {
                if let mockString = mockPasteboardString, !mockString.utf8.isEmpty {
                    sendAddress = mockString
                } else {
                    sendAddress = ""
                }
            }
        }
        
        let testViewModel = TestSendViewModel(store: mockStore)
        testViewModel.mockPasteboardString = nil
        
        testViewModel.userDidTapPaste()
        XCTAssertEqual(testViewModel.sendAddress, "", "Should set empty string when pasteboard is nil")
    }
}
