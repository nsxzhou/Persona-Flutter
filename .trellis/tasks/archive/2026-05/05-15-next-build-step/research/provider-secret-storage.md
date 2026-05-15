# Provider Secret Storage Research

## Question

How should Persona Flutter store OpenAI-compatible Provider API Keys in a local-first desktop Flutter app?

## Local Constraints

* Persona Flutter is desktop-first: macOS first, Windows second, mobile later.
* The app is local-first and BYOK, so Provider API Keys are user secrets and should not be stored as plain text in SQLite.
* The existing data layer uses Drift/SQLite for persisted app data.
* Existing macOS entitlements currently enable app sandboxing but do not include Keychain Sharing.

## Evidence

* `flutter_secure_storage` on pub.dev is a Flutter plugin for encrypted sensitive data and supports Android, iOS, macOS, Windows, Linux, and Web.
* Its documented platform behavior uses Keychain for iOS/macOS and platform-specific secure storage for Windows and Linux.
* Its macOS/iOS notes say macOS runner entitlements need Keychain Sharing configured, or writes may appear successful without persisting.
* Its Linux notes require `libsecret-1-dev` for build and `libsecret-1-0` for runtime packaging.

Source: https://pub.dev/packages/flutter_secure_storage

## Options

### Option A: Store full Provider config, including API Key, in SQLite

Benefits:
* Simplest implementation.
* Easy backup/restore behavior.

Costs:
* Stores user secrets in the same database as regular app metadata.
* Poor security baseline for a BYOK desktop writing app.

### Option B: Store Provider metadata in SQLite and API Key in OS secure storage

Benefits:
* Keeps queryable Provider metadata in Drift.
* Keeps secrets out of SQLite.
* Aligns with platform-native secret storage on macOS and later Windows.

Costs:
* Adds dependency and platform configuration.
* Backup/restore must treat API Keys separately or require re-entry after restore.
* Requires graceful UI for missing/unreadable secrets.

### Option C: Do not persist API Keys; require entry each session

Benefits:
* Minimal secret-at-rest surface.

Costs:
* Bad usability for a long-session writing app.
* Blocks automation and queued workflows after restart.

## Recommendation

Use Option B for the MVP: persist Provider metadata in SQLite and store API Keys through `flutter_secure_storage`. Treat secret loss/unreadability as a recoverable Provider state that asks the user to re-enter the key.
