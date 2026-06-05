# ADR-0001: Bundle Node.js Runtime for Market Data Scraping

## Status

Accepted

## Context

Persona needs to scrape real-time market data from Chinese web novel platforms (Qidian, Fanqie, Jinjiang, etc.) to power the AI recommendation feature. Most of these platforms serve client-rendered SPA pages that require JavaScript execution to extract data from the DOM.

## Decision

We bundle Node.js runtime (~50MB) with the Flutter desktop app and use Puppeteer to control a headless Chrome instance for scraping. The scraper scripts run as child processes via `Process.run()`.

## Considered Options

- **Pure Dart HTTP + HTML parsing**: Lighter weight but fails on client-rendered SPA pages (most target platforms)
- **Embedded WebView in Flutter**: Avoids external runtime dependency but desktop WebView support is unstable across macOS/Windows
- **Dart CDP client**: Connects to user's installed Chrome but requires users to have Chrome installed and Dart CDP libraries are less mature

## Consequences

- App size increases by ~50MB due to Node.js runtime
- Scraping is robust across all target platforms, handling anti-bot measures, lazy loading, and authentication
- Scripts are isolated from the main Flutter process, simplifying error handling and recovery
- Maintenance burden includes keeping Node.js runtime and Puppeteer versions compatible with target platforms
