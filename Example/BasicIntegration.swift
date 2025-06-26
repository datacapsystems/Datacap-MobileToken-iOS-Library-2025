import UIKit
import DatacapTokenLibrary

// MARK: - Basic Integration Example
// This file demonstrates the minimal code needed to integrate DatacapTokenLibrary

class BasicIntegrationViewController: UIViewController {
    
    let tokenService = DatacapTokenService(publicKey: "demo") // Use your actual key in production
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tokenService.delegate = self
    }
    
    // MARK: - Option 1: Use Built-in UI
    @IBAction func showCardEntryUI() {
        tokenService.presentCardEntry(from: self)
    }
    
    // MARK: - Option 2: Direct Tokenization
    func tokenizeCard() {
        Task {
            do {
                let token = try await tokenService.generateToken(
                    cardNumber: "4111111111111111",
                    expMonth: "12",
                    expYear: "25",
                    cvv: "123"
                )
                print("Success! Token: \(token)")
            } catch {
                print("Error: \(error)")
            }
        }
    }
}

// MARK: - DatacapTokenServiceDelegate
extension BasicIntegrationViewController: DatacapTokenServiceDelegate {
    func tokenizationDidSucceed(token: String) {
        print("Tokenization succeeded: \(token)")
        // Send token to your server
    }
    
    func tokenizationDidFail(error: Error) {
        print("Tokenization failed: \(error)")
        // Handle error appropriately
    }
    
    func tokenizationDidCancel() {
        print("User cancelled tokenization")
    }
}