# ADR-0004: Market Scan Improvements - Manual Control, Data Integrity, and Performance

## Status

Accepted

## Context

The market scan feature (扫榜) scrapes ranking data from Qidian, Fanqie, and Jinjiang platforms to power AI-driven writing recommendations. Several issues have emerged:

1. **Automatic scanning runs uncontrollably**: A background scheduler triggers scans every 6 hours and on app startup, with no user control.
2. **Novel synopses are truncated**: Scraper scripts hard-truncate descriptions at 200 characters (Qidian, Fanqie) or leave them empty (Jinjiang).
3. **UI is severely laggy**: The scan data browser renders all rankings as a flat `Column` with no virtualization, watches the same providers multiple times, and has ~700 lines of duplicated widget code between `scan_data_browser.dart` and `recommendation_page.dart`.
4. **Historical data grows unbounded**: Each scan inserts new ranking records without cleaning up old runs, causing database bloat.

## Decisions

### 1. Remove automatic scanning; manual trigger only

Remove the `MarketScanScheduler` timer logic and the app-startup auto-scan call in `app_shell.dart`. Scanning is triggered only when the user explicitly clicks the "立即扫描" button.

**Rationale**: Users do not need background scanning; they scan on demand when they want fresh data. This eliminates unnecessary network requests, Chrome process spawning, and resource consumption.

### 2. Remove description truncation in scrapers

- **Qidian** (`qidian_scraper.js` line 67): Remove `.slice(0, 200)` from `(record.desc || '').slice(0, 200)`.
- **Fanqie** (`fanqie_scraper.js` line 106): Remove `.slice(0, 200)` from `next.textContent?.trim()?.slice(0, 200)`.
- **Jinjiang**: No change. The list page does not contain descriptions, and visiting individual book detail pages is too costly. Descriptions remain empty.

**Rationale**: The 200-character limit was arbitrary and made synopses unusable. The SSR data and detail pages contain full descriptions for Qidian and Fanqie.

### 3. Fix UI performance with virtualization and provider consolidation

Three changes:

**a. Virtualized list rendering**: Replace the flat `Column` + `.map()` pattern in `_buildRankingsList` with `ListView.builder` (or `CustomScrollView` with `SliverList`), building chart sections lazily.

**b. Aggregate provider**: Create a single `scanDataBundleProvider` that returns a `(books, rankings, runs)` tuple, replacing the three separate `FutureProvider` watches and their nested `.when()` chains.

**c. Deduplicate widget code**: Refactor `ScanDataBrowser` to accept a `showHeader` parameter (default `true`). When `false`, it renders always-expanded without the collapsible header. Replace the ~700-line duplicated `_ScanDataTab` in `recommendation_page.dart` with `ScanDataBrowser(showHeader: false)`.

### 4. Auto-cleanup old scan runs

After each successful scan completes, check the total number of `MarketScanRun` records. If it exceeds a threshold (e.g., 10 runs per platform), delete the oldest runs and their associated `marketRankingRecords`. Book records (`marketBookRecords`) are retained since they are upserted and serve as the canonical book catalog.

**Rationale**: Keeps the database lean. 10 runs per platform provides sufficient history for the "扫描历史" panel without unbounded growth.

### 5. Database persistence (no change needed)

The existing persistence strategy is correct: books are upserted via `insertOnConflictUpdate` on `(platform, platformBookId)`, and rankings are freshly inserted per run with FK to `runId`. No changes required.

## Consequences

- App startup is faster (no background scan triggered)
- Network and CPU usage is predictable and user-controlled
- Book detail dialogs show complete synopses for Qidian and Fanqie
- Scan data browser scrolls smoothly even with hundreds of ranking entries
- Code maintenance burden is reduced by eliminating 700 lines of duplication
- Database size stays bounded regardless of scan frequency
