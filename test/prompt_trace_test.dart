import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/core/database/app_database.dart';
import 'package:persona_flutter/src/core/llm/application/llm_invocation_service.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_client.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_message.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_request.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_stream_event.dart';
import 'package:persona_flutter/src/core/tasks/application/prompt_trace_recorder.dart';
import 'package:persona_flutter/src/core/tasks/data/drift_workflow_task_repository.dart';
import 'package:persona_flutter/src/core/tasks/domain/workflow_task.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';

void main() {
  test(
    'workflow task preview dismissal persists in repository streams',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftWorkflowTaskRepository(database);
      await database
          .into(database.workflowTaskRecords)
          .insert(
            WorkflowTaskRecordsCompanion.insert(
              id: 'task-preview-1',
              kind: 'novel_asset_generation',
              status: WorkflowTaskStatus.succeeded.name,
              title: '资产生成',
              createdAt: DateTime.utc(2026, 5, 23),
              updatedAt: DateTime.utc(2026, 5, 23),
            ),
          );

      await repository.dismissTaskPreview('task-preview-1');

      final found = await repository.findTask('task-preview-1');
      expect(found!.previewDismissedAt, isNotNull);

      final recent = await repository.watchTasks().first;
      expect(recent.single.previewDismissedAt, found.previewDismissedAt);
    },
  );

  test('prompt trace renderer emits YAML+MD with safe fences', () {
    final markdown = renderPromptTraceMarkdown(
      workflowTaskId: 'task-1',
      workflowKind: 'plot_analysis',
      runId: 'run-1',
      providerId: 'provider-1',
      modelName: 'deepseek-chat',
      calls: [
        PromptTraceCall(
          index: 1,
          stage: 'reporting',
          label: 'build_report',
          modelName: 'deepseek-chat',
          temperature: 0.4,
          startedAt: DateTime.utc(2026, 5, 17, 1),
          completedAt: DateTime.utc(2026, 5, 17, 1, 0, 1),
          durationMs: 1000,
          messages: const [
            LlmMessage.system('SYSTEM'),
            LlmMessage.user(
              'User contains fence:\n```dart\nvoid main() {}\n```',
            ),
          ],
          outputCharCount: 7,
          outputExcerpt: 'OUTPUT',
          errorSummary: null,
        ),
      ],
    );

    expect(markdown, startsWith('---\nformat: persona.workflow_prompt_trace'));
    expect(markdown, contains('workflow_task_id: "task-1"'));
    expect(markdown, contains('# Prompt Trace'));
    expect(markdown, contains('## Call 1 - reporting / build_report'));
    expect(markdown, contains('````\nUser contains fence:'));
  });

  test('prompt trace output excerpt keeps head and tail', () {
    final output = '${'a' * 1300}${'b' * 1300}';

    final excerpt = buildPromptTraceOutputExcerpt(output);

    expect(excerpt, startsWith('a' * 1200));
    expect(excerpt, contains('...[omitted '));
    expect(excerpt, endsWith('b' * 1200));
  });

  test(
    'llm invocation trace captures composed messages and redacts key',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftWorkflowTaskRepository(database);
      await database
          .into(database.workflowTaskRecords)
          .insert(
            WorkflowTaskRecordsCompanion.insert(
              id: 'task-1',
              kind: 'style_analysis',
              status: WorkflowTaskStatus.running.name,
              title: '风格分析',
              createdAt: DateTime.utc(2026, 5, 17),
              updatedAt: DateTime.utc(2026, 5, 17),
            ),
          );
      final provider = _provider(apiKey: 'sk-secret-token');
      final recorder = PromptTraceRecorder(
        repository: repository,
        workflowTaskId: 'task-1',
        workflowKind: 'style_analysis',
        runId: 'run-1',
        providerId: provider.id,
        providerApiKey: provider.apiKey,
        modelName: provider.defaultModel,
        stageLabel: () => 'reporting',
      );
      final service = const LlmInvocationService(
        client: _StaticLlmClient('done'),
      );

      await service
          .streamChat(
            provider: provider,
            businessSystemPrompt: 'Business',
            messages: const [LlmMessage.user('Use sk-secret-token now')],
            promptTrace: recorder.config(label: 'trace_call'),
          )
          .drain<void>();

      final trace = await repository.watchPromptTrace('task-1').first;
      expect(trace, isNotNull);
      expect(trace!.traceMarkdown, contains('Business\n\nProvider rules'));
      expect(trace.traceMarkdown, contains('Use [REDACTED] now'));
      expect(trace.traceMarkdown, isNot(contains('sk-secret-token')));
      expect(trace.traceMarkdown, contains('### Output excerpt'));
    },
  );
}

ProviderConfig _provider({required String apiKey}) {
  return ProviderConfig(
    id: 'provider-1',
    name: 'OpenAI',
    baseUrl: 'https://api.example.com/v1',
    apiKey: apiKey,
    defaultModel: 'deepseek-chat',
    systemPrompt: 'Provider rules',
    isEnabled: true,
    testStatus: ProviderTestStatus.untested,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
}

class _StaticLlmClient implements LlmClient {
  const _StaticLlmClient(this.output);

  final String output;

  @override
  Stream<LlmStreamEvent> streamChat({
    required ProviderConfig provider,
    required LlmRequest request,
  }) async* {
    yield LlmStreamDelta(output);
    yield const LlmStreamDone();
  }
}
