//
//  Models.swift
//  DatacapTokenLibrary
//
//  Copyright © 2025 Datacap Systems, Inc. All rights reserved.
//

import Foundation

// MARK: - Card Data Model
public struct CardData {
    public let cardNumber: String
    public let expirationMonth: String
    public let expirationYear: String
    public let cvv: String
    
    public init(cardNumber: String, expirationMonth: String, expirationYear: String, cvv: String) {
        self.cardNumber = cardNumber
        self.expirationMonth = expirationMonth
        self.expirationYear = expirationYear
        self.cvv = cvv
    }
}