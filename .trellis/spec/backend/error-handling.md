# Error Handling

> How errors are handled in this project.

---

## Overview

Domain and infrastructure errors use custom exception classes that implement `Exception`. Each exception holds a single `String message` field and overrides `toString()`. There is no shared base exception class.

Async repository and provider failures are surfaced through Riverpod `AsyncValue` and rendered in presentation widgets with loading/error/data branches.

---

## Exception Classes

All exceptions follow the same structural pattern:

```dart
class FooException implements Exception {
  const FooException(this.message);
  final String message;
  @override
  String toString() => message;
}
```

### Core exceptions

| Class | File | Layer | Purpose |
|-------|------|-------|---------|
| `LlmCancellationException` | `core/llm/domain/llm_cancellation.dart` | domain | LLM request cancelled via `LlmCancellationToken` |
| `NovelImportException` | `features/novel_workshop/domain/novel_import.dart` | domain | Novel import failure (invalid file, parse error) |
| `LlmClientException` | `core/llm/data/langchain_llm_client.dart` | data | Underlying LangChain provider call failure |
| `ImageGenerationClientException` | `core/image_generation/data/bearer_image_generation_client.dart` | data | Bearer-auth image generation HTTP failure |
| `EmptyMarkdownCompletionException` | `core/llm/application/markdown_completion_service.dart` | application | LLM returned empty/blank markdown output |

### Feature validation exceptions

| Class | File | Layer | Purpose |
|-------|------|-------|---------|
| `MemoryPatchValidationException` | `features/novel_workshop/application/memory_patch_document.dart` | application | Memory patch YAML structure validation |
| `OutlineDetailValidationException` | `features/novel_workshop/application/outline_detail_parser.dart` | application | Outline detail YAML validation |
| `CharacterGraphValidationException` | `features/novel_workshop/application/character_graph_parser.dart` | application | Character relationship graph validation |
| `VolumeBlueprintValidationException` | `features/novel_workshop/application/volume_blueprint_parser.dart` | application | Volume blueprint YAML validation |
| `VoiceProfileValidationException` | `features/style_lab/application/voice_profile_front_matter.dart` | application | Voice Profile front-matter validation |
| `StyleSampleImportException` | `features/style_lab/application/style_sample_importer.dart` | application | Style sample file import failure |
| `PlotChunkSketchValidationException` | `features/plot_lab/application/plot_chunk_sketch_document.dart` | application | Plot chunk sketch document validation |
| `PlotStoryEngineValidationException` | `features/plot_lab/application/story_engine_normalizer.dart` | application | Story Engine normalization validation |
| `PlotSampleImportException` | `features/plot_lab/application/plot_sample_importer.dart` | application | Plot sample file import failure |

---

## Placement Convention

- **domain/** — user-facing import or cancellation errors that represent a business-level failure.
- **data/** — adapter-level errors wrapping third-party SDK or HTTP failures.
- **application/** — validation errors for document parsing, normalization, and sample import. Most exceptions live here.

---

## Error Handling Patterns

Repository methods expose typed results through `Future<T>` or `Stream<T>`. Provider boundaries surface asynchronous failures unless the service can add domain-specific recovery or context.

Presentation widgets must handle loading, data, and error states for async providers.

---

## API Error Responses

Not applicable: there is no HTTP API in the Flutter rewrite baseline.

---

## Common Mistakes

* Do not swallow repository exceptions silently.
* Do not render async provider data without an error branch.
* Do not introduce HTTP-style error response DTOs unless a real API boundary is added.
* Do not throw `StateError` for validation failures that have a dedicated exception class.
