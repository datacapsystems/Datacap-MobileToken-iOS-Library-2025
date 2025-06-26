//
//  SwiftUIIntegration.swift
//  DatacapTokenLibrary Example
//
//  Demonstrates SwiftUI integration with DatacapTokenLibrary
//

import SwiftUI
import DatacapTokenLibrary

// MARK: - SwiftUI View Model
class TokenizationViewModel: ObservableObject {
    @Published var isShowingTokenUI = false
    @Published var tokenResult: String = ""
    @Published var errorMessage: String = ""
    @Published var isLoading = false
    
    private let tokenService: DatacapTokenService
    
    init(publicKey: String, isCertification: Bool = true) {
        self.tokenService = DatacapTokenService(publicKey: publicKey, isCertification: isCertification)
    }
    
    func tokenizeWithDirectAPI(cardNumber: String, expMonth: String, expYear: String, cvv: String) async {
        isLoading = true
        errorMessage = ""
        tokenResult = ""
        
        let cardData = CardData(
            cardNumber: cardNumber,
            expirationMonth: expMonth,
            expirationYear: expYear,
            cvv: cvv
        )
        
        do {
            let token = try await tokenService.generateTokenDirect(for: cardData)
            await MainActor.run {
                self.tokenResult = token.token
                self.isLoading = false
            }
        } catch let error as DatacapTokenError {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

// MARK: - SwiftUI Views
struct TokenizationView: View {
    @StateObject private var viewModel = TokenizationViewModel(publicKey: "demo")
    @State private var cardNumber = ""
    @State private var expMonth = ""
    @State private var expYear = ""
    @State private var cvv = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Card Information")) {
                    TextField("Card Number", text: $cardNumber)
                        .keyboardType(.numberPad)
                    
                    HStack {
                        TextField("MM", text: $expMonth)
                            .keyboardType(.numberPad)
                            .frame(width: 50)
                        
                        Text("/")
                        
                        TextField("YY", text: $expYear)
                            .keyboardType(.numberPad)
                            .frame(width: 50)
                        
                        Spacer()
                        
                        TextField("CVV", text: $cvv)
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                    }
                }
                
                Section {
                    Button("Use Built-in UI") {
                        viewModel.isShowingTokenUI = true
                    }
                    .foregroundColor(.blue)
                    
                    Button("Tokenize with Direct API") {
                        Task {
                            await viewModel.tokenizeWithDirectAPI(
                                cardNumber: cardNumber,
                                expMonth: expMonth,
                                expYear: expYear,
                                cvv: cvv
                            )
                        }
                    }
                    .foregroundColor(.green)
                    .disabled(viewModel.isLoading)
                }
                
                if viewModel.isLoading {
                    Section {
                        HStack {
                            ProgressView()
                            Text("Processing...")
                                .padding(.leading)
                        }
                    }
                }
                
                if !viewModel.tokenResult.isEmpty {
                    Section(header: Text("Token Result")) {
                        Text(viewModel.tokenResult)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.green)
                    }
                }
                
                if !viewModel.errorMessage.isEmpty {
                    Section(header: Text("Error")) {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Datacap Tokenization")
            .sheet(isPresented: $viewModel.isShowingTokenUI) {
                TokenUIWrapper(tokenService: viewModel.tokenService) { token in
                    viewModel.tokenResult = token.token
                } onError: { error in
                    viewModel.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - UIKit Bridge for Built-in UI
struct TokenUIWrapper: UIViewControllerRepresentable {
    let tokenService: DatacapTokenService
    let onSuccess: (DatacapToken) -> Void
    let onError: (DatacapTokenError) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        tokenService.delegate = context.coordinator
        
        // Present the token UI after a brief delay to ensure proper presentation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            tokenService.requestToken(from: viewController)
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No updates needed
    }
    
    class Coordinator: NSObject, DatacapTokenServiceDelegate {
        let parent: TokenUIWrapper
        
        init(_ parent: TokenUIWrapper) {
            self.parent = parent
        }
        
        func tokenRequestDidSucceed(_ token: DatacapToken) {
            parent.onSuccess(token)
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func tokenRequestDidFail(error: DatacapTokenError) {
            parent.onError(error)
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func tokenRequestDidCancel() {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - SwiftUI App Example
struct DatacapTokenApp: App {
    var body: some Scene {
        WindowGroup {
            TokenizationView()
        }
    }
}

// MARK: - SwiftUI Preview
struct TokenizationView_Previews: PreviewProvider {
    static var previews: some View {
        TokenizationView()
    }
}

// MARK: - Advanced SwiftUI Integration with Combine
import Combine

class AdvancedTokenViewModel: ObservableObject {
    @Published var cardNumber = ""
    @Published var isValidCard = false
    @Published var detectedCardType = "Unknown"
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Real-time card validation
        $cardNumber
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] number in
                let cleaned = number.replacingOccurrences(of: " ", with: "")
                self?.isValidCard = CardValidator.validateCardNumber(cleaned)
                self?.detectedCardType = CardValidator.detectCardType(cleaned)
            }
            .store(in: &cancellables)
    }
}

struct AdvancedTokenizationView: View {
    @StateObject private var viewModel = AdvancedTokenViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Card Number")
                .font(.headline)
            
            TextField("1234 5678 9012 3456", text: $viewModel.cardNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: viewModel.cardNumber) { newValue in
                    // Format as user types
                    let formatted = CardFormatter.formatCardNumber(
                        newValue,
                        cardType: viewModel.detectedCardType
                    )
                    if formatted != newValue {
                        viewModel.cardNumber = formatted
                    }
                }
            
            HStack {
                Label(viewModel.detectedCardType, systemImage: "creditcard")
                    .foregroundColor(.blue)
                
                Spacer()
                
                if viewModel.isValidCard {
                    Label("Valid", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
    }
}