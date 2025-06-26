//
//  CardFormatter.swift
//  DatacapTokenLibrary
//
//  Copyright © 2025 Datacap Systems, Inc. All rights reserved.
//

import Foundation

public enum CardFormatter {
    
    /// Mask card number showing only last 4 digits
    public static func maskCardNumber(_ number: String) -> String {
        let cleaned = number.replacingOccurrences(of: " ", with: "")
        guard cleaned.count >= 4 else { return number }
        
        let last4 = String(cleaned.suffix(4))
        let cardType = CardValidator.detectCardType(cleaned)
        
        // Format based on card type
        switch cardType {
        case "American Express":
            // **** ****** *1234
            return "**** ****** *\(last4)"
        case "Diners Club":
            // **** ****** 1234
            return "**** ****** \(last4)"
        default:
            // **** **** **** 1234
            return "**** **** **** \(last4)"
        }
    }
    
    /// Format card number with appropriate spacing
    public static func formatCardNumber(_ text: String, cardType: String? = nil) -> String {
        let cleaned = text.replacingOccurrences(of: " ", with: "")
        let detectedType = cardType ?? CardValidator.detectCardType(cleaned)
        var formatted = ""
        
        switch detectedType {
        case "American Express":
            // 4-6-5 format (15 digits)
            for (index, character) in cleaned.enumerated() {
                if index == 4 || index == 10 {
                    formatted += " "
                }
                formatted += String(character)
                if index >= 14 { break }
            }
        case "Diners Club":
            // 4-6-4 format (14 digits)
            for (index, character) in cleaned.enumerated() {
                if index == 4 || index == 10 {
                    formatted += " "
                }
                formatted += String(character)
                if index >= 13 { break }
            }
        default:
            // 4-4-4-4 format (16 digits)
            for (index, character) in cleaned.enumerated() {
                if index > 0 && index % 4 == 0 {
                    formatted += " "
                }
                formatted += String(character)
                if index >= 15 { break }
            }
        }
        
        return formatted
    }
}