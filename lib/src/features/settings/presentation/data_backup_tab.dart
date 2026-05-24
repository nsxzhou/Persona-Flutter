import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/local_backup_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/persona_page.dart';
import '../application/local_backup_providers.dart';

class DataBackupTab extends ConsumerWidget {
  const DataBackupTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final backupState = ref.watch(localBackupControllerProvider);
    final isBusy = backupState.isLoading;
    final value = backupState.value;
    final result = value?.result;

    return PersonaPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PersonaSectionHeader(
            title: '本地备份',
            description: '导出或恢复完整本地 SQLite 数据库快照。',
            trailing: PersonaStatusPill(
              label: result == null ? '明文快照' : _operationLabel(result),
              icon: result?.operation == LocalBackupOperation.restore
                  ? Icons.restore_outlined
                  : Icons.save_alt_outlined,
              color: result == null ? colorScheme.error : colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 720;
              final actions = [
                FilledButton.icon(
                  onPressed: isBusy
                      ? null
                      : () => ref
                            .read(localBackupControllerProvider.notifier)
                            .exportBackup(),
                  icon: isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_alt_outlined, size: 18),
                  label: const Text('导出备份'),
                ),
                OutlinedButton.icon(
                  onPressed: isBusy
                      ? null
                      : () => _confirmRestore(context, ref),
                  icon: const Icon(Icons.restore_outlined, size: 18),
                  label: const Text('恢复备份'),
                ),
              ];

              return Flex(
                direction: isNarrow ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: isNarrow
                    ? CrossAxisAlignment.stretch
                    : CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: isNarrow ? 0 : 1,
                    child: _BackupWarningCard(
                      result: result,
                      error: backupState.error,
                    ),
                  ),
                  SizedBox(
                    width: isNarrow ? 0 : 16,
                    height: isNarrow ? 14 : 0,
                  ),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment:
                        isNarrow ? WrapAlignment.start : WrapAlignment.end,
                    children: actions,
                  ),
                ],
              );
            },
          ),
          if (result?.rollbackPath != null) ...[
            const SizedBox(height: 12),
            Text(
              '恢复前回滚副本：${result!.rollbackPath}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
                fontFamilyFallback: const ['Menlo', 'Courier'],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmRestore(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('恢复本地备份'),
          content: const Text(
            '恢复会用所选备份覆盖当前全部本地数据，包括项目、章节、分析结果、Provider 配置和 API Key。操作前会自动保留当前数据库回滚副本。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.restore_outlined, size: 18),
              label: const Text('选择备份并恢复'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    await ref.read(localBackupControllerProvider.notifier).restoreBackup();
  }
}

class _BackupWarningCard extends StatelessWidget {
  const _BackupWarningCard({required this.result, required this.error});

  final LocalBackupResult? result;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasError = error != null;
    final icon = hasError
        ? Icons.error_outline
        : result == null
        ? Icons.key_outlined
        : Icons.check_circle_outline;
    final color = hasError
        ? colorScheme.error
        : result == null
        ? colorScheme.error
        : colorScheme.primary;
    final title = hasError
        ? '操作失败'
        : result == null
        ? '备份包含敏感信息'
        : result!.message;
    final description = hasError
        ? '$error'
        : result == null
        ? '备份文件是明文 SQLite 快照，会包含本机保存的 Provider API Key，请只保存到可信位置。'
        : '${_formatTime(result!.completedAt)} · ${result!.targetPath}';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(kPanelRadius),
        border: Border.all(
          color: hasError
              ? colorScheme.error.withValues(alpha: 0.55)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.titleSmall),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: hasError
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _operationLabel(LocalBackupResult result) {
  return switch (result.operation) {
    LocalBackupOperation.export => '已导出',
    LocalBackupOperation.restore => '已恢复',
  };
}

String _formatTime(DateTime value) {
  final local = value.toLocal();
  String two(int input) => input.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}
