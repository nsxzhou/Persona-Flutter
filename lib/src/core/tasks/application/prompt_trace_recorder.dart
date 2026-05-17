import '../../llm/domain/llm_message.dart';
import '../../llm/application/llm_invocation_service.dart';
import 'workflow_task_repository.dart';

const promptTraceFormat = 'persona.workflow_prompt_trace';
const promptTraceVersion = 1;
const _outputExcerptChars = 1200;

class PromptTraceRecorder {
  PromptTraceRecorder({
    required this.repository,
    required this.workflowTaskId,
    required this.workflowKind,
    required this.runId,
    required this.providerId,
    required this.providerApiKey,
    required this.modelName,
    required this.stageLabel,
  });

  final WorkflowTaskRepository repository;
  final String workflowTaskId;
  final String workflowKind;
  final String runId;
  final String providerId;
  final String providerApiKey;
  final String modelName;
  final String? Function() stageLabel;

  final List<PromptTraceCall> _calls = [];

  LlmPromptTraceConfig config({required String label}) {
    return LlmPromptTraceConfig(label: label, onComplete: record);
  }

  Future<void> record(LlmPromptTraceEvent event) async {
    final completedAt = event.completedAt;
    final sanitizedMessages = event.messages
        .map(
          (message) =>
              LlmMessage(role: message.role, content: _redact(message.content)),
        )
        .toList(growable: false);
    final sanitizedOutput = event.output == null
        ? null
        : _redact(event.output!);
    final sanitizedError = event.errorSummary == null
        ? null
        : _redact(event.errorSummary!);

    _calls.add(
      PromptTraceCall(
        index: _calls.length + 1,
        stage: stageLabel(),
        label: event.label,
        modelName: event.modelName,
        temperature: event.temperature,
        startedAt: event.startedAt,
        completedAt: completedAt,
        durationMs: completedAt.difference(event.startedAt).inMilliseconds,
        messages: sanitizedMessages,
        outputCharCount: sanitizedOutput?.length,
        outputExcerpt: sanitizedOutput == null
            ? null
            : buildPromptTraceOutputExcerpt(sanitizedOutput),
        errorSummary: sanitizedError,
      ),
    );

    try {
      await repository.upsertPromptTrace(
        workflowTaskId: workflowTaskId,
        traceMarkdown: renderPromptTraceMarkdown(
          workflowTaskId: workflowTaskId,
          workflowKind: workflowKind,
          runId: runId,
          providerId: providerId,
          modelName: modelName,
          calls: _calls,
        ),
      );
    } on Object {
      // Prompt traces are audit artifacts; tracing must not fail the workflow.
    }
  }

  String _redact(String value) {
    var result = value;
    final trimmedKey = providerApiKey.trim();
    if (trimmedKey.isNotEmpty) {
      result = result.replaceAll(trimmedKey, '[REDACTED]');
    }
    result = result.replaceAll(
      RegExp(r'Bearer\s+[A-Za-z0-9._~+/=-]+', caseSensitive: false),
      'Bearer [REDACTED]',
    );
    result = result.replaceAll(
      RegExp(r'sk-[A-Za-z0-9_-]{8,}'),
      'sk-[REDACTED]',
    );
    return result;
  }
}

class PromptTraceCall {
  const PromptTraceCall({
    required this.index,
    required this.stage,
    required this.label,
    required this.modelName,
    required this.temperature,
    required this.startedAt,
    required this.completedAt,
    required this.durationMs,
    required this.messages,
    required this.outputCharCount,
    required this.outputExcerpt,
    required this.errorSummary,
  });

  final int index;
  final String? stage;
  final String label;
  final String modelName;
  final double temperature;
  final DateTime startedAt;
  final DateTime completedAt;
  final int durationMs;
  final List<LlmMessage> messages;
  final int? outputCharCount;
  final String? outputExcerpt;
  final String? errorSummary;

  int get totalInputChars {
    return messages.fold(0, (sum, message) => sum + message.content.length);
  }

  bool get failed => errorSummary != null;
}

String buildPromptTraceOutputExcerpt(String output) {
  final text = output.trim();
  if (text.length <= _outputExcerptChars * 2) {
    return text;
  }
  final head = text.substring(0, _outputExcerptChars).trimRight();
  final tail = text.substring(text.length - _outputExcerptChars).trimLeft();
  final omitted = text.length - head.length - tail.length;
  return '$head\n\n...[omitted $omitted chars]...\n\n$tail';
}

String renderPromptTraceMarkdown({
  required String workflowTaskId,
  required String workflowKind,
  required String runId,
  required String providerId,
  required String modelName,
  required List<PromptTraceCall> calls,
}) {
  final totalInputChars = calls.fold(
    0,
    (sum, call) => sum + call.totalInputChars,
  );
  final failedCalls = calls.where((call) => call.failed).length;
  final updatedAt = DateTime.now().toUtc().toIso8601String();
  final lines = <String>[
    '---',
    'format: $promptTraceFormat',
    'version: $promptTraceVersion',
    'workflow_task_id: ${_yamlQuote(workflowTaskId)}',
    'workflow_kind: ${_yamlQuote(workflowKind)}',
    'run_id: ${_yamlQuote(runId)}',
    'provider_id: ${_yamlQuote(providerId)}',
    'model_name: ${_yamlQuote(modelName)}',
    'calls: ${calls.length}',
    'failed_calls: $failedCalls',
    'total_input_chars: $totalInputChars',
    'updated_at: ${_yamlQuote(updatedAt)}',
    '---',
    '',
    '# Prompt Trace',
    '',
    '| Field | Value |',
    '| --- | --- |',
    '| Workflow task ID | `${_escapeTable(workflowTaskId)}` |',
    '| Workflow kind | `${_escapeTable(workflowKind)}` |',
    '| Run ID | `${_escapeTable(runId)}` |',
    '| Calls | ${calls.length} |',
    '| Failed calls | $failedCalls |',
    '| Total input chars | $totalInputChars |',
    '',
  ];

  if (calls.isEmpty) {
    lines.add('No LLM calls recorded yet.');
    return '${lines.join('\n')}\n';
  }

  lines.addAll([
    '## Call summary',
    '',
    '| # | Stage | Label | Model | Temperature | Input chars | Output chars | Failed | Error |',
    '| --- | --- | --- | --- | ---: | ---: | ---: | --- | --- |',
  ]);
  for (final call in calls) {
    lines.add(
      '| '
      '${call.index} | '
      '${_escapeTable(call.stage ?? '-')} | '
      '${_escapeTable(call.label)} | '
      '${_escapeTable(call.modelName)} | '
      '${call.temperature} | '
      '${call.totalInputChars} | '
      '${call.outputCharCount ?? '-'} | '
      '${call.failed ? 'yes' : 'no'} | '
      '${_escapeTable(call.errorSummary ?? '-')} |',
    );
  }
  lines.add('');

  for (final call in calls) {
    lines.addAll(_renderCall(call));
  }

  return '${lines.join('\n').trimRight()}\n';
}

List<String> _renderCall(PromptTraceCall call) {
  final lines = <String>[
    '## Call ${call.index} - ${call.stage ?? 'unknown-stage'} / ${call.label}',
    '',
    '| Field | Value |',
    '| --- | --- |',
    '| Stage | `${_escapeTable(call.stage ?? '-')}` |',
    '| Label | `${_escapeTable(call.label)}` |',
    '| Model | `${_escapeTable(call.modelName)}` |',
    '| Temperature | ${call.temperature} |',
    '| Started at | `${call.startedAt.toUtc().toIso8601String()}` |',
    '| Completed at | `${call.completedAt.toUtc().toIso8601String()}` |',
    '| Duration | ${call.durationMs} ms |',
    '| Input chars | ${call.totalInputChars} |',
    '| Output chars | ${call.outputCharCount ?? '-'} |',
    '| Failed | ${call.failed ? 'yes' : 'no'} |',
  ];
  if (call.errorSummary != null) {
    lines.add('| Error | `${_escapeTable(call.errorSummary!)}` |');
  }
  lines.add('');

  for (final message in call.messages) {
    lines.addAll([
      '### ${_roleLabel(message.role)} message',
      '',
      '- Chars: ${message.content.length}',
      '',
      _fencedCodeBlock(message.content),
      '',
    ]);
  }

  lines.addAll(['### Output excerpt', '']);
  if (call.outputExcerpt != null) {
    lines.addAll([_fencedCodeBlock(call.outputExcerpt!), '']);
  } else if (call.errorSummary != null) {
    lines.add(
      'Call failed before producing output: `${_escapeTable(call.errorSummary!)}`',
    );
    lines.add('');
  } else {
    lines.add('No output captured.');
    lines.add('');
  }
  return lines;
}

String _roleLabel(LlmMessageRole role) {
  return switch (role) {
    LlmMessageRole.system => 'System',
    LlmMessageRole.user => 'User',
    LlmMessageRole.assistant => 'Assistant',
  };
}

String _fencedCodeBlock(String content) {
  final longest = RegExp(r'`+')
      .allMatches(content)
      .fold<int>(
        0,
        (max, match) =>
            match.group(0)!.length > max ? match.group(0)!.length : max,
      );
  final fence = '`' * (longest >= 3 ? longest + 1 : 3);
  return '$fence\n$content\n$fence';
}

String _yamlQuote(String value) {
  return '"${value.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"';
}

String _escapeTable(String value) {
  return value.replaceAll('|', r'\|').replaceAll('\n', '<br>');
}
