//
//  DatacapTokenViewController.swift
//  DatacapTokenLibrary
//
//  Copyright © 2025 Datacap Systems, Inc. All rights reserved.
//

import UIKit

// MARK: - Token View Controller Protocol
protocol DatacapTokenViewControllerDelegate: AnyObject {
    func tokenViewController(_ controller: DatacapTokenViewController, didCollectCardData cardData: CardData)
    func tokenViewControllerDidCancel(_ controller: DatacapTokenViewController)
}

// MARK: - Token Input View Controller
class DatacapTokenViewController: UIViewController {
    
    weak var delegate: DatacapTokenViewControllerDelegate?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let cardNumberField = UITextField()
    private let expirationField = UITextField()
    private let expirationDatePicker = UIDatePicker()
    private let cvvField = UITextField()
    private let submitButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yy"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Enter Card Details"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Card Number Field
        cardNumberField.placeholder = "Card Number"
        cardNumberField.borderStyle = .roundedRect
        cardNumberField.keyboardType = .numberPad
        cardNumberField.delegate = self
        cardNumberField.translatesAutoresizingMaskIntoConstraints = false
        cardNumberField.addTarget(self, action: #selector(cardNumberChanged), for: .editingChanged)
        contentView.addSubview(cardNumberField)
        
        // Card type icon
        let cardTypeIcon = UIImageView()
        cardTypeIcon.translatesAutoresizingMaskIntoConstraints = false
        cardTypeIcon.contentMode = .scaleAspectFit
        cardTypeIcon.tag = 100
        cardNumberField.rightView = cardTypeIcon
        cardNumberField.rightViewMode = .always
        
        // Expiration Field
        expirationField.placeholder = "MM/YY"
        expirationField.borderStyle = .roundedRect
        expirationField.delegate = self
        expirationField.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup date picker
        expirationDatePicker.datePickerMode = .date
        expirationDatePicker.preferredDatePickerStyle = .wheels
        expirationDatePicker.minimumDate = Date()
        expirationDatePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        
        expirationField.inputView = expirationDatePicker
        
        // Add toolbar to date picker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissDatePicker))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexSpace, doneButton]
        expirationField.inputAccessoryView = toolbar
        
        contentView.addSubview(expirationField)
        
        // CVV Field
        cvvField.placeholder = "CVV"
        cvvField.borderStyle = .roundedRect
        cvvField.keyboardType = .numberPad
        cvvField.isSecureTextEntry = true
        cvvField.delegate = self
        cvvField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cvvField)
        
        // Submit Button
        submitButton.setTitle("Submit", for: .normal)
        submitButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        submitButton.backgroundColor = UIColor(red: 148/255, green: 26/255, blue: 37/255, alpha: 1.0)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 8
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        contentView.addSubview(submitButton)
        
        // Cancel Button
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        contentView.addSubview(cancelButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            cardNumberField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            cardNumberField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            cardNumberField.heightAnchor.constraint(equalToConstant: 50),
            
            expirationField.topAnchor.constraint(equalTo: cardNumberField.bottomAnchor, constant: 20),
            expirationField.heightAnchor.constraint(equalToConstant: 50),
            
            cvvField.topAnchor.constraint(equalTo: cardNumberField.bottomAnchor, constant: 20),
            cvvField.heightAnchor.constraint(equalToConstant: 50),
            
            submitButton.topAnchor.constraint(equalTo: expirationField.bottomAnchor, constant: 40),
            submitButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            
            cancelButton.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 16),
            cancelButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
        
        // Add device-specific width constraints
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad: Constrain form elements to a reasonable width
            let maxWidth: CGFloat = 600
            NSLayoutConstraint.activate([
                titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth),
                cardNumberField.widthAnchor.constraint(equalToConstant: maxWidth),
                submitButton.widthAnchor.constraint(equalToConstant: maxWidth),
                expirationField.leadingAnchor.constraint(equalTo: cardNumberField.leadingAnchor),
                expirationField.widthAnchor.constraint(equalToConstant: (maxWidth - 20) * 0.4),
                cvvField.trailingAnchor.constraint(equalTo: cardNumberField.trailingAnchor),
                cvvField.widthAnchor.constraint(equalToConstant: (maxWidth - 20) * 0.4)
            ])
        } else {
            // iPhone: Use full width with margins
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                cardNumberField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                cardNumberField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                submitButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                submitButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                expirationField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                expirationField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4, constant: -30),
                cvvField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                cvvField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4, constant: -30)
            ])
        }
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.scrollIndicatorInsets.bottom = keyboardHeight
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        scrollView.scrollIndicatorInsets.bottom = 0
    }
    
    @objc private func cardNumberChanged() {
        guard let text = cardNumberField.text else { return }
        
        // Detect card type and update icon
        let cardType = CardValidator.detectCardType(text.replacingOccurrences(of: " ", with: ""))
        updateCardTypeIcon(cardType)
        
        // Format the card number
        let formatted = CardFormatter.formatCardNumber(text, cardType: cardType)
        if formatted != text {
            cardNumberField.text = formatted
        }
    }
    
    private func updateCardTypeIcon(_ cardType: String) {
        guard let iconView = cardNumberField.rightView as? UIImageView else { return }
        
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        
        switch cardType {
        case "Visa":
            iconView.image = UIImage(systemName: "creditcard", withConfiguration: config)
            iconView.tintColor = .systemBlue
        case "Mastercard":
            iconView.image = UIImage(systemName: "creditcard", withConfiguration: config)
            iconView.tintColor = .systemOrange
        case "American Express":
            iconView.image = UIImage(systemName: "creditcard", withConfiguration: config)
            iconView.tintColor = .systemTeal
        case "Discover":
            iconView.image = UIImage(systemName: "creditcard", withConfiguration: config)
            iconView.tintColor = .systemPurple
        case "Diners Club":
            iconView.image = UIImage(systemName: "creditcard", withConfiguration: config)
            iconView.tintColor = .systemIndigo
        default:
            iconView.image = UIImage(systemName: "creditcard", withConfiguration: config)
            iconView.tintColor = .systemGray
        }
    }
    
    @objc private func datePickerChanged() {
        expirationField.text = dateFormatter.string(from: expirationDatePicker.date)
    }
    
    @objc private func dismissDatePicker() {
        expirationField.resignFirstResponder()
    }
    
    @objc private func submitTapped() {
        guard let cardNumber = cardNumberField.text, !cardNumber.isEmpty,
              let expiration = expirationField.text, !expiration.isEmpty,
              let cvv = cvvField.text, !cvv.isEmpty else {
            showAlert(title: "Missing Information", message: "Please fill in all fields")
            return
        }
        
        // Extract month and year
        let components = expiration.split(separator: "/")
        guard components.count == 2 else {
            showAlert(title: "Invalid Date", message: "Please select a valid expiration date")
            return
        }
        
        let cardData = CardData(
            cardNumber: cardNumber,
            expirationMonth: String(components[0]),
            expirationYear: String(components[1]),
            cvv: cvv
        )
        
        delegate?.tokenViewController(self, didCollectCardData: cardData)
    }
    
    @objc private func cancelTapped() {
        delegate?.tokenViewControllerDidCancel(self)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextField Delegate
extension DatacapTokenViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == cardNumberField {
            // Only allow numbers
            let allowedCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: " "))
            let characterSet = CharacterSet(charactersIn: string)
            if !allowedCharacters.isSuperset(of: characterSet) {
                return false
            }
            
            // Handle max length based on card type
            let currentText = textField.text ?? ""
            let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
            let cleaned = prospectiveText.replacingOccurrences(of: " ", with: "")
            
            let cardType = CardValidator.detectCardType(cleaned)
            let maxLength = CardValidator.maxLengthForCardType(cardType)
            
            return cleaned.count <= maxLength
        } else if textField == cvvField {
            // Only allow numbers for CVV
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            if !allowedCharacters.isSuperset(of: characterSet) {
                return false
            }
            
            // CVV length based on card type
            let currentText = textField.text ?? ""
            let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            let cardType = CardValidator.detectCardType(cardNumberField.text?.replacingOccurrences(of: " ", with: "") ?? "")
            let maxLength = CardValidator.cvvLengthForCardType(cardType)
            
            return prospectiveText.count <= maxLength
        }
        
        return true
    }
}