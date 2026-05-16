import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:langchain_core/language_models.dart';
import 'package:langchain_core/prompts.dart';
import 'package:langchain_core/tools.dart';
import 'package:persona_flutter/src/core/database/app_database.dart';
import 'package:persona_flutter/src/core/llm/application/llm_invocation_service.dart';
import 'package:persona_flutter/src/core/llm/application/provider_prompt_composer.dart';
import 'package:persona_flutter/src/core/llm/data/langchain_llm_client.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_client.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_message.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_request.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_stream_event.dart';
import 'package:persona_flutter/src/features/settings/application/provider_connectivity_tester.dart';
import 'package:persona_flutter/src/features/settings/data/drift_provider_config_repository.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';

void main() {
  test('provider connectivity tester requests the models endpoint', () async {
    late http.BaseRequest capturedRequest;

    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response('{"data":[]}', 200);
    });

    final tester = ProviderConnectivityTester(client: client);
    final provider = ProviderConfig(
      id: 'provider-1',
      name: 'OpenAI',
      baseUrl: 'https://api.example.com/v1',
      apiKey: 'sk-test',
      defaultModel: 'gpt-4.1-mini',
      systemPrompt: '',
      isEnabled: true,
      testStatus: ProviderTestStatus.untested,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

    final result = await tester.test(provider);

    expect(result.isSuccess, isTrue);
    expect(result.message, contains('连接成功'));
    expect(capturedRequest.url.toString(), 'https://api.example.com/v1/models');
    expect(capturedRequest.headers['Authorization'], 'Bearer sk-test');
    expect(capturedRequest.headers['Accept'], 'application/json');
  });

  test('provider repository round-trips provider records in sqlite', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final repository = DriftProviderConfigRepository(database);
    const input = ProviderConfigInput(
      name: 'OpenAI',
      baseUrl: 'https://api.example.com/v1',
      apiKey: 'sk-test',
      defaultModel: 'gpt-4.1-mini',
      systemPrompt: 'Provider house rules',
      isEnabled: true,
    );

    await repository.saveProvider(input: input);

    final saved = (await repository.watchProviders().first).single;
    expect(saved.name, input.name);
    expect(saved.baseUrl, input.baseUrl);
    expect(saved.apiKey, input.apiKey);
    expect(saved.defaultModel, input.defaultModel);
    expect(saved.systemPrompt, input.systemPrompt);
    expect(saved.testStatus, ProviderTestStatus.untested);

    await repository.updateSystemPrompt(
      id: saved.id,
      systemPrompt: 'Updated provider rules',
    );
    final promptUpdated = await repository.findProvider(saved.id);
    expect(promptUpdated!.systemPrompt, 'Updated provider rules');

    await repository.updateTestResult(
      id: saved.id,
      status: ProviderTestStatus.succeeded,
      testedAt: DateTime.utc(2026, 5, 15, 12, 0),
      message: 'ok',
    );

    final updated = await repository.findProvider(saved.id);
    expect(updated, isNotNull);
    expect(updated!.testStatus, ProviderTestStatus.succeeded);
    expect(updated.lastTestMessage, 'ok');

    await repository.deleteProvider(saved.id);
    expect(await repository.findProvider(saved.id), isNull);
  });

  test(
    'provider prompt composer appends provider prompt after business prompt',
    () {
      const composer = ProviderPromptComposer();

      expect(
        composer.compose(
          businessSystemPrompt: 'Business prompt',
          providerSystemPrompt: 'Provider prompt',
        ),
        'Business prompt\n\nProvider prompt',
      );
      expect(
        composer.compose(
          businessSystemPrompt: 'Business prompt',
          providerSystemPrompt: '   ',
        ),
        'Business prompt',
      );
      expect(
        composer.compose(
          businessSystemPrompt: '   ',
          providerSystemPrompt: 'Provider prompt',
        ),
        'Provider prompt',
      );
    },
  );

  test('llm invocation service sends composed system prompt first', () async {
    final provider = ProviderConfig(
      id: 'provider-1',
      name: 'OpenAI',
      baseUrl: 'https://api.example.com/v1',
      apiKey: 'sk-test',
      defaultModel: 'gpt-4.1-mini',
      systemPrompt: 'Provider prompt',
      isEnabled: true,
      testStatus: ProviderTestStatus.untested,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    final client = _CapturingLlmClient();
    final service = LlmInvocationService(client: client);

    await service
        .streamChat(
          provider: provider,
          businessSystemPrompt: 'Business prompt',
          messages: const [LlmMessage.user('继续')],
          temperature: 0.6,
        )
        .drain<void>();

    expect(client.capturedRequest?.model, 'gpt-4.1-mini');
    expect(client.capturedRequest?.temperature, 0.6);
    expect(client.capturedRequest?.messages.map((message) => message.content), [
      'Business prompt\n\nProvider prompt',
      '继续',
    ]);
    expect(client.capturedRequest?.messages.map((message) => message.role), [
      LlmMessageRole.system,
      LlmMessageRole.user,
    ]);
  });

  test(
    'langchain llm client maps streaming chunks without leaking api key',
    () async {
      final provider = ProviderConfig(
        id: 'provider-1',
        name: 'OpenAI',
        baseUrl: 'https://api.example.com/v1',
        apiKey: 'sk-secret',
        defaultModel: 'gpt-4.1-mini',
        systemPrompt: '',
        isEnabled: true,
        testStatus: ProviderTestStatus.untested,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );
      late PromptValue capturedPrompt;
      ChatModelOptions? capturedOptions;
      final client = LangChainLlmClient(
        modelFactory: (_) => _RecordingChatModel(
          onStream: (prompt, options) {
            capturedPrompt = prompt;
            capturedOptions = options;
            return const ['模', '型'];
          },
        ),
      );

      final events = await client
          .streamChat(
            provider: provider,
            request: const LlmRequest(
              model: 'gpt-4.1-mini',
              temperature: 0.4,
              messages: [
                LlmMessage.system('SYSTEM'),
                LlmMessage.user('第一句'),
                LlmMessage.assistant('上一轮'),
                LlmMessage.user('继续'),
              ],
            ),
          )
          .toList();

      expect(
        events.whereType<LlmStreamDelta>().map((event) => event.text).join(),
        '模型',
      );
      expect(events.last, isA<LlmStreamDone>());
      expect(
        capturedPrompt.toChatMessages().map(
          (message) => message.contentAsString,
        ),
        ['SYSTEM', '第一句', '上一轮', '继续'],
      );
      expect(capturedOptions?.model, 'gpt-4.1-mini');
    },
  );

  test('langchain llm client sanitizes provider api key in errors', () async {
    final provider = ProviderConfig(
      id: 'provider-1',
      name: 'OpenAI',
      baseUrl: 'https://api.example.com/v1',
      apiKey: 'sk-secret',
      defaultModel: 'gpt-4.1-mini',
      systemPrompt: '',
      isEnabled: true,
      testStatus: ProviderTestStatus.untested,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    final client = LangChainLlmClient(
      modelFactory: (_) => _ThrowingChatModel(),
    );

    await expectLater(
      client
          .streamChat(
            provider: provider,
            request: const LlmRequest(
              model: 'gpt-4.1-mini',
              messages: [LlmMessage.user('hello')],
            ),
          )
          .drain<void>(),
      throwsA(
        isA<LlmClientException>().having(
          (error) => error.message,
          'message',
          allOf(contains('[REDACTED]'), isNot(contains('sk-secret'))),
        ),
      ),
    );
  });
}

class _CapturingLlmClient implements LlmClient {
  LlmRequest? capturedRequest;

  @override
  Stream<LlmStreamEvent> streamChat({
    required ProviderConfig provider,
    required LlmRequest request,
  }) async* {
    capturedRequest = request;
    yield const LlmStreamDone();
  }
}

class _RecordingChatModel extends BaseChatModel<ChatModelOptions> {
  _RecordingChatModel({required this.onStream})
    : super(defaultOptions: const _TestChatModelOptions());

  final List<String> Function(PromptValue prompt, ChatModelOptions? options)
  onStream;

  @override
  String get modelType => 'recording-chat-model';

  @override
  Future<ChatResult> invoke(PromptValue input, {ChatModelOptions? options}) {
    throw UnimplementedError();
  }

  @override
  Stream<ChatResult> stream(PromptValue input, {ChatModelOptions? options}) {
    return Stream.fromIterable(onStream(input, options)).map(
      (text) => ChatResult(
        id: 'chunk',
        output: AIChatMessage(content: text),
        finishReason: FinishReason.unspecified,
        metadata: const {},
        usage: const LanguageModelUsage(),
        streaming: true,
      ),
    );
  }

  @override
  Future<List<int>> tokenize(
    PromptValue promptValue, {
    ChatModelOptions? options,
  }) async {
    return const [];
  }
}

class _ThrowingChatModel extends BaseChatModel<ChatModelOptions> {
  _ThrowingChatModel() : super(defaultOptions: const _TestChatModelOptions());

  @override
  String get modelType => 'throwing-chat-model';

  @override
  Future<ChatResult> invoke(PromptValue input, {ChatModelOptions? options}) {
    throw UnimplementedError();
  }

  @override
  Stream<ChatResult> stream(
    PromptValue input, {
    ChatModelOptions? options,
  }) async* {
    throw StateError('upstream rejected sk-secret');
  }

  @override
  Future<List<int>> tokenize(
    PromptValue promptValue, {
    ChatModelOptions? options,
  }) async {
    return const [];
  }
}

class _TestChatModelOptions extends ChatModelOptions {
  const _TestChatModelOptions({super.model});

  @override
  _TestChatModelOptions copyWith({
    String? model,
    List<ToolSpec>? tools,
    ChatToolChoice? toolChoice,
    int? concurrencyLimit,
  }) {
    return _TestChatModelOptions(model: model ?? this.model);
  }
}
