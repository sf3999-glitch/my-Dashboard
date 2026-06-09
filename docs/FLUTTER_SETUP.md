# AI House Planner — Flutter Setup Guide

This guide walks through setting up the Flutter development environment and running the AI House Planner mobile/web app on all supported platforms.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Install Flutter SDK](#install-flutter-sdk)
3. [Clone and Configure](#clone-and-configure)
4. [Android Setup](#android-setup)
5. [iOS Setup](#ios-setup)
6. [Web Setup](#web-setup)
7. [Firebase Configuration](#firebase-configuration)
8. [Environment Configuration](#environment-configuration)
9. [Running the App](#running-the-app)
10. [Build Commands](#build-commands)
11. [Release Builds](#release-builds)
12. [Troubleshooting](#troubleshooting)

---

## Prerequisites

| Tool            | Minimum Version | Install Link                                           |
|-----------------|-----------------|--------------------------------------------------------|
| Flutter SDK     | 3.19.0          | https://docs.flutter.dev/get-started/install          |
| Dart SDK        | 3.3.0           | (bundled with Flutter)                                 |
| Android Studio  | 2023.1+         | https://developer.android.com/studio                   |
| Xcode           | 15.0+ (macOS)   | Mac App Store                                          |
| VS Code         | Latest          | https://code.visualstudio.com (recommended editor)    |
| Node.js         | 20+             | https://nodejs.org (for backend during development)   |
| CocoaPods       | 1.14+ (macOS)   | `sudo gem install cocoapods`                           |

---

## Install Flutter SDK

### macOS / Linux

```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable ~/flutter

# Add to PATH (add this to ~/.zshrc or ~/.bashrc)
export PATH="$PATH:$HOME/flutter/bin"

# Apply
source ~/.zshrc

# Verify installation
flutter --version
flutter doctor
```

### Windows

1. Download the Flutter SDK zip from https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\flutter`
3. Add `C:\flutter\bin` to your `PATH` environment variable
4. Open a new PowerShell window and run `flutter doctor`

### Verify Installation

```bash
flutter doctor -v
```

Resolve any issues flagged by `flutter doctor` before proceeding. Common fixes:

- **Android toolchain**: Run `flutter doctor --android-licenses` and accept all licenses
- **Xcode**: Run `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
- **CocoaPods**: Run `sudo gem install cocoapods`

---

## Clone and Configure

```bash
# Clone the repository (if not already done)
git clone https://github.com/your-org/ai-house-planner.git
cd ai-house-planner/flutter_app

# Install Flutter dependencies
flutter pub get

# Verify everything is set up
flutter doctor
```

---

## Android Setup

### 1. Install Android Studio

Download from https://developer.android.com/studio and install with the **Android SDK**, **Android SDK Platform**, and **Android Virtual Device** components.

### 2. Configure SDK

Open Android Studio → SDK Manager and install:
- **Android SDK Platform 34** (Android 14)
- **Android SDK Build-Tools 34**
- **Android Emulator**
- **Intel x86 Emulator Accelerator (HAXM)**

### 3. Create an Emulator

Android Studio → Device Manager → Create Device:
- Select **Pixel 7** (or similar)
- System Image: **API 34 / Android 14 / x86_64**
- Click **Finish**

### 4. Configure `local.properties`

In `flutter_app/android/local.properties`, set:

```properties
sdk.dir=/Users/your-username/Library/Android/sdk
flutter.sdk=/Users/your-username/flutter
flutter.buildMode=debug
flutter.versionName=1.0.0
flutter.versionCode=1
```

### 5. Configure signing for release builds

Generate a keystore:

```bash
keytool -genkey -v \
  -keystore ~/houseplanner-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias houseplanner
```

Create `flutter_app/android/key.properties`:

```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=houseplanner
storeFile=/Users/your-username/houseplanner-release.jks
```

Update `flutter_app/android/app/build.gradle` to use the signing config:

```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

---

## iOS Setup

> iOS builds require a Mac running macOS 14+ with Xcode 15+.

### 1. Install Xcode

Install from the Mac App Store, then run:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### 2. Install CocoaPods

```bash
sudo gem install cocoapods
```

### 3. Install iOS dependencies

```bash
cd flutter_app/ios
pod install
cd ..
```

### 4. Open in Xcode

```bash
open ios/Runner.xcworkspace
```

In Xcode:
1. Select the **Runner** target → **Signing & Capabilities**
2. Set your **Team** (requires Apple Developer account, free tier works for simulators)
3. Update the **Bundle Identifier** to `ai.houseplanner.app` (or your custom identifier)

### 5. Create a Simulator

```bash
# List available simulators
xcrun simctl list devices

# Boot iPhone 15 simulator
xcrun simctl boot "iPhone 15 Pro"
open -a Simulator
```

---

## Web Setup

No additional tools are required for Flutter Web. Ensure you have Chrome installed.

```bash
# Enable web support (only needed once)
flutter config --enable-web

# Check that Chrome is detected
flutter devices
```

---

## Firebase Configuration

The app uses Firebase for Google Sign-In and optional push notifications.

### 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project: `AI House Planner`
3. Enable **Authentication** → **Sign-in method** → enable **Google**

### 2. Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### 3. Configure Firebase for your app

```bash
cd flutter_app

# This command adds google-services.json (Android) and
# GoogleService-Info.plist (iOS) automatically:
flutterfire configure \
  --project=your-firebase-project-id \
  --platforms=android,ios,web
```

This creates `lib/firebase_options.dart` which is used by `main.dart`.

### 4. Android: Place configuration file

`google-services.json` should be at `android/app/google-services.json`.

### 5. iOS: Place configuration file

`GoogleService-Info.plist` should be at `ios/Runner/GoogleService-Info.plist`.

> **Security:** Add `google-services.json` and `GoogleService-Info.plist` to `.gitignore`. They contain API keys that should not be committed publicly.

---

## Environment Configuration

The app reads its backend URL and other configuration from `lib/config/env.dart`.

### Development

```dart
// lib/config/env.dart
class Env {
  static const String apiBaseUrl = 'http://localhost:3000/api/v1';
  static const String appName = 'AI House Planner';
  static const bool debugMode = true;
}
```

### Production

Use `--dart-define` flags at build time to inject production values without modifying source code:

```bash
flutter build apk \
  --dart-define=API_BASE_URL=https://api.houseplanner.ai/api/v1 \
  --dart-define=DEBUG_MODE=false
```

Update `env.dart` to read from defines:

```dart
class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );
  static const bool debugMode = bool.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: true,
  );
}
```

---

## Running the App

### List available devices

```bash
flutter devices
```

Example output:
```
3 connected devices:
iPhone 15 Pro (mobile)   • ABCD1234 • ios            • iOS 17.2
sdk gphone64 (mobile)    • emulator-5554 • android  • Android 14
Chrome (web)             • chrome   • web-javascript • Google Chrome 122
```

### Run in debug mode

```bash
# Run on a specific device by ID
flutter run -d emulator-5554      # Android emulator
flutter run -d ABCD1234           # iOS simulator
flutter run -d chrome             # Web browser

# Run with hot reload (default for debug)
flutter run
```

### Hot Reload vs Hot Restart

| Action           | Shortcut | Behavior                                  |
|------------------|----------|-------------------------------------------|
| Hot Reload       | `r`      | Inject code changes, preserve state       |
| Hot Restart      | `R`      | Full restart, state is reset              |
| Quit             | `q`      | Stop the app                              |

---

## Build Commands

### Android

```bash
# Debug APK
flutter build apk --debug

# Release APK (single file)
flutter build apk --release

# Release AAB (recommended for Play Store)
flutter build appbundle --release

# Output location
ls build/app/outputs/flutter-apk/app-release.apk
ls build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
# Debug build (simulator only)
flutter build ios --debug --simulator

# Release build (requires code signing)
flutter build ios --release

# Create IPA for App Store
flutter build ipa --release
# IPA location: build/ios/ipa/AI House Planner.ipa
```

### Web

```bash
# Debug web build
flutter build web

# Release web build (minified, tree-shaken)
flutter build web --release --dart-define=API_BASE_URL=https://api.houseplanner.ai/api/v1

# Output location
ls build/web/
```

---

## Release Builds

### Publishing to Google Play Store

1. Build the release AAB:
   ```bash
   flutter build appbundle --release \
     --dart-define=API_BASE_URL=https://api.houseplanner.ai/api/v1
   ```
2. Go to [Google Play Console](https://play.google.com/console)
3. Create application → upload `app-release.aab`
4. Fill in store listing, screenshots, privacy policy
5. Submit for review (typically 3–7 days)

### Publishing to Apple App Store

1. Build the IPA:
   ```bash
   flutter build ipa --release \
     --dart-define=API_BASE_URL=https://api.houseplanner.ai/api/v1
   ```
2. Open Xcode → Product → Archive
3. In Organizer, select the archive → **Distribute App** → App Store Connect
4. Go to [App Store Connect](https://appstoreconnect.apple.com) and submit for review

### Deploying Web Build

```bash
flutter build web --release

# Copy to your web server, S3 bucket, or Firebase Hosting:
aws s3 sync build/web/ s3://houseplanner-web-app/ --delete

# Or Firebase Hosting:
firebase deploy --only hosting
```

---

## Troubleshooting

### `flutter doctor` issues

| Issue                         | Fix                                                               |
|-------------------------------|-------------------------------------------------------------------|
| Android licenses not accepted | `flutter doctor --android-licenses`                              |
| Xcode not found               | `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer` |
| CocoaPods not installed       | `sudo gem install cocoapods`                                      |
| Java version wrong            | Install JDK 17: `brew install openjdk@17`                        |

### Build errors

```bash
# Clear build cache
flutter clean
flutter pub get

# Reset iOS pods
cd ios && pod deintegrate && pod install && cd ..

# Invalidate Gradle caches (Android)
cd android && ./gradlew clean && cd ..
```

### Dependency conflicts

```bash
# Show dependency tree
flutter pub deps

# Upgrade all packages
flutter pub upgrade --major-versions
```

### Network calls failing in development

Ensure the backend is running at `http://localhost:3000` and the Android emulator uses `http://10.0.2.2:3000` (the special alias for host loopback from emulators):

```dart
// lib/config/env.dart
static String get apiBaseUrl {
  if (kDebugMode && Platform.isAndroid) {
    return 'http://10.0.2.2:3000/api/v1';
  }
  return const String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://localhost:3000/api/v1');
}
```

### iOS simulator network issues

Add the following to `ios/Runner/Info.plist` to allow HTTP in development:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

> Remove this before a production release. Use HTTPS in production.
