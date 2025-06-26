# Testing Guide for Datacap Mobile Token iOS Library

This guide provides comprehensive testing procedures to ensure the library is working perfectly for production use.

## Pre-Testing Requirements

- Xcode 13.0 or later
- iOS Simulator or physical device running iOS 13.0+
- Valid Datacap API keys (certification and/or production)
- Swift 5.0 or later

## 1. Build Verification

### Swift Package Manager Build
```bash
# Clean any existing build artifacts
rm -rf .build .swiftpm

# Build the library
swift build

# Build for specific platform
swift build -Xswiftc "-sdk" -Xswiftc "`xcrun --sdk iphonesimulator --show-sdk-path`" -Xswiftc "-target" -Xswiftc "x86_64-apple-ios13.0-simulator"
```

### Xcode Build
1. Open Package.swift in Xcode
2. Select "DatacapTokenLibrary" scheme
3. Build for iOS Simulator (⌘+B)
4. Verify no warnings or errors

## 2. Unit Tests

### Running Tests via Command Line
```bash
# Run all tests
swift test

# Run with verbose output
swift test --verbose

# Run specific test
swift test --filter DatacapTokenLibraryTests.testCardValidation
```

### Running Tests in Xcode
1. Open Package.swift in Xcode
2. Press ⌘+U to run all tests
3. Check Test Navigator for results

### Test Coverage Areas
- ✅ Card number validation (Luhn algorithm)
- ✅ Card type detection
- ✅ Card formatting
- ✅ Expiration date validation
- ✅ CVV validation
- ✅ Token generation (demo mode)
- ✅ Error handling

## 3. API Integration Testing

### Using the Test Script
```bash
# 1. Edit test-api.swift with your API keys
# 2. Run the test
./test-api.swift

# Expected output:
# ✅ SUCCESS for both certification and production
# Token, Brand, Last4, and Expiration displayed
```

### Manual API Testing
```swift
// Test with demo mode (no API calls)
let demoService = DatacapTokenService(publicKey: "demo", isCertification: true)

// Test with real API
let service = DatacapTokenService(publicKey: "YOUR_KEY", isCertification: true)
```

## 4. UI Component Testing

### Built-in UI Test
1. Create a test iOS app project
2. Add the library via SPM
3. Implement the following test code:

```swift
import UIKit
import DatacapTokenLibrary

class TestViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let service = DatacapTokenService(publicKey: "demo", isCertification: true)
        service.delegate = self
        service.requestToken(from: self)
    }
}

extension TestViewController: DatacapTokenServiceDelegate {
    func tokenRequestDidSucceed(_ token: DatacapToken) {
        print("✅ Token generated: \(token.token)")
    }
    
    func tokenRequestDidFail(error: DatacapTokenError) {
        print("❌ Error: \(error.localizedDescription)")
    }
    
    func tokenRequestDidCancel() {
        print("❌ User cancelled")
    }
}
```

### Test Cases for UI
- Enter valid test card: 4111111111111111
- Verify formatting: shows as "4111 1111 1111 1111"
- Test expiration: any future MM/YY
- Test CVV: any 3-4 digits
- Test cancel button functionality

## 5. Integration Testing

### Swift Package Manager Integration
```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/datacapsystems/Datacap-MobileToken-iOS-Library-2025.git", from: "1.0.0")
]
```

### Example App Testing
1. Navigate to Example/BasicIntegration
2. Open in Xcode
3. Build and run on simulator
4. Verify all functionality

## 6. Edge Case Testing

### Card Validation Edge Cases
- Empty card number
- Invalid card number (fails Luhn)
- Unsupported card types
- Expired dates
- Invalid CVV lengths

### Network Edge Cases
- No internet connection
- Timeout scenarios
- Invalid API keys
- Server errors

## 7. Performance Testing

### Memory Usage
- Monitor memory during tokenization
- Verify no memory leaks
- Check proper cleanup after use

### Response Times
- Measure API response times
- Verify UI responsiveness
- Test with slow network conditions

## 8. Security Testing

### Data Handling
- Verify no card data persistence
- Check memory clearing
- Validate secure transmission

### API Key Security
- Test with invalid keys
- Verify error messages don't leak info
- Check key rotation handling

## 9. Compatibility Testing

### iOS Versions
- iOS 13.0 (minimum)
- iOS 14.x
- iOS 15.x
- iOS 16.x
- iOS 17.x
- iOS 18.x (latest)

### Device Testing
- iPhone SE (smallest)
- iPhone 15 Pro Max (largest)
- iPad (various sizes)

## 10. Production Readiness Checklist

- [ ] All unit tests passing
- [ ] API integration verified (cert & prod)
- [ ] UI components working correctly
- [ ] No memory leaks detected
- [ ] Performance meets requirements
- [ ] Security best practices followed
- [ ] Documentation complete and accurate
- [ ] Example code runs without issues
- [ ] No compiler warnings
- [ ] Git repository clean and tagged

## Troubleshooting

### Common Issues

1. **Build Failures**
   - Clean derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`
   - Reset package cache: `swift package reset`

2. **API Errors**
   - Verify API key is correct
   - Check environment (cert vs prod)
   - Ensure internet connectivity

3. **UI Issues**
   - Verify iOS deployment target
   - Check simulator/device iOS version
   - Ensure proper view controller presentation

## Reporting Issues

If you encounter any issues:
1. Check this troubleshooting guide
2. Review the README documentation
3. Submit an issue at: https://github.com/datacapsystems/Datacap-MobileToken-iOS-Library-2025/issues

Include:
- Library version
- iOS version
- Device/Simulator info
- Steps to reproduce
- Error messages
- Sample code (if applicable)