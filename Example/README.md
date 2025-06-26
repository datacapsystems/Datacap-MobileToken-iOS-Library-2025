# DatacapTokenLibrary Example

This example demonstrates how to integrate the DatacapTokenLibrary into your iOS application.

## Running the Example

1. Copy the library source files to your project or install via SPM/CocoaPods
2. Replace `"demo"` with your actual Datacap public key in `ExampleViewController.swift`
3. Build and run the project

## Features Demonstrated

- **Built-in UI**: Shows how to use the provided card entry UI
- **Custom Integration**: Demonstrates direct tokenization with your own UI
- **Error Handling**: Shows proper error handling patterns
- **Delegate Pattern**: Implements all delegate methods

## Important Notes

- The example uses "demo" mode which generates fake tokens
- Never use test card numbers in production
- Always use `isCertification: false` for production environments

## Code Structure

- `AppDelegate.swift`: Basic app setup
- `ExampleViewController.swift`: Main example implementation showing both UI modes