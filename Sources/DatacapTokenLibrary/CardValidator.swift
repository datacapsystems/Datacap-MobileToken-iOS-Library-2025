//
//  CardValidator.swift
//  DatacapTokenLibrary
//
//  Copyright © 2025 Datacap Systems, Inc. All rights reserved.
//

import Foundation

public enum CardValidator {
    
    /// Validate card number using Luhn algorithm
    public static func validateCardNumber(_ number: String) -> Bool {
        let cleaned = number.replacingOccurrences(of: " ", with: "")
        guard cleaned.count >= 13 && cleaned.count <= 19 else { return false }
        
        // Luhn algorithm
        var sum = 0
        let reversedCharacters = cleaned.reversed().map { String($0) }
        for (idx, element) in reversedCharacters.enumerated() {
            guard let digit = Int(element) else { return false }
            switch (idx % 2 == 1, digit) {
            case (true, 9): sum += 9
            case (true, 0...8): sum += (digit * 2) % 9
            default: sum += digit
            }
        }
        return sum % 10 == 0
    }
    
    /// Detect card type from card number
    public static func detectCardType(_ number: String) -> String {
        let cleaned = number.replacingOccurrences(of: " ", with: "")
        
        if cleaned.hasPrefix("4") {
            return "Visa"
        } else if let prefix = Int(cleaned.prefix(2)), (51...55).contains(prefix) {
            return "Mastercard"
        } else if let prefix = Int(cleaned.prefix(4)), (2221...2720).contains(prefix) {
            return "Mastercard"
        } else if cleaned.hasPrefix("34") || cleaned.hasPrefix("37") {
            return "American Express"
        } else if cleaned.hasPrefix("6011") || cleaned.hasPrefix("65") {
            return "Discover"
        } else if let prefix = Int(cleaned.prefix(3)), (644...649).contains(prefix) {
            return "Discover"
        } else if cleaned.hasPrefix("36") || cleaned.hasPrefix("38") {
            return "Diners Club"
        } else if let prefix = Int(cleaned.prefix(3)), (300...305).contains(prefix) {
            return "Diners Club"
        }
        
        return "Unknown"
    }
    
    /// Get maximum card number length for card type
    public static func maxLengthForCardType(_ cardType: String) -> Int {
        switch cardType {
        case "American Express": return 15
        case "Diners Club": return 14
        default: return 16
        }
    }
    
    /// Get CVV length for card type
    public static func cvvLengthForCardType(_ cardType: String) -> Int {
        return cardType == "American Express" ? 4 : 3
    }
}