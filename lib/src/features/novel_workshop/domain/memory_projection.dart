import 'package:freezed_annotation/freezed_annotation.dart';

part 'memory_projection.freezed.dart';
part 'memory_projection.g.dart';

@freezed
abstract class MemoryProjection with _$MemoryProjection {
  const factory MemoryProjection({
    required String id,
    required String projectId,
    @Default('') String recentSummary,
    @Default('') String globalSummary,
    @Default('') String factLedgerMarkdown,
    @Default('') String characterStatesMarkdown,
    @Default('') String unresolvedHooksMarkdown,
    String? updatedFromChapterId,
    required DateTime updatedAt,
  }) = _MemoryProjection;

  factory MemoryProjection.fromJson(Map<String, Object?> json) =>
      _$MemoryProjectionFromJson(json);
}

class MemoryProjectionInput {
  const MemoryProjectionInput({
    required this.projectId,
    this.recentSummary = '',
    this.globalSummary = '',
    this.factLedgerMarkdown = '',
    this.characterStatesMarkdown = '',
    this.unresolvedHooksMarkdown = '',
    this.updatedFromChapterId,
  });

  final String projectId;
  final String recentSummary;
  final String globalSummary;
  final String factLedgerMarkdown;
  final String characterStatesMarkdown;
  final String unresolvedHooksMarkdown;
  final String? updatedFromChapterId;
}
