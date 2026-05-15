# HTTP Client Dependency Research

## Question

Which HTTP client dependency should Persona Flutter use for the Provider connectivity test MVP?

## Local Constraints

* The app currently has no HTTP client dependency.
* The connectivity test only needs a simple real request to an OpenAI-compatible endpoint, such as `GET /models`.
* The codebase does not currently use interceptors, retries, uploads, or advanced request adapters.
* The slice should remain desktop-first and simple to reason about.

## Evidence

Primary sources:

* `package:http` is a composable, multi-platform, future-based API for HTTP requests and supports `Android, iOS, Linux, macOS, web, Windows`.
  Source: https://pub.dev/packages/http
* `package:http` documents that it is easiest to use via the top-level functions and that the default implementation is `BrowserClient` on web and `IOClient` on other platforms.
  Source: https://pub.dev/documentation/http/latest/index.html
* `dio` is a more powerful HTTP client with global settings, interceptors, cancellation, upload/download support, custom adapters, and other advanced features.
  Sources: https://pub.dev/packages/dio and https://pub.dev/documentation/dio/latest/index.html

## Options

### Option A: `package:http`

Benefits:
* Minimal API surface for a single request/response slice.
* Good fit for a simple GET-based compatibility probe.
* Cross-platform support is already documented by the package.
* Easier to keep the implementation small and explicit.

Costs:
* Less convenient if we later need retries, interceptors, or richer request pipelines.

### Option B: `dio`

Benefits:
* Better prepared for future interceptors, cancellation, timeouts, and richer provider networking.
* Useful if provider calls quickly expand beyond a single probe request.

Costs:
* Heavier than needed for the current slice.
* Adds abstraction before the project has a demonstrated need for it.

## Recommendation

Use `package:http` for the Provider connectivity test MVP. It is enough for the first real network probe, keeps the code small, and avoids introducing a heavier client before the app needs interceptor or retry features.
