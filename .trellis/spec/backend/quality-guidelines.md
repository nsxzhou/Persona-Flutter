# Quality Guidelines

> Code quality standards for backend development.

---

## Overview

Backend-like Dart code must keep persistence, domain, application, and presentation boundaries separate. The app uses Drift, Riverpod, Freezed, JSON serialization, and build_runner-generated files.

---

## Forbidden Patterns

* Do not import Drift table records directly into feature presentation widgets.
* Do not edit generated `*.g.dart` or `*.freezed.dart` files.
* Do not add separate local HTTP backend abstractions without an explicit architecture decision.
* Do not store API keys or manuscript content in logs.

---

## Required Patterns

* Expose persistence through repository contracts.
* Convert Drift rows to domain models before UI consumption.
* Use Riverpod providers for service/repository wiring.
* Run `dart run build_runner build` after changing Drift, Freezed, JSON, or Riverpod annotations.

---

## Testing Requirements

Run:

```bash
dart run build_runner build
dart format lib test .trellis/spec
flutter analyze
flutter test
```

Add focused tests for changed behavior. Current smoke coverage lives in `test/widget_test.dart`.

---

## Code Review Checklist

* Are generated files up to date?
* Does UI depend only on providers/application contracts?
* Are local persistence contracts typed and testable?
* Are async provider loading/error/data states handled?

---

## Scenario: macOS outbound provider connectivity

### 1. Scope / Trigger
- Trigger: Any feature that performs outbound HTTPS from the macOS Flutter app, including Provider connectivity tests.

### 2. Signatures
- Entitlement keys:
  - `macos/Runner/DebugProfile.entitlements`: `com.apple.security.network.client`
  - `macos/Runner/Release.entitlements`: `com.apple.security.network.client`

### 3. Contracts
- Debug/Profile and Release builds must both include client networking when the app calls external Provider endpoints.
- `com.apple.security.network.server` is not sufficient for outbound HTTPS.

### 4. Validation & Error Matrix
- Missing `network.client` -> macOS sandbox can throw `SocketException: Operation not permitted, errno = 1`.
- Incorrect Provider URL/API Key -> HTTP or provider-specific failure, not `Operation not permitted`.

### 5. Good/Base/Bad Cases
- Good: add `network.client` before shipping Provider network calls.
- Base: re-run the macOS app after changing entitlements.
- Bad: debug the URL/model/key when the OS error is sandbox permission denial.

### 6. Tests Required
- `flutter analyze`
- `flutter test`
- Manual macOS rerun is required because entitlement changes apply after rebuilding/relaunching the app.

### 7. Wrong vs Correct
#### Wrong
Assume `com.apple.security.network.server` permits outbound Provider requests.
#### Correct
Enable `com.apple.security.network.client` for outbound Provider connectivity.
