//
//  DatacapTokenService.swift
//  DatacapTokenLibrary
//
//  Production-ready implementation of Datacap tokenization
//  
//  API Documentation:
//  - Certification endpoint: https://token-cert.dcap.com/v1/otu
//  - Production endpoint: https://token.dcap.com/v1/otu
//  - Method: POST with Authorization header containing token key
//
//  Integration Guide:
//  1. Add DatacapTokenLibrary to your project via SPM or CocoaPods
//  2. Initialize with your public key (token key)
//  3. Call requestToken() to show UI or generateTokenDirect() for custom UI
//  4. Handle delegate callbacks for success/failure
//
//  Version: 1.0.0
//  Copyright © 2025 Datacap Systems, Inc. All rights reserved.
//

import UIKit

// MARK: - Token Response Model
public struct DatacapToken {
    public let token: String
    public let maskedCardNumber: String
    public let cardType: String
    public let expirationDate: String
    public let responseCode: String
    public let responseMessage: String
    public let timestamp: Date
}

// MARK: - Token Delegate Protocol
public protocol DatacapTokenServiceDelegate: AnyObject {
    func tokenRequestDidSucceed(_ token: DatacapToken)
    func tokenRequestDidFail(error: DatacapTokenError)
    func tokenRequestDidCancel()
}

// MARK: - Error Types
public enum DatacapTokenError: LocalizedError {
    case invalidPublicKey
    case invalidCardNumber
    case invalidExpirationDate
    case invalidCVV
    case networkError(String)
    case tokenizationFailed(String)
    case userCancelled
    case missingAPIConfiguration
    
    public var errorDescription: String? {
        switch self {
        case .invalidPublicKey:
            return "Invalid public key provided"
        case .invalidCardNumber:
            return "Invalid card number"
        case .invalidExpirationDate:
            return "Invalid expiration date"
        case .invalidCVV:
            return "Invalid CVV"
        case .networkError(let message):
            return "Network error: \(message)"
        case .tokenizationFailed(let message):
            return "Tokenization failed: \(message)"
        case .userCancelled:
            return "User cancelled the operation"
        case .missingAPIConfiguration:
            return "API endpoint and key must be configured"
        }
    }
}

// MARK: - Main Service Class
public class DatacapTokenService {
    
    public weak var delegate: DatacapTokenServiceDelegate?
    private var publicKey: String
    private var isCertification: Bool
    
    /// Initialize the token service
    /// - Parameters:
    ///   - publicKey: Your Datacap API public key (token key)
    ///   - isCertification: true for certification environment, false for production
    public init(publicKey: String, isCertification: Bool = true) {
        self.publicKey = publicKey
        self.isCertification = isCertification
    }
    
    // MARK: - Public Methods
    
    /// Request a token by presenting the card input UI
    public func requestToken(from viewController: UIViewController) {
        // Validate configuration
        guard !publicKey.isEmpty else {
            delegate?.tokenRequestDidFail(error: .missingAPIConfiguration)
            return
        }
        
        let tokenViewController = DatacapTokenViewController()
        tokenViewController.delegate = self
        tokenViewController.modalPresentationStyle = .fullScreen
        viewController.present(tokenViewController, animated: true)
    }
    
    /// Generate a token directly without UI (for custom implementations)
    /// - Parameter cardData: Card information to tokenize
    /// - Returns: DatacapToken on success
    /// - Throws: DatacapTokenError on failure
    public func generateTokenDirect(for cardData: CardData) async throws -> DatacapToken {
        // Validate configuration
        guard !publicKey.isEmpty else {
            throw DatacapTokenError.missingAPIConfiguration
        }
        
        // Validate card data
        let cleanedNumber = cardData.cardNumber.replacingOccurrences(of: " ", with: "")
        guard CardValidator.validateCardNumber(cleanedNumber) else {
            throw DatacapTokenError.invalidCardNumber
        }
        
        // Generate token
        let token = await generateToken(for: cardData)
        
        // Check if token generation failed
        if token.responseCode != "00" && !token.responseCode.isEmpty {
            throw DatacapTokenError.tokenizationFailed(token.responseMessage)
        }
        
        return token
    }
    
    // MARK: - Private Methods
    
    private func generateToken(for cardData: CardData) async -> DatacapToken {
        // Check if we should use demo mode for testing
        if publicKey == "demo" {
            // Demo mode - generate a fake token
            let demoToken = "tok_demo_\(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(16))"
            return DatacapToken(
                token: demoToken,
                maskedCardNumber: CardFormatter.maskCardNumber(cardData.cardNumber),
                cardType: CardValidator.detectCardType(cardData.cardNumber),
                expirationDate: "\(cardData.expirationMonth)/\(cardData.expirationYear)",
                responseCode: "00",
                responseMessage: "Demo token generated successfully",
                timestamp: Date()
            )
        }
        
        // Datacap tokenization endpoints
        let endpoint = isCertification ? "https://token-cert.dcap.com/v1/otu" : "https://token.dcap.com/v1/otu"
        
        guard let url = URL(string: endpoint) else {
            return DatacapToken(
                token: "",
                maskedCardNumber: CardFormatter.maskCardNumber(cardData.cardNumber),
                cardType: CardValidator.detectCardType(cardData.cardNumber),
                expirationDate: "\(cardData.expirationMonth)/\(cardData.expirationYear)",
                responseCode: "999",
                responseMessage: "Invalid API endpoint: \(endpoint)",
                timestamp: Date()
            )
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(publicKey, forHTTPHeaderField: "Authorization")
        
        // Prepare request body
        let body: [String: Any] = [
            "Account": cardData.cardNumber.replacingOccurrences(of: " ", with: ""),
            "ExpirationMonth": cardData.expirationMonth,
            "ExpirationYear": cardData.expirationYear,
            "CVV": cardData.cvv
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw DatacapTokenError.networkError("Invalid response")
            }
            
            // Datacap tokenization returns 200 for success
            if httpResponse.statusCode == 200 {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    throw DatacapTokenError.tokenizationFailed("Invalid response format")
                }
                
                // Check for errors in response
                if let errors = json["Errors"] as? [String], !errors.isEmpty {
                    throw DatacapTokenError.tokenizationFailed(errors.joined(separator: ", "))
                }
                
                // Parse successful response
                guard let token = json["Token"] as? String, !token.isEmpty else {
                    throw DatacapTokenError.tokenizationFailed("No token in response")
                }
                
                let brand = json["Brand"] as? String ?? CardValidator.detectCardType(cardData.cardNumber)
                let last4 = json["Last4"] as? String ?? String(cardData.cardNumber.suffix(4).replacingOccurrences(of: " ", with: ""))
                
                return DatacapToken(
                    token: token,
                    maskedCardNumber: "**** \(last4)",
                    cardType: brand,
                    expirationDate: "\(cardData.expirationMonth)/\(cardData.expirationYear)",
                    responseCode: "00",
                    responseMessage: "Success",
                    timestamp: Date()
                )
            } else {
                // Handle error response
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let errors = json["Errors"] as? [String] {
                        throw DatacapTokenError.tokenizationFailed(errors.joined(separator: ", "))
                    }
                    if let message = json["Message"] as? String {
                        throw DatacapTokenError.tokenizationFailed(message)
                    }
                }
                throw DatacapTokenError.networkError("HTTP \(httpResponse.statusCode)")
            }
            
        } catch let error as DatacapTokenError {
            return DatacapToken(
                token: "",
                maskedCardNumber: CardFormatter.maskCardNumber(cardData.cardNumber),
                cardType: CardValidator.detectCardType(cardData.cardNumber),
                expirationDate: "\(cardData.expirationMonth)/\(cardData.expirationYear)",
                responseCode: "999",
                responseMessage: error.localizedDescription,
                timestamp: Date()
            )
        } catch {
            return DatacapToken(
                token: "",
                maskedCardNumber: CardFormatter.maskCardNumber(cardData.cardNumber),
                cardType: CardValidator.detectCardType(cardData.cardNumber),
                expirationDate: "\(cardData.expirationMonth)/\(cardData.expirationYear)",
                responseCode: "999",
                responseMessage: error.localizedDescription,
                timestamp: Date()
            )
        }
    }
}

// MARK: - Token View Controller Delegate
extension DatacapTokenService: DatacapTokenViewControllerDelegate {
    func tokenViewController(_ controller: DatacapTokenViewController, didCollectCardData cardData: CardData) {
        // Validate card data
        let cleanedNumber = cardData.cardNumber.replacingOccurrences(of: " ", with: "")
        
        guard CardValidator.validateCardNumber(cleanedNumber) else {
            controller.dismiss(animated: true) {
                self.delegate?.tokenRequestDidFail(error: .invalidCardNumber)
            }
            return
        }
        
        // Generate token asynchronously
        Task {
            let token = await generateToken(for: cardData)
            
            // Check if token generation failed
            if token.responseCode != "00" && !token.responseCode.isEmpty {
                await MainActor.run {
                    controller.dismiss(animated: true) {
                        let error = DatacapTokenError.tokenizationFailed(token.responseMessage)
                        self.delegate?.tokenRequestDidFail(error: error)
                    }
                }
                return
            }
            
            // Success - dismiss and notify delegate
            await MainActor.run {
                controller.dismiss(animated: true) {
                    self.delegate?.tokenRequestDidSucceed(token)
                }
            }
        }
    }
    
    func tokenViewControllerDidCancel(_ controller: DatacapTokenViewController) {
        controller.dismiss(animated: true) {
            self.delegate?.tokenRequestDidCancel()
        }
    }
}