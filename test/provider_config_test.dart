import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:langchain_core/language_models.dart';
import 'package:langchain_core/prompts.dart';
import 'package:langchain_core/tools.dart';
import 'package:persona_flutter/src/core/database/app_database.dart';
import 'package:persona_flutter/src/core/image_generation/data/bearer_image_generation_client.dart';
import 'package:persona_flutter/src/core/image_generation/domain/image_generation_request.dart';
import 'package:persona_flutter/src/core/llm/application/llm_invocation_service.dart';
import 'package:persona_flutter/src/core/llm/data/langchain_llm_client.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_client.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_message.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_request.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_stream_event.dart';
import 'package:persona_flutter/src/features/settings/application/provider_connectivity_tester.dart';
import 'package:persona_flutter/src/features/settings/data/drift_image_provider_config_repository.dart';
import 'package:persona_flutter/src/features/settings/data/drift_provider_config_repository.dart';
import 'package:persona_flutter/src/features/settings/domain/image_provider_config.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';
import 'package:sqlite3/sqlite3.dart';

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
      modelNames: ['gpt-4.1', 'gpt-4.1-mini', 'gpt-4.1-mini', ' '],
      systemPrompt: 'Provider house rules',
      isEnabled: true,
    );

    await repository.saveProvider(input: input);

    final saved = (await repository.watchProviders().first).single;
    expect(saved.name, input.name);
    expect(saved.baseUrl, input.baseUrl);
    expect(saved.apiKey, input.apiKey);
    expect(saved.defaultModel, input.defaultModel);
    expect(saved.modelNames, ['gpt-4.1-mini', 'gpt-4.1']);
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

    await repository.saveProvider(
      id: saved.id,
      input: const ProviderConfigInput(
        name: 'OpenAI',
        baseUrl: 'https://api.example.com/v1',
        apiKey: 'sk-test',
        defaultModel: 'gpt-4.1-nano',
        modelNames: ['gpt-4.1-mini'],
        systemPrompt: '',
        isEnabled: true,
      ),
    );
    final modelUpdated = await repository.findProvider(saved.id);
    expect(modelUpdated!.modelNames, ['gpt-4.1-nano', 'gpt-4.1-mini']);

    await repository.deleteProvider(saved.id);
    expect(await repository.findProvider(saved.id), isNull);
  });

  test('image provider repository round-trips records in sqlite', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final repository = DriftImageProviderConfigRepository(database);
    const input = ImageProviderConfigInput(
      name: 'NewAPI Image',
      baseUrl: 'https://image.example.com',
      apiKey: 'sk-image',
      defaultModel: 'gpt-5-3',
      providerKind: ImageProviderKind.grok,
      modelNames: ['gpt-5-3', 'gpt-image-1', 'gpt-5-3', ' '],
      defaultAspectRatio: ImageAspectRatioPreset.wide,
      defaultSize: ImageSizePreset.twoK,
      defaultQuality: ImageQualityPreset.high,
      defaultResponseFormat: ImageResponseFormat.b64Json,
      isEnabled: true,
    );

    await repository.saveProvider(input: input);

    final saved = (await repository.watchProviders().first).single;
    expect(saved.name, input.name);
    expect(saved.baseUrl, input.baseUrl);
    expect(saved.apiKey, input.apiKey);
    expect(saved.defaultModel, input.defaultModel);
    expect(saved.providerKind, ImageProviderKind.grok);
    expect(saved.modelNames, ['gpt-5-3', 'gpt-image-1']);
    expect(saved.defaultAspectRatio, ImageAspectRatioPreset.wide);
    expect(saved.defaultSize, ImageSizePreset.twoK);
    expect(saved.defaultQuality, ImageQualityPreset.high);
    expect(saved.defaultResponseFormat, ImageResponseFormat.b64Json);
    expect(saved.testStatus, ProviderTestStatus.untested);

    await repository.updateTestResult(
      id: saved.id,
      status: ProviderTestStatus.succeeded,
      testedAt: DateTime.utc(2026, 5, 24, 12, 0),
      message: 'sample ok',
    );
    final tested = await repository.findProvider(saved.id);
    expect(tested!.testStatus, ProviderTestStatus.succeeded);
    expect(tested.lastTestMessage, 'sample ok');

    await repository.deleteProvider(saved.id);
    expect(await repository.findProvider(saved.id), isNull);
  });

  test('schema 27 migration backfills image provider kind as gpt', () async {
    final sqlite = sqlite3.openInMemory();
    addTearDown(sqlite.dispose);
    sqlite.execute('PRAGMA user_version = 26');
    sqlite.execute('''
      CREATE TABLE image_provider_config_records (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        base_url TEXT NOT NULL,
        api_key TEXT NOT NULL,
        default_model TEXT NOT NULL,
        default_aspect_ratio TEXT NOT NULL DEFAULT '1:1',
        default_size TEXT NOT NULL DEFAULT '1K',
        default_quality TEXT NOT NULL DEFAULT 'auto',
        default_response_format TEXT NOT NULL DEFAULT 'url',
        is_enabled INTEGER NOT NULL DEFAULT 1,
        test_status TEXT NOT NULL,
        last_tested_at INTEGER,
        last_test_message TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    sqlite.execute('''
      CREATE TABLE image_provider_model_records (
        provider_id TEXT NOT NULL,
        model_name TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (provider_id, model_name),
        FOREIGN KEY (provider_id) REFERENCES image_provider_config_records(id)
      )
    ''');
    final now = DateTime.utc(2026, 5, 24).millisecondsSinceEpoch;
    sqlite.execute(
      '''
      INSERT INTO image_provider_config_records (
        id, name, base_url, api_key, default_model, default_aspect_ratio,
        default_size, default_quality, default_response_format, is_enabled,
        test_status, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        'legacy-image',
        'Legacy Image',
        'https://image.example.com',
        'sk-image',
        'gpt-5-3',
        '1:1',
        '1K',
        'auto',
        'url',
        1,
        ProviderTestStatus.untested.name,
        now,
        now,
      ],
    );

    final database = AppDatabase(NativeDatabase.opened(sqlite));
    addTearDown(database.close);
    final repository = DriftImageProviderConfigRepository(database);

    final provider = await repository.findProvider('legacy-image');
    expect(provider, isNotNull);
    expect(provider!.providerKind, ImageProviderKind.gpt);
  });

  test(
    'bearer image client sends generations request with bearer auth',
    () async {
      late http.Request capturedRequest;
      final client = MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          '{"created":1,"data":[{"url":"https://cdn.example.com/a.png","revised_prompt":"cat"}]}',
          200,
        );
      });
      final imageClient = BearerImageGenerationClient(client: client);
      final provider = _imageProvider();

      final result = await imageClient.generateImage(
        provider: provider,
        request: const ImageGenerationRequest(
          model: 'gpt-5-3',
          prompt: '一只猫',
          size: '1024x1024',
          quality: 'auto',
        ),
      );

      expect(
        capturedRequest.url.toString(),
        'https://image.example.com/v1/images/generations',
      );
      expect(
        capturedRequest.headers['Authorization'],
        'Bearer sk-image-secret',
      );
      expect(capturedRequest.headers['token'], isNull);
      expect(capturedRequest.body, contains('"model":"gpt-5-3"'));
      expect(capturedRequest.body, contains('"size":"1024x1024"'));
      expect(capturedRequest.body, contains('"quality":"auto"'));
      expect(capturedRequest.body, contains('"response_format":"url"'));
      expect(capturedRequest.body, isNot(contains('"n"')));
      expect(result.images.single.url, 'https://cdn.example.com/a.png');
      expect(result.images.single.revisedPrompt, 'cat');
    },
  );

  test('bearer image client sends grok chat completions request', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        '{"created":1,"choices":[{"message":{"content":"![image](https://cdn.example.com/grok.png)"}}],"usage":{"total_tokens":1}}',
        200,
      );
    });
    final imageClient = BearerImageGenerationClient(client: client);

    final result = await imageClient.generateImage(
      provider: _imageProvider(
        defaultModel: 'grok-imagine-image-lite',
        providerKind: ImageProviderKind.grok,
      ),
      request: const ImageGenerationRequest(
        model: 'grok-imagine-image-lite',
        prompt: '一只猫',
        size: '1024x1024',
        quality: 'auto',
      ),
    );

    expect(
      capturedRequest.url.toString(),
      'https://image.example.com/v1/chat/completions',
    );
    expect(capturedRequest.body, contains('"stream":false'));
    expect(capturedRequest.body, contains('"messages"'));
    expect(capturedRequest.body, contains('"image_config"'));
    expect(capturedRequest.body, contains('"size":"1024x1024"'));
    expect(capturedRequest.body, contains('"response_format":"url"'));
    expect(capturedRequest.body, isNot(contains('"quality"')));
    expect(capturedRequest.body, isNot(contains('"n"')));
    expect(result.images.single.url, 'https://cdn.example.com/grok.png');
  });

  test('bearer image client returns only first generated image', () async {
    final client = MockClient((request) async {
      return http.Response(
        '{"created":1,"data":[{"url":"https://cdn.example.com/a.png"},{"url":"https://cdn.example.com/b.png"}]}',
        200,
      );
    });
    final imageClient = BearerImageGenerationClient(client: client);

    final result = await imageClient.generateImage(
      provider: _imageProvider(),
      request: const ImageGenerationRequest(
        model: 'gpt-5-3',
        prompt: '一只猫',
        size: '1024x1024',
        quality: 'auto',
      ),
    );

    expect(result.images, hasLength(1));
    expect(result.images.single.url, 'https://cdn.example.com/a.png');
  });

  test('bearer image client supports edit endpoint contract', () async {
    late http.BaseRequest capturedRequest;
    final client = _BaseRequestClient((request) async {
      capturedRequest = request;
      return http.Response(
        '{"created":1,"data":[{"b64_json":"aW1hZ2U="}]}',
        200,
      );
    });
    final imageClient = BearerImageGenerationClient(client: client);

    final result = await imageClient.editImage(
      provider: _imageProvider(baseUrl: 'https://image.example.com/v1'),
      request: const ImageEditRequest(
        model: 'gpt-5-3',
        prompt: '改成夜景',
        imageBytes: [1, 2, 3],
        imageFilename: 'source.png',
        size: '1024x1024',
        quality: 'high',
      ),
    );

    expect(
      capturedRequest.url.toString(),
      'https://image.example.com/v1/images/edits',
    );
    expect(capturedRequest.headers['Authorization'], 'Bearer sk-image-secret');
    expect(
      (capturedRequest as http.MultipartRequest).fields['quality'],
      'high',
    );
    expect(result.images.single.b64Json, 'aW1hZ2U=');
  });

  test('bearer image client rejects grok edit requests', () async {
    final imageClient = BearerImageGenerationClient(
      client: MockClient((_) {
        throw StateError('network should not be called');
      }),
    );

    await expectLater(
      imageClient.editImage(
        provider: _imageProvider(providerKind: ImageProviderKind.grok),
        request: const ImageEditRequest(
          model: 'grok-imagine-image-lite',
          prompt: '改成夜景',
          imageBytes: [1, 2, 3],
          imageFilename: 'source.png',
          size: '1024x1024',
          quality: 'auto',
        ),
      ),
      throwsA(
        isA<ImageGenerationClientException>().having(
          (error) => error.message,
          'message',
          contains('暂不支持图片编辑'),
        ),
      ),
    );
  });

  test('bearer image client sanitizes api key in errors', () async {
    final client = MockClient((request) async {
      return http.Response('rejected sk-image-secret', 401);
    });
    final imageClient = BearerImageGenerationClient(client: client);

    await expectLater(
      imageClient.generateImage(
        provider: _imageProvider(),
        request: const ImageGenerationRequest(
          model: 'gpt-5-3',
          prompt: '一只猫',
          size: '1024x1024',
          quality: 'auto',
        ),
      ),
      throwsA(
        isA<ImageGenerationClientException>().having(
          (error) => error.message,
          'message',
          allOf(contains('[REDACTED]'), isNot(contains('sk-image-secret'))),
        ),
      ),
    );
  });

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

  test('llm invocation service can override provider default model', () async {
    final provider = ProviderConfig(
      id: 'provider-1',
      name: 'OpenAI',
      baseUrl: 'https://api.example.com/v1',
      apiKey: 'sk-test',
      defaultModel: 'gpt-4.1-mini',
      modelNames: const ['gpt-4.1-mini', 'gpt-4.1'],
      systemPrompt: '',
      isEnabled: true,
      testStatus: ProviderTestStatus.untested,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    final client = _CapturingLlmClient();
    final service = LlmInvocationService(client: client);
    LlmPromptTraceEvent? traceEvent;

    await service
        .streamChat(
          provider: provider,
          businessSystemPrompt: '',
          messages: const [LlmMessage.user('hi')],
          modelName: 'gpt-4.1',
          promptTrace: LlmPromptTraceConfig(
            label: 'test',
            onComplete: (event) async => traceEvent = event,
          ),
        )
        .drain<void>();

    expect(client.capturedRequest?.model, 'gpt-4.1');
    expect(traceEvent?.modelName, 'gpt-4.1');
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

ImageProviderConfig _imageProvider({
  String baseUrl = 'https://image.example.com',
  ImageProviderKind providerKind = ImageProviderKind.gpt,
  String defaultModel = 'gpt-5-3',
}) {
  return ImageProviderConfig(
    id: 'image-provider-1',
    name: 'NewAPI Image',
    baseUrl: baseUrl,
    apiKey: 'sk-image-secret',
    defaultModel: defaultModel,
    providerKind: providerKind,
    modelNames: [defaultModel],
    isEnabled: true,
    testStatus: ProviderTestStatus.untested,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
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

class _BaseRequestClient extends http.BaseClient {
  _BaseRequestClient(this.handler);

  final Future<http.Response> Function(http.BaseRequest request) handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await handler(request);
    return http.StreamedResponse(
      Stream<List<int>>.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      request: request,
      reasonPhrase: response.reasonPhrase,
    );
  }
}
