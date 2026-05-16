// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WorkflowTaskRecordsTable extends WorkflowTaskRecords
    with TableInfo<$WorkflowTaskRecordsTable, WorkflowTaskRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkflowTaskRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
    'stage',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    status,
    title,
    stage,
    errorMessage,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workflow_task_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkflowTaskRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('stage')) {
      context.handle(
        _stageMeta,
        stage.isAcceptableOrUnknown(data['stage']!, _stageMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkflowTaskRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkflowTaskRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WorkflowTaskRecordsTable createAlias(String alias) {
    return $WorkflowTaskRecordsTable(attachedDatabase, alias);
  }
}

class WorkflowTaskRecord extends DataClass
    implements Insertable<WorkflowTaskRecord> {
  final String id;
  final String kind;
  final String status;
  final String title;
  final String? stage;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WorkflowTaskRecord({
    required this.id,
    required this.kind,
    required this.status,
    required this.title,
    this.stage,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['status'] = Variable<String>(status);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || stage != null) {
      map['stage'] = Variable<String>(stage);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WorkflowTaskRecordsCompanion toCompanion(bool nullToAbsent) {
    return WorkflowTaskRecordsCompanion(
      id: Value(id),
      kind: Value(kind),
      status: Value(status),
      title: Value(title),
      stage: stage == null && nullToAbsent
          ? const Value.absent()
          : Value(stage),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WorkflowTaskRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkflowTaskRecord(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      status: serializer.fromJson<String>(json['status']),
      title: serializer.fromJson<String>(json['title']),
      stage: serializer.fromJson<String?>(json['stage']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'status': serializer.toJson<String>(status),
      'title': serializer.toJson<String>(title),
      'stage': serializer.toJson<String?>(stage),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WorkflowTaskRecord copyWith({
    String? id,
    String? kind,
    String? status,
    String? title,
    Value<String?> stage = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WorkflowTaskRecord(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    status: status ?? this.status,
    title: title ?? this.title,
    stage: stage.present ? stage.value : this.stage,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WorkflowTaskRecord copyWithCompanion(WorkflowTaskRecordsCompanion data) {
    return WorkflowTaskRecord(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      status: data.status.present ? data.status.value : this.status,
      title: data.title.present ? data.title.value : this.title,
      stage: data.stage.present ? data.stage.value : this.stage,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkflowTaskRecord(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('title: $title, ')
          ..write('stage: $stage, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    status,
    title,
    stage,
    errorMessage,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkflowTaskRecord &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.status == this.status &&
          other.title == this.title &&
          other.stage == this.stage &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WorkflowTaskRecordsCompanion extends UpdateCompanion<WorkflowTaskRecord> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> status;
  final Value<String> title;
  final Value<String?> stage;
  final Value<String?> errorMessage;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WorkflowTaskRecordsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.status = const Value.absent(),
    this.title = const Value.absent(),
    this.stage = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkflowTaskRecordsCompanion.insert({
    required String id,
    required String kind,
    required String status,
    required String title,
    this.stage = const Value.absent(),
    this.errorMessage = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       status = Value(status),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WorkflowTaskRecord> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? status,
    Expression<String>? title,
    Expression<String>? stage,
    Expression<String>? errorMessage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (status != null) 'status': status,
      if (title != null) 'title': title,
      if (stage != null) 'stage': stage,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkflowTaskRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? status,
    Value<String>? title,
    Value<String?>? stage,
    Value<String?>? errorMessage,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WorkflowTaskRecordsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      title: title ?? this.title,
      stage: stage ?? this.stage,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkflowTaskRecordsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('title: $title, ')
          ..write('stage: $stage, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProviderConfigRecordsTable extends ProviderConfigRecords
    with TableInfo<$ProviderConfigRecordsTable, ProviderConfigRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProviderConfigRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseUrlMeta = const VerificationMeta(
    'baseUrl',
  );
  @override
  late final GeneratedColumn<String> baseUrl = GeneratedColumn<String>(
    'base_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _apiKeyMeta = const VerificationMeta('apiKey');
  @override
  late final GeneratedColumn<String> apiKey = GeneratedColumn<String>(
    'api_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultModelMeta = const VerificationMeta(
    'defaultModel',
  );
  @override
  late final GeneratedColumn<String> defaultModel = GeneratedColumn<String>(
    'default_model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _systemPromptMeta = const VerificationMeta(
    'systemPrompt',
  );
  @override
  late final GeneratedColumn<String> systemPrompt = GeneratedColumn<String>(
    'system_prompt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _testStatusMeta = const VerificationMeta(
    'testStatus',
  );
  @override
  late final GeneratedColumn<String> testStatus = GeneratedColumn<String>(
    'test_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastTestedAtMeta = const VerificationMeta(
    'lastTestedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastTestedAt = GeneratedColumn<DateTime>(
    'last_tested_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastTestMessageMeta = const VerificationMeta(
    'lastTestMessage',
  );
  @override
  late final GeneratedColumn<String> lastTestMessage = GeneratedColumn<String>(
    'last_test_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    baseUrl,
    apiKey,
    defaultModel,
    systemPrompt,
    isEnabled,
    testStatus,
    lastTestedAt,
    lastTestMessage,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'provider_config_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProviderConfigRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('base_url')) {
      context.handle(
        _baseUrlMeta,
        baseUrl.isAcceptableOrUnknown(data['base_url']!, _baseUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_baseUrlMeta);
    }
    if (data.containsKey('api_key')) {
      context.handle(
        _apiKeyMeta,
        apiKey.isAcceptableOrUnknown(data['api_key']!, _apiKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_apiKeyMeta);
    }
    if (data.containsKey('default_model')) {
      context.handle(
        _defaultModelMeta,
        defaultModel.isAcceptableOrUnknown(
          data['default_model']!,
          _defaultModelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultModelMeta);
    }
    if (data.containsKey('system_prompt')) {
      context.handle(
        _systemPromptMeta,
        systemPrompt.isAcceptableOrUnknown(
          data['system_prompt']!,
          _systemPromptMeta,
        ),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('test_status')) {
      context.handle(
        _testStatusMeta,
        testStatus.isAcceptableOrUnknown(data['test_status']!, _testStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_testStatusMeta);
    }
    if (data.containsKey('last_tested_at')) {
      context.handle(
        _lastTestedAtMeta,
        lastTestedAt.isAcceptableOrUnknown(
          data['last_tested_at']!,
          _lastTestedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_test_message')) {
      context.handle(
        _lastTestMessageMeta,
        lastTestMessage.isAcceptableOrUnknown(
          data['last_test_message']!,
          _lastTestMessageMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProviderConfigRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProviderConfigRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      baseUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_url'],
      )!,
      apiKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}api_key'],
      )!,
      defaultModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_model'],
      )!,
      systemPrompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_prompt'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      testStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}test_status'],
      )!,
      lastTestedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_tested_at'],
      ),
      lastTestMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_test_message'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProviderConfigRecordsTable createAlias(String alias) {
    return $ProviderConfigRecordsTable(attachedDatabase, alias);
  }
}

class ProviderConfigRecord extends DataClass
    implements Insertable<ProviderConfigRecord> {
  final String id;
  final String name;
  final String baseUrl;
  final String apiKey;
  final String defaultModel;
  final String systemPrompt;
  final bool isEnabled;
  final String testStatus;
  final DateTime? lastTestedAt;
  final String? lastTestMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ProviderConfigRecord({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.apiKey,
    required this.defaultModel,
    required this.systemPrompt,
    required this.isEnabled,
    required this.testStatus,
    this.lastTestedAt,
    this.lastTestMessage,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['base_url'] = Variable<String>(baseUrl);
    map['api_key'] = Variable<String>(apiKey);
    map['default_model'] = Variable<String>(defaultModel);
    map['system_prompt'] = Variable<String>(systemPrompt);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['test_status'] = Variable<String>(testStatus);
    if (!nullToAbsent || lastTestedAt != null) {
      map['last_tested_at'] = Variable<DateTime>(lastTestedAt);
    }
    if (!nullToAbsent || lastTestMessage != null) {
      map['last_test_message'] = Variable<String>(lastTestMessage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProviderConfigRecordsCompanion toCompanion(bool nullToAbsent) {
    return ProviderConfigRecordsCompanion(
      id: Value(id),
      name: Value(name),
      baseUrl: Value(baseUrl),
      apiKey: Value(apiKey),
      defaultModel: Value(defaultModel),
      systemPrompt: Value(systemPrompt),
      isEnabled: Value(isEnabled),
      testStatus: Value(testStatus),
      lastTestedAt: lastTestedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastTestedAt),
      lastTestMessage: lastTestMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(lastTestMessage),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProviderConfigRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProviderConfigRecord(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      baseUrl: serializer.fromJson<String>(json['baseUrl']),
      apiKey: serializer.fromJson<String>(json['apiKey']),
      defaultModel: serializer.fromJson<String>(json['defaultModel']),
      systemPrompt: serializer.fromJson<String>(json['systemPrompt']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      testStatus: serializer.fromJson<String>(json['testStatus']),
      lastTestedAt: serializer.fromJson<DateTime?>(json['lastTestedAt']),
      lastTestMessage: serializer.fromJson<String?>(json['lastTestMessage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'baseUrl': serializer.toJson<String>(baseUrl),
      'apiKey': serializer.toJson<String>(apiKey),
      'defaultModel': serializer.toJson<String>(defaultModel),
      'systemPrompt': serializer.toJson<String>(systemPrompt),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'testStatus': serializer.toJson<String>(testStatus),
      'lastTestedAt': serializer.toJson<DateTime?>(lastTestedAt),
      'lastTestMessage': serializer.toJson<String?>(lastTestMessage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProviderConfigRecord copyWith({
    String? id,
    String? name,
    String? baseUrl,
    String? apiKey,
    String? defaultModel,
    String? systemPrompt,
    bool? isEnabled,
    String? testStatus,
    Value<DateTime?> lastTestedAt = const Value.absent(),
    Value<String?> lastTestMessage = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ProviderConfigRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    baseUrl: baseUrl ?? this.baseUrl,
    apiKey: apiKey ?? this.apiKey,
    defaultModel: defaultModel ?? this.defaultModel,
    systemPrompt: systemPrompt ?? this.systemPrompt,
    isEnabled: isEnabled ?? this.isEnabled,
    testStatus: testStatus ?? this.testStatus,
    lastTestedAt: lastTestedAt.present ? lastTestedAt.value : this.lastTestedAt,
    lastTestMessage: lastTestMessage.present
        ? lastTestMessage.value
        : this.lastTestMessage,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProviderConfigRecord copyWithCompanion(ProviderConfigRecordsCompanion data) {
    return ProviderConfigRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      baseUrl: data.baseUrl.present ? data.baseUrl.value : this.baseUrl,
      apiKey: data.apiKey.present ? data.apiKey.value : this.apiKey,
      defaultModel: data.defaultModel.present
          ? data.defaultModel.value
          : this.defaultModel,
      systemPrompt: data.systemPrompt.present
          ? data.systemPrompt.value
          : this.systemPrompt,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      testStatus: data.testStatus.present
          ? data.testStatus.value
          : this.testStatus,
      lastTestedAt: data.lastTestedAt.present
          ? data.lastTestedAt.value
          : this.lastTestedAt,
      lastTestMessage: data.lastTestMessage.present
          ? data.lastTestMessage.value
          : this.lastTestMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProviderConfigRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('apiKey: $apiKey, ')
          ..write('defaultModel: $defaultModel, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('testStatus: $testStatus, ')
          ..write('lastTestedAt: $lastTestedAt, ')
          ..write('lastTestMessage: $lastTestMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    baseUrl,
    apiKey,
    defaultModel,
    systemPrompt,
    isEnabled,
    testStatus,
    lastTestedAt,
    lastTestMessage,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProviderConfigRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.baseUrl == this.baseUrl &&
          other.apiKey == this.apiKey &&
          other.defaultModel == this.defaultModel &&
          other.systemPrompt == this.systemPrompt &&
          other.isEnabled == this.isEnabled &&
          other.testStatus == this.testStatus &&
          other.lastTestedAt == this.lastTestedAt &&
          other.lastTestMessage == this.lastTestMessage &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProviderConfigRecordsCompanion
    extends UpdateCompanion<ProviderConfigRecord> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> baseUrl;
  final Value<String> apiKey;
  final Value<String> defaultModel;
  final Value<String> systemPrompt;
  final Value<bool> isEnabled;
  final Value<String> testStatus;
  final Value<DateTime?> lastTestedAt;
  final Value<String?> lastTestMessage;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProviderConfigRecordsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.baseUrl = const Value.absent(),
    this.apiKey = const Value.absent(),
    this.defaultModel = const Value.absent(),
    this.systemPrompt = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.testStatus = const Value.absent(),
    this.lastTestedAt = const Value.absent(),
    this.lastTestMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProviderConfigRecordsCompanion.insert({
    required String id,
    required String name,
    required String baseUrl,
    required String apiKey,
    required String defaultModel,
    this.systemPrompt = const Value.absent(),
    this.isEnabled = const Value.absent(),
    required String testStatus,
    this.lastTestedAt = const Value.absent(),
    this.lastTestMessage = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       baseUrl = Value(baseUrl),
       apiKey = Value(apiKey),
       defaultModel = Value(defaultModel),
       testStatus = Value(testStatus),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProviderConfigRecord> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? baseUrl,
    Expression<String>? apiKey,
    Expression<String>? defaultModel,
    Expression<String>? systemPrompt,
    Expression<bool>? isEnabled,
    Expression<String>? testStatus,
    Expression<DateTime>? lastTestedAt,
    Expression<String>? lastTestMessage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (baseUrl != null) 'base_url': baseUrl,
      if (apiKey != null) 'api_key': apiKey,
      if (defaultModel != null) 'default_model': defaultModel,
      if (systemPrompt != null) 'system_prompt': systemPrompt,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (testStatus != null) 'test_status': testStatus,
      if (lastTestedAt != null) 'last_tested_at': lastTestedAt,
      if (lastTestMessage != null) 'last_test_message': lastTestMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProviderConfigRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? baseUrl,
    Value<String>? apiKey,
    Value<String>? defaultModel,
    Value<String>? systemPrompt,
    Value<bool>? isEnabled,
    Value<String>? testStatus,
    Value<DateTime?>? lastTestedAt,
    Value<String?>? lastTestMessage,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProviderConfigRecordsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      defaultModel: defaultModel ?? this.defaultModel,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      isEnabled: isEnabled ?? this.isEnabled,
      testStatus: testStatus ?? this.testStatus,
      lastTestedAt: lastTestedAt ?? this.lastTestedAt,
      lastTestMessage: lastTestMessage ?? this.lastTestMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (baseUrl.present) {
      map['base_url'] = Variable<String>(baseUrl.value);
    }
    if (apiKey.present) {
      map['api_key'] = Variable<String>(apiKey.value);
    }
    if (defaultModel.present) {
      map['default_model'] = Variable<String>(defaultModel.value);
    }
    if (systemPrompt.present) {
      map['system_prompt'] = Variable<String>(systemPrompt.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (testStatus.present) {
      map['test_status'] = Variable<String>(testStatus.value);
    }
    if (lastTestedAt.present) {
      map['last_tested_at'] = Variable<DateTime>(lastTestedAt.value);
    }
    if (lastTestMessage.present) {
      map['last_test_message'] = Variable<String>(lastTestMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProviderConfigRecordsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('apiKey: $apiKey, ')
          ..write('defaultModel: $defaultModel, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('testStatus: $testStatus, ')
          ..write('lastTestedAt: $lastTestedAt, ')
          ..write('lastTestMessage: $lastTestMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WorkflowTaskRecordsTable workflowTaskRecords =
      $WorkflowTaskRecordsTable(this);
  late final $ProviderConfigRecordsTable providerConfigRecords =
      $ProviderConfigRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    workflowTaskRecords,
    providerConfigRecords,
  ];
}

typedef $$WorkflowTaskRecordsTableCreateCompanionBuilder =
    WorkflowTaskRecordsCompanion Function({
      required String id,
      required String kind,
      required String status,
      required String title,
      Value<String?> stage,
      Value<String?> errorMessage,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$WorkflowTaskRecordsTableUpdateCompanionBuilder =
    WorkflowTaskRecordsCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<String> status,
      Value<String> title,
      Value<String?> stage,
      Value<String?> errorMessage,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$WorkflowTaskRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkflowTaskRecordsTable> {
  $$WorkflowTaskRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkflowTaskRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkflowTaskRecordsTable> {
  $$WorkflowTaskRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkflowTaskRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkflowTaskRecordsTable> {
  $$WorkflowTaskRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WorkflowTaskRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkflowTaskRecordsTable,
          WorkflowTaskRecord,
          $$WorkflowTaskRecordsTableFilterComposer,
          $$WorkflowTaskRecordsTableOrderingComposer,
          $$WorkflowTaskRecordsTableAnnotationComposer,
          $$WorkflowTaskRecordsTableCreateCompanionBuilder,
          $$WorkflowTaskRecordsTableUpdateCompanionBuilder,
          (
            WorkflowTaskRecord,
            BaseReferences<
              _$AppDatabase,
              $WorkflowTaskRecordsTable,
              WorkflowTaskRecord
            >,
          ),
          WorkflowTaskRecord,
          PrefetchHooks Function()
        > {
  $$WorkflowTaskRecordsTableTableManager(
    _$AppDatabase db,
    $WorkflowTaskRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkflowTaskRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkflowTaskRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WorkflowTaskRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> stage = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkflowTaskRecordsCompanion(
                id: id,
                kind: kind,
                status: status,
                title: title,
                stage: stage,
                errorMessage: errorMessage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required String status,
                required String title,
                Value<String?> stage = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WorkflowTaskRecordsCompanion.insert(
                id: id,
                kind: kind,
                status: status,
                title: title,
                stage: stage,
                errorMessage: errorMessage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkflowTaskRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkflowTaskRecordsTable,
      WorkflowTaskRecord,
      $$WorkflowTaskRecordsTableFilterComposer,
      $$WorkflowTaskRecordsTableOrderingComposer,
      $$WorkflowTaskRecordsTableAnnotationComposer,
      $$WorkflowTaskRecordsTableCreateCompanionBuilder,
      $$WorkflowTaskRecordsTableUpdateCompanionBuilder,
      (
        WorkflowTaskRecord,
        BaseReferences<
          _$AppDatabase,
          $WorkflowTaskRecordsTable,
          WorkflowTaskRecord
        >,
      ),
      WorkflowTaskRecord,
      PrefetchHooks Function()
    >;
typedef $$ProviderConfigRecordsTableCreateCompanionBuilder =
    ProviderConfigRecordsCompanion Function({
      required String id,
      required String name,
      required String baseUrl,
      required String apiKey,
      required String defaultModel,
      Value<String> systemPrompt,
      Value<bool> isEnabled,
      required String testStatus,
      Value<DateTime?> lastTestedAt,
      Value<String?> lastTestMessage,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ProviderConfigRecordsTableUpdateCompanionBuilder =
    ProviderConfigRecordsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> baseUrl,
      Value<String> apiKey,
      Value<String> defaultModel,
      Value<String> systemPrompt,
      Value<bool> isEnabled,
      Value<String> testStatus,
      Value<DateTime?> lastTestedAt,
      Value<String?> lastTestMessage,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ProviderConfigRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ProviderConfigRecordsTable> {
  $$ProviderConfigRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apiKey => $composableBuilder(
    column: $table.apiKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultModel => $composableBuilder(
    column: $table.defaultModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemPrompt => $composableBuilder(
    column: $table.systemPrompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get testStatus => $composableBuilder(
    column: $table.testStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastTestedAt => $composableBuilder(
    column: $table.lastTestedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastTestMessage => $composableBuilder(
    column: $table.lastTestMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProviderConfigRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProviderConfigRecordsTable> {
  $$ProviderConfigRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apiKey => $composableBuilder(
    column: $table.apiKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultModel => $composableBuilder(
    column: $table.defaultModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemPrompt => $composableBuilder(
    column: $table.systemPrompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get testStatus => $composableBuilder(
    column: $table.testStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastTestedAt => $composableBuilder(
    column: $table.lastTestedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastTestMessage => $composableBuilder(
    column: $table.lastTestMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProviderConfigRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProviderConfigRecordsTable> {
  $$ProviderConfigRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get baseUrl =>
      $composableBuilder(column: $table.baseUrl, builder: (column) => column);

  GeneratedColumn<String> get apiKey =>
      $composableBuilder(column: $table.apiKey, builder: (column) => column);

  GeneratedColumn<String> get defaultModel => $composableBuilder(
    column: $table.defaultModel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get systemPrompt => $composableBuilder(
    column: $table.systemPrompt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<String> get testStatus => $composableBuilder(
    column: $table.testStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastTestedAt => $composableBuilder(
    column: $table.lastTestedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastTestMessage => $composableBuilder(
    column: $table.lastTestMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProviderConfigRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProviderConfigRecordsTable,
          ProviderConfigRecord,
          $$ProviderConfigRecordsTableFilterComposer,
          $$ProviderConfigRecordsTableOrderingComposer,
          $$ProviderConfigRecordsTableAnnotationComposer,
          $$ProviderConfigRecordsTableCreateCompanionBuilder,
          $$ProviderConfigRecordsTableUpdateCompanionBuilder,
          (
            ProviderConfigRecord,
            BaseReferences<
              _$AppDatabase,
              $ProviderConfigRecordsTable,
              ProviderConfigRecord
            >,
          ),
          ProviderConfigRecord,
          PrefetchHooks Function()
        > {
  $$ProviderConfigRecordsTableTableManager(
    _$AppDatabase db,
    $ProviderConfigRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProviderConfigRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ProviderConfigRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProviderConfigRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> baseUrl = const Value.absent(),
                Value<String> apiKey = const Value.absent(),
                Value<String> defaultModel = const Value.absent(),
                Value<String> systemPrompt = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<String> testStatus = const Value.absent(),
                Value<DateTime?> lastTestedAt = const Value.absent(),
                Value<String?> lastTestMessage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProviderConfigRecordsCompanion(
                id: id,
                name: name,
                baseUrl: baseUrl,
                apiKey: apiKey,
                defaultModel: defaultModel,
                systemPrompt: systemPrompt,
                isEnabled: isEnabled,
                testStatus: testStatus,
                lastTestedAt: lastTestedAt,
                lastTestMessage: lastTestMessage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String baseUrl,
                required String apiKey,
                required String defaultModel,
                Value<String> systemPrompt = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                required String testStatus,
                Value<DateTime?> lastTestedAt = const Value.absent(),
                Value<String?> lastTestMessage = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProviderConfigRecordsCompanion.insert(
                id: id,
                name: name,
                baseUrl: baseUrl,
                apiKey: apiKey,
                defaultModel: defaultModel,
                systemPrompt: systemPrompt,
                isEnabled: isEnabled,
                testStatus: testStatus,
                lastTestedAt: lastTestedAt,
                lastTestMessage: lastTestMessage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProviderConfigRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProviderConfigRecordsTable,
      ProviderConfigRecord,
      $$ProviderConfigRecordsTableFilterComposer,
      $$ProviderConfigRecordsTableOrderingComposer,
      $$ProviderConfigRecordsTableAnnotationComposer,
      $$ProviderConfigRecordsTableCreateCompanionBuilder,
      $$ProviderConfigRecordsTableUpdateCompanionBuilder,
      (
        ProviderConfigRecord,
        BaseReferences<
          _$AppDatabase,
          $ProviderConfigRecordsTable,
          ProviderConfigRecord
        >,
      ),
      ProviderConfigRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WorkflowTaskRecordsTableTableManager get workflowTaskRecords =>
      $$WorkflowTaskRecordsTableTableManager(_db, _db.workflowTaskRecords);
  $$ProviderConfigRecordsTableTableManager get providerConfigRecords =>
      $$ProviderConfigRecordsTableTableManager(_db, _db.providerConfigRecords);
}
