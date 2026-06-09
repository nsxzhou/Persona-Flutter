# Quality Guidelines

> Code quality standards for frontend development.

---

## Overview

<!--
Document your project's quality standards here.

Questions to answer:
- What patterns are forbidden?
- What linting rules do you enforce?
- What are your testing requirements?
- What code review standards apply?
-->

(To be filled by the team)

---

## Forbidden Patterns

<!-- Patterns that should never be used and why -->

(To be filled by the team)

---

## Required Patterns

<!-- Patterns that must always be used -->

### Market Scan Count Semantics

Market Scan UI must keep book and ranking-entry counts separate:

- `MarketBook` counts are de-duplicated book samples and should be labeled as
  `本` or `书籍样本`.
- `MarketRanking` counts and `MarketScanRun.itemCount` are ranking/scrape
  entries and should be labeled as `条` or `榜单条目`.
- Platform filters, list result counts, and visible list contents must use the
  same metric. When changing these counts, include a duplicate-ranking fixture
  in `test/market_scan/recommendation_page_test.dart`.

---

## Testing Requirements

<!-- What level of testing is expected -->

(To be filled by the team)

---

## Code Review Checklist

<!-- What reviewers should check -->

(To be filled by the team)
