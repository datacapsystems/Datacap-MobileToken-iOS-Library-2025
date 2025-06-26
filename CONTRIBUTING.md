# Contributing to Datacap Mobile Token iOS Library

Thank you for your interest in contributing to the Datacap Mobile Token iOS Library! We welcome contributions from the community and are grateful for your support.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Process](#development-process)
- [Style Guidelines](#style-guidelines)
- [Commit Messages](#commit-messages)
- [Pull Request Process](#pull-request-process)
- [Reporting Issues](#reporting-issues)
- [Security Vulnerabilities](#security-vulnerabilities)

## Code of Conduct

This project adheres to our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to support@datacapsystems.com.

## Getting Started

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/Datacap-MobileToken-iOS-Library-2025.git
   cd Datacap-MobileToken-iOS-Library-2025
   ```
3. Add the upstream repository as a remote:
   ```bash
   git remote add upstream https://github.com/datacapsystems/Datacap-MobileToken-iOS-Library-2025.git
   ```
4. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## How to Contribute

### Types of Contributions

- **Bug Fixes**: Fix issues in the codebase
- **Features**: Add new functionality
- **Documentation**: Improve or add documentation
- **Tests**: Add or improve test coverage
- **Performance**: Optimize existing code
- **Examples**: Add or improve example implementations

### Before You Start

1. Check existing [issues](https://github.com/datacapsystems/Datacap-MobileToken-iOS-Library-2025/issues) and [pull requests](https://github.com/datacapsystems/Datacap-MobileToken-iOS-Library-2025/pulls)
2. For significant changes, open an issue first to discuss your proposal
3. Ensure your contribution aligns with the project's goals and architecture

## Development Process

### Environment Setup

1. **Xcode**: Version 13.0 or later
2. **Swift**: Version 5.0 or later
3. **iOS Deployment Target**: 13.0+

### Building the Library

```bash
# Using Swift Package Manager
swift build

# Run tests
swift test
```

### Testing Your Changes

1. Run all unit tests:
   ```bash
   swift test
   ```

2. Test the example application:
   ```bash
   cd Example
   open BasicIntegration.xcodeproj
   ```

3. Manual testing with demo mode:
   ```swift
   let service = DatacapTokenService(publicKey: "demo", isCertification: true)
   ```

## Style Guidelines

### Swift Code Style

We follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) with these specifics:

1. **Indentation**: 4 spaces (no tabs)
2. **Line Length**: 120 characters maximum
3. **Access Control**: Be explicit with access levels
4. **Documentation**: Use /// for public APIs
5. **Naming**: Clear, descriptive names following Swift conventions

Example:
```swift
/// Validates a payment card number using the Luhn algorithm
/// - Parameter cardNumber: The card number to validate
/// - Returns: True if the card number is valid
public static func validateCardNumber(_ cardNumber: String) -> Bool {
    // Implementation
}
```

### File Organization

- One type per file
- Group related functionality using extensions
- Order: Properties, Initializers, Public Methods, Private Methods

## Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Test additions or modifications
- `chore`: Maintenance tasks

### Examples
```
feat(validation): add support for Diners Club cards

- Added regex pattern for Diners Club
- Updated card type detection logic
- Added unit tests for new card type

Closes #123
```

## Pull Request Process

1. **Update Documentation**: Ensure README.md and other docs reflect your changes
2. **Add Tests**: Include unit tests for new functionality
3. **Run Tests**: Ensure all tests pass locally
4. **Update Changelog**: Add an entry to CHANGELOG.md
5. **Clean Commits**: Squash or organize commits logically
6. **PR Description**: Provide a clear description of changes

### PR Template

```markdown
## Description
Brief description of the changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Manual testing completed
- [ ] Example app tested

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] Changelog updated
```

## Reporting Issues

### Bug Reports

Include:
1. Library version
2. iOS version and device
3. Steps to reproduce
4. Expected vs actual behavior
5. Code samples (sanitized)
6. Error messages/logs

### Feature Requests

Include:
1. Use case description
2. Proposed solution
3. Alternative solutions considered
4. Impact on existing functionality

## Security Vulnerabilities

**Do not report security vulnerabilities through public issues.**

Please email security@datacapsystems.com with:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if available)

See our [Security Policy](SECURITY.md) for more details.

## Questions?

For questions about contributing, please:
1. Check existing documentation
2. Search closed issues
3. Contact support@datacapsystems.com

Thank you for contributing to the Datacap Mobile Token iOS Library!