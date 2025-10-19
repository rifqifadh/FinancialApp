# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FinancialApp is a cross-platform SwiftUI application targeting iOS 26.0+ and macOS 26.0+. The app uses Supabase as a backend-as-a-service platform and integrates Google Sign-In for authentication.

## Build & Run Commands

### Building the App
```bash
# Debug build
xcodebuild -scheme FinancialApp -configuration Debug build

# Release build
xcodebuild -scheme FinancialApp -configuration Release build
```

### Running Tests
```bash
# iOS Simulator
xcodebuild -scheme FinancialApp -configuration Debug test -destination 'platform=iOS Simulator,name=iPhone 15'

# macOS
xcodebuild -scheme FinancialApp -configuration Debug test -destination 'platform=macOS'
```

### Cleaning Build Artifacts
```bash
xcodebuild -scheme FinancialApp clean
```

### Opening in Xcode
```bash
open FinancialApp.xcodeproj
```

### Listing Project Information
```bash
xcodebuild -list -project FinancialApp.xcodeproj
```

## Architecture

### Dependency Management

The project uses Swift Package Manager (SPM) for all dependencies. Dependencies are resolved via `Package.resolved` located at `FinancialApp.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`.

Key dependencies include:

- **Supabase Swift SDK** (v2.36.0): Provides Auth, Functions, PostgREST, Realtime, and Storage modules for backend integration
- **Point-Free Dependencies** (v1.10.0): Dependency injection framework used for managing app dependencies and enabling testable code
  - Includes: `Dependencies`, `DependenciesMacros`, and `DependenciesTestSupport`
- **GoogleSignIn-iOS** (v9.0.0): Google authentication integration
  - Includes: `GoogleSignIn` and `GoogleSignInSwift`

### Project Structure

- **FinancialAppApp.swift**: Main app entry point using `@main` attribute
- **ContentView.swift**: Root SwiftUI view
- **Assets.xcassets/**: Asset catalog containing app icons and color assets

### Configuration

- **Bundle Identifier**: `com.rifqifadh.FinancialApp`
- **Development Team**: UVT3R8TDBM
- **Minimum Deployment Targets**: iOS 26.0, macOS 26.0, visionOS 26.0
- **Supported Platforms**: iOS, iOS Simulator, macOS, visionOS, visionOS Simulator
- **Swift Version**: 5.0
- **Swift Concurrency**: Uses `MainActor` isolation by default
- **Build Configurations**: Debug and Release
- **App Sandbox**: Enabled on macOS with readonly user-selected files access
- **Hardened Runtime**: Enabled for macOS builds

### Architectural Patterns

This project appears to be following the Point-Free philosophy:
- Use the **Dependencies** library for dependency injection rather than singletons or environment objects
- Structure features as composable modules
- Write testable code by injecting dependencies through the `@Dependency` property wrapper

When integrating Supabase features, create dependency clients that wrap the Supabase SDK to enable testing and modularity.

## Key Implementation Details

### Supabase Integration

The Supabase client should be configured with your project URL and anonymous key. When implementing Supabase features:
- Import specific modules (e.g., `import Auth`, `import PostgREST`) rather than the entire Supabase package
- Configure the client in a dependency to allow for testing and environment-specific configurations

### Google Sign-In

Google Sign-In is available as a dependency. Implementation requires:
- Configuring the Google Client ID in the app's configuration
- Handling URL schemes for OAuth callbacks
- Integrating with Supabase Auth for session management
