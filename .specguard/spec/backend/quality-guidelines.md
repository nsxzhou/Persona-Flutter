# Quality Guidelines

> Code quality standards for backend development.

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

### Market Scan Recommendation Contract

Market Scan recommendation output is a cross-layer contract, not prompt-only
text. When changing `RecommendationDirection` fields or the YAML front matter
shape, update these consumers together:

- `recommendation_prompts.dart` output and repair prompts
- `recommendation_direction_document_parser.dart` validation and extraction
- `recommendation_direction.dart` plus generated Freezed/JSON files
- `recommendation_page.dart` rendering and project prefill behavior
- focused parser/service/page tests under `test/market_scan/`

---

## Testing Requirements

<!-- What level of testing is expected -->

Run the targeted Market Scan tests after changing the recommendation contract:

```bash
flutter test test/market_scan/recommendation_generation_service_test.dart test/market_scan/recommendation_page_test.dart
```

---

## Code Review Checklist

<!-- What reviewers should check -->

(To be filled by the team)
