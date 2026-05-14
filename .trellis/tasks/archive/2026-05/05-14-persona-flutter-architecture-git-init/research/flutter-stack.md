# Flutter Stack Research

## Local Toolchain Evidence

* Flutter: 3.41.6 stable.
* Dart: 3.11.4 stable.
* Platform: macOS/Darwin ARM64.
* `flutter doctor -v` reports Android, Chrome, connected macOS device, and network resources available.
* `flutter doctor -v` also reports Xcode incomplete and CocoaPods missing, so macOS/iOS plugin builds may be blocked until Xcode setup is completed. Project scaffolding and Dart-level analysis/tests can still proceed.

## Package Evidence

* `go_router`: Pub.dev identifies it as a Flutter package from `flutter.dev` for declarative URL-based routing with Flutter Router API. Current observed version: `17.2.3`.
  * Source: https://pub.dev/packages/go_router
* `drift`: Pub.dev identifies it as a reactive persistence library for Dart and Flutter built on top of SQLite. Current observed version: `2.33.0`.
  * Source: https://pub.dev/packages/drift
  * Native runtime reference: https://pub.dev/documentation/drift/latest/native
* `riverpod` / `flutter_riverpod`: Pub.dev identifies Riverpod as a reactive caching and data-binding framework. Current observed versions: `riverpod 3.2.1`, `flutter_riverpod 3.3.1`.
  * Source: https://pub.dev/packages/riverpod
  * Source: https://pub.dev/packages/flutter_riverpod

## Recommended Baseline

Use a conservative Flutter application stack:

* UI app shell and platform scaffolding: Flutter.
* Routing: `go_router`.
* State and dependency wiring: `flutter_riverpod` / Riverpod.
* SQLite persistence: `drift` with native SQLite packages.
* Domain models: plain Dart classes first; add `freezed` / `json_serializable` only when generated immutable unions or JSON contracts become worth the build-runner cost.

## Rationale

* The architecture skeleton should keep feature scope small while locking durable boundaries.
* `go_router`, Riverpod, and Drift are widely used Flutter ecosystem choices that fit desktop-first local apps.
* Deferring heavy model code generation keeps the first scaffold readable and reduces setup friction.
* Drift gives a typed SQLite boundary and migration path, which matters for long-lived local user data and backup/restore.
