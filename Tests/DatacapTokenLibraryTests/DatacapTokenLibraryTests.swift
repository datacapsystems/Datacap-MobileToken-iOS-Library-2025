//
//  DatacapTokenLibraryTests.swift
//  DatacapTokenLibraryTests
//
//  Copyright © 2025 Datacap Systems, Inc. All rights reserved.
//

import XCTest
@testable import DatacapTokenLibrary

final class DatacapTokenLibraryTests: XCTestCase {
    
    // MARK: - Card Validation Tests
    
    func testValidCardNumbers() {
        // Test valid card numbers
        XCTAssertTrue(CardValidator.validateCardNumber("4111111111111111")) // Visa
        XCTAssertTrue(CardValidator.validateCardNumber("5500000000000004")) // Mastercard
        XCTAssertTrue(CardValidator.validateCardNumber("340000000000009"))  // Amex
        XCTAssertTrue(CardValidator.validateCardNumber("6011000000000004")) // Discover
        XCTAssertTrue(CardValidator.validateCardNumber("3566002020360505")) // JCB
    }
    
    func testInvalidCardNumbers() {
        // Test invalid card numbers
        XCTAssertFalse(CardValidator.validateCardNumber("4111111111111112")) // Invalid Luhn
        XCTAssertFalse(CardValidator.validateCardNumber("1234567890123456")) // Invalid format
        XCTAssertFalse(CardValidator.validateCardNumber("411111111111"))     // Too short
        XCTAssertFalse(CardValidator.validateCardNumber(""))                 // Empty
        XCTAssertFalse(CardValidator.validateCardNumber("abcd"))             // Non-numeric
    }
    
    func testCardNumbersWithSpaces() {
        // Test that validator handles spaces correctly
        XCTAssertTrue(CardValidator.validateCardNumber("4111 1111 1111 1111"))
        XCTAssertTrue(CardValidator.validateCardNumber("5500 0000 0000 0004"))
    }
    
    // MARK: - Card Type Detection Tests
    
    func testCardTypeDetection() {
        XCTAssertEqual(CardValidator.detectCardType("4111111111111111"), "Visa")
        XCTAssertEqual(CardValidator.detectCardType("5500000000000004"), "Mastercard")
        XCTAssertEqual(CardValidator.detectCardType("2221000000000009"), "Mastercard")
        XCTAssertEqual(CardValidator.detectCardType("340000000000009"), "American Express")
        XCTAssertEqual(CardValidator.detectCardType("370000000000002"), "American Express")
        XCTAssertEqual(CardValidator.detectCardType("6011000000000004"), "Discover")
        XCTAssertEqual(CardValidator.detectCardType("6500000000000002"), "Discover")
        XCTAssertEqual(CardValidator.detectCardType("36000000000008"), "Diners Club")
        XCTAssertEqual(CardValidator.detectCardType("38000000000006"), "Diners Club")
        XCTAssertEqual(CardValidator.detectCardType("9999999999999999"), "Unknown")
    }
    
    func testCardTypeLengths() {
        XCTAssertEqual(CardValidator.maxLengthForCardType("Visa"), 16)
        XCTAssertEqual(CardValidator.maxLengthForCardType("Mastercard"), 16)
        XCTAssertEqual(CardValidator.maxLengthForCardType("American Express"), 15)
        XCTAssertEqual(CardValidator.maxLengthForCardType("Diners Club"), 14)
        XCTAssertEqual(CardValidator.maxLengthForCardType("Unknown"), 16)
    }
    
    func testCVVLengths() {
        XCTAssertEqual(CardValidator.cvvLengthForCardType("American Express"), 4)
        XCTAssertEqual(CardValidator.cvvLengthForCardType("Visa"), 3)
        XCTAssertEqual(CardValidator.cvvLengthForCardType("Mastercard"), 3)
        XCTAssertEqual(CardValidator.cvvLengthForCardType("Discover"), 3)
    }
    
    // MARK: - Card Formatting Tests
    
    func testCardNumberFormatting() {
        // Test Visa/Mastercard formatting (4-4-4-4)
        XCTAssertEqual(CardFormatter.formatCardNumber("4111111111111111"), "4111 1111 1111 1111")
        XCTAssertEqual(CardFormatter.formatCardNumber("5500000000000004"), "5500 0000 0000 0004")
        
        // Test American Express formatting (4-6-5)
        XCTAssertEqual(CardFormatter.formatCardNumber("340000000000009"), "3400 000000 00009")
        
        // Test Diners Club formatting (4-6-4)
        XCTAssertEqual(CardFormatter.formatCardNumber("36000000000008"), "3600 000000 0008")
        
        // Test partial numbers
        XCTAssertEqual(CardFormatter.formatCardNumber("4111"), "4111")
        XCTAssertEqual(CardFormatter.formatCardNumber("41111"), "4111 1")
    }
    
    func testCardNumberMasking() {
        XCTAssertEqual(CardFormatter.maskCardNumber("4111111111111111"), "**** **** **** 1111")
        XCTAssertEqual(CardFormatter.maskCardNumber("340000000000009"), "**** ****** *0009")
        XCTAssertEqual(CardFormatter.maskCardNumber("36000000000008"), "**** ****** 0008")
        
        // Test with spaces
        XCTAssertEqual(CardFormatter.maskCardNumber("4111 1111 1111 1111"), "**** **** **** 1111")
        
        // Test short numbers
        XCTAssertEqual(CardFormatter.maskCardNumber("411"), "411")
        XCTAssertEqual(CardFormatter.maskCardNumber(""), "")
    }
    
    // MARK: - Token Service Tests
    
    func testTokenServiceInitialization() {
        let service = DatacapTokenService(publicKey: "test_key", isCertification: true)
        XCTAssertNotNil(service)
    }
    
    func testDemoModeToken() async throws {
        let service = DatacapTokenService(publicKey: "demo", isCertification: true)
        
        let cardData = CardData(
            cardNumber: "4111111111111111",
            expirationMonth: "12",
            expirationYear: "25",
            cvv: "123"
        )
        
        let token = try await service.generateTokenDirect(for: cardData)
        
        XCTAssertTrue(token.token.hasPrefix("tok_demo_"))
        XCTAssertEqual(token.responseCode, "00")
        XCTAssertEqual(token.cardType, "Visa")
        XCTAssertEqual(token.maskedCardNumber, "**** **** **** 1111")
        XCTAssertEqual(token.expirationDate, "12/25")
    }
    
    func testInvalidCardNumberError() async {
        let service = DatacapTokenService(publicKey: "test_key", isCertification: true)
        
        let cardData = CardData(
            cardNumber: "1234567890123456", // Invalid card number
            expirationMonth: "12",
            expirationYear: "25",
            cvv: "123"
        )
        
        do {
            _ = try await service.generateTokenDirect(for: cardData)
            XCTFail("Expected error for invalid card number")
        } catch let error as DatacapTokenError {
            if case .invalidCardNumber = error {
                // Success - expected error
            } else {
                XCTFail("Expected invalidCardNumber error, got: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testMissingAPIKeyError() async {
        let service = DatacapTokenService(publicKey: "", isCertification: true)
        
        let cardData = CardData(
            cardNumber: "4111111111111111",
            expirationMonth: "12",
            expirationYear: "25",
            cvv: "123"
        )
        
        do {
            _ = try await service.generateTokenDirect(for: cardData)
            XCTFail("Expected error for missing API key")
        } catch let error as DatacapTokenError {
            if case .missingAPIConfiguration = error {
                // Success - expected error
            } else {
                XCTFail("Expected missingAPIConfiguration error, got: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Model Tests
    
    func testCardDataInitialization() {
        let cardData = CardData(
            cardNumber: "4111111111111111",
            expirationMonth: "12",
            expirationYear: "25",
            cvv: "123"
        )
        
        XCTAssertEqual(cardData.cardNumber, "4111111111111111")
        XCTAssertEqual(cardData.expirationMonth, "12")
        XCTAssertEqual(cardData.expirationYear, "25")
        XCTAssertEqual(cardData.cvv, "123")
    }
}