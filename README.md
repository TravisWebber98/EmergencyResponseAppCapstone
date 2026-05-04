# Emergency Response App (Capstone)

Emergency Response App is a Flutter mobile application built for the ETAMU Computer Science Capstone (2026). The app provides a community-centered space for crisis communication, incident posting, and response coordination.

## Project Overview

This application combines:

- **Firebase Authentication** for account access and session handling.
- **Cloud Firestore** for online data storage and synchronization.
- **Isar local database** for on-device persistence/offline-friendly workflows.
- **Location services** for attaching incident locations to posts.
- **Image upload/select support** for richer post context.
- **Backup-server integration (PocketBase demo)** for alternate post import/sync workflows.

## Main Features

- Account registration/login and auth-gated app launch.
- Community feed and post workflows.
- Messaging, notifications, and profile management.
- Theme toggle (dark/light mode).
- Optional backup-server demo screen for fetching/importing backup posts.

## Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **Backend Services:** Firebase Auth + Firestore
- **Local Storage:** Isar (`isar_community`)
- **Networking:** `http`
- **Location:** `geolocator`, `geocoding`

---

## Environment Setup

### 1) Prerequisites

Install the following before running:

1. **Flutter SDK** (stable channel)
2. **Dart SDK** compatible with `pubspec.yaml` (`sdk: ^3.10.7`)
3. **Android Studio** (or another IDE) with:
   - Android SDK
   - Android platform tools
   - An emulator OR physical Android device
4. (Optional) **Xcode** for iOS builds on macOS
5. **Git**

Verify installation:

```powershell
flutter --version
dart --version
flutter doctor
```

### 2) Clone and open project

```powershell
git clone <your-repo-url>
cd emergency_response_app
```

### 3) Install dependencies

```powershell
flutter pub get
```

### 4) Firebase configuration notes

The app initializes Firebase in `lib/main.dart` using `lib/firebase_options.dart`.

- Android Firebase config is present at:
  - `android/app/google-services.json`
- If you use your own Firebase project (or need to run on other platforms), reconfigure with FlutterFire:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

Then ensure generated/required files are present for your target platforms.

### 5) Platform permissions

Location permissions are already declared in project files:

- Android: `android/app/src/main/AndroidManifest.xml`
- iOS: `ios/Runner/Info.plist`

When prompted at runtime, allow location access to use location-tagged posting.

---

## How to Run

### Quick start

1. Start an Android emulator (or connect a device).
2. From project root:

```powershell
flutter pub get
flutter run
```

3. Select the target device when prompted (if multiple are available).

### Useful run commands

```powershell
flutter devices
flutter run -d <deviceId>
flutter clean
flutter pub get
```

---

## Testing and Quality Checks

Run unit/widget tests:

```powershell
flutter test
```

Run static analysis:

```powershell
flutter analyze
```

---

## Optional: Backup Server Demo Notes

The backup demo service (`PocketBaseBackupService`) defaults to:

- `http://10.42.0.1:8090`

If you want to use the backup flow, make sure a reachable PocketBase instance is running at that address (or update the service URL in code).

---

## Project Structure (high-level)

```text
lib/
  core/
    services/        # Firebase/Isar/location/backup services
  features/
    auth/
    community/
    messaging/
    posts/
    backup_server/
  models/
  repositories/
test/
  features/community/
```

---

## Troubleshooting

- **`flutter doctor` reports issues**
  - Resolve all blocking issues before running.
- **Firebase init/auth errors**
  - Re-check Firebase config files and run `flutterfire configure` if needed.
- **No location available**
  - Enable device location services and grant app permission.
- **Build cache/dependency issues**
  - Run:

  ```powershell
  flutter clean
  flutter pub get
  ```

---

## Final Run Sequence

Once environment is setup, use this sequence:

1. `flutter doctor`
2. `flutter pub get`
3. Launch emulator/device
4. `flutter run`
