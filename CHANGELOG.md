# Changelog

All notable changes to the Datacap Mobile Token iOS Library will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Improved documentation and community files
- Contributing guidelines
- Code of Conduct
- Security policy
- GitHub Actions CI/CD workflows
- Privacy manifest for iOS 17+ compliance

## [1.0.0] - 2025-01-01

### Added
- Initial release of Datacap Mobile Token iOS Library
- Swift-native implementation replacing legacy Objective-C framework
- Built-in card entry UI with DatacapTokenViewController
- Direct tokenization API with async/await support
- Comprehensive card validation (Luhn algorithm, BIN detection)
- Support for major card types: Visa, Mastercard, American Express, Discover, Diners Club
- Real-time card number formatting
- Demo mode for development testing
- Swift Package Manager support
- Comprehensive unit test suite
- Example implementation project
- Full API documentation

### Security
- TLS 1.2+ enforcement for all API communications
- No persistence of sensitive card data
- Automatic memory clearing after tokenization
- Secure token-only responses

[Unreleased]: https://github.com/datacapsystems/Datacap-MobileToken-iOS-Library-2025/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/datacapsystems/Datacap-MobileToken-iOS-Library-2025/releases/tag/v1.0.0
EOF < /dev/null
