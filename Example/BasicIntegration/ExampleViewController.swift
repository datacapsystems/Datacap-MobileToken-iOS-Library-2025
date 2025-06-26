//
//  ExampleViewController.swift
//  DatacapTokenLibrary Example
//
//  This example demonstrates basic integration of the DatacapTokenLibrary
//

import UIKit
// When using the library via SPM or CocoaPods:
// import DatacapTokenLibrary

class ExampleViewController: UIViewController {
    
    // Initialize the token service
    private let tokenService = DatacapTokenService(
        publicKey: "demo", // Replace with your actual public key
        isCertification: true // Set to false for production
    )
    
    // UI Elements
    private let titleLabel = UILabel()
    private let tokenizeButton = UIButton(type: .system)
    private let customUIButton = UIButton(type: .system)
    private let resultTextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tokenService.delegate = self
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Title
        titleLabel.text = "DatacapTokenLibrary Example"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Tokenize with UI Button
        tokenizeButton.setTitle("Tokenize with Built-in UI", for: .normal)
        tokenizeButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        tokenizeButton.backgroundColor = .systemBlue
        tokenizeButton.setTitleColor(.white, for: .normal)
        tokenizeButton.layer.cornerRadius = 8
        tokenizeButton.translatesAutoresizingMaskIntoConstraints = false
        tokenizeButton.addTarget(self, action: #selector(tokenizeWithUI), for: .touchUpInside)
        view.addSubview(tokenizeButton)
        
        // Custom UI Button
        customUIButton.setTitle("Tokenize with Custom Data", for: .normal)
        customUIButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        customUIButton.backgroundColor = .systemGreen
        customUIButton.setTitleColor(.white, for: .normal)
        customUIButton.layer.cornerRadius = 8
        customUIButton.translatesAutoresizingMaskIntoConstraints = false
        customUIButton.addTarget(self, action: #selector(tokenizeWithCustomData), for: .touchUpInside)
        view.addSubview(customUIButton)
        
        // Result Text View
        resultTextView.isEditable = false
        resultTextView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        resultTextView.layer.borderColor = UIColor.systemGray4.cgColor
        resultTextView.layer.borderWidth = 1
        resultTextView.layer.cornerRadius = 8
        resultTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultTextView)
        
        // Layout
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tokenizeButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            tokenizeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tokenizeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tokenizeButton.heightAnchor.constraint(equalToConstant: 50),
            
            customUIButton.topAnchor.constraint(equalTo: tokenizeButton.bottomAnchor, constant: 20),
            customUIButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            customUIButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            customUIButton.heightAnchor.constraint(equalToConstant: 50),
            
            resultTextView.topAnchor.constraint(equalTo: customUIButton.bottomAnchor, constant: 40),
            resultTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resultTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func tokenizeWithUI() {
        logResult("Presenting tokenization UI...")
        tokenService.requestToken(from: self)
    }
    
    @objc private func tokenizeWithCustomData() {
        logResult("Tokenizing with test data...")
        
        Task {
            do {
                // Test card data - never use real card data in production
                let testCard = CardData(
                    cardNumber: "4111 1111 1111 1111",
                    expirationMonth: "12",
                    expirationYear: "25",
                    cvv: "123"
                )
                
                let token = try await tokenService.generateTokenDirect(for: testCard)
                
                await MainActor.run {
                    self.handleTokenSuccess(token)
                }
                
            } catch let error as DatacapTokenError {
                await MainActor.run {
                    self.handleTokenError(error)
                }
            } catch {
                await MainActor.run {
                    self.logResult("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func logResult(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logMessage = "[\(timestamp)] \(message)\n"
        resultTextView.text = (resultTextView.text ?? "") + logMessage
        
        // Auto-scroll to bottom
        if resultTextView.text.count > 0 {
            let bottom = NSMakeRange(resultTextView.text.count - 1, 1)
            resultTextView.scrollRangeToVisible(bottom)
        }
    }
    
    private func handleTokenSuccess(_ token: DatacapToken) {
        logResult("✅ Token Generated Successfully!")
        logResult("Token: \(token.token)")
        logResult("Card: \(token.maskedCardNumber) (\(token.cardType))")
        logResult("Expiry: \(token.expirationDate)")
        logResult("Response: \(token.responseCode) - \(token.responseMessage)")
        logResult("---")
    }
    
    private func handleTokenError(_ error: DatacapTokenError) {
        logResult("❌ Tokenization Failed!")
        logResult("Error: \(error.localizedDescription)")
        logResult("---")
    }
}

// MARK: - DatacapTokenServiceDelegate
extension ExampleViewController: DatacapTokenServiceDelegate {
    func tokenRequestDidSucceed(_ token: DatacapToken) {
        handleTokenSuccess(token)
    }
    
    func tokenRequestDidFail(error: DatacapTokenError) {
        handleTokenError(error)
    }
    
    func tokenRequestDidCancel() {
        logResult("User cancelled tokenization")
        logResult("---")
    }
}