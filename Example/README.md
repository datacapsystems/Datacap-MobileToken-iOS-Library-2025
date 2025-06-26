# DatacapTokenLibrary Example

This directory contains minimal integration examples. For a complete production implementation, see our full demo app: [Datacap-MobileToken-iOS-2025](https://github.com/datacapsystems/Datacap-MobileToken-iOS-2025)

## Features Demonstrated

- UI-based card tokenization with built-in view controller
- Direct API tokenization with custom UI
- Proper error handling and validation
- Demo mode for testing without API calls
- Environment switching (certification/production)

## Running the Example

### Swift Package Manager
1. Open the example project in Xcode
2. The library is already linked via local package
3. Select a simulator or device
4. Build and run (⌘R)

### Manual Integration
1. Copy the library source files to your project
2. Replace `"demo"` with your actual Datacap public key
3. Build and run the project

## Key Integration Points

### Using the Built-in UI

```swift
let tokenService = DatacapTokenService(publicKey: "your-public-key")
tokenService.delegate = self

// Present the built-in card entry UI
tokenService.presentCardEntry(from: self)
```

### Direct Tokenization

```swift
let tokenService = DatacapTokenService(publicKey: "your-public-key")

Task {
    do {
        let token = try await tokenService.generateToken(
            cardNumber: "4111111111111111",
            expMonth: "12",
            expYear: "25",
            cvv: "123"
        )
        print("Token: \(token)")
    } catch {
        print("Error: \(error)")
    }
}
```

### Demo Mode

Use "demo" as the public key to test without making actual API calls:

```swift
let tokenService = DatacapTokenService(publicKey: "demo")
```

## Code Structure

- `ContentView.swift`: Main SwiftUI view with integration examples
- `ExampleViewController.swift`: UIKit example showing both UI modes
- `SettingsView.swift`: Configuration for environment switching

## Testing Cards

For demo mode, you can use any valid card number format:
- Visa: 4111111111111111
- Mastercard: 5555555555554444
- American Express: 378282246310005
- Discover: 6011111111111117

## Important Notes

- The example uses "demo" mode by default
- Never commit real API keys to source control
- Always validate cards before tokenization
- Use `isCertification: false` for production

## Additional Resources

- [Main Documentation](../README.md)
- [API Reference](https://datacapsystems.com/docs/api)
- [Support](mailto:support@datacapsystems.com)