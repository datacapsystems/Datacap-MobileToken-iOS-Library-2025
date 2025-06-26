#!/usr/bin/env swift

import Foundation

// DATACAP API TEST SCRIPT
// This script tests your Datacap API keys to ensure they're working correctly.
//
// USAGE:
// 1. Replace YOUR_CERT_KEY and YOUR_PROD_KEY below with your actual API keys
// 2. Run: ./test-api.swift
// 3. The script will test both environments and show the results
//
// IMPORTANT: Never commit this file with real API keys!

// ========== CONFIGURATION ==========
// Replace these with your actual API keys
let CERT_API_KEY = "REDACTED_TOKEN_KEY"  // Your certification API key
let PROD_API_KEY = "REDACTED_TOKEN_KEY"  // Your production API key

// Test card data (this is a valid test card number)
let TEST_CARD_NUMBER = "4111111111111111"
let TEST_EXP_MONTH = "12"
let TEST_EXP_YEAR = "25"
let TEST_CVV = "123"
// ==================================

// Test the Datacap API directly
class DatacapAPITest {
    let certURL = "https://token-cert.dcap.com/v1/otu"
    let prodURL = "https://token.dcap.com/v1/otu"
    
    func testTokenization(publicKey: String, isCertification: Bool) async {
        let url = isCertification ? certURL : prodURL
        let environment = isCertification ? "CERTIFICATION" : "PRODUCTION"
        
        print("\n🔄 Testing \(environment) environment...")
        print("URL: \(url)")
        print("Public Key: \(String(publicKey.prefix(8)))...")
        
        // Test card data
        let requestBody: [String: Any] = [
            "account": TEST_CARD_NUMBER,
            "expirationMonth": TEST_EXP_MONTH,
            "expirationYear": TEST_EXP_YEAR,
            "cvv": TEST_CVV
        ]
        
        do {
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(publicKey, forHTTPHeaderField: "Authorization")
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Response Status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("✅ SUCCESS!")
                        print("   Token: \(json["Token"] ?? "N/A")")
                        print("   Brand: \(json["Brand"] ?? "N/A")")
                        print("   Last4: \(json["Last4"] ?? "N/A")")
                        print("   Exp: \(json["ExpirationMonth"] ?? "")/\(json["ExpirationYear"] ?? "")")
                    }
                } else {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("❌ Error: \(responseString)")
                    }
                }
            }
        } catch {
            print("❌ Error: \(error)")
        }
    }
}

// Check if API keys are configured
if CERT_API_KEY == "YOUR_CERT_KEY" || PROD_API_KEY == "YOUR_PROD_KEY" {
    print("❌ ERROR: Please configure your API keys!")
    print("Edit this file and replace YOUR_CERT_KEY and YOUR_PROD_KEY with your actual keys.")
    print("\nTo get your API keys:")
    print("1. Log in to your Datacap merchant portal")
    print("2. Navigate to Settings > API Keys")
    print("3. Copy your certification and production keys")
    exit(1)
}

// Run tests
Task {
    let tester = DatacapAPITest()
    
    print("🔐 Datacap API Test Tool")
    print("========================")
    print("Test Card: \(TEST_CARD_NUMBER)")
    print("Expiration: \(TEST_EXP_MONTH)/\(TEST_EXP_YEAR)")
    
    // Test certification environment
    await tester.testTokenization(
        publicKey: CERT_API_KEY,
        isCertification: true
    )
    
    // Test production environment
    await tester.testTokenization(
        publicKey: PROD_API_KEY,
        isCertification: false
    )
    
    print("\n✅ API tests completed!")
    print("\nNOTE: If both tests succeeded, your API keys are properly configured.")
    print("You can now use these keys in your iOS application.")
    exit(0)
}

// Keep script running
RunLoop.main.run(until: Date(timeIntervalSinceNow: 5))
