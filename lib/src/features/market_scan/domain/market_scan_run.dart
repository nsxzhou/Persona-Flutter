import 'package:freezed_annotation/freezed_annotation.dart';

part 'market_scan_run.freezed.dart';
part 'market_scan_run.g.dart';

enum MarketScanRunStatus { running, completed, failed }

@freezed
abstract class MarketScanRun with _$MarketScanRun {
  const factory MarketScanRun({
    required String id,
    required String platform,
    required MarketScanRunStatus status,
    required DateTime startedAt,
    DateTime? completedAt,
    @Default(0) int itemCount,
    String? errorMessage,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MarketScanRun;

  factory MarketScanRun.fromJson(Map<String, Object?> json) =>
      _$MarketScanRunFromJson(json);
}
