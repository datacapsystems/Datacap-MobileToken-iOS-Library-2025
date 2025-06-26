# Security Policy

## Supported Versions

We release patches for security vulnerabilities. Currently supported versions:

 < /dev/null |  Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

If you discover a security vulnerability, please report it by emailing:

**security@datacapsystems.com**

Please include the following information:

- Type of vulnerability (e.g., buffer overflow, SQL injection, cross-site scripting)
- Full paths of source file(s) related to the manifestation of the vulnerability
- Location of the affected source code (tag/branch/commit or direct URL)
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the vulnerability, including how an attacker might exploit it

## Response Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 5 business days
- **Resolution Timeline**: Based on severity
  - Critical: 7-14 days
  - High: 14-30 days
  - Medium: 30-60 days
  - Low: 60-90 days

## Security Best Practices

When using this library:

1. **API Key Management**
   - Never hardcode API keys in your source code
   - Use iOS Keychain for storing sensitive credentials
   - Rotate API keys regularly
   - Use separate keys for development and production

2. **Environment Configuration**
   - Always use production endpoints for live transactions
   - Ensure certification mode is disabled in production builds
   - Implement proper environment detection

3. **Network Security**
   - The library enforces TLS 1.2+ for all communications
   - Consider implementing certificate pinning for additional security
   - Monitor for suspicious network activity

4. **Data Handling**
   - Never log full card numbers or CVV codes
   - The library automatically clears sensitive data from memory
   - Implement rate limiting for tokenization requests
   - Sanitize all error messages shown to users

## Compliance

This library is designed to help reduce PCI DSS scope by:

- Never storing card data
- Transmitting data only to certified tokenization endpoints
- Returning only tokens, never raw card data
- Implementing secure coding practices

## Security Updates

Security updates will be released as:
- Patch versions for non-breaking security fixes
- Minor versions if security fixes require API changes

Monitor our releases page for security updates:
https://github.com/datacapsystems/Datacap-MobileToken-iOS-Library-2025/releases

## Contact

For urgent security matters, contact:
- Email: security@datacapsystems.com
- Support: support@datacapsystems.com

## Acknowledgments

We appreciate security researchers who responsibly disclose vulnerabilities. Acknowledgment will be given in release notes unless anonymity is requested.
