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

class $WorkflowPromptTraceRecordsTable extends WorkflowPromptTraceRecords
    with
        TableInfo<$WorkflowPromptTraceRecordsTable, WorkflowPromptTraceRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkflowPromptTraceRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _workflowTaskIdMeta = const VerificationMeta(
    'workflowTaskId',
  );
  @override
  late final GeneratedColumn<String> workflowTaskId = GeneratedColumn<String>(
    'workflow_task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workflow_task_records (id)',
    ),
  );
  static const VerificationMeta _traceMarkdownMeta = const VerificationMeta(
    'traceMarkdown',
  );
  @override
  late final GeneratedColumn<String> traceMarkdown = GeneratedColumn<String>(
    'trace_markdown',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    workflowTaskId,
    traceMarkdown,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workflow_prompt_trace_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkflowPromptTraceRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('workflow_task_id')) {
      context.handle(
        _workflowTaskIdMeta,
        workflowTaskId.isAcceptableOrUnknown(
          data['workflow_task_id']!,
          _workflowTaskIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workflowTaskIdMeta);
    }
    if (data.containsKey('trace_markdown')) {
      context.handle(
        _traceMarkdownMeta,
        traceMarkdown.isAcceptableOrUnknown(
          data['trace_markdown']!,
          _traceMarkdownMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_traceMarkdownMeta);
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
  Set<GeneratedColumn> get $primaryKey => {workflowTaskId};
  @override
  WorkflowPromptTraceRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkflowPromptTraceRecord(
      workflowTaskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workflow_task_id'],
      )!,
      traceMarkdown: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trace_markdown'],
      )!,
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
  $WorkflowPromptTraceRecordsTable createAlias(String alias) {
    return $WorkflowPromptTraceRecordsTable(attachedDatabase, alias);
  }
}

class WorkflowPromptTraceRecord extends DataClass
    implements Insertable<WorkflowPromptTraceRecord> {
  final String workflowTaskId;
  final String traceMarkdown;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WorkflowPromptTraceRecord({
    required this.workflowTaskId,
    required this.traceMarkdown,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['workflow_task_id'] = Variable<String>(workflowTaskId);
    map['trace_markdown'] = Variable<String>(traceMarkdown);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WorkflowPromptTraceRecordsCompanion toCompanion(bool nullToAbsent) {
    return WorkflowPromptTraceRecordsCompanion(
      workflowTaskId: Value(workflowTaskId),
      traceMarkdown: Value(traceMarkdown),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WorkflowPromptTraceRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkflowPromptTraceRecord(
      workflowTaskId: serializer.fromJson<String>(json['workflowTaskId']),
      traceMarkdown: serializer.fromJson<String>(json['traceMarkdown']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'workflowTaskId': serializer.toJson<String>(workflowTaskId),
      'traceMarkdown': serializer.toJson<String>(traceMarkdown),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WorkflowPromptTraceRecord copyWith({
    String? workflowTaskId,
    String? traceMarkdown,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WorkflowPromptTraceRecord(
    workflowTaskId: workflowTaskId ?? this.workflowTaskId,
    traceMarkdown: traceMarkdown ?? this.traceMarkdown,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WorkflowPromptTraceRecord copyWithCompanion(
    WorkflowPromptTraceRecordsCompanion data,
  ) {
    return WorkflowPromptTraceRecord(
      workflowTaskId: data.workflowTaskId.present
          ? data.workflowTaskId.value
          : this.workflowTaskId,
      traceMarkdown: data.traceMarkdown.present
          ? data.traceMarkdown.value
          : this.traceMarkdown,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkflowPromptTraceRecord(')
          ..write('workflowTaskId: $workflowTaskId, ')
          ..write('traceMarkdown: $traceMarkdown, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(workflowTaskId, traceMarkdown, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkflowPromptTraceRecord &&
          other.workflowTaskId == this.workflowTaskId &&
          other.traceMarkdown == this.traceMarkdown &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WorkflowPromptTraceRecordsCompanion
    extends UpdateCompanion<WorkflowPromptTraceRecord> {
  final Value<String> workflowTaskId;
  final Value<String> traceMarkdown;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WorkflowPromptTraceRecordsCompanion({
    this.workflowTaskId = const Value.absent(),
    this.traceMarkdown = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkflowPromptTraceRecordsCompanion.insert({
    required String workflowTaskId,
    required String traceMarkdown,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : workflowTaskId = Value(workflowTaskId),
       traceMarkdown = Value(traceMarkdown),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WorkflowPromptTraceRecord> custom({
    Expression<String>? workflowTaskId,
    Expression<String>? traceMarkdown,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (workflowTaskId != null) 'workflow_task_id': workflowTaskId,
      if (traceMarkdown != null) 'trace_markdown': traceMarkdown,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkflowPromptTraceRecordsCompanion copyWith({
    Value<String>? workflowTaskId,
    Value<String>? traceMarkdown,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WorkflowPromptTraceRecordsCompanion(
      workflowTaskId: workflowTaskId ?? this.workflowTaskId,
      traceMarkdown: traceMarkdown ?? this.traceMarkdown,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (workflowTaskId.present) {
      map['workflow_task_id'] = Variable<String>(workflowTaskId.value);
    }
    if (traceMarkdown.present) {
      map['trace_markdown'] = Variable<String>(traceMarkdown.value);
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
    return (StringBuffer('WorkflowPromptTraceRecordsCompanion(')
          ..write('workflowTaskId: $workflowTaskId, ')
          ..write('traceMarkdown: $traceMarkdown, ')
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

class $ProjectRecordsTable extends ProjectRecords
    with TableInfo<$ProjectRecordsTable, ProjectRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    title,
    description,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
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
  ProjectRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
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
  $ProjectRecordsTable createAlias(String alias) {
    return $ProjectRecordsTable(attachedDatabase, alias);
  }
}

class ProjectRecord extends DataClass implements Insertable<ProjectRecord> {
  final String id;
  final String title;
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ProjectRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProjectRecordsCompanion toCompanion(bool nullToAbsent) {
    return ProjectRecordsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProjectRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectRecord(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProjectRecord copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ProjectRecord(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProjectRecord copyWithCompanion(ProjectRecordsCompanion data) {
    return ProjectRecord(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectRecord(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, description, status, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectRecord &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProjectRecordsCompanion extends UpdateCompanion<ProjectRecord> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProjectRecordsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectRecordsCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProjectRecord> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? description,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProjectRecordsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
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
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
    return (StringBuffer('ProjectRecordsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StyleSampleRecordsTable extends StyleSampleRecords
    with TableInfo<$StyleSampleRecordsTable, StyleSampleRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StyleSampleRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
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
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _characterCountMeta = const VerificationMeta(
    'characterCount',
  );
  @override
  late final GeneratedColumn<int> characterCount = GeneratedColumn<int>(
    'character_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES project_records (id)',
    ),
  );
  static const VerificationMeta _sourceFilenameMeta = const VerificationMeta(
    'sourceFilename',
  );
  @override
  late final GeneratedColumn<String> sourceFilename = GeneratedColumn<String>(
    'source_filename',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _epubBookTitleMeta = const VerificationMeta(
    'epubBookTitle',
  );
  @override
  late final GeneratedColumn<String> epubBookTitle = GeneratedColumn<String>(
    'epub_book_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _epubAuthorMeta = const VerificationMeta(
    'epubAuthor',
  );
  @override
  late final GeneratedColumn<String> epubAuthor = GeneratedColumn<String>(
    'epub_author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _epubChapterTitleMeta = const VerificationMeta(
    'epubChapterTitle',
  );
  @override
  late final GeneratedColumn<String> epubChapterTitle = GeneratedColumn<String>(
    'epub_chapter_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _epubChapterIndexMeta = const VerificationMeta(
    'epubChapterIndex',
  );
  @override
  late final GeneratedColumn<int> epubChapterIndex = GeneratedColumn<int>(
    'epub_chapter_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    sourceType,
    title,
    content,
    characterCount,
    projectId,
    sourceFilename,
    epubBookTitle,
    epubAuthor,
    epubChapterTitle,
    epubChapterIndex,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'style_sample_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<StyleSampleRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('character_count')) {
      context.handle(
        _characterCountMeta,
        characterCount.isAcceptableOrUnknown(
          data['character_count']!,
          _characterCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterCountMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('source_filename')) {
      context.handle(
        _sourceFilenameMeta,
        sourceFilename.isAcceptableOrUnknown(
          data['source_filename']!,
          _sourceFilenameMeta,
        ),
      );
    }
    if (data.containsKey('epub_book_title')) {
      context.handle(
        _epubBookTitleMeta,
        epubBookTitle.isAcceptableOrUnknown(
          data['epub_book_title']!,
          _epubBookTitleMeta,
        ),
      );
    }
    if (data.containsKey('epub_author')) {
      context.handle(
        _epubAuthorMeta,
        epubAuthor.isAcceptableOrUnknown(data['epub_author']!, _epubAuthorMeta),
      );
    }
    if (data.containsKey('epub_chapter_title')) {
      context.handle(
        _epubChapterTitleMeta,
        epubChapterTitle.isAcceptableOrUnknown(
          data['epub_chapter_title']!,
          _epubChapterTitleMeta,
        ),
      );
    }
    if (data.containsKey('epub_chapter_index')) {
      context.handle(
        _epubChapterIndexMeta,
        epubChapterIndex.isAcceptableOrUnknown(
          data['epub_chapter_index']!,
          _epubChapterIndexMeta,
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
  StyleSampleRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StyleSampleRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      characterCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}character_count'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      sourceFilename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_filename'],
      ),
      epubBookTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}epub_book_title'],
      ),
      epubAuthor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}epub_author'],
      ),
      epubChapterTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}epub_chapter_title'],
      ),
      epubChapterIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}epub_chapter_index'],
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
  $StyleSampleRecordsTable createAlias(String alias) {
    return $StyleSampleRecordsTable(attachedDatabase, alias);
  }
}

class StyleSampleRecord extends DataClass
    implements Insertable<StyleSampleRecord> {
  final String id;
  final String sourceType;
  final String title;
  final String content;
  final int characterCount;
  final String? projectId;
  final String? sourceFilename;
  final String? epubBookTitle;
  final String? epubAuthor;
  final String? epubChapterTitle;
  final int? epubChapterIndex;
  final DateTime createdAt;
  final DateTime updatedAt;
  const StyleSampleRecord({
    required this.id,
    required this.sourceType,
    required this.title,
    required this.content,
    required this.characterCount,
    this.projectId,
    this.sourceFilename,
    this.epubBookTitle,
    this.epubAuthor,
    this.epubChapterTitle,
    this.epubChapterIndex,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_type'] = Variable<String>(sourceType);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    map['character_count'] = Variable<int>(characterCount);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    if (!nullToAbsent || sourceFilename != null) {
      map['source_filename'] = Variable<String>(sourceFilename);
    }
    if (!nullToAbsent || epubBookTitle != null) {
      map['epub_book_title'] = Variable<String>(epubBookTitle);
    }
    if (!nullToAbsent || epubAuthor != null) {
      map['epub_author'] = Variable<String>(epubAuthor);
    }
    if (!nullToAbsent || epubChapterTitle != null) {
      map['epub_chapter_title'] = Variable<String>(epubChapterTitle);
    }
    if (!nullToAbsent || epubChapterIndex != null) {
      map['epub_chapter_index'] = Variable<int>(epubChapterIndex);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StyleSampleRecordsCompanion toCompanion(bool nullToAbsent) {
    return StyleSampleRecordsCompanion(
      id: Value(id),
      sourceType: Value(sourceType),
      title: Value(title),
      content: Value(content),
      characterCount: Value(characterCount),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      sourceFilename: sourceFilename == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceFilename),
      epubBookTitle: epubBookTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(epubBookTitle),
      epubAuthor: epubAuthor == null && nullToAbsent
          ? const Value.absent()
          : Value(epubAuthor),
      epubChapterTitle: epubChapterTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(epubChapterTitle),
      epubChapterIndex: epubChapterIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(epubChapterIndex),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory StyleSampleRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StyleSampleRecord(
      id: serializer.fromJson<String>(json['id']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      characterCount: serializer.fromJson<int>(json['characterCount']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      sourceFilename: serializer.fromJson<String?>(json['sourceFilename']),
      epubBookTitle: serializer.fromJson<String?>(json['epubBookTitle']),
      epubAuthor: serializer.fromJson<String?>(json['epubAuthor']),
      epubChapterTitle: serializer.fromJson<String?>(json['epubChapterTitle']),
      epubChapterIndex: serializer.fromJson<int?>(json['epubChapterIndex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceType': serializer.toJson<String>(sourceType),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'characterCount': serializer.toJson<int>(characterCount),
      'projectId': serializer.toJson<String?>(projectId),
      'sourceFilename': serializer.toJson<String?>(sourceFilename),
      'epubBookTitle': serializer.toJson<String?>(epubBookTitle),
      'epubAuthor': serializer.toJson<String?>(epubAuthor),
      'epubChapterTitle': serializer.toJson<String?>(epubChapterTitle),
      'epubChapterIndex': serializer.toJson<int?>(epubChapterIndex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StyleSampleRecord copyWith({
    String? id,
    String? sourceType,
    String? title,
    String? content,
    int? characterCount,
    Value<String?> projectId = const Value.absent(),
    Value<String?> sourceFilename = const Value.absent(),
    Value<String?> epubBookTitle = const Value.absent(),
    Value<String?> epubAuthor = const Value.absent(),
    Value<String?> epubChapterTitle = const Value.absent(),
    Value<int?> epubChapterIndex = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => StyleSampleRecord(
    id: id ?? this.id,
    sourceType: sourceType ?? this.sourceType,
    title: title ?? this.title,
    content: content ?? this.content,
    characterCount: characterCount ?? this.characterCount,
    projectId: projectId.present ? projectId.value : this.projectId,
    sourceFilename: sourceFilename.present
        ? sourceFilename.value
        : this.sourceFilename,
    epubBookTitle: epubBookTitle.present
        ? epubBookTitle.value
        : this.epubBookTitle,
    epubAuthor: epubAuthor.present ? epubAuthor.value : this.epubAuthor,
    epubChapterTitle: epubChapterTitle.present
        ? epubChapterTitle.value
        : this.epubChapterTitle,
    epubChapterIndex: epubChapterIndex.present
        ? epubChapterIndex.value
        : this.epubChapterIndex,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  StyleSampleRecord copyWithCompanion(StyleSampleRecordsCompanion data) {
    return StyleSampleRecord(
      id: data.id.present ? data.id.value : this.id,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      characterCount: data.characterCount.present
          ? data.characterCount.value
          : this.characterCount,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      sourceFilename: data.sourceFilename.present
          ? data.sourceFilename.value
          : this.sourceFilename,
      epubBookTitle: data.epubBookTitle.present
          ? data.epubBookTitle.value
          : this.epubBookTitle,
      epubAuthor: data.epubAuthor.present
          ? data.epubAuthor.value
          : this.epubAuthor,
      epubChapterTitle: data.epubChapterTitle.present
          ? data.epubChapterTitle.value
          : this.epubChapterTitle,
      epubChapterIndex: data.epubChapterIndex.present
          ? data.epubChapterIndex.value
          : this.epubChapterIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StyleSampleRecord(')
          ..write('id: $id, ')
          ..write('sourceType: $sourceType, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('characterCount: $characterCount, ')
          ..write('projectId: $projectId, ')
          ..write('sourceFilename: $sourceFilename, ')
          ..write('epubBookTitle: $epubBookTitle, ')
          ..write('epubAuthor: $epubAuthor, ')
          ..write('epubChapterTitle: $epubChapterTitle, ')
          ..write('epubChapterIndex: $epubChapterIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceType,
    title,
    content,
    characterCount,
    projectId,
    sourceFilename,
    epubBookTitle,
    epubAuthor,
    epubChapterTitle,
    epubChapterIndex,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StyleSampleRecord &&
          other.id == this.id &&
          other.sourceType == this.sourceType &&
          other.title == this.title &&
          other.content == this.content &&
          other.characterCount == this.characterCount &&
          other.projectId == this.projectId &&
          other.sourceFilename == this.sourceFilename &&
          other.epubBookTitle == this.epubBookTitle &&
          other.epubAuthor == this.epubAuthor &&
          other.epubChapterTitle == this.epubChapterTitle &&
          other.epubChapterIndex == this.epubChapterIndex &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class StyleSampleRecordsCompanion extends UpdateCompanion<StyleSampleRecord> {
  final Value<String> id;
  final Value<String> sourceType;
  final Value<String> title;
  final Value<String> content;
  final Value<int> characterCount;
  final Value<String?> projectId;
  final Value<String?> sourceFilename;
  final Value<String?> epubBookTitle;
  final Value<String?> epubAuthor;
  final Value<String?> epubChapterTitle;
  final Value<int?> epubChapterIndex;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const StyleSampleRecordsCompanion({
    this.id = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.characterCount = const Value.absent(),
    this.projectId = const Value.absent(),
    this.sourceFilename = const Value.absent(),
    this.epubBookTitle = const Value.absent(),
    this.epubAuthor = const Value.absent(),
    this.epubChapterTitle = const Value.absent(),
    this.epubChapterIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StyleSampleRecordsCompanion.insert({
    required String id,
    required String sourceType,
    required String title,
    required String content,
    required int characterCount,
    this.projectId = const Value.absent(),
    this.sourceFilename = const Value.absent(),
    this.epubBookTitle = const Value.absent(),
    this.epubAuthor = const Value.absent(),
    this.epubChapterTitle = const Value.absent(),
    this.epubChapterIndex = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceType = Value(sourceType),
       title = Value(title),
       content = Value(content),
       characterCount = Value(characterCount),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<StyleSampleRecord> custom({
    Expression<String>? id,
    Expression<String>? sourceType,
    Expression<String>? title,
    Expression<String>? content,
    Expression<int>? characterCount,
    Expression<String>? projectId,
    Expression<String>? sourceFilename,
    Expression<String>? epubBookTitle,
    Expression<String>? epubAuthor,
    Expression<String>? epubChapterTitle,
    Expression<int>? epubChapterIndex,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceType != null) 'source_type': sourceType,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (characterCount != null) 'character_count': characterCount,
      if (projectId != null) 'project_id': projectId,
      if (sourceFilename != null) 'source_filename': sourceFilename,
      if (epubBookTitle != null) 'epub_book_title': epubBookTitle,
      if (epubAuthor != null) 'epub_author': epubAuthor,
      if (epubChapterTitle != null) 'epub_chapter_title': epubChapterTitle,
      if (epubChapterIndex != null) 'epub_chapter_index': epubChapterIndex,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StyleSampleRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceType,
    Value<String>? title,
    Value<String>? content,
    Value<int>? characterCount,
    Value<String?>? projectId,
    Value<String?>? sourceFilename,
    Value<String?>? epubBookTitle,
    Value<String?>? epubAuthor,
    Value<String?>? epubChapterTitle,
    Value<int?>? epubChapterIndex,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return StyleSampleRecordsCompanion(
      id: id ?? this.id,
      sourceType: sourceType ?? this.sourceType,
      title: title ?? this.title,
      content: content ?? this.content,
      characterCount: characterCount ?? this.characterCount,
      projectId: projectId ?? this.projectId,
      sourceFilename: sourceFilename ?? this.sourceFilename,
      epubBookTitle: epubBookTitle ?? this.epubBookTitle,
      epubAuthor: epubAuthor ?? this.epubAuthor,
      epubChapterTitle: epubChapterTitle ?? this.epubChapterTitle,
      epubChapterIndex: epubChapterIndex ?? this.epubChapterIndex,
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
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (characterCount.present) {
      map['character_count'] = Variable<int>(characterCount.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (sourceFilename.present) {
      map['source_filename'] = Variable<String>(sourceFilename.value);
    }
    if (epubBookTitle.present) {
      map['epub_book_title'] = Variable<String>(epubBookTitle.value);
    }
    if (epubAuthor.present) {
      map['epub_author'] = Variable<String>(epubAuthor.value);
    }
    if (epubChapterTitle.present) {
      map['epub_chapter_title'] = Variable<String>(epubChapterTitle.value);
    }
    if (epubChapterIndex.present) {
      map['epub_chapter_index'] = Variable<int>(epubChapterIndex.value);
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
    return (StringBuffer('StyleSampleRecordsCompanion(')
          ..write('id: $id, ')
          ..write('sourceType: $sourceType, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('characterCount: $characterCount, ')
          ..write('projectId: $projectId, ')
          ..write('sourceFilename: $sourceFilename, ')
          ..write('epubBookTitle: $epubBookTitle, ')
          ..write('epubAuthor: $epubAuthor, ')
          ..write('epubChapterTitle: $epubChapterTitle, ')
          ..write('epubChapterIndex: $epubChapterIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StyleAnalysisRunRecordsTable extends StyleAnalysisRunRecords
    with TableInfo<$StyleAnalysisRunRecordsTable, StyleAnalysisRunRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StyleAnalysisRunRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workflowTaskIdMeta = const VerificationMeta(
    'workflowTaskId',
  );
  @override
  late final GeneratedColumn<String> workflowTaskId = GeneratedColumn<String>(
    'workflow_task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workflow_task_records (id)',
    ),
  );
  static const VerificationMeta _sampleIdMeta = const VerificationMeta(
    'sampleId',
  );
  @override
  late final GeneratedColumn<String> sampleId = GeneratedColumn<String>(
    'sample_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES style_sample_records (id)',
    ),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES provider_config_records (id)',
    ),
  );
  static const VerificationMeta _modelNameMeta = const VerificationMeta(
    'modelName',
  );
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
    'model_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _styleNameMeta = const VerificationMeta(
    'styleName',
  );
  @override
  late final GeneratedColumn<String> styleName = GeneratedColumn<String>(
    'style_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES project_records (id)',
    ),
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
  static const VerificationMeta _logsMeta = const VerificationMeta('logs');
  @override
  late final GeneratedColumn<String> logs = GeneratedColumn<String>(
    'logs',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _analysisReportMarkdownMeta =
      const VerificationMeta('analysisReportMarkdown');
  @override
  late final GeneratedColumn<String> analysisReportMarkdown =
      GeneratedColumn<String>(
        'analysis_report_markdown',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _voiceProfileMarkdownMeta =
      const VerificationMeta('voiceProfileMarkdown');
  @override
  late final GeneratedColumn<String> voiceProfileMarkdown =
      GeneratedColumn<String>(
        'voice_profile_markdown',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chunkCountMeta = const VerificationMeta(
    'chunkCount',
  );
  @override
  late final GeneratedColumn<int> chunkCount = GeneratedColumn<int>(
    'chunk_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _characterCountMeta = const VerificationMeta(
    'characterCount',
  );
  @override
  late final GeneratedColumn<int> characterCount = GeneratedColumn<int>(
    'character_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workflowTaskId,
    sampleId,
    providerId,
    modelName,
    styleName,
    projectId,
    status,
    stage,
    errorMessage,
    logs,
    analysisReportMarkdown,
    voiceProfileMarkdown,
    profileId,
    chunkCount,
    characterCount,
    createdAt,
    updatedAt,
    startedAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'style_analysis_run_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<StyleAnalysisRunRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workflow_task_id')) {
      context.handle(
        _workflowTaskIdMeta,
        workflowTaskId.isAcceptableOrUnknown(
          data['workflow_task_id']!,
          _workflowTaskIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workflowTaskIdMeta);
    }
    if (data.containsKey('sample_id')) {
      context.handle(
        _sampleIdMeta,
        sampleId.isAcceptableOrUnknown(data['sample_id']!, _sampleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sampleIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('model_name')) {
      context.handle(
        _modelNameMeta,
        modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta),
      );
    } else if (isInserting) {
      context.missing(_modelNameMeta);
    }
    if (data.containsKey('style_name')) {
      context.handle(
        _styleNameMeta,
        styleName.isAcceptableOrUnknown(data['style_name']!, _styleNameMeta),
      );
    } else if (isInserting) {
      context.missing(_styleNameMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
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
    if (data.containsKey('logs')) {
      context.handle(
        _logsMeta,
        logs.isAcceptableOrUnknown(data['logs']!, _logsMeta),
      );
    }
    if (data.containsKey('analysis_report_markdown')) {
      context.handle(
        _analysisReportMarkdownMeta,
        analysisReportMarkdown.isAcceptableOrUnknown(
          data['analysis_report_markdown']!,
          _analysisReportMarkdownMeta,
        ),
      );
    }
    if (data.containsKey('voice_profile_markdown')) {
      context.handle(
        _voiceProfileMarkdownMeta,
        voiceProfileMarkdown.isAcceptableOrUnknown(
          data['voice_profile_markdown']!,
          _voiceProfileMarkdownMeta,
        ),
      );
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('chunk_count')) {
      context.handle(
        _chunkCountMeta,
        chunkCount.isAcceptableOrUnknown(data['chunk_count']!, _chunkCountMeta),
      );
    }
    if (data.containsKey('character_count')) {
      context.handle(
        _characterCountMeta,
        characterCount.isAcceptableOrUnknown(
          data['character_count']!,
          _characterCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterCountMeta);
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
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StyleAnalysisRunRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StyleAnalysisRunRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workflowTaskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workflow_task_id'],
      )!,
      sampleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sample_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      modelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_name'],
      )!,
      styleName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}style_name'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      logs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logs'],
      )!,
      analysisReportMarkdown: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}analysis_report_markdown'],
      ),
      voiceProfileMarkdown: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voice_profile_markdown'],
      ),
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      ),
      chunkCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chunk_count'],
      )!,
      characterCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}character_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $StyleAnalysisRunRecordsTable createAlias(String alias) {
    return $StyleAnalysisRunRecordsTable(attachedDatabase, alias);
  }
}

class StyleAnalysisRunRecord extends DataClass
    implements Insertable<StyleAnalysisRunRecord> {
  final String id;
  final String workflowTaskId;
  final String sampleId;
  final String providerId;
  final String modelName;
  final String styleName;
  final String? projectId;
  final String status;
  final String? stage;
  final String? errorMessage;
  final String logs;
  final String? analysisReportMarkdown;
  final String? voiceProfileMarkdown;
  final String? profileId;
  final int chunkCount;
  final int characterCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  const StyleAnalysisRunRecord({
    required this.id,
    required this.workflowTaskId,
    required this.sampleId,
    required this.providerId,
    required this.modelName,
    required this.styleName,
    this.projectId,
    required this.status,
    this.stage,
    this.errorMessage,
    required this.logs,
    this.analysisReportMarkdown,
    this.voiceProfileMarkdown,
    this.profileId,
    required this.chunkCount,
    required this.characterCount,
    required this.createdAt,
    required this.updatedAt,
    this.startedAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workflow_task_id'] = Variable<String>(workflowTaskId);
    map['sample_id'] = Variable<String>(sampleId);
    map['provider_id'] = Variable<String>(providerId);
    map['model_name'] = Variable<String>(modelName);
    map['style_name'] = Variable<String>(styleName);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || stage != null) {
      map['stage'] = Variable<String>(stage);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['logs'] = Variable<String>(logs);
    if (!nullToAbsent || analysisReportMarkdown != null) {
      map['analysis_report_markdown'] = Variable<String>(
        analysisReportMarkdown,
      );
    }
    if (!nullToAbsent || voiceProfileMarkdown != null) {
      map['voice_profile_markdown'] = Variable<String>(voiceProfileMarkdown);
    }
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<String>(profileId);
    }
    map['chunk_count'] = Variable<int>(chunkCount);
    map['character_count'] = Variable<int>(characterCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  StyleAnalysisRunRecordsCompanion toCompanion(bool nullToAbsent) {
    return StyleAnalysisRunRecordsCompanion(
      id: Value(id),
      workflowTaskId: Value(workflowTaskId),
      sampleId: Value(sampleId),
      providerId: Value(providerId),
      modelName: Value(modelName),
      styleName: Value(styleName),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      status: Value(status),
      stage: stage == null && nullToAbsent
          ? const Value.absent()
          : Value(stage),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      logs: Value(logs),
      analysisReportMarkdown: analysisReportMarkdown == null && nullToAbsent
          ? const Value.absent()
          : Value(analysisReportMarkdown),
      voiceProfileMarkdown: voiceProfileMarkdown == null && nullToAbsent
          ? const Value.absent()
          : Value(voiceProfileMarkdown),
      profileId: profileId == null && nullToAbsent
          ? const Value.absent()
          : Value(profileId),
      chunkCount: Value(chunkCount),
      characterCount: Value(characterCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory StyleAnalysisRunRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StyleAnalysisRunRecord(
      id: serializer.fromJson<String>(json['id']),
      workflowTaskId: serializer.fromJson<String>(json['workflowTaskId']),
      sampleId: serializer.fromJson<String>(json['sampleId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      modelName: serializer.fromJson<String>(json['modelName']),
      styleName: serializer.fromJson<String>(json['styleName']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      status: serializer.fromJson<String>(json['status']),
      stage: serializer.fromJson<String?>(json['stage']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      logs: serializer.fromJson<String>(json['logs']),
      analysisReportMarkdown: serializer.fromJson<String?>(
        json['analysisReportMarkdown'],
      ),
      voiceProfileMarkdown: serializer.fromJson<String?>(
        json['voiceProfileMarkdown'],
      ),
      profileId: serializer.fromJson<String?>(json['profileId']),
      chunkCount: serializer.fromJson<int>(json['chunkCount']),
      characterCount: serializer.fromJson<int>(json['characterCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workflowTaskId': serializer.toJson<String>(workflowTaskId),
      'sampleId': serializer.toJson<String>(sampleId),
      'providerId': serializer.toJson<String>(providerId),
      'modelName': serializer.toJson<String>(modelName),
      'styleName': serializer.toJson<String>(styleName),
      'projectId': serializer.toJson<String?>(projectId),
      'status': serializer.toJson<String>(status),
      'stage': serializer.toJson<String?>(stage),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'logs': serializer.toJson<String>(logs),
      'analysisReportMarkdown': serializer.toJson<String?>(
        analysisReportMarkdown,
      ),
      'voiceProfileMarkdown': serializer.toJson<String?>(voiceProfileMarkdown),
      'profileId': serializer.toJson<String?>(profileId),
      'chunkCount': serializer.toJson<int>(chunkCount),
      'characterCount': serializer.toJson<int>(characterCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  StyleAnalysisRunRecord copyWith({
    String? id,
    String? workflowTaskId,
    String? sampleId,
    String? providerId,
    String? modelName,
    String? styleName,
    Value<String?> projectId = const Value.absent(),
    String? status,
    Value<String?> stage = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    String? logs,
    Value<String?> analysisReportMarkdown = const Value.absent(),
    Value<String?> voiceProfileMarkdown = const Value.absent(),
    Value<String?> profileId = const Value.absent(),
    int? chunkCount,
    int? characterCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
  }) => StyleAnalysisRunRecord(
    id: id ?? this.id,
    workflowTaskId: workflowTaskId ?? this.workflowTaskId,
    sampleId: sampleId ?? this.sampleId,
    providerId: providerId ?? this.providerId,
    modelName: modelName ?? this.modelName,
    styleName: styleName ?? this.styleName,
    projectId: projectId.present ? projectId.value : this.projectId,
    status: status ?? this.status,
    stage: stage.present ? stage.value : this.stage,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    logs: logs ?? this.logs,
    analysisReportMarkdown: analysisReportMarkdown.present
        ? analysisReportMarkdown.value
        : this.analysisReportMarkdown,
    voiceProfileMarkdown: voiceProfileMarkdown.present
        ? voiceProfileMarkdown.value
        : this.voiceProfileMarkdown,
    profileId: profileId.present ? profileId.value : this.profileId,
    chunkCount: chunkCount ?? this.chunkCount,
    characterCount: characterCount ?? this.characterCount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  StyleAnalysisRunRecord copyWithCompanion(
    StyleAnalysisRunRecordsCompanion data,
  ) {
    return StyleAnalysisRunRecord(
      id: data.id.present ? data.id.value : this.id,
      workflowTaskId: data.workflowTaskId.present
          ? data.workflowTaskId.value
          : this.workflowTaskId,
      sampleId: data.sampleId.present ? data.sampleId.value : this.sampleId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      styleName: data.styleName.present ? data.styleName.value : this.styleName,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      status: data.status.present ? data.status.value : this.status,
      stage: data.stage.present ? data.stage.value : this.stage,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      logs: data.logs.present ? data.logs.value : this.logs,
      analysisReportMarkdown: data.analysisReportMarkdown.present
          ? data.analysisReportMarkdown.value
          : this.analysisReportMarkdown,
      voiceProfileMarkdown: data.voiceProfileMarkdown.present
          ? data.voiceProfileMarkdown.value
          : this.voiceProfileMarkdown,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      chunkCount: data.chunkCount.present
          ? data.chunkCount.value
          : this.chunkCount,
      characterCount: data.characterCount.present
          ? data.characterCount.value
          : this.characterCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StyleAnalysisRunRecord(')
          ..write('id: $id, ')
          ..write('workflowTaskId: $workflowTaskId, ')
          ..write('sampleId: $sampleId, ')
          ..write('providerId: $providerId, ')
          ..write('modelName: $modelName, ')
          ..write('styleName: $styleName, ')
          ..write('projectId: $projectId, ')
          ..write('status: $status, ')
          ..write('stage: $stage, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('logs: $logs, ')
          ..write('analysisReportMarkdown: $analysisReportMarkdown, ')
          ..write('voiceProfileMarkdown: $voiceProfileMarkdown, ')
          ..write('profileId: $profileId, ')
          ..write('chunkCount: $chunkCount, ')
          ..write('characterCount: $characterCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workflowTaskId,
    sampleId,
    providerId,
    modelName,
    styleName,
    projectId,
    status,
    stage,
    errorMessage,
    logs,
    analysisReportMarkdown,
    voiceProfileMarkdown,
    profileId,
    chunkCount,
    characterCount,
    createdAt,
    updatedAt,
    startedAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StyleAnalysisRunRecord &&
          other.id == this.id &&
          other.workflowTaskId == this.workflowTaskId &&
          other.sampleId == this.sampleId &&
          other.providerId == this.providerId &&
          other.modelName == this.modelName &&
          other.styleName == this.styleName &&
          other.projectId == this.projectId &&
          other.status == this.status &&
          other.stage == this.stage &&
          other.errorMessage == this.errorMessage &&
          other.logs == this.logs &&
          other.analysisReportMarkdown == this.analysisReportMarkdown &&
          other.voiceProfileMarkdown == this.voiceProfileMarkdown &&
          other.profileId == this.profileId &&
          other.chunkCount == this.chunkCount &&
          other.characterCount == this.characterCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt);
}

class StyleAnalysisRunRecordsCompanion
    extends UpdateCompanion<StyleAnalysisRunRecord> {
  final Value<String> id;
  final Value<String> workflowTaskId;
  final Value<String> sampleId;
  final Value<String> providerId;
  final Value<String> modelName;
  final Value<String> styleName;
  final Value<String?> projectId;
  final Value<String> status;
  final Value<String?> stage;
  final Value<String?> errorMessage;
  final Value<String> logs;
  final Value<String?> analysisReportMarkdown;
  final Value<String?> voiceProfileMarkdown;
  final Value<String?> profileId;
  final Value<int> chunkCount;
  final Value<int> characterCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const StyleAnalysisRunRecordsCompanion({
    this.id = const Value.absent(),
    this.workflowTaskId = const Value.absent(),
    this.sampleId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.modelName = const Value.absent(),
    this.styleName = const Value.absent(),
    this.projectId = const Value.absent(),
    this.status = const Value.absent(),
    this.stage = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.logs = const Value.absent(),
    this.analysisReportMarkdown = const Value.absent(),
    this.voiceProfileMarkdown = const Value.absent(),
    this.profileId = const Value.absent(),
    this.chunkCount = const Value.absent(),
    this.characterCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StyleAnalysisRunRecordsCompanion.insert({
    required String id,
    required String workflowTaskId,
    required String sampleId,
    required String providerId,
    required String modelName,
    required String styleName,
    this.projectId = const Value.absent(),
    required String status,
    this.stage = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.logs = const Value.absent(),
    this.analysisReportMarkdown = const Value.absent(),
    this.voiceProfileMarkdown = const Value.absent(),
    this.profileId = const Value.absent(),
    this.chunkCount = const Value.absent(),
    required int characterCount,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workflowTaskId = Value(workflowTaskId),
       sampleId = Value(sampleId),
       providerId = Value(providerId),
       modelName = Value(modelName),
       styleName = Value(styleName),
       status = Value(status),
       characterCount = Value(characterCount),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<StyleAnalysisRunRecord> custom({
    Expression<String>? id,
    Expression<String>? workflowTaskId,
    Expression<String>? sampleId,
    Expression<String>? providerId,
    Expression<String>? modelName,
    Expression<String>? styleName,
    Expression<String>? projectId,
    Expression<String>? status,
    Expression<String>? stage,
    Expression<String>? errorMessage,
    Expression<String>? logs,
    Expression<String>? analysisReportMarkdown,
    Expression<String>? voiceProfileMarkdown,
    Expression<String>? profileId,
    Expression<int>? chunkCount,
    Expression<int>? characterCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workflowTaskId != null) 'workflow_task_id': workflowTaskId,
      if (sampleId != null) 'sample_id': sampleId,
      if (providerId != null) 'provider_id': providerId,
      if (modelName != null) 'model_name': modelName,
      if (styleName != null) 'style_name': styleName,
      if (projectId != null) 'project_id': projectId,
      if (status != null) 'status': status,
      if (stage != null) 'stage': stage,
      if (errorMessage != null) 'error_message': errorMessage,
      if (logs != null) 'logs': logs,
      if (analysisReportMarkdown != null)
        'analysis_report_markdown': analysisReportMarkdown,
      if (voiceProfileMarkdown != null)
        'voice_profile_markdown': voiceProfileMarkdown,
      if (profileId != null) 'profile_id': profileId,
      if (chunkCount != null) 'chunk_count': chunkCount,
      if (characterCount != null) 'character_count': characterCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StyleAnalysisRunRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? workflowTaskId,
    Value<String>? sampleId,
    Value<String>? providerId,
    Value<String>? modelName,
    Value<String>? styleName,
    Value<String?>? projectId,
    Value<String>? status,
    Value<String?>? stage,
    Value<String?>? errorMessage,
    Value<String>? logs,
    Value<String?>? analysisReportMarkdown,
    Value<String?>? voiceProfileMarkdown,
    Value<String?>? profileId,
    Value<int>? chunkCount,
    Value<int>? characterCount,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return StyleAnalysisRunRecordsCompanion(
      id: id ?? this.id,
      workflowTaskId: workflowTaskId ?? this.workflowTaskId,
      sampleId: sampleId ?? this.sampleId,
      providerId: providerId ?? this.providerId,
      modelName: modelName ?? this.modelName,
      styleName: styleName ?? this.styleName,
      projectId: projectId ?? this.projectId,
      status: status ?? this.status,
      stage: stage ?? this.stage,
      errorMessage: errorMessage ?? this.errorMessage,
      logs: logs ?? this.logs,
      analysisReportMarkdown:
          analysisReportMarkdown ?? this.analysisReportMarkdown,
      voiceProfileMarkdown: voiceProfileMarkdown ?? this.voiceProfileMarkdown,
      profileId: profileId ?? this.profileId,
      chunkCount: chunkCount ?? this.chunkCount,
      characterCount: characterCount ?? this.characterCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workflowTaskId.present) {
      map['workflow_task_id'] = Variable<String>(workflowTaskId.value);
    }
    if (sampleId.present) {
      map['sample_id'] = Variable<String>(sampleId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (styleName.present) {
      map['style_name'] = Variable<String>(styleName.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (logs.present) {
      map['logs'] = Variable<String>(logs.value);
    }
    if (analysisReportMarkdown.present) {
      map['analysis_report_markdown'] = Variable<String>(
        analysisReportMarkdown.value,
      );
    }
    if (voiceProfileMarkdown.present) {
      map['voice_profile_markdown'] = Variable<String>(
        voiceProfileMarkdown.value,
      );
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (chunkCount.present) {
      map['chunk_count'] = Variable<int>(chunkCount.value);
    }
    if (characterCount.present) {
      map['character_count'] = Variable<int>(characterCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StyleAnalysisRunRecordsCompanion(')
          ..write('id: $id, ')
          ..write('workflowTaskId: $workflowTaskId, ')
          ..write('sampleId: $sampleId, ')
          ..write('providerId: $providerId, ')
          ..write('modelName: $modelName, ')
          ..write('styleName: $styleName, ')
          ..write('projectId: $projectId, ')
          ..write('status: $status, ')
          ..write('stage: $stage, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('logs: $logs, ')
          ..write('analysisReportMarkdown: $analysisReportMarkdown, ')
          ..write('voiceProfileMarkdown: $voiceProfileMarkdown, ')
          ..write('profileId: $profileId, ')
          ..write('chunkCount: $chunkCount, ')
          ..write('characterCount: $characterCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StyleProfileRecordsTable extends StyleProfileRecords
    with TableInfo<$StyleProfileRecordsTable, StyleProfileRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StyleProfileRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceRunIdMeta = const VerificationMeta(
    'sourceRunId',
  );
  @override
  late final GeneratedColumn<String> sourceRunId = GeneratedColumn<String>(
    'source_run_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES style_analysis_run_records (id)',
    ),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES provider_config_records (id)',
    ),
  );
  static const VerificationMeta _modelNameMeta = const VerificationMeta(
    'modelName',
  );
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
    'model_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _styleNameMeta = const VerificationMeta(
    'styleName',
  );
  @override
  late final GeneratedColumn<String> styleName = GeneratedColumn<String>(
    'style_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileMarkdownMeta = const VerificationMeta(
    'profileMarkdown',
  );
  @override
  late final GeneratedColumn<String> profileMarkdown = GeneratedColumn<String>(
    'profile_markdown',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _analysisReportMarkdownMeta =
      const VerificationMeta('analysisReportMarkdown');
  @override
  late final GeneratedColumn<String> analysisReportMarkdown =
      GeneratedColumn<String>(
        'analysis_report_markdown',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES project_records (id)',
    ),
  );
  static const VerificationMeta _sourceSampleIdMeta = const VerificationMeta(
    'sourceSampleId',
  );
  @override
  late final GeneratedColumn<String> sourceSampleId = GeneratedColumn<String>(
    'source_sample_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES style_sample_records (id)',
    ),
  );
  static const VerificationMeta _sourceTitleMeta = const VerificationMeta(
    'sourceTitle',
  );
  @override
  late final GeneratedColumn<String> sourceTitle = GeneratedColumn<String>(
    'source_title',
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
    sourceRunId,
    providerId,
    modelName,
    styleName,
    profileMarkdown,
    analysisReportMarkdown,
    projectId,
    sourceSampleId,
    sourceTitle,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'style_profile_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<StyleProfileRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_run_id')) {
      context.handle(
        _sourceRunIdMeta,
        sourceRunId.isAcceptableOrUnknown(
          data['source_run_id']!,
          _sourceRunIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceRunIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('model_name')) {
      context.handle(
        _modelNameMeta,
        modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta),
      );
    } else if (isInserting) {
      context.missing(_modelNameMeta);
    }
    if (data.containsKey('style_name')) {
      context.handle(
        _styleNameMeta,
        styleName.isAcceptableOrUnknown(data['style_name']!, _styleNameMeta),
      );
    } else if (isInserting) {
      context.missing(_styleNameMeta);
    }
    if (data.containsKey('profile_markdown')) {
      context.handle(
        _profileMarkdownMeta,
        profileMarkdown.isAcceptableOrUnknown(
          data['profile_markdown']!,
          _profileMarkdownMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_profileMarkdownMeta);
    }
    if (data.containsKey('analysis_report_markdown')) {
      context.handle(
        _analysisReportMarkdownMeta,
        analysisReportMarkdown.isAcceptableOrUnknown(
          data['analysis_report_markdown']!,
          _analysisReportMarkdownMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_analysisReportMarkdownMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('source_sample_id')) {
      context.handle(
        _sourceSampleIdMeta,
        sourceSampleId.isAcceptableOrUnknown(
          data['source_sample_id']!,
          _sourceSampleIdMeta,
        ),
      );
    }
    if (data.containsKey('source_title')) {
      context.handle(
        _sourceTitleMeta,
        sourceTitle.isAcceptableOrUnknown(
          data['source_title']!,
          _sourceTitleMeta,
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
  StyleProfileRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StyleProfileRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceRunId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_run_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      modelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_name'],
      )!,
      styleName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}style_name'],
      )!,
      profileMarkdown: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_markdown'],
      )!,
      analysisReportMarkdown: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}analysis_report_markdown'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      sourceSampleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_sample_id'],
      ),
      sourceTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_title'],
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
  $StyleProfileRecordsTable createAlias(String alias) {
    return $StyleProfileRecordsTable(attachedDatabase, alias);
  }
}

class StyleProfileRecord extends DataClass
    implements Insertable<StyleProfileRecord> {
  final String id;
  final String sourceRunId;
  final String providerId;
  final String modelName;
  final String styleName;
  final String profileMarkdown;
  final String analysisReportMarkdown;
  final String? projectId;
  final String? sourceSampleId;
  final String? sourceTitle;
  final DateTime createdAt;
  final DateTime updatedAt;
  const StyleProfileRecord({
    required this.id,
    required this.sourceRunId,
    required this.providerId,
    required this.modelName,
    required this.styleName,
    required this.profileMarkdown,
    required this.analysisReportMarkdown,
    this.projectId,
    this.sourceSampleId,
    this.sourceTitle,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_run_id'] = Variable<String>(sourceRunId);
    map['provider_id'] = Variable<String>(providerId);
    map['model_name'] = Variable<String>(modelName);
    map['style_name'] = Variable<String>(styleName);
    map['profile_markdown'] = Variable<String>(profileMarkdown);
    map['analysis_report_markdown'] = Variable<String>(analysisReportMarkdown);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    if (!nullToAbsent || sourceSampleId != null) {
      map['source_sample_id'] = Variable<String>(sourceSampleId);
    }
    if (!nullToAbsent || sourceTitle != null) {
      map['source_title'] = Variable<String>(sourceTitle);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StyleProfileRecordsCompanion toCompanion(bool nullToAbsent) {
    return StyleProfileRecordsCompanion(
      id: Value(id),
      sourceRunId: Value(sourceRunId),
      providerId: Value(providerId),
      modelName: Value(modelName),
      styleName: Value(styleName),
      profileMarkdown: Value(profileMarkdown),
      analysisReportMarkdown: Value(analysisReportMarkdown),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      sourceSampleId: sourceSampleId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceSampleId),
      sourceTitle: sourceTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceTitle),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory StyleProfileRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StyleProfileRecord(
      id: serializer.fromJson<String>(json['id']),
      sourceRunId: serializer.fromJson<String>(json['sourceRunId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      modelName: serializer.fromJson<String>(json['modelName']),
      styleName: serializer.fromJson<String>(json['styleName']),
      profileMarkdown: serializer.fromJson<String>(json['profileMarkdown']),
      analysisReportMarkdown: serializer.fromJson<String>(
        json['analysisReportMarkdown'],
      ),
      projectId: serializer.fromJson<String?>(json['projectId']),
      sourceSampleId: serializer.fromJson<String?>(json['sourceSampleId']),
      sourceTitle: serializer.fromJson<String?>(json['sourceTitle']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceRunId': serializer.toJson<String>(sourceRunId),
      'providerId': serializer.toJson<String>(providerId),
      'modelName': serializer.toJson<String>(modelName),
      'styleName': serializer.toJson<String>(styleName),
      'profileMarkdown': serializer.toJson<String>(profileMarkdown),
      'analysisReportMarkdown': serializer.toJson<String>(
        analysisReportMarkdown,
      ),
      'projectId': serializer.toJson<String?>(projectId),
      'sourceSampleId': serializer.toJson<String?>(sourceSampleId),
      'sourceTitle': serializer.toJson<String?>(sourceTitle),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StyleProfileRecord copyWith({
    String? id,
    String? sourceRunId,
    String? providerId,
    String? modelName,
    String? styleName,
    String? profileMarkdown,
    String? analysisReportMarkdown,
    Value<String?> projectId = const Value.absent(),
    Value<String?> sourceSampleId = const Value.absent(),
    Value<String?> sourceTitle = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => StyleProfileRecord(
    id: id ?? this.id,
    sourceRunId: sourceRunId ?? this.sourceRunId,
    providerId: providerId ?? this.providerId,
    modelName: modelName ?? this.modelName,
    styleName: styleName ?? this.styleName,
    profileMarkdown: profileMarkdown ?? this.profileMarkdown,
    analysisReportMarkdown:
        analysisReportMarkdown ?? this.analysisReportMarkdown,
    projectId: projectId.present ? projectId.value : this.projectId,
    sourceSampleId: sourceSampleId.present
        ? sourceSampleId.value
        : this.sourceSampleId,
    sourceTitle: sourceTitle.present ? sourceTitle.value : this.sourceTitle,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  StyleProfileRecord copyWithCompanion(StyleProfileRecordsCompanion data) {
    return StyleProfileRecord(
      id: data.id.present ? data.id.value : this.id,
      sourceRunId: data.sourceRunId.present
          ? data.sourceRunId.value
          : this.sourceRunId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      styleName: data.styleName.present ? data.styleName.value : this.styleName,
      profileMarkdown: data.profileMarkdown.present
          ? data.profileMarkdown.value
          : this.profileMarkdown,
      analysisReportMarkdown: data.analysisReportMarkdown.present
          ? data.analysisReportMarkdown.value
          : this.analysisReportMarkdown,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      sourceSampleId: data.sourceSampleId.present
          ? data.sourceSampleId.value
          : this.sourceSampleId,
      sourceTitle: data.sourceTitle.present
          ? data.sourceTitle.value
          : this.sourceTitle,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StyleProfileRecord(')
          ..write('id: $id, ')
          ..write('sourceRunId: $sourceRunId, ')
          ..write('providerId: $providerId, ')
          ..write('modelName: $modelName, ')
          ..write('styleName: $styleName, ')
          ..write('profileMarkdown: $profileMarkdown, ')
          ..write('analysisReportMarkdown: $analysisReportMarkdown, ')
          ..write('projectId: $projectId, ')
          ..write('sourceSampleId: $sourceSampleId, ')
          ..write('sourceTitle: $sourceTitle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceRunId,
    providerId,
    modelName,
    styleName,
    profileMarkdown,
    analysisReportMarkdown,
    projectId,
    sourceSampleId,
    sourceTitle,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StyleProfileRecord &&
          other.id == this.id &&
          other.sourceRunId == this.sourceRunId &&
          other.providerId == this.providerId &&
          other.modelName == this.modelName &&
          other.styleName == this.styleName &&
          other.profileMarkdown == this.profileMarkdown &&
          other.analysisReportMarkdown == this.analysisReportMarkdown &&
          other.projectId == this.projectId &&
          other.sourceSampleId == this.sourceSampleId &&
          other.sourceTitle == this.sourceTitle &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class StyleProfileRecordsCompanion extends UpdateCompanion<StyleProfileRecord> {
  final Value<String> id;
  final Value<String> sourceRunId;
  final Value<String> providerId;
  final Value<String> modelName;
  final Value<String> styleName;
  final Value<String> profileMarkdown;
  final Value<String> analysisReportMarkdown;
  final Value<String?> projectId;
  final Value<String?> sourceSampleId;
  final Value<String?> sourceTitle;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const StyleProfileRecordsCompanion({
    this.id = const Value.absent(),
    this.sourceRunId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.modelName = const Value.absent(),
    this.styleName = const Value.absent(),
    this.profileMarkdown = const Value.absent(),
    this.analysisReportMarkdown = const Value.absent(),
    this.projectId = const Value.absent(),
    this.sourceSampleId = const Value.absent(),
    this.sourceTitle = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StyleProfileRecordsCompanion.insert({
    required String id,
    required String sourceRunId,
    required String providerId,
    required String modelName,
    required String styleName,
    required String profileMarkdown,
    required String analysisReportMarkdown,
    this.projectId = const Value.absent(),
    this.sourceSampleId = const Value.absent(),
    this.sourceTitle = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceRunId = Value(sourceRunId),
       providerId = Value(providerId),
       modelName = Value(modelName),
       styleName = Value(styleName),
       profileMarkdown = Value(profileMarkdown),
       analysisReportMarkdown = Value(analysisReportMarkdown),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<StyleProfileRecord> custom({
    Expression<String>? id,
    Expression<String>? sourceRunId,
    Expression<String>? providerId,
    Expression<String>? modelName,
    Expression<String>? styleName,
    Expression<String>? profileMarkdown,
    Expression<String>? analysisReportMarkdown,
    Expression<String>? projectId,
    Expression<String>? sourceSampleId,
    Expression<String>? sourceTitle,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceRunId != null) 'source_run_id': sourceRunId,
      if (providerId != null) 'provider_id': providerId,
      if (modelName != null) 'model_name': modelName,
      if (styleName != null) 'style_name': styleName,
      if (profileMarkdown != null) 'profile_markdown': profileMarkdown,
      if (analysisReportMarkdown != null)
        'analysis_report_markdown': analysisReportMarkdown,
      if (projectId != null) 'project_id': projectId,
      if (sourceSampleId != null) 'source_sample_id': sourceSampleId,
      if (sourceTitle != null) 'source_title': sourceTitle,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StyleProfileRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceRunId,
    Value<String>? providerId,
    Value<String>? modelName,
    Value<String>? styleName,
    Value<String>? profileMarkdown,
    Value<String>? analysisReportMarkdown,
    Value<String?>? projectId,
    Value<String?>? sourceSampleId,
    Value<String?>? sourceTitle,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return StyleProfileRecordsCompanion(
      id: id ?? this.id,
      sourceRunId: sourceRunId ?? this.sourceRunId,
      providerId: providerId ?? this.providerId,
      modelName: modelName ?? this.modelName,
      styleName: styleName ?? this.styleName,
      profileMarkdown: profileMarkdown ?? this.profileMarkdown,
      analysisReportMarkdown:
          analysisReportMarkdown ?? this.analysisReportMarkdown,
      projectId: projectId ?? this.projectId,
      sourceSampleId: sourceSampleId ?? this.sourceSampleId,
      sourceTitle: sourceTitle ?? this.sourceTitle,
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
    if (sourceRunId.present) {
      map['source_run_id'] = Variable<String>(sourceRunId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (styleName.present) {
      map['style_name'] = Variable<String>(styleName.value);
    }
    if (profileMarkdown.present) {
      map['profile_markdown'] = Variable<String>(profileMarkdown.value);
    }
    if (analysisReportMarkdown.present) {
      map['analysis_report_markdown'] = Variable<String>(
        analysisReportMarkdown.value,
      );
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (sourceSampleId.present) {
      map['source_sample_id'] = Variable<String>(sourceSampleId.value);
    }
    if (sourceTitle.present) {
      map['source_title'] = Variable<String>(sourceTitle.value);
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
    return (StringBuffer('StyleProfileRecordsCompanion(')
          ..write('id: $id, ')
          ..write('sourceRunId: $sourceRunId, ')
          ..write('providerId: $providerId, ')
          ..write('modelName: $modelName, ')
          ..write('styleName: $styleName, ')
          ..write('profileMarkdown: $profileMarkdown, ')
          ..write('analysisReportMarkdown: $analysisReportMarkdown, ')
          ..write('projectId: $projectId, ')
          ..write('sourceSampleId: $sourceSampleId, ')
          ..write('sourceTitle: $sourceTitle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlotSampleRecordsTable extends PlotSampleRecords
    with TableInfo<$PlotSampleRecordsTable, PlotSampleRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlotSampleRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
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
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _characterCountMeta = const VerificationMeta(
    'characterCount',
  );
  @override
  late final GeneratedColumn<int> characterCount = GeneratedColumn<int>(
    'character_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceFilenameMeta = const VerificationMeta(
    'sourceFilename',
  );
  @override
  late final GeneratedColumn<String> sourceFilename = GeneratedColumn<String>(
    'source_filename',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _epubBookTitleMeta = const VerificationMeta(
    'epubBookTitle',
  );
  @override
  late final GeneratedColumn<String> epubBookTitle = GeneratedColumn<String>(
    'epub_book_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _epubAuthorMeta = const VerificationMeta(
    'epubAuthor',
  );
  @override
  late final GeneratedColumn<String> epubAuthor = GeneratedColumn<String>(
    'epub_author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _epubChapterCountMeta = const VerificationMeta(
    'epubChapterCount',
  );
  @override
  late final GeneratedColumn<int> epubChapterCount = GeneratedColumn<int>(
    'epub_chapter_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    sourceType,
    title,
    content,
    characterCount,
    sourceFilename,
    epubBookTitle,
    epubAuthor,
    epubChapterCount,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plot_sample_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlotSampleRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('character_count')) {
      context.handle(
        _characterCountMeta,
        characterCount.isAcceptableOrUnknown(
          data['character_count']!,
          _characterCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterCountMeta);
    }
    if (data.containsKey('source_filename')) {
      context.handle(
        _sourceFilenameMeta,
        sourceFilename.isAcceptableOrUnknown(
          data['source_filename']!,
          _sourceFilenameMeta,
        ),
      );
    }
    if (data.containsKey('epub_book_title')) {
      context.handle(
        _epubBookTitleMeta,
        epubBookTitle.isAcceptableOrUnknown(
          data['epub_book_title']!,
          _epubBookTitleMeta,
        ),
      );
    }
    if (data.containsKey('epub_author')) {
      context.handle(
        _epubAuthorMeta,
        epubAuthor.isAcceptableOrUnknown(data['epub_author']!, _epubAuthorMeta),
      );
    }
    if (data.containsKey('epub_chapter_count')) {
      context.handle(
        _epubChapterCountMeta,
        epubChapterCount.isAcceptableOrUnknown(
          data['epub_chapter_count']!,
          _epubChapterCountMeta,
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
  PlotSampleRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlotSampleRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      characterCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}character_count'],
      )!,
      sourceFilename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_filename'],
      ),
      epubBookTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}epub_book_title'],
      ),
      epubAuthor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}epub_author'],
      ),
      epubChapterCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}epub_chapter_count'],
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
  $PlotSampleRecordsTable createAlias(String alias) {
    return $PlotSampleRecordsTable(attachedDatabase, alias);
  }
}

class PlotSampleRecord extends DataClass
    implements Insertable<PlotSampleRecord> {
  final String id;
  final String sourceType;
  final String title;
  final String content;
  final int characterCount;
  final String? sourceFilename;
  final String? epubBookTitle;
  final String? epubAuthor;
  final int? epubChapterCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PlotSampleRecord({
    required this.id,
    required this.sourceType,
    required this.title,
    required this.content,
    required this.characterCount,
    this.sourceFilename,
    this.epubBookTitle,
    this.epubAuthor,
    this.epubChapterCount,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_type'] = Variable<String>(sourceType);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    map['character_count'] = Variable<int>(characterCount);
    if (!nullToAbsent || sourceFilename != null) {
      map['source_filename'] = Variable<String>(sourceFilename);
    }
    if (!nullToAbsent || epubBookTitle != null) {
      map['epub_book_title'] = Variable<String>(epubBookTitle);
    }
    if (!nullToAbsent || epubAuthor != null) {
      map['epub_author'] = Variable<String>(epubAuthor);
    }
    if (!nullToAbsent || epubChapterCount != null) {
      map['epub_chapter_count'] = Variable<int>(epubChapterCount);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlotSampleRecordsCompanion toCompanion(bool nullToAbsent) {
    return PlotSampleRecordsCompanion(
      id: Value(id),
      sourceType: Value(sourceType),
      title: Value(title),
      content: Value(content),
      characterCount: Value(characterCount),
      sourceFilename: sourceFilename == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceFilename),
      epubBookTitle: epubBookTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(epubBookTitle),
      epubAuthor: epubAuthor == null && nullToAbsent
          ? const Value.absent()
          : Value(epubAuthor),
      epubChapterCount: epubChapterCount == null && nullToAbsent
          ? const Value.absent()
          : Value(epubChapterCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlotSampleRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlotSampleRecord(
      id: serializer.fromJson<String>(json['id']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      characterCount: serializer.fromJson<int>(json['characterCount']),
      sourceFilename: serializer.fromJson<String?>(json['sourceFilename']),
      epubBookTitle: serializer.fromJson<String?>(json['epubBookTitle']),
      epubAuthor: serializer.fromJson<String?>(json['epubAuthor']),
      epubChapterCount: serializer.fromJson<int?>(json['epubChapterCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceType': serializer.toJson<String>(sourceType),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'characterCount': serializer.toJson<int>(characterCount),
      'sourceFilename': serializer.toJson<String?>(sourceFilename),
      'epubBookTitle': serializer.toJson<String?>(epubBookTitle),
      'epubAuthor': serializer.toJson<String?>(epubAuthor),
      'epubChapterCount': serializer.toJson<int?>(epubChapterCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PlotSampleRecord copyWith({
    String? id,
    String? sourceType,
    String? title,
    String? content,
    int? characterCount,
    Value<String?> sourceFilename = const Value.absent(),
    Value<String?> epubBookTitle = const Value.absent(),
    Value<String?> epubAuthor = const Value.absent(),
    Value<int?> epubChapterCount = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PlotSampleRecord(
    id: id ?? this.id,
    sourceType: sourceType ?? this.sourceType,
    title: title ?? this.title,
    content: content ?? this.content,
    characterCount: characterCount ?? this.characterCount,
    sourceFilename: sourceFilename.present
        ? sourceFilename.value
        : this.sourceFilename,
    epubBookTitle: epubBookTitle.present
        ? epubBookTitle.value
        : this.epubBookTitle,
    epubAuthor: epubAuthor.present ? epubAuthor.value : this.epubAuthor,
    epubChapterCount: epubChapterCount.present
        ? epubChapterCount.value
        : this.epubChapterCount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PlotSampleRecord copyWithCompanion(PlotSampleRecordsCompanion data) {
    return PlotSampleRecord(
      id: data.id.present ? data.id.value : this.id,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      characterCount: data.characterCount.present
          ? data.characterCount.value
          : this.characterCount,
      sourceFilename: data.sourceFilename.present
          ? data.sourceFilename.value
          : this.sourceFilename,
      epubBookTitle: data.epubBookTitle.present
          ? data.epubBookTitle.value
          : this.epubBookTitle,
      epubAuthor: data.epubAuthor.present
          ? data.epubAuthor.value
          : this.epubAuthor,
      epubChapterCount: data.epubChapterCount.present
          ? data.epubChapterCount.value
          : this.epubChapterCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlotSampleRecord(')
          ..write('id: $id, ')
          ..write('sourceType: $sourceType, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('characterCount: $characterCount, ')
          ..write('sourceFilename: $sourceFilename, ')
          ..write('epubBookTitle: $epubBookTitle, ')
          ..write('epubAuthor: $epubAuthor, ')
          ..write('epubChapterCount: $epubChapterCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceType,
    title,
    content,
    characterCount,
    sourceFilename,
    epubBookTitle,
    epubAuthor,
    epubChapterCount,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlotSampleRecord &&
          other.id == this.id &&
          other.sourceType == this.sourceType &&
          other.title == this.title &&
          other.content == this.content &&
          other.characterCount == this.characterCount &&
          other.sourceFilename == this.sourceFilename &&
          other.epubBookTitle == this.epubBookTitle &&
          other.epubAuthor == this.epubAuthor &&
          other.epubChapterCount == this.epubChapterCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PlotSampleRecordsCompanion extends UpdateCompanion<PlotSampleRecord> {
  final Value<String> id;
  final Value<String> sourceType;
  final Value<String> title;
  final Value<String> content;
  final Value<int> characterCount;
  final Value<String?> sourceFilename;
  final Value<String?> epubBookTitle;
  final Value<String?> epubAuthor;
  final Value<int?> epubChapterCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PlotSampleRecordsCompanion({
    this.id = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.characterCount = const Value.absent(),
    this.sourceFilename = const Value.absent(),
    this.epubBookTitle = const Value.absent(),
    this.epubAuthor = const Value.absent(),
    this.epubChapterCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlotSampleRecordsCompanion.insert({
    required String id,
    required String sourceType,
    required String title,
    required String content,
    required int characterCount,
    this.sourceFilename = const Value.absent(),
    this.epubBookTitle = const Value.absent(),
    this.epubAuthor = const Value.absent(),
    this.epubChapterCount = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceType = Value(sourceType),
       title = Value(title),
       content = Value(content),
       characterCount = Value(characterCount),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PlotSampleRecord> custom({
    Expression<String>? id,
    Expression<String>? sourceType,
    Expression<String>? title,
    Expression<String>? content,
    Expression<int>? characterCount,
    Expression<String>? sourceFilename,
    Expression<String>? epubBookTitle,
    Expression<String>? epubAuthor,
    Expression<int>? epubChapterCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceType != null) 'source_type': sourceType,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (characterCount != null) 'character_count': characterCount,
      if (sourceFilename != null) 'source_filename': sourceFilename,
      if (epubBookTitle != null) 'epub_book_title': epubBookTitle,
      if (epubAuthor != null) 'epub_author': epubAuthor,
      if (epubChapterCount != null) 'epub_chapter_count': epubChapterCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlotSampleRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceType,
    Value<String>? title,
    Value<String>? content,
    Value<int>? characterCount,
    Value<String?>? sourceFilename,
    Value<String?>? epubBookTitle,
    Value<String?>? epubAuthor,
    Value<int?>? epubChapterCount,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PlotSampleRecordsCompanion(
      id: id ?? this.id,
      sourceType: sourceType ?? this.sourceType,
      title: title ?? this.title,
      content: content ?? this.content,
      characterCount: characterCount ?? this.characterCount,
      sourceFilename: sourceFilename ?? this.sourceFilename,
      epubBookTitle: epubBookTitle ?? this.epubBookTitle,
      epubAuthor: epubAuthor ?? this.epubAuthor,
      epubChapterCount: epubChapterCount ?? this.epubChapterCount,
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
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (characterCount.present) {
      map['character_count'] = Variable<int>(characterCount.value);
    }
    if (sourceFilename.present) {
      map['source_filename'] = Variable<String>(sourceFilename.value);
    }
    if (epubBookTitle.present) {
      map['epub_book_title'] = Variable<String>(epubBookTitle.value);
    }
    if (epubAuthor.present) {
      map['epub_author'] = Variable<String>(epubAuthor.value);
    }
    if (epubChapterCount.present) {
      map['epub_chapter_count'] = Variable<int>(epubChapterCount.value);
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
    return (StringBuffer('PlotSampleRecordsCompanion(')
          ..write('id: $id, ')
          ..write('sourceType: $sourceType, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('characterCount: $characterCount, ')
          ..write('sourceFilename: $sourceFilename, ')
          ..write('epubBookTitle: $epubBookTitle, ')
          ..write('epubAuthor: $epubAuthor, ')
          ..write('epubChapterCount: $epubChapterCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlotAnalysisRunRecordsTable extends PlotAnalysisRunRecords
    with TableInfo<$PlotAnalysisRunRecordsTable, PlotAnalysisRunRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlotAnalysisRunRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workflowTaskIdMeta = const VerificationMeta(
    'workflowTaskId',
  );
  @override
  late final GeneratedColumn<String> workflowTaskId = GeneratedColumn<String>(
    'workflow_task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workflow_task_records (id)',
    ),
  );
  static const VerificationMeta _sampleIdMeta = const VerificationMeta(
    'sampleId',
  );
  @override
  late final GeneratedColumn<String> sampleId = GeneratedColumn<String>(
    'sample_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plot_sample_records (id)',
    ),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES provider_config_records (id)',
    ),
  );
  static const VerificationMeta _modelNameMeta = const VerificationMeta(
    'modelName',
  );
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
    'model_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plotNameMeta = const VerificationMeta(
    'plotName',
  );
  @override
  late final GeneratedColumn<String> plotName = GeneratedColumn<String>(
    'plot_name',
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
  static const VerificationMeta _logsMeta = const VerificationMeta('logs');
  @override
  late final GeneratedColumn<String> logs = GeneratedColumn<String>(
    'logs',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _analysisReportMarkdownMeta =
      const VerificationMeta('analysisReportMarkdown');
  @override
  late final GeneratedColumn<String> analysisReportMarkdown =
      GeneratedColumn<String>(
        'analysis_report_markdown',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _plotSkeletonMarkdownMeta =
      const VerificationMeta('plotSkeletonMarkdown');
  @override
  late final GeneratedColumn<String> plotSkeletonMarkdown =
      GeneratedColumn<String>(
        'plot_skeleton_markdown',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _storyEngineMarkdownMeta =
      const VerificationMeta('storyEngineMarkdown');
  @override
  late final GeneratedColumn<String> storyEngineMarkdown =
      GeneratedColumn<String>(
        'story_engine_markdown',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chunkCountMeta = const VerificationMeta(
    'chunkCount',
  );
  @override
  late final GeneratedColumn<int> chunkCount = GeneratedColumn<int>(
    'chunk_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _characterCountMeta = const VerificationMeta(
    'characterCount',
  );
  @override
  late final GeneratedColumn<int> characterCount = GeneratedColumn<int>(
    'character_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workflowTaskId,
    sampleId,
    providerId,
    modelName,
    plotName,
    status,
    stage,
    errorMessage,
    logs,
    analysisReportMarkdown,
    plotSkeletonMarkdown,
    storyEngineMarkdown,
    profileId,
    chunkCount,
    characterCount,
    createdAt,
    updatedAt,
    startedAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plot_analysis_run_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlotAnalysisRunRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workflow_task_id')) {
      context.handle(
        _workflowTaskIdMeta,
        workflowTaskId.isAcceptableOrUnknown(
          data['workflow_task_id']!,
          _workflowTaskIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workflowTaskIdMeta);
    }
    if (data.containsKey('sample_id')) {
      context.handle(
        _sampleIdMeta,
        sampleId.isAcceptableOrUnknown(data['sample_id']!, _sampleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sampleIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('model_name')) {
      context.handle(
        _modelNameMeta,
        modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta),
      );
    } else if (isInserting) {
      context.missing(_modelNameMeta);
    }
    if (data.containsKey('plot_name')) {
      context.handle(
        _plotNameMeta,
        plotName.isAcceptableOrUnknown(data['plot_name']!, _plotNameMeta),
      );
    } else if (isInserting) {
      context.missing(_plotNameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
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
    if (data.containsKey('logs')) {
      context.handle(
        _logsMeta,
        logs.isAcceptableOrUnknown(data['logs']!, _logsMeta),
      );
    }
    if (data.containsKey('analysis_report_markdown')) {
      context.handle(
        _analysisReportMarkdownMeta,
        analysisReportMarkdown.isAcceptableOrUnknown(
          data['analysis_report_markdown']!,
          _analysisReportMarkdownMeta,
        ),
      );
    }
    if (data.containsKey('plot_skeleton_markdown')) {
      context.handle(
        _plotSkeletonMarkdownMeta,
        plotSkeletonMarkdown.isAcceptableOrUnknown(
          data['plot_skeleton_markdown']!,
          _plotSkeletonMarkdownMeta,
        ),
      );
    }
    if (data.containsKey('story_engine_markdown')) {
      context.handle(
        _storyEngineMarkdownMeta,
        storyEngineMarkdown.isAcceptableOrUnknown(
          data['story_engine_markdown']!,
          _storyEngineMarkdownMeta,
        ),
      );
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('chunk_count')) {
      context.handle(
        _chunkCountMeta,
        chunkCount.isAcceptableOrUnknown(data['chunk_count']!, _chunkCountMeta),
      );
    }
    if (data.containsKey('character_count')) {
      context.handle(
        _characterCountMeta,
        characterCount.isAcceptableOrUnknown(
          data['character_count']!,
          _characterCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterCountMeta);
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
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlotAnalysisRunRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlotAnalysisRunRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workflowTaskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workflow_task_id'],
      )!,
      sampleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sample_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      modelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_name'],
      )!,
      plotName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plot_name'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      logs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logs'],
      )!,
      analysisReportMarkdown: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}analysis_report_markdown'],
      ),
      plotSkeletonMarkdown: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plot_skeleton_markdown'],
      ),
      storyEngineMarkdown: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}story_engine_markdown'],
      ),
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      ),
      chunkCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chunk_count'],
      )!,
      characterCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}character_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $PlotAnalysisRunRecordsTable createAlias(String alias) {
    return $PlotAnalysisRunRecordsTable(attachedDatabase, alias);
  }
}

class PlotAnalysisRunRecord extends DataClass
    implements Insertable<PlotAnalysisRunRecord> {
  final String id;
  final String workflowTaskId;
  final String sampleId;
  final String providerId;
  final String modelName;
  final String plotName;
  final String status;
  final String? stage;
  final String? errorMessage;
  final String logs;
  final String? analysisReportMarkdown;
  final String? plotSkeletonMarkdown;
  final String? storyEngineMarkdown;
  final String? profileId;
  final int chunkCount;
  final int characterCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  const PlotAnalysisRunRecord({
    required this.id,
    required this.workflowTaskId,
    required this.sampleId,
    required this.providerId,
    required this.modelName,
    required this.plotName,
    required this.status,
    this.stage,
    this.errorMessage,
    required this.logs,
    this.analysisReportMarkdown,
    this.plotSkeletonMarkdown,
    this.storyEngineMarkdown,
    this.profileId,
    required this.chunkCount,
    required this.characterCount,
    required this.createdAt,
    required this.updatedAt,
    this.startedAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workflow_task_id'] = Variable<String>(workflowTaskId);
    map['sample_id'] = Variable<String>(sampleId);
    map['provider_id'] = Variable<String>(providerId);
    map['model_name'] = Variable<String>(modelName);
    map['plot_name'] = Variable<String>(plotName);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || stage != null) {
      map['stage'] = Variable<String>(stage);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['logs'] = Variable<String>(logs);
    if (!nullToAbsent || analysisReportMarkdown != null) {
      map['analysis_report_markdown'] = Variable<String>(
        analysisReportMarkdown,
      );
    }
    if (!nullToAbsent || plotSkeletonMarkdown != null) {
      map['plot_skeleton_markdown'] = Variable<String>(plotSkeletonMarkdown);
    }
    if (!nullToAbsent || storyEngineMarkdown != null) {
      map['story_engine_markdown'] = Variable<String>(storyEngineMarkdown);
    }
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<String>(profileId);
    }
    map['chunk_count'] = Variable<int>(chunkCount);
    map['character_count'] = Variable<int>(characterCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  PlotAnalysisRunRecordsCompanion toCompanion(bool nullToAbsent) {
    return PlotAnalysisRunRecordsCompanion(
      id: Value(id),
      workflowTaskId: Value(workflowTaskId),
      sampleId: Value(sampleId),
      providerId: Value(providerId),
      modelName: Value(modelName),
      plotName: Value(plotName),
      status: Value(status),
      stage: stage == null && nullToAbsent
          ? const Value.absent()
          : Value(stage),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      logs: Value(logs),
      analysisReportMarkdown: analysisReportMarkdown == null && nullToAbsent
          ? const Value.absent()
          : Value(analysisReportMarkdown),
      plotSkeletonMarkdown: plotSkeletonMarkdown == null && nullToAbsent
          ? const Value.absent()
          : Value(plotSkeletonMarkdown),
      storyEngineMarkdown: storyEngineMarkdown == null && nullToAbsent
          ? const Value.absent()
          : Value(storyEngineMarkdown),
      profileId: profileId == null && nullToAbsent
          ? const Value.absent()
          : Value(profileId),
      chunkCount: Value(chunkCount),
      characterCount: Value(characterCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory PlotAnalysisRunRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlotAnalysisRunRecord(
      id: serializer.fromJson<String>(json['id']),
      workflowTaskId: serializer.fromJson<String>(json['workflowTaskId']),
      sampleId: serializer.fromJson<String>(json['sampleId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      modelName: serializer.fromJson<String>(json['modelName']),
      plotName: serializer.fromJson<String>(json['plotName']),
      status: serializer.fromJson<String>(json['status']),
      stage: serializer.fromJson<String?>(json['stage']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      logs: serializer.fromJson<String>(json['logs']),
      analysisReportMarkdown: serializer.fromJson<String?>(
        json['analysisReportMarkdown'],
      ),
      plotSkeletonMarkdown: serializer.fromJson<String?>(
        json['plotSkeletonMarkdown'],
      ),
      storyEngineMarkdown: serializer.fromJson<String?>(
        json['storyEngineMarkdown'],
      ),
      profileId: serializer.fromJson<String?>(json['profileId']),
      chunkCount: serializer.fromJson<int>(json['chunkCount']),
      characterCount: serializer.fromJson<int>(json['characterCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workflowTaskId': serializer.toJson<String>(workflowTaskId),
      'sampleId': serializer.toJson<String>(sampleId),
      'providerId': serializer.toJson<String>(providerId),
      'modelName': serializer.toJson<String>(modelName),
      'plotName': serializer.toJson<String>(plotName),
      'status': serializer.toJson<String>(status),
      'stage': serializer.toJson<String?>(stage),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'logs': serializer.toJson<String>(logs),
      'analysisReportMarkdown': serializer.toJson<String?>(
        analysisReportMarkdown,
      ),
      'plotSkeletonMarkdown': serializer.toJson<String?>(plotSkeletonMarkdown),
      'storyEngineMarkdown': serializer.toJson<String?>(storyEngineMarkdown),
      'profileId': serializer.toJson<String?>(profileId),
      'chunkCount': serializer.toJson<int>(chunkCount),
      'characterCount': serializer.toJson<int>(characterCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  PlotAnalysisRunRecord copyWith({
    String? id,
    String? workflowTaskId,
    String? sampleId,
    String? providerId,
    String? modelName,
    String? plotName,
    String? status,
    Value<String?> stage = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    String? logs,
    Value<String?> analysisReportMarkdown = const Value.absent(),
    Value<String?> plotSkeletonMarkdown = const Value.absent(),
    Value<String?> storyEngineMarkdown = const Value.absent(),
    Value<String?> profileId = const Value.absent(),
    int? chunkCount,
    int? characterCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
  }) => PlotAnalysisRunRecord(
    id: id ?? this.id,
    workflowTaskId: workflowTaskId ?? this.workflowTaskId,
    sampleId: sampleId ?? this.sampleId,
    providerId: providerId ?? this.providerId,
    modelName: modelName ?? this.modelName,
    plotName: plotName ?? this.plotName,
    status: status ?? this.status,
    stage: stage.present ? stage.value : this.stage,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    logs: logs ?? this.logs,
    analysisReportMarkdown: analysisReportMarkdown.present
        ? analysisReportMarkdown.value
        : this.analysisReportMarkdown,
    plotSkeletonMarkdown: plotSkeletonMarkdown.present
        ? plotSkeletonMarkdown.value
        : this.plotSkeletonMarkdown,
    storyEngineMarkdown: storyEngineMarkdown.present
        ? storyEngineMarkdown.value
        : this.storyEngineMarkdown,
    profileId: profileId.present ? profileId.value : this.profileId,
    chunkCount: chunkCount ?? this.chunkCount,
    characterCount: characterCount ?? this.characterCount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  PlotAnalysisRunRecord copyWithCompanion(
    PlotAnalysisRunRecordsCompanion data,
  ) {
    return PlotAnalysisRunRecord(
      id: data.id.present ? data.id.value : this.id,
      workflowTaskId: data.workflowTaskId.present
          ? data.workflowTaskId.value
          : this.workflowTaskId,
      sampleId: data.sampleId.present ? data.sampleId.value : this.sampleId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      plotName: data.plotName.present ? data.plotName.value : this.plotName,
      status: data.status.present ? data.status.value : this.status,
      stage: data.stage.present ? data.stage.value : this.stage,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      logs: data.logs.present ? data.logs.value : this.logs,
      analysisReportMarkdown: data.analysisReportMarkdown.present
          ? data.analysisReportMarkdown.value
          : this.analysisReportMarkdown,
      plotSkeletonMarkdown: data.plotSkeletonMarkdown.present
          ? data.plotSkeletonMarkdown.value
          : this.plotSkeletonMarkdown,
      storyEngineMarkdown: data.storyEngineMarkdown.present
          ? data.storyEngineMarkdown.value
          : this.storyEngineMarkdown,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      chunkCount: data.chunkCount.present
          ? data.chunkCount.value
          : this.chunkCount,
      characterCount: data.characterCount.present
          ? data.characterCount.value
          : this.characterCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlotAnalysisRunRecord(')
          ..write('id: $id, ')
          ..write('workflowTaskId: $workflowTaskId, ')
          ..write('sampleId: $sampleId, ')
          ..write('providerId: $providerId, ')
          ..write('modelName: $modelName, ')
          ..write('plotName: $plotName, ')
          ..write('status: $status, ')
          ..write('stage: $stage, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('logs: $logs, ')
          ..write('analysisReportMarkdown: $analysisReportMarkdown, ')
          ..write('plotSkeletonMarkdown: $plotSkeletonMarkdown, ')
          ..write('storyEngineMarkdown: $storyEngineMarkdown, ')
          ..write('profileId: $profileId, ')
          ..write('chunkCount: $chunkCount, ')
          ..write('characterCount: $characterCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workflowTaskId,
    sampleId,
    providerId,
    modelName,
    plotName,
    status,
    stage,
    errorMessage,
    logs,
    analysisReportMarkdown,
    plotSkeletonMarkdown,
    storyEngineMarkdown,
    profileId,
    chunkCount,
    characterCount,
    createdAt,
    updatedAt,
    startedAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlotAnalysisRunRecord &&
          other.id == this.id &&
          other.workflowTaskId == this.workflowTaskId &&
          other.sampleId == this.sampleId &&
          other.providerId == this.providerId &&
          other.modelName == this.modelName &&
          other.plotName == this.plotName &&
          other.status == this.status &&
          other.stage == this.stage &&
          other.errorMessage == this.errorMessage &&
          other.logs == this.logs &&
          other.analysisReportMarkdown == this.analysisReportMarkdown &&
          other.plotSkeletonMarkdown == this.plotSkeletonMarkdown &&
          other.storyEngineMarkdown == this.storyEngineMarkdown &&
          other.profileId == this.profileId &&
          other.chunkCount == this.chunkCount &&
          other.characterCount == this.characterCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt);
}

class PlotAnalysisRunRecordsCompanion
    extends UpdateCompanion<PlotAnalysisRunRecord> {
  final Value<String> id;
  final Value<String> workflowTaskId;
  final Value<String> sampleId;
  final Value<String> providerId;
  final Value<String> modelName;
  final Value<String> plotName;
  final Value<String> status;
  final Value<String?> stage;
  final Value<String?> errorMessage;
  final Value<String> logs;
  final Value<String?> analysisReportMarkdown;
  final Value<String?> plotSkeletonMarkdown;
  final Value<String?> storyEngineMarkdown;
  final Value<String?> profileId;
  final Value<int> chunkCount;
  final Value<int> characterCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const PlotAnalysisRunRecordsCompanion({
    this.id = const Value.absent(),
    this.workflowTaskId = const Value.absent(),
    this.sampleId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.modelName = const Value.absent(),
    this.plotName = const Value.absent(),
    this.status = const Value.absent(),
    this.stage = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.logs = const Value.absent(),
    this.analysisReportMarkdown = const Value.absent(),
    this.plotSkeletonMarkdown = const Value.absent(),
    this.storyEngineMarkdown = const Value.absent(),
    this.profileId = const Value.absent(),
    this.chunkCount = const Value.absent(),
    this.characterCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlotAnalysisRunRecordsCompanion.insert({
    required String id,
    required String workflowTaskId,
    required String sampleId,
    required String providerId,
    required String modelName,
    required String plotName,
    required String status,
    this.stage = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.logs = const Value.absent(),
    this.analysisReportMarkdown = const Value.absent(),
    this.plotSkeletonMarkdown = const Value.absent(),
    this.storyEngineMarkdown = const Value.absent(),
    this.profileId = const Value.absent(),
    this.chunkCount = const Value.absent(),
    required int characterCount,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workflowTaskId = Value(workflowTaskId),
       sampleId = Value(sampleId),
       providerId = Value(providerId),
       modelName = Value(modelName),
       plotName = Value(plotName),
       status = Value(status),
       characterCount = Value(characterCount),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PlotAnalysisRunRecord> custom({
    Expression<String>? id,
    Expression<String>? workflowTaskId,
    Expression<String>? sampleId,
    Expression<String>? providerId,
    Expression<String>? modelName,
    Expression<String>? plotName,
    Expression<String>? status,
    Expression<String>? stage,
    Expression<String>? errorMessage,
    Expression<String>? logs,
    Expression<String>? analysisReportMarkdown,
    Expression<String>? plotSkeletonMarkdown,
    Expression<String>? storyEngineMarkdown,
    Expression<String>? profileId,
    Expression<int>? chunkCount,
    Expression<int>? characterCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workflowTaskId != null) 'workflow_task_id': workflowTaskId,
      if (sampleId != null) 'sample_id': sampleId,
      if (providerId != null) 'provider_id': providerId,
      if (modelName != null) 'model_name': modelName,
      if (plotName != null) 'plot_name': plotName,
      if (status != null) 'status': status,
      if (stage != null) 'stage': stage,
      if (errorMessage != null) 'error_message': errorMessage,
      if (logs != null) 'logs': logs,
      if (analysisReportMarkdown != null)
        'analysis_report_markdown': analysisReportMarkdown,
      if (plotSkeletonMarkdown != null)
        'plot_skeleton_markdown': plotSkeletonMarkdown,
      if (storyEngineMarkdown != null)
        'story_engine_markdown': storyEngineMarkdown,
      if (profileId != null) 'profile_id': profileId,
      if (chunkCount != null) 'chunk_count': chunkCount,
      if (characterCount != null) 'character_count': characterCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlotAnalysisRunRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? workflowTaskId,
    Value<String>? sampleId,
    Value<String>? providerId,
    Value<String>? modelName,
    Value<String>? plotName,
    Value<String>? status,
    Value<String?>? stage,
    Value<String?>? errorMessage,
    Value<String>? logs,
    Value<String?>? analysisReportMarkdown,
    Value<String?>? plotSkeletonMarkdown,
    Value<String?>? storyEngineMarkdown,
    Value<String?>? profileId,
    Value<int>? chunkCount,
    Value<int>? characterCount,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return PlotAnalysisRunRecordsCompanion(
      id: id ?? this.id,
      workflowTaskId: workflowTaskId ?? this.workflowTaskId,
      sampleId: sampleId ?? this.sampleId,
      providerId: providerId ?? this.providerId,
      modelName: modelName ?? this.modelName,
      plotName: plotName ?? this.plotName,
      status: status ?? this.status,
      stage: stage ?? this.stage,
      errorMessage: errorMessage ?? this.errorMessage,
      logs: logs ?? this.logs,
      analysisReportMarkdown:
          analysisReportMarkdown ?? this.analysisReportMarkdown,
      plotSkeletonMarkdown: plotSkeletonMarkdown ?? this.plotSkeletonMarkdown,
      storyEngineMarkdown: storyEngineMarkdown ?? this.storyEngineMarkdown,
      profileId: profileId ?? this.profileId,
      chunkCount: chunkCount ?? this.chunkCount,
      characterCount: characterCount ?? this.characterCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workflowTaskId.present) {
      map['workflow_task_id'] = Variable<String>(workflowTaskId.value);
    }
    if (sampleId.present) {
      map['sample_id'] = Variable<String>(sampleId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (plotName.present) {
      map['plot_name'] = Variable<String>(plotName.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (logs.present) {
      map['logs'] = Variable<String>(logs.value);
    }
    if (analysisReportMarkdown.present) {
      map['analysis_report_markdown'] = Variable<String>(
        analysisReportMarkdown.value,
      );
    }
    if (plotSkeletonMarkdown.present) {
      map['plot_skeleton_markdown'] = Variable<String>(
        plotSkeletonMarkdown.value,
      );
    }
    if (storyEngineMarkdown.present) {
      map['story_engine_markdown'] = Variable<String>(
        storyEngineMarkdown.value,
      );
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (chunkCount.present) {
      map['chunk_count'] = Variable<int>(chunkCount.value);
    }
    if (characterCount.present) {
      map['character_count'] = Variable<int>(characterCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlotAnalysisRunRecordsCompanion(')
          ..write('id: $id, ')
          ..write('workflowTaskId: $workflowTaskId, ')
          ..write('sampleId: $sampleId, ')
          ..write('providerId: $providerId, ')
          ..write('modelName: $modelName, ')
          ..write('plotName: $plotName, ')
          ..write('status: $status, ')
          ..write('stage: $stage, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('logs: $logs, ')
          ..write('analysisReportMarkdown: $analysisReportMarkdown, ')
          ..write('plotSkeletonMarkdown: $plotSkeletonMarkdown, ')
          ..write('storyEngineMarkdown: $storyEngineMarkdown, ')
          ..write('profileId: $profileId, ')
          ..write('chunkCount: $chunkCount, ')
          ..write('characterCount: $characterCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlotProfileRecordsTable extends PlotProfileRecords
    with TableInfo<$PlotProfileRecordsTable, PlotProfileRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlotProfileRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceRunIdMeta = const VerificationMeta(
    'sourceRunId',
  );
  @override
  late final GeneratedColumn<String> sourceRunId = GeneratedColumn<String>(
    'source_run_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES plot_analysis_run_records (id)',
    ),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES provider_config_records (id)',
    ),
  );
  static const VerificationMeta _modelNameMeta = const VerificationMeta(
    'modelName',
  );
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
    'model_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plotNameMeta = const VerificationMeta(
    'plotName',
  );
  @override
  late final GeneratedColumn<String> plotName = GeneratedColumn<String>(
    'plot_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storyEngineMarkdownMeta =
      const VerificationMeta('storyEngineMarkdown');
  @override
  late final GeneratedColumn<String> storyEngineMarkdown =
      GeneratedColumn<String>(
        'story_engine_markdown',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _analysisReportMarkdownMeta =
      const VerificationMeta('analysisReportMarkdown');
  @override
  late final GeneratedColumn<String> analysisReportMarkdown =
      GeneratedColumn<String>(
        'analysis_report_markdown',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _plotSkeletonMarkdownMeta =
      const VerificationMeta('plotSkeletonMarkdown');
  @override
  late final GeneratedColumn<String> plotSkeletonMarkdown =
      GeneratedColumn<String>(
        'plot_skeleton_markdown',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _sourceSampleIdMeta = const VerificationMeta(
    'sourceSampleId',
  );
  @override
  late final GeneratedColumn<String> sourceSampleId = GeneratedColumn<String>(
    'source_sample_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plot_sample_records (id)',
    ),
  );
  static const VerificationMeta _sourceTitleMeta = const VerificationMeta(
    'sourceTitle',
  );
  @override
  late final GeneratedColumn<String> sourceTitle = GeneratedColumn<String>(
    'source_title',
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
    sourceRunId,
    providerId,
    modelName,
    plotName,
    storyEngineMarkdown,
    analysisReportMarkdown,
    plotSkeletonMarkdown,
    sourceSampleId,
    sourceTitle,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plot_profile_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlotProfileRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_run_id')) {
      context.handle(
        _sourceRunIdMeta,
        sourceRunId.isAcceptableOrUnknown(
          data['source_run_id']!,
          _sourceRunIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceRunIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('model_name')) {
      context.handle(
        _modelNameMeta,
        modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta),
      );
    } else if (isInserting) {
      context.missing(_modelNameMeta);
    }
    if (data.containsKey('plot_name')) {
      context.handle(
        _plotNameMeta,
        plotName.isAcceptableOrUnknown(data['plot_name']!, _plotNameMeta),
      );
    } else if (isInserting) {
      context.missing(_plotNameMeta);
    }
    if (data.containsKey('story_engine_markdown')) {
      context.handle(
        _storyEngineMarkdownMeta,
        storyEngineMarkdown.isAcceptableOrUnknown(
          data['story_engine_markdown']!,
          _storyEngineMarkdownMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storyEngineMarkdownMeta);
    }
    if (data.containsKey('analysis_report_markdown')) {
      context.handle(
        _analysisReportMarkdownMeta,
        analysisReportMarkdown.isAcceptableOrUnknown(
          data['analysis_report_markdown']!,
          _analysisReportMarkdownMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_analysisReportMarkdownMeta);
    }
    if (data.containsKey('plot_skeleton_markdown')) {
      context.handle(
        _plotSkeletonMarkdownMeta,
        plotSkeletonMarkdown.isAcceptableOrUnknown(
          data['plot_skeleton_markdown']!,
          _plotSkeletonMarkdownMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plotSkeletonMarkdownMeta);
    }
    if (data.containsKey('source_sample_id')) {
      context.handle(
        _sourceSampleIdMeta,
        sourceSampleId.isAcceptableOrUnknown(
          data['source_sample_id']!,
          _sourceSampleIdMeta,
        ),
      );
    }
    if (data.containsKey('source_title')) {
      context.handle(
        _sourceTitleMeta,
        sourceTitle.isAcceptableOrUnknown(
          data['source_title']!,
          _sourceTitleMeta,
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
  PlotProfileRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlotProfileRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceRunId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_run_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      modelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_name'],
      )!,
      plotName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plot_name'],
      )!,
      storyEngineMarkdown: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}story_engine_markdown'],
      )!,
      analysisReportMarkdown: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}analysis_report_markdown'],
      )!,
      plotSkeletonMarkdown: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plot_skeleton_markdown'],
      )!,
      sourceSampleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_sample_id'],
      ),
      sourceTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_title'],
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
  $PlotProfileRecordsTable createAlias(String alias) {
    return $PlotProfileRecordsTable(attachedDatabase, alias);
  }
}

class PlotProfileRecord extends DataClass
    implements Insertable<PlotProfileRecord> {
  final String id;
  final String sourceRunId;
  final String providerId;
  final String modelName;
  final String plotName;
  final String storyEngineMarkdown;
  final String analysisReportMarkdown;
  final String plotSkeletonMarkdown;
  final String? sourceSampleId;
  final String? sourceTitle;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PlotProfileRecord({
    required this.id,
    required this.sourceRunId,
    required this.providerId,
    required this.modelName,
    required this.plotName,
    required this.storyEngineMarkdown,
    required this.analysisReportMarkdown,
    required this.plotSkeletonMarkdown,
    this.sourceSampleId,
    this.sourceTitle,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_run_id'] = Variable<String>(sourceRunId);
    map['provider_id'] = Variable<String>(providerId);
    map['model_name'] = Variable<String>(modelName);
    map['plot_name'] = Variable<String>(plotName);
    map['story_engine_markdown'] = Variable<String>(storyEngineMarkdown);
    map['analysis_report_markdown'] = Variable<String>(analysisReportMarkdown);
    map['plot_skeleton_markdown'] = Variable<String>(plotSkeletonMarkdown);
    if (!nullToAbsent || sourceSampleId != null) {
      map['source_sample_id'] = Variable<String>(sourceSampleId);
    }
    if (!nullToAbsent || sourceTitle != null) {
      map['source_title'] = Variable<String>(sourceTitle);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlotProfileRecordsCompanion toCompanion(bool nullToAbsent) {
    return PlotProfileRecordsCompanion(
      id: Value(id),
      sourceRunId: Value(sourceRunId),
      providerId: Value(providerId),
      modelName: Value(modelName),
      plotName: Value(plotName),
      storyEngineMarkdown: Value(storyEngineMarkdown),
      analysisReportMarkdown: Value(analysisReportMarkdown),
      plotSkeletonMarkdown: Value(plotSkeletonMarkdown),
      sourceSampleId: sourceSampleId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceSampleId),
      sourceTitle: sourceTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceTitle),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlotProfileRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlotProfileRecord(
      id: serializer.fromJson<String>(json['id']),
      sourceRunId: serializer.fromJson<String>(json['sourceRunId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      modelName: serializer.fromJson<String>(json['modelName']),
      plotName: serializer.fromJson<String>(json['plotName']),
      storyEngineMarkdown: serializer.fromJson<String>(
        json['storyEngineMarkdown'],
      ),
      analysisReportMarkdown: serializer.fromJson<String>(
        json['analysisReportMarkdown'],
      ),
      plotSkeletonMarkdown: serializer.fromJson<String>(
        json['plotSkeletonMarkdown'],
      ),
      sourceSampleId: serializer.fromJson<String?>(json['sourceSampleId']),
      sourceTitle: serializer.fromJson<String?>(json['sourceTitle']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceRunId': serializer.toJson<String>(sourceRunId),
      'providerId': serializer.toJson<String>(providerId),
      'modelName': serializer.toJson<String>(modelName),
      'plotName': serializer.toJson<String>(plotName),
      'storyEngineMarkdown': serializer.toJson<String>(storyEngineMarkdown),
      'analysisReportMarkdown': serializer.toJson<String>(
        analysisReportMarkdown,
      ),
      'plotSkeletonMarkdown': serializer.toJson<String>(plotSkeletonMarkdown),
      'sourceSampleId': serializer.toJson<String?>(sourceSampleId),
      'sourceTitle': serializer.toJson<String?>(sourceTitle),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PlotProfileRecord copyWith({
    String? id,
    String? sourceRunId,
    String? providerId,
    String? modelName,
    String? plotName,
    String? storyEngineMarkdown,
    String? analysisReportMarkdown,
    String? plotSkeletonMarkdown,
    Value<String?> sourceSampleId = const Value.absent(),
    Value<String?> sourceTitle = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PlotProfileRecord(
    id: id ?? this.id,
    sourceRunId: sourceRunId ?? this.sourceRunId,
    providerId: providerId ?? this.providerId,
    modelName: modelName ?? this.modelName,
    plotName: plotName ?? this.plotName,
    storyEngineMarkdown: storyEngineMarkdown ?? this.storyEngineMarkdown,
    analysisReportMarkdown:
        analysisReportMarkdown ?? this.analysisReportMarkdown,
    plotSkeletonMarkdown: plotSkeletonMarkdown ?? this.plotSkeletonMarkdown,
    sourceSampleId: sourceSampleId.present
        ? sourceSampleId.value
        : this.sourceSampleId,
    sourceTitle: sourceTitle.present ? sourceTitle.value : this.sourceTitle,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PlotProfileRecord copyWithCompanion(PlotProfileRecordsCompanion data) {
    return PlotProfileRecord(
      id: data.id.present ? data.id.value : this.id,
      sourceRunId: data.sourceRunId.present
          ? data.sourceRunId.value
          : this.sourceRunId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      plotName: data.plotName.present ? data.plotName.value : this.plotName,
      storyEngineMarkdown: data.storyEngineMarkdown.present
          ? data.storyEngineMarkdown.value
          : this.storyEngineMarkdown,
      analysisReportMarkdown: data.analysisReportMarkdown.present
          ? data.analysisReportMarkdown.value
          : this.analysisReportMarkdown,
      plotSkeletonMarkdown: data.plotSkeletonMarkdown.present
          ? data.plotSkeletonMarkdown.value
          : this.plotSkeletonMarkdown,
      sourceSampleId: data.sourceSampleId.present
          ? data.sourceSampleId.value
          : this.sourceSampleId,
      sourceTitle: data.sourceTitle.present
          ? data.sourceTitle.value
          : this.sourceTitle,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlotProfileRecord(')
          ..write('id: $id, ')
          ..write('sourceRunId: $sourceRunId, ')
          ..write('providerId: $providerId, ')
          ..write('modelName: $modelName, ')
          ..write('plotName: $plotName, ')
          ..write('storyEngineMarkdown: $storyEngineMarkdown, ')
          ..write('analysisReportMarkdown: $analysisReportMarkdown, ')
          ..write('plotSkeletonMarkdown: $plotSkeletonMarkdown, ')
          ..write('sourceSampleId: $sourceSampleId, ')
          ..write('sourceTitle: $sourceTitle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceRunId,
    providerId,
    modelName,
    plotName,
    storyEngineMarkdown,
    analysisReportMarkdown,
    plotSkeletonMarkdown,
    sourceSampleId,
    sourceTitle,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlotProfileRecord &&
          other.id == this.id &&
          other.sourceRunId == this.sourceRunId &&
          other.providerId == this.providerId &&
          other.modelName == this.modelName &&
          other.plotName == this.plotName &&
          other.storyEngineMarkdown == this.storyEngineMarkdown &&
          other.analysisReportMarkdown == this.analysisReportMarkdown &&
          other.plotSkeletonMarkdown == this.plotSkeletonMarkdown &&
          other.sourceSampleId == this.sourceSampleId &&
          other.sourceTitle == this.sourceTitle &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PlotProfileRecordsCompanion extends UpdateCompanion<PlotProfileRecord> {
  final Value<String> id;
  final Value<String> sourceRunId;
  final Value<String> providerId;
  final Value<String> modelName;
  final Value<String> plotName;
  final Value<String> storyEngineMarkdown;
  final Value<String> analysisReportMarkdown;
  final Value<String> plotSkeletonMarkdown;
  final Value<String?> sourceSampleId;
  final Value<String?> sourceTitle;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PlotProfileRecordsCompanion({
    this.id = const Value.absent(),
    this.sourceRunId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.modelName = const Value.absent(),
    this.plotName = const Value.absent(),
    this.storyEngineMarkdown = const Value.absent(),
    this.analysisReportMarkdown = const Value.absent(),
    this.plotSkeletonMarkdown = const Value.absent(),
    this.sourceSampleId = const Value.absent(),
    this.sourceTitle = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlotProfileRecordsCompanion.insert({
    required String id,
    required String sourceRunId,
    required String providerId,
    required String modelName,
    required String plotName,
    required String storyEngineMarkdown,
    required String analysisReportMarkdown,
    required String plotSkeletonMarkdown,
    this.sourceSampleId = const Value.absent(),
    this.sourceTitle = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceRunId = Value(sourceRunId),
       providerId = Value(providerId),
       modelName = Value(modelName),
       plotName = Value(plotName),
       storyEngineMarkdown = Value(storyEngineMarkdown),
       analysisReportMarkdown = Value(analysisReportMarkdown),
       plotSkeletonMarkdown = Value(plotSkeletonMarkdown),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PlotProfileRecord> custom({
    Expression<String>? id,
    Expression<String>? sourceRunId,
    Expression<String>? providerId,
    Expression<String>? modelName,
    Expression<String>? plotName,
    Expression<String>? storyEngineMarkdown,
    Expression<String>? analysisReportMarkdown,
    Expression<String>? plotSkeletonMarkdown,
    Expression<String>? sourceSampleId,
    Expression<String>? sourceTitle,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceRunId != null) 'source_run_id': sourceRunId,
      if (providerId != null) 'provider_id': providerId,
      if (modelName != null) 'model_name': modelName,
      if (plotName != null) 'plot_name': plotName,
      if (storyEngineMarkdown != null)
        'story_engine_markdown': storyEngineMarkdown,
      if (analysisReportMarkdown != null)
        'analysis_report_markdown': analysisReportMarkdown,
      if (plotSkeletonMarkdown != null)
        'plot_skeleton_markdown': plotSkeletonMarkdown,
      if (sourceSampleId != null) 'source_sample_id': sourceSampleId,
      if (sourceTitle != null) 'source_title': sourceTitle,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlotProfileRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceRunId,
    Value<String>? providerId,
    Value<String>? modelName,
    Value<String>? plotName,
    Value<String>? storyEngineMarkdown,
    Value<String>? analysisReportMarkdown,
    Value<String>? plotSkeletonMarkdown,
    Value<String?>? sourceSampleId,
    Value<String?>? sourceTitle,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PlotProfileRecordsCompanion(
      id: id ?? this.id,
      sourceRunId: sourceRunId ?? this.sourceRunId,
      providerId: providerId ?? this.providerId,
      modelName: modelName ?? this.modelName,
      plotName: plotName ?? this.plotName,
      storyEngineMarkdown: storyEngineMarkdown ?? this.storyEngineMarkdown,
      analysisReportMarkdown:
          analysisReportMarkdown ?? this.analysisReportMarkdown,
      plotSkeletonMarkdown: plotSkeletonMarkdown ?? this.plotSkeletonMarkdown,
      sourceSampleId: sourceSampleId ?? this.sourceSampleId,
      sourceTitle: sourceTitle ?? this.sourceTitle,
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
    if (sourceRunId.present) {
      map['source_run_id'] = Variable<String>(sourceRunId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (plotName.present) {
      map['plot_name'] = Variable<String>(plotName.value);
    }
    if (storyEngineMarkdown.present) {
      map['story_engine_markdown'] = Variable<String>(
        storyEngineMarkdown.value,
      );
    }
    if (analysisReportMarkdown.present) {
      map['analysis_report_markdown'] = Variable<String>(
        analysisReportMarkdown.value,
      );
    }
    if (plotSkeletonMarkdown.present) {
      map['plot_skeleton_markdown'] = Variable<String>(
        plotSkeletonMarkdown.value,
      );
    }
    if (sourceSampleId.present) {
      map['source_sample_id'] = Variable<String>(sourceSampleId.value);
    }
    if (sourceTitle.present) {
      map['source_title'] = Variable<String>(sourceTitle.value);
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
    return (StringBuffer('PlotProfileRecordsCompanion(')
          ..write('id: $id, ')
          ..write('sourceRunId: $sourceRunId, ')
          ..write('providerId: $providerId, ')
          ..write('modelName: $modelName, ')
          ..write('plotName: $plotName, ')
          ..write('storyEngineMarkdown: $storyEngineMarkdown, ')
          ..write('analysisReportMarkdown: $analysisReportMarkdown, ')
          ..write('plotSkeletonMarkdown: $plotSkeletonMarkdown, ')
          ..write('sourceSampleId: $sourceSampleId, ')
          ..write('sourceTitle: $sourceTitle, ')
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
  late final $WorkflowPromptTraceRecordsTable workflowPromptTraceRecords =
      $WorkflowPromptTraceRecordsTable(this);
  late final $ProviderConfigRecordsTable providerConfigRecords =
      $ProviderConfigRecordsTable(this);
  late final $ProjectRecordsTable projectRecords = $ProjectRecordsTable(this);
  late final $StyleSampleRecordsTable styleSampleRecords =
      $StyleSampleRecordsTable(this);
  late final $StyleAnalysisRunRecordsTable styleAnalysisRunRecords =
      $StyleAnalysisRunRecordsTable(this);
  late final $StyleProfileRecordsTable styleProfileRecords =
      $StyleProfileRecordsTable(this);
  late final $PlotSampleRecordsTable plotSampleRecords =
      $PlotSampleRecordsTable(this);
  late final $PlotAnalysisRunRecordsTable plotAnalysisRunRecords =
      $PlotAnalysisRunRecordsTable(this);
  late final $PlotProfileRecordsTable plotProfileRecords =
      $PlotProfileRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    workflowTaskRecords,
    workflowPromptTraceRecords,
    providerConfigRecords,
    projectRecords,
    styleSampleRecords,
    styleAnalysisRunRecords,
    styleProfileRecords,
    plotSampleRecords,
    plotAnalysisRunRecords,
    plotProfileRecords,
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

final class $$WorkflowTaskRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WorkflowTaskRecordsTable,
          WorkflowTaskRecord
        > {
  $$WorkflowTaskRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $WorkflowPromptTraceRecordsTable,
    List<WorkflowPromptTraceRecord>
  >
  _workflowPromptTraceRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workflowPromptTraceRecords,
        aliasName: $_aliasNameGenerator(
          db.workflowTaskRecords.id,
          db.workflowPromptTraceRecords.workflowTaskId,
        ),
      );

  $$WorkflowPromptTraceRecordsTableProcessedTableManager
  get workflowPromptTraceRecordsRefs {
    final manager = $$WorkflowPromptTraceRecordsTableTableManager(
      $_db,
      $_db.workflowPromptTraceRecords,
    ).filter((f) => f.workflowTaskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workflowPromptTraceRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $StyleAnalysisRunRecordsTable,
    List<StyleAnalysisRunRecord>
  >
  _styleAnalysisRunRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.styleAnalysisRunRecords,
        aliasName: $_aliasNameGenerator(
          db.workflowTaskRecords.id,
          db.styleAnalysisRunRecords.workflowTaskId,
        ),
      );

  $$StyleAnalysisRunRecordsTableProcessedTableManager
  get styleAnalysisRunRecordsRefs {
    final manager = $$StyleAnalysisRunRecordsTableTableManager(
      $_db,
      $_db.styleAnalysisRunRecords,
    ).filter((f) => f.workflowTaskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _styleAnalysisRunRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PlotAnalysisRunRecordsTable,
    List<PlotAnalysisRunRecord>
  >
  _plotAnalysisRunRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.plotAnalysisRunRecords,
        aliasName: $_aliasNameGenerator(
          db.workflowTaskRecords.id,
          db.plotAnalysisRunRecords.workflowTaskId,
        ),
      );

  $$PlotAnalysisRunRecordsTableProcessedTableManager
  get plotAnalysisRunRecordsRefs {
    final manager = $$PlotAnalysisRunRecordsTableTableManager(
      $_db,
      $_db.plotAnalysisRunRecords,
    ).filter((f) => f.workflowTaskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _plotAnalysisRunRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  Expression<bool> workflowPromptTraceRecordsRefs(
    Expression<bool> Function($$WorkflowPromptTraceRecordsTableFilterComposer f)
    f,
  ) {
    final $$WorkflowPromptTraceRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workflowPromptTraceRecords,
          getReferencedColumn: (t) => t.workflowTaskId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkflowPromptTraceRecordsTableFilterComposer(
                $db: $db,
                $table: $db.workflowPromptTraceRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> styleAnalysisRunRecordsRefs(
    Expression<bool> Function($$StyleAnalysisRunRecordsTableFilterComposer f) f,
  ) {
    final $$StyleAnalysisRunRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.styleAnalysisRunRecords,
          getReferencedColumn: (t) => t.workflowTaskId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StyleAnalysisRunRecordsTableFilterComposer(
                $db: $db,
                $table: $db.styleAnalysisRunRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> plotAnalysisRunRecordsRefs(
    Expression<bool> Function($$PlotAnalysisRunRecordsTableFilterComposer f) f,
  ) {
    final $$PlotAnalysisRunRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.plotAnalysisRunRecords,
          getReferencedColumn: (t) => t.workflowTaskId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlotAnalysisRunRecordsTableFilterComposer(
                $db: $db,
                $table: $db.plotAnalysisRunRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
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

  Expression<T> workflowPromptTraceRecordsRefs<T extends Object>(
    Expression<T> Function(
      $$WorkflowPromptTraceRecordsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$WorkflowPromptTraceRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workflowPromptTraceRecords,
          getReferencedColumn: (t) => t.workflowTaskId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkflowPromptTraceRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.workflowPromptTraceRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> styleAnalysisRunRecordsRefs<T extends Object>(
    Expression<T> Function($$StyleAnalysisRunRecordsTableAnnotationComposer a)
    f,
  ) {
    final $$StyleAnalysisRunRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.styleAnalysisRunRecords,
          getReferencedColumn: (t) => t.workflowTaskId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StyleAnalysisRunRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.styleAnalysisRunRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> plotAnalysisRunRecordsRefs<T extends Object>(
    Expression<T> Function($$PlotAnalysisRunRecordsTableAnnotationComposer a) f,
  ) {
    final $$PlotAnalysisRunRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.plotAnalysisRunRecords,
          getReferencedColumn: (t) => t.workflowTaskId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlotAnalysisRunRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.plotAnalysisRunRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
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
          (WorkflowTaskRecord, $$WorkflowTaskRecordsTableReferences),
          WorkflowTaskRecord,
          PrefetchHooks Function({
            bool workflowPromptTraceRecordsRefs,
            bool styleAnalysisRunRecordsRefs,
            bool plotAnalysisRunRecordsRefs,
          })
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
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkflowTaskRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workflowPromptTraceRecordsRefs = false,
                styleAnalysisRunRecordsRefs = false,
                plotAnalysisRunRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workflowPromptTraceRecordsRefs)
                      db.workflowPromptTraceRecords,
                    if (styleAnalysisRunRecordsRefs) db.styleAnalysisRunRecords,
                    if (plotAnalysisRunRecordsRefs) db.plotAnalysisRunRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (workflowPromptTraceRecordsRefs)
                        await $_getPrefetchedData<
                          WorkflowTaskRecord,
                          $WorkflowTaskRecordsTable,
                          WorkflowPromptTraceRecord
                        >(
                          currentTable: table,
                          referencedTable: $$WorkflowTaskRecordsTableReferences
                              ._workflowPromptTraceRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkflowTaskRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).workflowPromptTraceRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workflowTaskId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (styleAnalysisRunRecordsRefs)
                        await $_getPrefetchedData<
                          WorkflowTaskRecord,
                          $WorkflowTaskRecordsTable,
                          StyleAnalysisRunRecord
                        >(
                          currentTable: table,
                          referencedTable: $$WorkflowTaskRecordsTableReferences
                              ._styleAnalysisRunRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkflowTaskRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).styleAnalysisRunRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workflowTaskId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (plotAnalysisRunRecordsRefs)
                        await $_getPrefetchedData<
                          WorkflowTaskRecord,
                          $WorkflowTaskRecordsTable,
                          PlotAnalysisRunRecord
                        >(
                          currentTable: table,
                          referencedTable: $$WorkflowTaskRecordsTableReferences
                              ._plotAnalysisRunRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkflowTaskRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).plotAnalysisRunRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workflowTaskId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
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
      (WorkflowTaskRecord, $$WorkflowTaskRecordsTableReferences),
      WorkflowTaskRecord,
      PrefetchHooks Function({
        bool workflowPromptTraceRecordsRefs,
        bool styleAnalysisRunRecordsRefs,
        bool plotAnalysisRunRecordsRefs,
      })
    >;
typedef $$WorkflowPromptTraceRecordsTableCreateCompanionBuilder =
    WorkflowPromptTraceRecordsCompanion Function({
      required String workflowTaskId,
      required String traceMarkdown,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$WorkflowPromptTraceRecordsTableUpdateCompanionBuilder =
    WorkflowPromptTraceRecordsCompanion Function({
      Value<String> workflowTaskId,
      Value<String> traceMarkdown,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$WorkflowPromptTraceRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WorkflowPromptTraceRecordsTable,
          WorkflowPromptTraceRecord
        > {
  $$WorkflowPromptTraceRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkflowTaskRecordsTable _workflowTaskIdTable(_$AppDatabase db) =>
      db.workflowTaskRecords.createAlias(
        $_aliasNameGenerator(
          db.workflowPromptTraceRecords.workflowTaskId,
          db.workflowTaskRecords.id,
        ),
      );

  $$WorkflowTaskRecordsTableProcessedTableManager get workflowTaskId {
    final $_column = $_itemColumn<String>('workflow_task_id')!;

    final manager = $$WorkflowTaskRecordsTableTableManager(
      $_db,
      $_db.workflowTaskRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workflowTaskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkflowPromptTraceRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkflowPromptTraceRecordsTable> {
  $$WorkflowPromptTraceRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get traceMarkdown => $composableBuilder(
    column: $table.traceMarkdown,
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

  $$WorkflowTaskRecordsTableFilterComposer get workflowTaskId {
    final $$WorkflowTaskRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workflowTaskId,
      referencedTable: $db.workflowTaskRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkflowTaskRecordsTableFilterComposer(
            $db: $db,
            $table: $db.workflowTaskRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkflowPromptTraceRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkflowPromptTraceRecordsTable> {
  $$WorkflowPromptTraceRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get traceMarkdown => $composableBuilder(
    column: $table.traceMarkdown,
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

  $$WorkflowTaskRecordsTableOrderingComposer get workflowTaskId {
    final $$WorkflowTaskRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workflowTaskId,
          referencedTable: $db.workflowTaskRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkflowTaskRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.workflowTaskRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$WorkflowPromptTraceRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkflowPromptTraceRecordsTable> {
  $$WorkflowPromptTraceRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get traceMarkdown => $composableBuilder(
    column: $table.traceMarkdown,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$WorkflowTaskRecordsTableAnnotationComposer get workflowTaskId {
    final $$WorkflowTaskRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workflowTaskId,
          referencedTable: $db.workflowTaskRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkflowTaskRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.workflowTaskRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$WorkflowPromptTraceRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkflowPromptTraceRecordsTable,
          WorkflowPromptTraceRecord,
          $$WorkflowPromptTraceRecordsTableFilterComposer,
          $$WorkflowPromptTraceRecordsTableOrderingComposer,
          $$WorkflowPromptTraceRecordsTableAnnotationComposer,
          $$WorkflowPromptTraceRecordsTableCreateCompanionBuilder,
          $$WorkflowPromptTraceRecordsTableUpdateCompanionBuilder,
          (
            WorkflowPromptTraceRecord,
            $$WorkflowPromptTraceRecordsTableReferences,
          ),
          WorkflowPromptTraceRecord,
          PrefetchHooks Function({bool workflowTaskId})
        > {
  $$WorkflowPromptTraceRecordsTableTableManager(
    _$AppDatabase db,
    $WorkflowPromptTraceRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkflowPromptTraceRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$WorkflowPromptTraceRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WorkflowPromptTraceRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> workflowTaskId = const Value.absent(),
                Value<String> traceMarkdown = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkflowPromptTraceRecordsCompanion(
                workflowTaskId: workflowTaskId,
                traceMarkdown: traceMarkdown,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String workflowTaskId,
                required String traceMarkdown,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WorkflowPromptTraceRecordsCompanion.insert(
                workflowTaskId: workflowTaskId,
                traceMarkdown: traceMarkdown,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkflowPromptTraceRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workflowTaskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workflowTaskId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.workflowTaskId,
                                referencedTable:
                                    $$WorkflowPromptTraceRecordsTableReferences
                                        ._workflowTaskIdTable(db),
                                referencedColumn:
                                    $$WorkflowPromptTraceRecordsTableReferences
                                        ._workflowTaskIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WorkflowPromptTraceRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkflowPromptTraceRecordsTable,
      WorkflowPromptTraceRecord,
      $$WorkflowPromptTraceRecordsTableFilterComposer,
      $$WorkflowPromptTraceRecordsTableOrderingComposer,
      $$WorkflowPromptTraceRecordsTableAnnotationComposer,
      $$WorkflowPromptTraceRecordsTableCreateCompanionBuilder,
      $$WorkflowPromptTraceRecordsTableUpdateCompanionBuilder,
      (WorkflowPromptTraceRecord, $$WorkflowPromptTraceRecordsTableReferences),
      WorkflowPromptTraceRecord,
      PrefetchHooks Function({bool workflowTaskId})
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

final class $$ProviderConfigRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ProviderConfigRecordsTable,
          ProviderConfigRecord
        > {
  $$ProviderConfigRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $StyleAnalysisRunRecordsTable,
    List<StyleAnalysisRunRecord>
  >
  _styleAnalysisRunRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.styleAnalysisRunRecords,
        aliasName: $_aliasNameGenerator(
          db.providerConfigRecords.id,
          db.styleAnalysisRunRecords.providerId,
        ),
      );

  $$StyleAnalysisRunRecordsTableProcessedTableManager
  get styleAnalysisRunRecordsRefs {
    final manager = $$StyleAnalysisRunRecordsTableTableManager(
      $_db,
      $_db.styleAnalysisRunRecords,
    ).filter((f) => f.providerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _styleAnalysisRunRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $StyleProfileRecordsTable,
    List<StyleProfileRecord>
  >
  _styleProfileRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.styleProfileRecords,
        aliasName: $_aliasNameGenerator(
          db.providerConfigRecords.id,
          db.styleProfileRecords.providerId,
        ),
      );

  $$StyleProfileRecordsTableProcessedTableManager get styleProfileRecordsRefs {
    final manager = $$StyleProfileRecordsTableTableManager(
      $_db,
      $_db.styleProfileRecords,
    ).filter((f) => f.providerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _styleProfileRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PlotAnalysisRunRecordsTable,
    List<PlotAnalysisRunRecord>
  >
  _plotAnalysisRunRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.plotAnalysisRunRecords,
        aliasName: $_aliasNameGenerator(
          db.providerConfigRecords.id,
          db.plotAnalysisRunRecords.providerId,
        ),
      );

  $$PlotAnalysisRunRecordsTableProcessedTableManager
  get plotAnalysisRunRecordsRefs {
    final manager = $$PlotAnalysisRunRecordsTableTableManager(
      $_db,
      $_db.plotAnalysisRunRecords,
    ).filter((f) => f.providerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _plotAnalysisRunRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlotProfileRecordsTable, List<PlotProfileRecord>>
  _plotProfileRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.plotProfileRecords,
        aliasName: $_aliasNameGenerator(
          db.providerConfigRecords.id,
          db.plotProfileRecords.providerId,
        ),
      );

  $$PlotProfileRecordsTableProcessedTableManager get plotProfileRecordsRefs {
    final manager = $$PlotProfileRecordsTableTableManager(
      $_db,
      $_db.plotProfileRecords,
    ).filter((f) => f.providerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _plotProfileRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  Expression<bool> styleAnalysisRunRecordsRefs(
    Expression<bool> Function($$StyleAnalysisRunRecordsTableFilterComposer f) f,
  ) {
    final $$StyleAnalysisRunRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.styleAnalysisRunRecords,
          getReferencedColumn: (t) => t.providerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StyleAnalysisRunRecordsTableFilterComposer(
                $db: $db,
                $table: $db.styleAnalysisRunRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> styleProfileRecordsRefs(
    Expression<bool> Function($$StyleProfileRecordsTableFilterComposer f) f,
  ) {
    final $$StyleProfileRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.styleProfileRecords,
      getReferencedColumn: (t) => t.providerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StyleProfileRecordsTableFilterComposer(
            $db: $db,
            $table: $db.styleProfileRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> plotAnalysisRunRecordsRefs(
    Expression<bool> Function($$PlotAnalysisRunRecordsTableFilterComposer f) f,
  ) {
    final $$PlotAnalysisRunRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.plotAnalysisRunRecords,
          getReferencedColumn: (t) => t.providerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlotAnalysisRunRecordsTableFilterComposer(
                $db: $db,
                $table: $db.plotAnalysisRunRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> plotProfileRecordsRefs(
    Expression<bool> Function($$PlotProfileRecordsTableFilterComposer f) f,
  ) {
    final $$PlotProfileRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plotProfileRecords,
      getReferencedColumn: (t) => t.providerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlotProfileRecordsTableFilterComposer(
            $db: $db,
            $table: $db.plotProfileRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  Expression<T> styleAnalysisRunRecordsRefs<T extends Object>(
    Expression<T> Function($$StyleAnalysisRunRecordsTableAnnotationComposer a)
    f,
  ) {
    final $$StyleAnalysisRunRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.styleAnalysisRunRecords,
          getReferencedColumn: (t) => t.providerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StyleAnalysisRunRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.styleAnalysisRunRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> styleProfileRecordsRefs<T extends Object>(
    Expression<T> Function($$StyleProfileRecordsTableAnnotationComposer a) f,
  ) {
    final $$StyleProfileRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.styleProfileRecords,
          getReferencedColumn: (t) => t.providerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StyleProfileRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.styleProfileRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> plotAnalysisRunRecordsRefs<T extends Object>(
    Expression<T> Function($$PlotAnalysisRunRecordsTableAnnotationComposer a) f,
  ) {
    final $$PlotAnalysisRunRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.plotAnalysisRunRecords,
          getReferencedColumn: (t) => t.providerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlotAnalysisRunRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.plotAnalysisRunRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> plotProfileRecordsRefs<T extends Object>(
    Expression<T> Function($$PlotProfileRecordsTableAnnotationComposer a) f,
  ) {
    final $$PlotProfileRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.plotProfileRecords,
          getReferencedColumn: (t) => t.providerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlotProfileRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.plotProfileRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
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
          (ProviderConfigRecord, $$ProviderConfigRecordsTableReferences),
          ProviderConfigRecord,
          PrefetchHooks Function({
            bool styleAnalysisRunRecordsRefs,
            bool styleProfileRecordsRefs,
            bool plotAnalysisRunRecordsRefs,
            bool plotProfileRecordsRefs,
          })
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
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProviderConfigRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                styleAnalysisRunRecordsRefs = false,
                styleProfileRecordsRefs = false,
                plotAnalysisRunRecordsRefs = false,
                plotProfileRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (styleAnalysisRunRecordsRefs) db.styleAnalysisRunRecords,
                    if (styleProfileRecordsRefs) db.styleProfileRecords,
                    if (plotAnalysisRunRecordsRefs) db.plotAnalysisRunRecords,
                    if (plotProfileRecordsRefs) db.plotProfileRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (styleAnalysisRunRecordsRefs)
                        await $_getPrefetchedData<
                          ProviderConfigRecord,
                          $ProviderConfigRecordsTable,
                          StyleAnalysisRunRecord
                        >(
                          currentTable: table,
                          referencedTable:
                              $$ProviderConfigRecordsTableReferences
                                  ._styleAnalysisRunRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProviderConfigRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).styleAnalysisRunRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.providerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (styleProfileRecordsRefs)
                        await $_getPrefetchedData<
                          ProviderConfigRecord,
                          $ProviderConfigRecordsTable,
                          StyleProfileRecord
                        >(
                          currentTable: table,
                          referencedTable:
                              $$ProviderConfigRecordsTableReferences
                                  ._styleProfileRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProviderConfigRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).styleProfileRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.providerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (plotAnalysisRunRecordsRefs)
                        await $_getPrefetchedData<
                          ProviderConfigRecord,
                          $ProviderConfigRecordsTable,
                          PlotAnalysisRunRecord
                        >(
                          currentTable: table,
                          referencedTable:
                              $$ProviderConfigRecordsTableReferences
                                  ._plotAnalysisRunRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProviderConfigRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).plotAnalysisRunRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.providerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (plotProfileRecordsRefs)
                        await $_getPrefetchedData<
                          ProviderConfigRecord,
                          $ProviderConfigRecordsTable,
                          PlotProfileRecord
                        >(
                          currentTable: table,
                          referencedTable:
                              $$ProviderConfigRecordsTableReferences
                                  ._plotProfileRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProviderConfigRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).plotProfileRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.providerId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
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
      (ProviderConfigRecord, $$ProviderConfigRecordsTableReferences),
      ProviderConfigRecord,
      PrefetchHooks Function({
        bool styleAnalysisRunRecordsRefs,
        bool styleProfileRecordsRefs,
        bool plotAnalysisRunRecordsRefs,
        bool plotProfileRecordsRefs,
      })
    >;
typedef $$ProjectRecordsTableCreateCompanionBuilder =
    ProjectRecordsCompanion Function({
      required String id,
      required String title,
      Value<String> description,
      required String status,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ProjectRecordsTableUpdateCompanionBuilder =
    ProjectRecordsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> description,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ProjectRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectRecordsTable, ProjectRecord> {
  $$ProjectRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$StyleSampleRecordsTable, List<StyleSampleRecord>>
  _styleSampleRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.styleSampleRecords,
        aliasName: $_aliasNameGenerator(
          db.projectRecords.id,
          db.styleSampleRecords.projectId,
        ),
      );

  $$StyleSampleRecordsTableProcessedTableManager get styleSampleRecordsRefs {
    final manager = $$StyleSampleRecordsTableTableManager(
      $_db,
      $_db.styleSampleRecords,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _styleSampleRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $StyleAnalysisRunRecordsTable,
    List<StyleAnalysisRunRecord>
  >
  _styleAnalysisRunRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.styleAnalysisRunRecords,
        aliasName: $_aliasNameGenerator(
          db.projectRecords.id,
          db.styleAnalysisRunRecords.projectId,
        ),
      );

  $$StyleAnalysisRunRecordsTableProcessedTableManager
  get styleAnalysisRunRecordsRefs {
    final manager = $$StyleAnalysisRunRecordsTableTableManager(
      $_db,
      $_db.styleAnalysisRunRecords,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _styleAnalysisRunRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $StyleProfileRecordsTable,
    List<StyleProfileRecord>
  >
  _styleProfileRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.styleProfileRecords,
        aliasName: $_aliasNameGenerator(
          db.projectRecords.id,
          db.styleProfileRecords.projectId,
        ),
      );

  $$StyleProfileRecordsTableProcessedTableManager get styleProfileRecordsRefs {
    final manager = $$StyleProfileRecordsTableTableManager(
      $_db,
      $_db.styleProfileRecords,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _styleProfileRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProjectRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectRecordsTable> {
  $$ProjectRecordsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
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

  Expression<bool> styleSampleRecordsRefs(
    Expression<bool> Function($$StyleSampleRecordsTableFilterComposer f) f,
  ) {
    final $$StyleSampleRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.styleSampleRecords,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StyleSampleRecordsTableFilterComposer(
            $db: $db,
            $table: $db.styleSampleRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> styleAnalysisRunRecordsRefs(
    Expression<bool> Function($$StyleAnalysisRunRecordsTableFilterComposer f) f,
  ) {
    final $$StyleAnalysisRunRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.styleAnalysisRunRecords,
          getReferencedColumn: (t) => t.projectId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StyleAnalysisRunRecordsTableFilterComposer(
                $db: $db,
                $table: $db.styleAnalysisRunRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> styleProfileRecordsRefs(
    Expression<bool> Function($$StyleProfileRecordsTableFilterComposer f) f,
  ) {
    final $$StyleProfileRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.styleProfileRecords,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StyleProfileRecordsTableFilterComposer(
            $db: $db,
            $table: $db.styleProfileRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectRecordsTable> {
  $$ProjectRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

class $$ProjectRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectRecordsTable> {
  $$ProjectRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> styleSampleRecordsRefs<T extends Object>(
    Expression<T> Function($$StyleSampleRecordsTableAnnotationComposer a) f,
  ) {
    final $$StyleSampleRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.styleSampleRecords,
          getReferencedColumn: (t) => t.projectId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StyleSampleRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.styleSampleRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> styleAnalysisRunRecordsRefs<T extends Object>(
    Expression<T> Function($$StyleAnalysisRunRecordsTableAnnotationComposer a)
    f,
  ) {
    final $$StyleAnalysisRunRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.styleAnalysisRunRecords,
          getReferencedColumn: (t) => t.projectId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StyleAnalysisRunRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.styleAnalysisRunRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> styleProfileRecordsRefs<T extends Object>(
    Expression<T> Function($$StyleProfileRecordsTableAnnotationComposer a) f,
  ) {
    final $$StyleProfileRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.styleProfileRecords,
          getReferencedColumn: (t) => t.projectId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StyleProfileRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.styleProfileRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ProjectRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectRecordsTable,
          ProjectRecord,
          $$ProjectRecordsTableFilterComposer,
          $$ProjectRecordsTableOrderingComposer,
          $$ProjectRecordsTableAnnotationComposer,
          $$ProjectRecordsTableCreateCompanionBuilder,
          $$ProjectRecordsTableUpdateCompanionBuilder,
          (ProjectRecord, $$ProjectRecordsTableReferences),
          ProjectRecord,
          PrefetchHooks Function({
            bool styleSampleRecordsRefs,
            bool styleAnalysisRunRecordsRefs,
            bool styleProfileRecordsRefs,
          })
        > {
  $$ProjectRecordsTableTableManager(
    _$AppDatabase db,
    $ProjectRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectRecordsCompanion(
                id: id,
                title: title,
                description: description,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> description = const Value.absent(),
                required String status,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProjectRecordsCompanion.insert(
                id: id,
                title: title,
                description: description,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProjectRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                styleSampleRecordsRefs = false,
                styleAnalysisRunRecordsRefs = false,
                styleProfileRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (styleSampleRecordsRefs) db.styleSampleRecords,
                    if (styleAnalysisRunRecordsRefs) db.styleAnalysisRunRecords,
                    if (styleProfileRecordsRefs) db.styleProfileRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (styleSampleRecordsRefs)
                        await $_getPrefetchedData<
                          ProjectRecord,
                          $ProjectRecordsTable,
                          StyleSampleRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectRecordsTableReferences
                              ._styleSampleRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).styleSampleRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (styleAnalysisRunRecordsRefs)
                        await $_getPrefetchedData<
                          ProjectRecord,
                          $ProjectRecordsTable,
                          StyleAnalysisRunRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectRecordsTableReferences
                              ._styleAnalysisRunRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).styleAnalysisRunRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (styleProfileRecordsRefs)
                        await $_getPrefetchedData<
                          ProjectRecord,
                          $ProjectRecordsTable,
                          StyleProfileRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectRecordsTableReferences
                              ._styleProfileRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).styleProfileRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProjectRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectRecordsTable,
      ProjectRecord,
      $$ProjectRecordsTableFilterComposer,
      $$ProjectRecordsTableOrderingComposer,
      $$ProjectRecordsTableAnnotationComposer,
      $$ProjectRecordsTableCreateCompanionBuilder,
      $$ProjectRecordsTableUpdateCompanionBuilder,
      (ProjectRecord, $$ProjectRecordsTableReferences),
      ProjectRecord,
      PrefetchHooks Function({
        bool styleSampleRecordsRefs,
        bool styleAnalysisRunRecordsRefs,
        bool styleProfileRecordsRefs,
      })
    >;
typedef $$StyleSampleRecordsTableCreateCompanionBuilder =
    StyleSampleRecordsCompanion Function({
      required String id,
      required String sourceType,
      required String title,
      required String content,
      required int characterCount,
      Value<String?> projectId,
      Value<String?> sourceFilename,
      Value<String?> epubBookTitle,
      Value<String?> epubAuthor,
      Value<String?> epubChapterTitle,
      Value<int?> epubChapterIndex,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$StyleSampleRecordsTableUpdateCompanionBuilder =
    StyleSampleRecordsCompanion Function({
      Value<String> id,
      Value<String> sourceType,
      Value<String> title,
      Value<String> content,
      Value<int> characterCount,
      Value<String?> projectId,
      Value<String?> sourceFilename,
      Value<String?> epubBookTitle,
      Value<String?> epubAuthor,
      Value<String?> epubChapterTitle,
      Value<int?> epubChapterIndex,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$StyleSampleRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StyleSampleRecordsTable,
          StyleSampleRecord
        > {
  $$StyleSampleRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProjectRecordsTable _projectIdTable(_$AppDatabase db) =>
      db.projectRecords.createAlias(
        $_aliasNameGenerator(
          db.styleSampleRecords.projectId,
          db.projectRecords.id,
        ),
      );

  $$ProjectRecordsTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<String>('project_id');
    if ($_column == null) return null;
    final manager = $$ProjectRecordsTableTableManager(
      $_db,
      $_db.projectRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $StyleAnalysisRunRecordsTable,
    List<StyleAnalysisRunRecord>
  >
  _styleAnalysisRunRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.styleAnalysisRunRecords,
        aliasName: $_aliasNameGenerator(
          db.styleSampleRecords.id,
          db.styleAnalysisRunRecords.sampleId,
        ),
      );

  $$StyleAnalysisRunRecordsTableProcessedTableManager
  get styleAnalysisRunRecordsRefs {
    final manager = $$StyleAnalysisRunRecordsTableTableManager(
      $_db,
      $_db.styleAnalysisRunRecords,
    ).filter((f) => f.sampleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _styleAnalysisRunRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $StyleProfileRecordsTable,
    List<StyleProfileRecord>
  >
  _styleProfileRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.styleProfileRecords,
        aliasName: $_aliasNameGenerator(
          db.styleSampleRecords.id,
          db.styleProfileRecords.sourceSampleId,
        ),
      );

  $$StyleProfileRecordsTableProcessedTableManager get styleProfileRecordsRefs {
    final manager = $$StyleProfileRecordsTableTableManager(
      $_db,
      $_db.styleProfileRecords,
    ).filter((f) => f.sourceSampleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _styleProfileRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StyleSampleRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $StyleSampleRecordsTable> {
  $$StyleSampleRecordsTableFilterComposer({
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

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get characterCount => $composableBuilder(
    column: $table.characterCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceFilename => $composableBuilder(
    column: $table.sourceFilename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get epubBookTitle => $composableBuilder(
    column: $table.epubBookTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get epubAuthor => $composableBuilder(
    column: $table.epubAuthor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get epubChapterTitle => $composableBuilder(
    column: $table.epubChapterTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get epubChapterIndex => $composableBuilder(
    column: $table.epubChapterIndex,
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

  $$ProjectRecordsTableFilterComposer get projectId {
    final $$ProjectRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectRecordsTableFilterComposer(
            $db: $db,
            $table: $db.projectRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> styleAnalysisRunRecordsRefs(
    Expression<bool> Function($$StyleAnalysisRunRecordsTableFilterComposer f) f,
  ) {
    final $$StyleAnalysisRunRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.styleAnalysisRunRecords,
          getReferencedColumn: (t) => t.sampleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StyleAnalysisRunRecordsTableFilterComposer(
                $db: $db,
                $table: $db.styleAnalysisRunRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> styleProfileRecordsRefs(
    Expression<bool> Function($$StyleProfileRecordsTableFilterComposer f) f,
  ) {
    final $$StyleProfileRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.styleProfileRecords,
      getReferencedColumn: (t) => t.sourceSampleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StyleProfileRecordsTableFilterComposer(
            $db: $db,
            $table: $db.styleProfileRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StyleSampleRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $StyleSampleRecordsTable> {
  $$StyleSampleRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get characterCount => $composableBuilder(
    column: $table.characterCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceFilename => $composableBuilder(
    column: $table.sourceFilename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get epubBookTitle => $composableBuilder(
    column: $table.epubBookTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get epubAuthor => $composableBuilder(
    column: $table.epubAuthor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get epubChapterTitle => $composableBuilder(
    column: $table.epubChapterTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get epubChapterIndex => $composableBuilder(
    column: $table.epubChapterIndex,
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

  $$ProjectRecordsTableOrderingComposer get projectId {
    final $$ProjectRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.projectRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StyleSampleRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StyleSampleRecordsTable> {
  $$StyleSampleRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get characterCount => $composableBuilder(
    column: $table.characterCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceFilename => $composableBuilder(
    column: $table.sourceFilename,
    builder: (column) => column,
  );

  GeneratedColumn<String> get epubBookTitle => $composableBuilder(
    column: $table.epubBookTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get epubAuthor => $composableBuilder(
    column: $table.epubAuthor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get epubChapterTitle => $composableBuilder(
    column: $table.epubChapterTitle,
    builder: (column) => column,
  );

  GeneratedColumn<int> get epubChapterIndex => $composableBuilder(
    column: $table.epubChapterIndex,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProjectRecordsTableAnnotationComposer get projectId {
    final $$ProjectRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.projectRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> styleAnalysisRunRecordsRefs<T extends Object>(
    Expression<T> Function($$StyleAnalysisRunRecordsTableAnnotationComposer a)
    f,
  ) {
    final $$StyleAnalysisRunRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.styleAnalysisRunRecords,
          getReferencedColumn: (t) => t.sampleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StyleAnalysisRunRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.styleAnalysisRunRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> styleProfileRecordsRefs<T extends Object>(
    Expression<T> Function($$StyleProfileRecordsTableAnnotationComposer a) f,
  ) {
    final $$StyleProfileRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.styleProfileRecords,
          getReferencedColumn: (t) => t.sourceSampleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StyleProfileRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.styleProfileRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StyleSampleRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StyleSampleRecordsTable,
          StyleSampleRecord,
          $$StyleSampleRecordsTableFilterComposer,
          $$StyleSampleRecordsTableOrderingComposer,
          $$StyleSampleRecordsTableAnnotationComposer,
          $$StyleSampleRecordsTableCreateCompanionBuilder,
          $$StyleSampleRecordsTableUpdateCompanionBuilder,
          (StyleSampleRecord, $$StyleSampleRecordsTableReferences),
          StyleSampleRecord,
          PrefetchHooks Function({
            bool projectId,
            bool styleAnalysisRunRecordsRefs,
            bool styleProfileRecordsRefs,
          })
        > {
  $$StyleSampleRecordsTableTableManager(
    _$AppDatabase db,
    $StyleSampleRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StyleSampleRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StyleSampleRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StyleSampleRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> characterCount = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String?> sourceFilename = const Value.absent(),
                Value<String?> epubBookTitle = const Value.absent(),
                Value<String?> epubAuthor = const Value.absent(),
                Value<String?> epubChapterTitle = const Value.absent(),
                Value<int?> epubChapterIndex = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StyleSampleRecordsCompanion(
                id: id,
                sourceType: sourceType,
                title: title,
                content: content,
                characterCount: characterCount,
                projectId: projectId,
                sourceFilename: sourceFilename,
                epubBookTitle: epubBookTitle,
                epubAuthor: epubAuthor,
                epubChapterTitle: epubChapterTitle,
                epubChapterIndex: epubChapterIndex,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sourceType,
                required String title,
                required String content,
                required int characterCount,
                Value<String?> projectId = const Value.absent(),
                Value<String?> sourceFilename = const Value.absent(),
                Value<String?> epubBookTitle = const Value.absent(),
                Value<String?> epubAuthor = const Value.absent(),
                Value<String?> epubChapterTitle = const Value.absent(),
                Value<int?> epubChapterIndex = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => StyleSampleRecordsCompanion.insert(
                id: id,
                sourceType: sourceType,
                title: title,
                content: content,
                characterCount: characterCount,
                projectId: projectId,
                sourceFilename: sourceFilename,
                epubBookTitle: epubBookTitle,
                epubAuthor: epubAuthor,
                epubChapterTitle: epubChapterTitle,
                epubChapterIndex: epubChapterIndex,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StyleSampleRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                projectId = false,
                styleAnalysisRunRecordsRefs = false,
                styleProfileRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (styleAnalysisRunRecordsRefs) db.styleAnalysisRunRecords,
                    if (styleProfileRecordsRefs) db.styleProfileRecords,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (projectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.projectId,
                                    referencedTable:
                                        $$StyleSampleRecordsTableReferences
                                            ._projectIdTable(db),
                                    referencedColumn:
                                        $$StyleSampleRecordsTableReferences
                                            ._projectIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (styleAnalysisRunRecordsRefs)
                        await $_getPrefetchedData<
                          StyleSampleRecord,
                          $StyleSampleRecordsTable,
                          StyleAnalysisRunRecord
                        >(
                          currentTable: table,
                          referencedTable: $$StyleSampleRecordsTableReferences
                              ._styleAnalysisRunRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StyleSampleRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).styleAnalysisRunRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sampleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (styleProfileRecordsRefs)
                        await $_getPrefetchedData<
                          StyleSampleRecord,
                          $StyleSampleRecordsTable,
                          StyleProfileRecord
                        >(
                          currentTable: table,
                          referencedTable: $$StyleSampleRecordsTableReferences
                              ._styleProfileRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StyleSampleRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).styleProfileRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceSampleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$StyleSampleRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StyleSampleRecordsTable,
      StyleSampleRecord,
      $$StyleSampleRecordsTableFilterComposer,
      $$StyleSampleRecordsTableOrderingComposer,
      $$StyleSampleRecordsTableAnnotationComposer,
      $$StyleSampleRecordsTableCreateCompanionBuilder,
      $$StyleSampleRecordsTableUpdateCompanionBuilder,
      (StyleSampleRecord, $$StyleSampleRecordsTableReferences),
      StyleSampleRecord,
      PrefetchHooks Function({
        bool projectId,
        bool styleAnalysisRunRecordsRefs,
        bool styleProfileRecordsRefs,
      })
    >;
typedef $$StyleAnalysisRunRecordsTableCreateCompanionBuilder =
    StyleAnalysisRunRecordsCompanion Function({
      required String id,
      required String workflowTaskId,
      required String sampleId,
      required String providerId,
      required String modelName,
      required String styleName,
      Value<String?> projectId,
      required String status,
      Value<String?> stage,
      Value<String?> errorMessage,
      Value<String> logs,
      Value<String?> analysisReportMarkdown,
      Value<String?> voiceProfileMarkdown,
      Value<String?> profileId,
      Value<int> chunkCount,
      required int characterCount,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$StyleAnalysisRunRecordsTableUpdateCompanionBuilder =
    StyleAnalysisRunRecordsCompanion Function({
      Value<String> id,
      Value<String> workflowTaskId,
      Value<String> sampleId,
      Value<String> providerId,
      Value<String> modelName,
      Value<String> styleName,
      Value<String?> projectId,
      Value<String> status,
      Value<String?> stage,
      Value<String?> errorMessage,
      Value<String> logs,
      Value<String?> analysisReportMarkdown,
      Value<String?> voiceProfileMarkdown,
      Value<String?> profileId,
      Value<int> chunkCount,
      Value<int> characterCount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

final class $$StyleAnalysisRunRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StyleAnalysisRunRecordsTable,
          StyleAnalysisRunRecord
        > {
  $$StyleAnalysisRunRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkflowTaskRecordsTable _workflowTaskIdTable(_$AppDatabase db) =>
      db.workflowTaskRecords.createAlias(
        $_aliasNameGenerator(
          db.styleAnalysisRunRecords.workflowTaskId,
          db.workflowTaskRecords.id,
        ),
      );

  $$WorkflowTaskRecordsTableProcessedTableManager get workflowTaskId {
    final $_column = $_itemColumn<String>('workflow_task_id')!;

    final manager = $$WorkflowTaskRecordsTableTableManager(
      $_db,
      $_db.workflowTaskRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workflowTaskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StyleSampleRecordsTable _sampleIdTable(_$AppDatabase db) =>
      db.styleSampleRecords.createAlias(
        $_aliasNameGenerator(
          db.styleAnalysisRunRecords.sampleId,
          db.styleSampleRecords.id,
        ),
      );

  $$StyleSampleRecordsTableProcessedTableManager get sampleId {
    final $_column = $_itemColumn<String>('sample_id')!;

    final manager = $$StyleSampleRecordsTableTableManager(
      $_db,
      $_db.styleSampleRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sampleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProviderConfigRecordsTable _providerIdTable(_$AppDatabase db) =>
      db.providerConfigRecords.createAlias(
        $_aliasNameGenerator(
          db.styleAnalysisRunRecords.providerId,
          db.providerConfigRecords.id,
        ),
      );

  $$ProviderConfigRecordsTableProcessedTableManager get providerId {
    final $_column = $_itemColumn<String>('provider_id')!;

    final manager = $$ProviderConfigRecordsTableTableManager(
      $_db,
      $_db.providerConfigRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_providerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProjectRecordsTable _projectIdTable(_$AppDatabase db) =>
      db.projectRecords.createAlias(
        $_aliasNameGenerator(
          db.styleAnalysisRunRecords.projectId,
          db.projectRecords.id,
        ),
      );

  $$ProjectRecordsTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<String>('project_id');
    if ($_column == null) return null;
    final manager = $$ProjectRecordsTableTableManager(
      $_db,
      $_db.projectRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $StyleProfileRecordsTable,
    List<StyleProfileRecord>
  >
  _styleProfileRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.styleProfileRecords,
        aliasName: $_aliasNameGenerator(
          db.styleAnalysisRunRecords.id,
          db.styleProfileRecords.sourceRunId,
        ),
      );

  $$StyleProfileRecordsTableProcessedTableManager get styleProfileRecordsRefs {
    final manager = $$StyleProfileRecordsTableTableManager(
      $_db,
      $_db.styleProfileRecords,
    ).filter((f) => f.sourceRunId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _styleProfileRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StyleAnalysisRunRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $StyleAnalysisRunRecordsTable> {
  $$StyleAnalysisRunRecordsTableFilterComposer({
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

  ColumnFilters<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get styleName => $composableBuilder(
    column: $table.styleName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnFilters<String> get logs => $composableBuilder(
    column: $table.logs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get analysisReportMarkdown => $composableBuilder(
    column: $table.analysisReportMarkdown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voiceProfileMarkdown => $composableBuilder(
    column: $table.voiceProfileMarkdown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chunkCount => $composableBuilder(
    column: $table.chunkCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get characterCount => $composableBuilder(
    column: $table.characterCount,
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

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkflowTaskRecordsTableFilterComposer get workflowTaskId {
    final $$WorkflowTaskRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workflowTaskId,
      referencedTable: $db.workflowTaskRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkflowTaskRecordsTableFilterComposer(
            $db: $db,
            $table: $db.workflowTaskRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StyleSampleRecordsTableFilterComposer get sampleId {
    final $$StyleSampleRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sampleId,
      referencedTable: $db.styleSampleRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StyleSampleRecordsTableFilterComposer(
            $db: $db,
            $table: $db.styleSampleRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProviderConfigRecordsTableFilterComposer get providerId {
    final $$ProviderConfigRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.providerId,
          referencedTable: $db.providerConfigRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProviderConfigRecordsTableFilterComposer(
                $db: $db,
                $table: $db.providerConfigRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ProjectRecordsTableFilterComposer get projectId {
    final $$ProjectRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectRecordsTableFilterComposer(
            $db: $db,
            $table: $db.projectRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> styleProfileRecordsRefs(
    Expression<bool> Function($$StyleProfileRecordsTableFilterComposer f) f,
  ) {
    final $$StyleProfileRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.styleProfileRecords,
      getReferencedColumn: (t) => t.sourceRunId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StyleProfileRecordsTableFilterComposer(
            $db: $db,
            $table: $db.styleProfileRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StyleAnalysisRunRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $StyleAnalysisRunRecordsTable> {
  $$StyleAnalysisRunRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get styleName => $composableBuilder(
    column: $table.styleName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnOrderings<String> get logs => $composableBuilder(
    column: $table.logs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get analysisReportMarkdown => $composableBuilder(
    column: $table.analysisReportMarkdown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voiceProfileMarkdown => $composableBuilder(
    column: $table.voiceProfileMarkdown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chunkCount => $composableBuilder(
    column: $table.chunkCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get characterCount => $composableBuilder(
    column: $table.characterCount,
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

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkflowTaskRecordsTableOrderingComposer get workflowTaskId {
    final $$WorkflowTaskRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workflowTaskId,
          referencedTable: $db.workflowTaskRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkflowTaskRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.workflowTaskRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$StyleSampleRecordsTableOrderingComposer get sampleId {
    final $$StyleSampleRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sampleId,
      referencedTable: $db.styleSampleRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StyleSampleRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.styleSampleRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProviderConfigRecordsTableOrderingComposer get providerId {
    final $$ProviderConfigRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.providerId,
          referencedTable: $db.providerConfigRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProviderConfigRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.providerConfigRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ProjectRecordsTableOrderingComposer get projectId {
    final $$ProjectRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.projectRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StyleAnalysisRunRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StyleAnalysisRunRecordsTable> {
  $$StyleAnalysisRunRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<String> get styleName =>
      $composableBuilder(column: $table.styleName, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get logs =>
      $composableBuilder(column: $table.logs, builder: (column) => column);

  GeneratedColumn<String> get analysisReportMarkdown => $composableBuilder(
    column: $table.analysisReportMarkdown,
    builder: (column) => column,
  );

  GeneratedColumn<String> get voiceProfileMarkdown => $composableBuilder(
    column: $table.voiceProfileMarkdown,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<int> get chunkCount => $composableBuilder(
    column: $table.chunkCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get characterCount => $composableBuilder(
    column: $table.characterCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$WorkflowTaskRecordsTableAnnotationComposer get workflowTaskId {
    final $$WorkflowTaskRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workflowTaskId,
          referencedTable: $db.workflowTaskRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkflowTaskRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.workflowTaskRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$StyleSampleRecordsTableAnnotationComposer get sampleId {
    final $$StyleSampleRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sampleId,
          referencedTable: $db.styleSampleRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StyleSampleRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.styleSampleRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ProviderConfigRecordsTableAnnotationComposer get providerId {
    final $$ProviderConfigRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.providerId,
          referencedTable: $db.providerConfigRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProviderConfigRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.providerConfigRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ProjectRecordsTableAnnotationComposer get projectId {
    final $$ProjectRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.projectRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> styleProfileRecordsRefs<T extends Object>(
    Expression<T> Function($$StyleProfileRecordsTableAnnotationComposer a) f,
  ) {
    final $$StyleProfileRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.styleProfileRecords,
          getReferencedColumn: (t) => t.sourceRunId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StyleProfileRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.styleProfileRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StyleAnalysisRunRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StyleAnalysisRunRecordsTable,
          StyleAnalysisRunRecord,
          $$StyleAnalysisRunRecordsTableFilterComposer,
          $$StyleAnalysisRunRecordsTableOrderingComposer,
          $$StyleAnalysisRunRecordsTableAnnotationComposer,
          $$StyleAnalysisRunRecordsTableCreateCompanionBuilder,
          $$StyleAnalysisRunRecordsTableUpdateCompanionBuilder,
          (StyleAnalysisRunRecord, $$StyleAnalysisRunRecordsTableReferences),
          StyleAnalysisRunRecord,
          PrefetchHooks Function({
            bool workflowTaskId,
            bool sampleId,
            bool providerId,
            bool projectId,
            bool styleProfileRecordsRefs,
          })
        > {
  $$StyleAnalysisRunRecordsTableTableManager(
    _$AppDatabase db,
    $StyleAnalysisRunRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StyleAnalysisRunRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$StyleAnalysisRunRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StyleAnalysisRunRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workflowTaskId = const Value.absent(),
                Value<String> sampleId = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> modelName = const Value.absent(),
                Value<String> styleName = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> stage = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String> logs = const Value.absent(),
                Value<String?> analysisReportMarkdown = const Value.absent(),
                Value<String?> voiceProfileMarkdown = const Value.absent(),
                Value<String?> profileId = const Value.absent(),
                Value<int> chunkCount = const Value.absent(),
                Value<int> characterCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StyleAnalysisRunRecordsCompanion(
                id: id,
                workflowTaskId: workflowTaskId,
                sampleId: sampleId,
                providerId: providerId,
                modelName: modelName,
                styleName: styleName,
                projectId: projectId,
                status: status,
                stage: stage,
                errorMessage: errorMessage,
                logs: logs,
                analysisReportMarkdown: analysisReportMarkdown,
                voiceProfileMarkdown: voiceProfileMarkdown,
                profileId: profileId,
                chunkCount: chunkCount,
                characterCount: characterCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                startedAt: startedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workflowTaskId,
                required String sampleId,
                required String providerId,
                required String modelName,
                required String styleName,
                Value<String?> projectId = const Value.absent(),
                required String status,
                Value<String?> stage = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String> logs = const Value.absent(),
                Value<String?> analysisReportMarkdown = const Value.absent(),
                Value<String?> voiceProfileMarkdown = const Value.absent(),
                Value<String?> profileId = const Value.absent(),
                Value<int> chunkCount = const Value.absent(),
                required int characterCount,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StyleAnalysisRunRecordsCompanion.insert(
                id: id,
                workflowTaskId: workflowTaskId,
                sampleId: sampleId,
                providerId: providerId,
                modelName: modelName,
                styleName: styleName,
                projectId: projectId,
                status: status,
                stage: stage,
                errorMessage: errorMessage,
                logs: logs,
                analysisReportMarkdown: analysisReportMarkdown,
                voiceProfileMarkdown: voiceProfileMarkdown,
                profileId: profileId,
                chunkCount: chunkCount,
                characterCount: characterCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                startedAt: startedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StyleAnalysisRunRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workflowTaskId = false,
                sampleId = false,
                providerId = false,
                projectId = false,
                styleProfileRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (styleProfileRecordsRefs) db.styleProfileRecords,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workflowTaskId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workflowTaskId,
                                    referencedTable:
                                        $$StyleAnalysisRunRecordsTableReferences
                                            ._workflowTaskIdTable(db),
                                    referencedColumn:
                                        $$StyleAnalysisRunRecordsTableReferences
                                            ._workflowTaskIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (sampleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sampleId,
                                    referencedTable:
                                        $$StyleAnalysisRunRecordsTableReferences
                                            ._sampleIdTable(db),
                                    referencedColumn:
                                        $$StyleAnalysisRunRecordsTableReferences
                                            ._sampleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (providerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.providerId,
                                    referencedTable:
                                        $$StyleAnalysisRunRecordsTableReferences
                                            ._providerIdTable(db),
                                    referencedColumn:
                                        $$StyleAnalysisRunRecordsTableReferences
                                            ._providerIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (projectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.projectId,
                                    referencedTable:
                                        $$StyleAnalysisRunRecordsTableReferences
                                            ._projectIdTable(db),
                                    referencedColumn:
                                        $$StyleAnalysisRunRecordsTableReferences
                                            ._projectIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (styleProfileRecordsRefs)
                        await $_getPrefetchedData<
                          StyleAnalysisRunRecord,
                          $StyleAnalysisRunRecordsTable,
                          StyleProfileRecord
                        >(
                          currentTable: table,
                          referencedTable:
                              $$StyleAnalysisRunRecordsTableReferences
                                  ._styleProfileRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StyleAnalysisRunRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).styleProfileRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceRunId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$StyleAnalysisRunRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StyleAnalysisRunRecordsTable,
      StyleAnalysisRunRecord,
      $$StyleAnalysisRunRecordsTableFilterComposer,
      $$StyleAnalysisRunRecordsTableOrderingComposer,
      $$StyleAnalysisRunRecordsTableAnnotationComposer,
      $$StyleAnalysisRunRecordsTableCreateCompanionBuilder,
      $$StyleAnalysisRunRecordsTableUpdateCompanionBuilder,
      (StyleAnalysisRunRecord, $$StyleAnalysisRunRecordsTableReferences),
      StyleAnalysisRunRecord,
      PrefetchHooks Function({
        bool workflowTaskId,
        bool sampleId,
        bool providerId,
        bool projectId,
        bool styleProfileRecordsRefs,
      })
    >;
typedef $$StyleProfileRecordsTableCreateCompanionBuilder =
    StyleProfileRecordsCompanion Function({
      required String id,
      required String sourceRunId,
      required String providerId,
      required String modelName,
      required String styleName,
      required String profileMarkdown,
      required String analysisReportMarkdown,
      Value<String?> projectId,
      Value<String?> sourceSampleId,
      Value<String?> sourceTitle,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$StyleProfileRecordsTableUpdateCompanionBuilder =
    StyleProfileRecordsCompanion Function({
      Value<String> id,
      Value<String> sourceRunId,
      Value<String> providerId,
      Value<String> modelName,
      Value<String> styleName,
      Value<String> profileMarkdown,
      Value<String> analysisReportMarkdown,
      Value<String?> projectId,
      Value<String?> sourceSampleId,
      Value<String?> sourceTitle,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$StyleProfileRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StyleProfileRecordsTable,
          StyleProfileRecord
        > {
  $$StyleProfileRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StyleAnalysisRunRecordsTable _sourceRunIdTable(_$AppDatabase db) =>
      db.styleAnalysisRunRecords.createAlias(
        $_aliasNameGenerator(
          db.styleProfileRecords.sourceRunId,
          db.styleAnalysisRunRecords.id,
        ),
      );

  $$StyleAnalysisRunRecordsTableProcessedTableManager get sourceRunId {
    final $_column = $_itemColumn<String>('source_run_id')!;

    final manager = $$StyleAnalysisRunRecordsTableTableManager(
      $_db,
      $_db.styleAnalysisRunRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceRunIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProviderConfigRecordsTable _providerIdTable(_$AppDatabase db) =>
      db.providerConfigRecords.createAlias(
        $_aliasNameGenerator(
          db.styleProfileRecords.providerId,
          db.providerConfigRecords.id,
        ),
      );

  $$ProviderConfigRecordsTableProcessedTableManager get providerId {
    final $_column = $_itemColumn<String>('provider_id')!;

    final manager = $$ProviderConfigRecordsTableTableManager(
      $_db,
      $_db.providerConfigRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_providerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProjectRecordsTable _projectIdTable(_$AppDatabase db) =>
      db.projectRecords.createAlias(
        $_aliasNameGenerator(
          db.styleProfileRecords.projectId,
          db.projectRecords.id,
        ),
      );

  $$ProjectRecordsTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<String>('project_id');
    if ($_column == null) return null;
    final manager = $$ProjectRecordsTableTableManager(
      $_db,
      $_db.projectRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StyleSampleRecordsTable _sourceSampleIdTable(_$AppDatabase db) =>
      db.styleSampleRecords.createAlias(
        $_aliasNameGenerator(
          db.styleProfileRecords.sourceSampleId,
          db.styleSampleRecords.id,
        ),
      );

  $$StyleSampleRecordsTableProcessedTableManager? get sourceSampleId {
    final $_column = $_itemColumn<String>('source_sample_id');
    if ($_column == null) return null;
    final manager = $$StyleSampleRecordsTableTableManager(
      $_db,
      $_db.styleSampleRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceSampleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StyleProfileRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $StyleProfileRecordsTable> {
  $$StyleProfileRecordsTableFilterComposer({
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

  ColumnFilters<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get styleName => $composableBuilder(
    column: $table.styleName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileMarkdown => $composableBuilder(
    column: $table.profileMarkdown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get analysisReportMarkdown => $composableBuilder(
    column: $table.analysisReportMarkdown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceTitle => $composableBuilder(
    column: $table.sourceTitle,
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

  $$StyleAnalysisRunRecordsTableFilterComposer get sourceRunId {
    final $$StyleAnalysisRunRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sourceRunId,
          referencedTable: $db.styleAnalysisRunRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StyleAnalysisRunRecordsTableFilterComposer(
                $db: $db,
                $table: $db.styleAnalysisRunRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ProviderConfigRecordsTableFilterComposer get providerId {
    final $$ProviderConfigRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.providerId,
          referencedTable: $db.providerConfigRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProviderConfigRecordsTableFilterComposer(
                $db: $db,
                $table: $db.providerConfigRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ProjectRecordsTableFilterComposer get projectId {
    final $$ProjectRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectRecordsTableFilterComposer(
            $db: $db,
            $table: $db.projectRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StyleSampleRecordsTableFilterComposer get sourceSampleId {
    final $$StyleSampleRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSampleId,
      referencedTable: $db.styleSampleRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StyleSampleRecordsTableFilterComposer(
            $db: $db,
            $table: $db.styleSampleRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StyleProfileRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $StyleProfileRecordsTable> {
  $$StyleProfileRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get styleName => $composableBuilder(
    column: $table.styleName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileMarkdown => $composableBuilder(
    column: $table.profileMarkdown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get analysisReportMarkdown => $composableBuilder(
    column: $table.analysisReportMarkdown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceTitle => $composableBuilder(
    column: $table.sourceTitle,
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

  $$StyleAnalysisRunRecordsTableOrderingComposer get sourceRunId {
    final $$StyleAnalysisRunRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sourceRunId,
          referencedTable: $db.styleAnalysisRunRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StyleAnalysisRunRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.styleAnalysisRunRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ProviderConfigRecordsTableOrderingComposer get providerId {
    final $$ProviderConfigRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.providerId,
          referencedTable: $db.providerConfigRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProviderConfigRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.providerConfigRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ProjectRecordsTableOrderingComposer get projectId {
    final $$ProjectRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.projectRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StyleSampleRecordsTableOrderingComposer get sourceSampleId {
    final $$StyleSampleRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSampleId,
      referencedTable: $db.styleSampleRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StyleSampleRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.styleSampleRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StyleProfileRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StyleProfileRecordsTable> {
  $$StyleProfileRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<String> get styleName =>
      $composableBuilder(column: $table.styleName, builder: (column) => column);

  GeneratedColumn<String> get profileMarkdown => $composableBuilder(
    column: $table.profileMarkdown,
    builder: (column) => column,
  );

  GeneratedColumn<String> get analysisReportMarkdown => $composableBuilder(
    column: $table.analysisReportMarkdown,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceTitle => $composableBuilder(
    column: $table.sourceTitle,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$StyleAnalysisRunRecordsTableAnnotationComposer get sourceRunId {
    final $$StyleAnalysisRunRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sourceRunId,
          referencedTable: $db.styleAnalysisRunRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StyleAnalysisRunRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.styleAnalysisRunRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ProviderConfigRecordsTableAnnotationComposer get providerId {
    final $$ProviderConfigRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.providerId,
          referencedTable: $db.providerConfigRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProviderConfigRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.providerConfigRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ProjectRecordsTableAnnotationComposer get projectId {
    final $$ProjectRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.projectRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StyleSampleRecordsTableAnnotationComposer get sourceSampleId {
    final $$StyleSampleRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sourceSampleId,
          referencedTable: $db.styleSampleRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StyleSampleRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.styleSampleRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$StyleProfileRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StyleProfileRecordsTable,
          StyleProfileRecord,
          $$StyleProfileRecordsTableFilterComposer,
          $$StyleProfileRecordsTableOrderingComposer,
          $$StyleProfileRecordsTableAnnotationComposer,
          $$StyleProfileRecordsTableCreateCompanionBuilder,
          $$StyleProfileRecordsTableUpdateCompanionBuilder,
          (StyleProfileRecord, $$StyleProfileRecordsTableReferences),
          StyleProfileRecord,
          PrefetchHooks Function({
            bool sourceRunId,
            bool providerId,
            bool projectId,
            bool sourceSampleId,
          })
        > {
  $$StyleProfileRecordsTableTableManager(
    _$AppDatabase db,
    $StyleProfileRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StyleProfileRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StyleProfileRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StyleProfileRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceRunId = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> modelName = const Value.absent(),
                Value<String> styleName = const Value.absent(),
                Value<String> profileMarkdown = const Value.absent(),
                Value<String> analysisReportMarkdown = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String?> sourceSampleId = const Value.absent(),
                Value<String?> sourceTitle = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StyleProfileRecordsCompanion(
                id: id,
                sourceRunId: sourceRunId,
                providerId: providerId,
                modelName: modelName,
                styleName: styleName,
                profileMarkdown: profileMarkdown,
                analysisReportMarkdown: analysisReportMarkdown,
                projectId: projectId,
                sourceSampleId: sourceSampleId,
                sourceTitle: sourceTitle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sourceRunId,
                required String providerId,
                required String modelName,
                required String styleName,
                required String profileMarkdown,
                required String analysisReportMarkdown,
                Value<String?> projectId = const Value.absent(),
                Value<String?> sourceSampleId = const Value.absent(),
                Value<String?> sourceTitle = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => StyleProfileRecordsCompanion.insert(
                id: id,
                sourceRunId: sourceRunId,
                providerId: providerId,
                modelName: modelName,
                styleName: styleName,
                profileMarkdown: profileMarkdown,
                analysisReportMarkdown: analysisReportMarkdown,
                projectId: projectId,
                sourceSampleId: sourceSampleId,
                sourceTitle: sourceTitle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StyleProfileRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sourceRunId = false,
                providerId = false,
                projectId = false,
                sourceSampleId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sourceRunId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceRunId,
                                    referencedTable:
                                        $$StyleProfileRecordsTableReferences
                                            ._sourceRunIdTable(db),
                                    referencedColumn:
                                        $$StyleProfileRecordsTableReferences
                                            ._sourceRunIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (providerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.providerId,
                                    referencedTable:
                                        $$StyleProfileRecordsTableReferences
                                            ._providerIdTable(db),
                                    referencedColumn:
                                        $$StyleProfileRecordsTableReferences
                                            ._providerIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (projectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.projectId,
                                    referencedTable:
                                        $$StyleProfileRecordsTableReferences
                                            ._projectIdTable(db),
                                    referencedColumn:
                                        $$StyleProfileRecordsTableReferences
                                            ._projectIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (sourceSampleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceSampleId,
                                    referencedTable:
                                        $$StyleProfileRecordsTableReferences
                                            ._sourceSampleIdTable(db),
                                    referencedColumn:
                                        $$StyleProfileRecordsTableReferences
                                            ._sourceSampleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$StyleProfileRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StyleProfileRecordsTable,
      StyleProfileRecord,
      $$StyleProfileRecordsTableFilterComposer,
      $$StyleProfileRecordsTableOrderingComposer,
      $$StyleProfileRecordsTableAnnotationComposer,
      $$StyleProfileRecordsTableCreateCompanionBuilder,
      $$StyleProfileRecordsTableUpdateCompanionBuilder,
      (StyleProfileRecord, $$StyleProfileRecordsTableReferences),
      StyleProfileRecord,
      PrefetchHooks Function({
        bool sourceRunId,
        bool providerId,
        bool projectId,
        bool sourceSampleId,
      })
    >;
typedef $$PlotSampleRecordsTableCreateCompanionBuilder =
    PlotSampleRecordsCompanion Function({
      required String id,
      required String sourceType,
      required String title,
      required String content,
      required int characterCount,
      Value<String?> sourceFilename,
      Value<String?> epubBookTitle,
      Value<String?> epubAuthor,
      Value<int?> epubChapterCount,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PlotSampleRecordsTableUpdateCompanionBuilder =
    PlotSampleRecordsCompanion Function({
      Value<String> id,
      Value<String> sourceType,
      Value<String> title,
      Value<String> content,
      Value<int> characterCount,
      Value<String?> sourceFilename,
      Value<String?> epubBookTitle,
      Value<String?> epubAuthor,
      Value<int?> epubChapterCount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PlotSampleRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PlotSampleRecordsTable,
          PlotSampleRecord
        > {
  $$PlotSampleRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $PlotAnalysisRunRecordsTable,
    List<PlotAnalysisRunRecord>
  >
  _plotAnalysisRunRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.plotAnalysisRunRecords,
        aliasName: $_aliasNameGenerator(
          db.plotSampleRecords.id,
          db.plotAnalysisRunRecords.sampleId,
        ),
      );

  $$PlotAnalysisRunRecordsTableProcessedTableManager
  get plotAnalysisRunRecordsRefs {
    final manager = $$PlotAnalysisRunRecordsTableTableManager(
      $_db,
      $_db.plotAnalysisRunRecords,
    ).filter((f) => f.sampleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _plotAnalysisRunRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlotProfileRecordsTable, List<PlotProfileRecord>>
  _plotProfileRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.plotProfileRecords,
        aliasName: $_aliasNameGenerator(
          db.plotSampleRecords.id,
          db.plotProfileRecords.sourceSampleId,
        ),
      );

  $$PlotProfileRecordsTableProcessedTableManager get plotProfileRecordsRefs {
    final manager = $$PlotProfileRecordsTableTableManager(
      $_db,
      $_db.plotProfileRecords,
    ).filter((f) => f.sourceSampleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _plotProfileRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlotSampleRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $PlotSampleRecordsTable> {
  $$PlotSampleRecordsTableFilterComposer({
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

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get characterCount => $composableBuilder(
    column: $table.characterCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceFilename => $composableBuilder(
    column: $table.sourceFilename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get epubBookTitle => $composableBuilder(
    column: $table.epubBookTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get epubAuthor => $composableBuilder(
    column: $table.epubAuthor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get epubChapterCount => $composableBuilder(
    column: $table.epubChapterCount,
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

  Expression<bool> plotAnalysisRunRecordsRefs(
    Expression<bool> Function($$PlotAnalysisRunRecordsTableFilterComposer f) f,
  ) {
    final $$PlotAnalysisRunRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.plotAnalysisRunRecords,
          getReferencedColumn: (t) => t.sampleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlotAnalysisRunRecordsTableFilterComposer(
                $db: $db,
                $table: $db.plotAnalysisRunRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> plotProfileRecordsRefs(
    Expression<bool> Function($$PlotProfileRecordsTableFilterComposer f) f,
  ) {
    final $$PlotProfileRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plotProfileRecords,
      getReferencedColumn: (t) => t.sourceSampleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlotProfileRecordsTableFilterComposer(
            $db: $db,
            $table: $db.plotProfileRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlotSampleRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlotSampleRecordsTable> {
  $$PlotSampleRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get characterCount => $composableBuilder(
    column: $table.characterCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceFilename => $composableBuilder(
    column: $table.sourceFilename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get epubBookTitle => $composableBuilder(
    column: $table.epubBookTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get epubAuthor => $composableBuilder(
    column: $table.epubAuthor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get epubChapterCount => $composableBuilder(
    column: $table.epubChapterCount,
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

class $$PlotSampleRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlotSampleRecordsTable> {
  $$PlotSampleRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get characterCount => $composableBuilder(
    column: $table.characterCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceFilename => $composableBuilder(
    column: $table.sourceFilename,
    builder: (column) => column,
  );

  GeneratedColumn<String> get epubBookTitle => $composableBuilder(
    column: $table.epubBookTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get epubAuthor => $composableBuilder(
    column: $table.epubAuthor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get epubChapterCount => $composableBuilder(
    column: $table.epubChapterCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> plotAnalysisRunRecordsRefs<T extends Object>(
    Expression<T> Function($$PlotAnalysisRunRecordsTableAnnotationComposer a) f,
  ) {
    final $$PlotAnalysisRunRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.plotAnalysisRunRecords,
          getReferencedColumn: (t) => t.sampleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlotAnalysisRunRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.plotAnalysisRunRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> plotProfileRecordsRefs<T extends Object>(
    Expression<T> Function($$PlotProfileRecordsTableAnnotationComposer a) f,
  ) {
    final $$PlotProfileRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.plotProfileRecords,
          getReferencedColumn: (t) => t.sourceSampleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlotProfileRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.plotProfileRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PlotSampleRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlotSampleRecordsTable,
          PlotSampleRecord,
          $$PlotSampleRecordsTableFilterComposer,
          $$PlotSampleRecordsTableOrderingComposer,
          $$PlotSampleRecordsTableAnnotationComposer,
          $$PlotSampleRecordsTableCreateCompanionBuilder,
          $$PlotSampleRecordsTableUpdateCompanionBuilder,
          (PlotSampleRecord, $$PlotSampleRecordsTableReferences),
          PlotSampleRecord,
          PrefetchHooks Function({
            bool plotAnalysisRunRecordsRefs,
            bool plotProfileRecordsRefs,
          })
        > {
  $$PlotSampleRecordsTableTableManager(
    _$AppDatabase db,
    $PlotSampleRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlotSampleRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlotSampleRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlotSampleRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> characterCount = const Value.absent(),
                Value<String?> sourceFilename = const Value.absent(),
                Value<String?> epubBookTitle = const Value.absent(),
                Value<String?> epubAuthor = const Value.absent(),
                Value<int?> epubChapterCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlotSampleRecordsCompanion(
                id: id,
                sourceType: sourceType,
                title: title,
                content: content,
                characterCount: characterCount,
                sourceFilename: sourceFilename,
                epubBookTitle: epubBookTitle,
                epubAuthor: epubAuthor,
                epubChapterCount: epubChapterCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sourceType,
                required String title,
                required String content,
                required int characterCount,
                Value<String?> sourceFilename = const Value.absent(),
                Value<String?> epubBookTitle = const Value.absent(),
                Value<String?> epubAuthor = const Value.absent(),
                Value<int?> epubChapterCount = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PlotSampleRecordsCompanion.insert(
                id: id,
                sourceType: sourceType,
                title: title,
                content: content,
                characterCount: characterCount,
                sourceFilename: sourceFilename,
                epubBookTitle: epubBookTitle,
                epubAuthor: epubAuthor,
                epubChapterCount: epubChapterCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlotSampleRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                plotAnalysisRunRecordsRefs = false,
                plotProfileRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (plotAnalysisRunRecordsRefs) db.plotAnalysisRunRecords,
                    if (plotProfileRecordsRefs) db.plotProfileRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (plotAnalysisRunRecordsRefs)
                        await $_getPrefetchedData<
                          PlotSampleRecord,
                          $PlotSampleRecordsTable,
                          PlotAnalysisRunRecord
                        >(
                          currentTable: table,
                          referencedTable: $$PlotSampleRecordsTableReferences
                              ._plotAnalysisRunRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlotSampleRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).plotAnalysisRunRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sampleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (plotProfileRecordsRefs)
                        await $_getPrefetchedData<
                          PlotSampleRecord,
                          $PlotSampleRecordsTable,
                          PlotProfileRecord
                        >(
                          currentTable: table,
                          referencedTable: $$PlotSampleRecordsTableReferences
                              ._plotProfileRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlotSampleRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).plotProfileRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceSampleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlotSampleRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlotSampleRecordsTable,
      PlotSampleRecord,
      $$PlotSampleRecordsTableFilterComposer,
      $$PlotSampleRecordsTableOrderingComposer,
      $$PlotSampleRecordsTableAnnotationComposer,
      $$PlotSampleRecordsTableCreateCompanionBuilder,
      $$PlotSampleRecordsTableUpdateCompanionBuilder,
      (PlotSampleRecord, $$PlotSampleRecordsTableReferences),
      PlotSampleRecord,
      PrefetchHooks Function({
        bool plotAnalysisRunRecordsRefs,
        bool plotProfileRecordsRefs,
      })
    >;
typedef $$PlotAnalysisRunRecordsTableCreateCompanionBuilder =
    PlotAnalysisRunRecordsCompanion Function({
      required String id,
      required String workflowTaskId,
      required String sampleId,
      required String providerId,
      required String modelName,
      required String plotName,
      required String status,
      Value<String?> stage,
      Value<String?> errorMessage,
      Value<String> logs,
      Value<String?> analysisReportMarkdown,
      Value<String?> plotSkeletonMarkdown,
      Value<String?> storyEngineMarkdown,
      Value<String?> profileId,
      Value<int> chunkCount,
      required int characterCount,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$PlotAnalysisRunRecordsTableUpdateCompanionBuilder =
    PlotAnalysisRunRecordsCompanion Function({
      Value<String> id,
      Value<String> workflowTaskId,
      Value<String> sampleId,
      Value<String> providerId,
      Value<String> modelName,
      Value<String> plotName,
      Value<String> status,
      Value<String?> stage,
      Value<String?> errorMessage,
      Value<String> logs,
      Value<String?> analysisReportMarkdown,
      Value<String?> plotSkeletonMarkdown,
      Value<String?> storyEngineMarkdown,
      Value<String?> profileId,
      Value<int> chunkCount,
      Value<int> characterCount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

final class $$PlotAnalysisRunRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PlotAnalysisRunRecordsTable,
          PlotAnalysisRunRecord
        > {
  $$PlotAnalysisRunRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkflowTaskRecordsTable _workflowTaskIdTable(_$AppDatabase db) =>
      db.workflowTaskRecords.createAlias(
        $_aliasNameGenerator(
          db.plotAnalysisRunRecords.workflowTaskId,
          db.workflowTaskRecords.id,
        ),
      );

  $$WorkflowTaskRecordsTableProcessedTableManager get workflowTaskId {
    final $_column = $_itemColumn<String>('workflow_task_id')!;

    final manager = $$WorkflowTaskRecordsTableTableManager(
      $_db,
      $_db.workflowTaskRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workflowTaskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlotSampleRecordsTable _sampleIdTable(_$AppDatabase db) =>
      db.plotSampleRecords.createAlias(
        $_aliasNameGenerator(
          db.plotAnalysisRunRecords.sampleId,
          db.plotSampleRecords.id,
        ),
      );

  $$PlotSampleRecordsTableProcessedTableManager get sampleId {
    final $_column = $_itemColumn<String>('sample_id')!;

    final manager = $$PlotSampleRecordsTableTableManager(
      $_db,
      $_db.plotSampleRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sampleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProviderConfigRecordsTable _providerIdTable(_$AppDatabase db) =>
      db.providerConfigRecords.createAlias(
        $_aliasNameGenerator(
          db.plotAnalysisRunRecords.providerId,
          db.providerConfigRecords.id,
        ),
      );

  $$ProviderConfigRecordsTableProcessedTableManager get providerId {
    final $_column = $_itemColumn<String>('provider_id')!;

    final manager = $$ProviderConfigRecordsTableTableManager(
      $_db,
      $_db.providerConfigRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_providerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PlotProfileRecordsTable, List<PlotProfileRecord>>
  _plotProfileRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.plotProfileRecords,
        aliasName: $_aliasNameGenerator(
          db.plotAnalysisRunRecords.id,
          db.plotProfileRecords.sourceRunId,
        ),
      );

  $$PlotProfileRecordsTableProcessedTableManager get plotProfileRecordsRefs {
    final manager = $$PlotProfileRecordsTableTableManager(
      $_db,
      $_db.plotProfileRecords,
    ).filter((f) => f.sourceRunId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _plotProfileRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlotAnalysisRunRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $PlotAnalysisRunRecordsTable> {
  $$PlotAnalysisRunRecordsTableFilterComposer({
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

  ColumnFilters<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plotName => $composableBuilder(
    column: $table.plotName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnFilters<String> get logs => $composableBuilder(
    column: $table.logs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get analysisReportMarkdown => $composableBuilder(
    column: $table.analysisReportMarkdown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plotSkeletonMarkdown => $composableBuilder(
    column: $table.plotSkeletonMarkdown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storyEngineMarkdown => $composableBuilder(
    column: $table.storyEngineMarkdown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chunkCount => $composableBuilder(
    column: $table.chunkCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get characterCount => $composableBuilder(
    column: $table.characterCount,
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

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkflowTaskRecordsTableFilterComposer get workflowTaskId {
    final $$WorkflowTaskRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workflowTaskId,
      referencedTable: $db.workflowTaskRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkflowTaskRecordsTableFilterComposer(
            $db: $db,
            $table: $db.workflowTaskRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlotSampleRecordsTableFilterComposer get sampleId {
    final $$PlotSampleRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sampleId,
      referencedTable: $db.plotSampleRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlotSampleRecordsTableFilterComposer(
            $db: $db,
            $table: $db.plotSampleRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProviderConfigRecordsTableFilterComposer get providerId {
    final $$ProviderConfigRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.providerId,
          referencedTable: $db.providerConfigRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProviderConfigRecordsTableFilterComposer(
                $db: $db,
                $table: $db.providerConfigRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<bool> plotProfileRecordsRefs(
    Expression<bool> Function($$PlotProfileRecordsTableFilterComposer f) f,
  ) {
    final $$PlotProfileRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plotProfileRecords,
      getReferencedColumn: (t) => t.sourceRunId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlotProfileRecordsTableFilterComposer(
            $db: $db,
            $table: $db.plotProfileRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlotAnalysisRunRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlotAnalysisRunRecordsTable> {
  $$PlotAnalysisRunRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plotName => $composableBuilder(
    column: $table.plotName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnOrderings<String> get logs => $composableBuilder(
    column: $table.logs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get analysisReportMarkdown => $composableBuilder(
    column: $table.analysisReportMarkdown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plotSkeletonMarkdown => $composableBuilder(
    column: $table.plotSkeletonMarkdown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storyEngineMarkdown => $composableBuilder(
    column: $table.storyEngineMarkdown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chunkCount => $composableBuilder(
    column: $table.chunkCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get characterCount => $composableBuilder(
    column: $table.characterCount,
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

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkflowTaskRecordsTableOrderingComposer get workflowTaskId {
    final $$WorkflowTaskRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workflowTaskId,
          referencedTable: $db.workflowTaskRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkflowTaskRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.workflowTaskRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$PlotSampleRecordsTableOrderingComposer get sampleId {
    final $$PlotSampleRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sampleId,
      referencedTable: $db.plotSampleRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlotSampleRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.plotSampleRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProviderConfigRecordsTableOrderingComposer get providerId {
    final $$ProviderConfigRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.providerId,
          referencedTable: $db.providerConfigRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProviderConfigRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.providerConfigRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$PlotAnalysisRunRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlotAnalysisRunRecordsTable> {
  $$PlotAnalysisRunRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<String> get plotName =>
      $composableBuilder(column: $table.plotName, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get logs =>
      $composableBuilder(column: $table.logs, builder: (column) => column);

  GeneratedColumn<String> get analysisReportMarkdown => $composableBuilder(
    column: $table.analysisReportMarkdown,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plotSkeletonMarkdown => $composableBuilder(
    column: $table.plotSkeletonMarkdown,
    builder: (column) => column,
  );

  GeneratedColumn<String> get storyEngineMarkdown => $composableBuilder(
    column: $table.storyEngineMarkdown,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<int> get chunkCount => $composableBuilder(
    column: $table.chunkCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get characterCount => $composableBuilder(
    column: $table.characterCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$WorkflowTaskRecordsTableAnnotationComposer get workflowTaskId {
    final $$WorkflowTaskRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workflowTaskId,
          referencedTable: $db.workflowTaskRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkflowTaskRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.workflowTaskRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$PlotSampleRecordsTableAnnotationComposer get sampleId {
    final $$PlotSampleRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sampleId,
          referencedTable: $db.plotSampleRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlotSampleRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.plotSampleRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ProviderConfigRecordsTableAnnotationComposer get providerId {
    final $$ProviderConfigRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.providerId,
          referencedTable: $db.providerConfigRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProviderConfigRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.providerConfigRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> plotProfileRecordsRefs<T extends Object>(
    Expression<T> Function($$PlotProfileRecordsTableAnnotationComposer a) f,
  ) {
    final $$PlotProfileRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.plotProfileRecords,
          getReferencedColumn: (t) => t.sourceRunId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlotProfileRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.plotProfileRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PlotAnalysisRunRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlotAnalysisRunRecordsTable,
          PlotAnalysisRunRecord,
          $$PlotAnalysisRunRecordsTableFilterComposer,
          $$PlotAnalysisRunRecordsTableOrderingComposer,
          $$PlotAnalysisRunRecordsTableAnnotationComposer,
          $$PlotAnalysisRunRecordsTableCreateCompanionBuilder,
          $$PlotAnalysisRunRecordsTableUpdateCompanionBuilder,
          (PlotAnalysisRunRecord, $$PlotAnalysisRunRecordsTableReferences),
          PlotAnalysisRunRecord,
          PrefetchHooks Function({
            bool workflowTaskId,
            bool sampleId,
            bool providerId,
            bool plotProfileRecordsRefs,
          })
        > {
  $$PlotAnalysisRunRecordsTableTableManager(
    _$AppDatabase db,
    $PlotAnalysisRunRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlotAnalysisRunRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PlotAnalysisRunRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PlotAnalysisRunRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workflowTaskId = const Value.absent(),
                Value<String> sampleId = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> modelName = const Value.absent(),
                Value<String> plotName = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> stage = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String> logs = const Value.absent(),
                Value<String?> analysisReportMarkdown = const Value.absent(),
                Value<String?> plotSkeletonMarkdown = const Value.absent(),
                Value<String?> storyEngineMarkdown = const Value.absent(),
                Value<String?> profileId = const Value.absent(),
                Value<int> chunkCount = const Value.absent(),
                Value<int> characterCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlotAnalysisRunRecordsCompanion(
                id: id,
                workflowTaskId: workflowTaskId,
                sampleId: sampleId,
                providerId: providerId,
                modelName: modelName,
                plotName: plotName,
                status: status,
                stage: stage,
                errorMessage: errorMessage,
                logs: logs,
                analysisReportMarkdown: analysisReportMarkdown,
                plotSkeletonMarkdown: plotSkeletonMarkdown,
                storyEngineMarkdown: storyEngineMarkdown,
                profileId: profileId,
                chunkCount: chunkCount,
                characterCount: characterCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                startedAt: startedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workflowTaskId,
                required String sampleId,
                required String providerId,
                required String modelName,
                required String plotName,
                required String status,
                Value<String?> stage = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String> logs = const Value.absent(),
                Value<String?> analysisReportMarkdown = const Value.absent(),
                Value<String?> plotSkeletonMarkdown = const Value.absent(),
                Value<String?> storyEngineMarkdown = const Value.absent(),
                Value<String?> profileId = const Value.absent(),
                Value<int> chunkCount = const Value.absent(),
                required int characterCount,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlotAnalysisRunRecordsCompanion.insert(
                id: id,
                workflowTaskId: workflowTaskId,
                sampleId: sampleId,
                providerId: providerId,
                modelName: modelName,
                plotName: plotName,
                status: status,
                stage: stage,
                errorMessage: errorMessage,
                logs: logs,
                analysisReportMarkdown: analysisReportMarkdown,
                plotSkeletonMarkdown: plotSkeletonMarkdown,
                storyEngineMarkdown: storyEngineMarkdown,
                profileId: profileId,
                chunkCount: chunkCount,
                characterCount: characterCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                startedAt: startedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlotAnalysisRunRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workflowTaskId = false,
                sampleId = false,
                providerId = false,
                plotProfileRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (plotProfileRecordsRefs) db.plotProfileRecords,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workflowTaskId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workflowTaskId,
                                    referencedTable:
                                        $$PlotAnalysisRunRecordsTableReferences
                                            ._workflowTaskIdTable(db),
                                    referencedColumn:
                                        $$PlotAnalysisRunRecordsTableReferences
                                            ._workflowTaskIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (sampleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sampleId,
                                    referencedTable:
                                        $$PlotAnalysisRunRecordsTableReferences
                                            ._sampleIdTable(db),
                                    referencedColumn:
                                        $$PlotAnalysisRunRecordsTableReferences
                                            ._sampleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (providerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.providerId,
                                    referencedTable:
                                        $$PlotAnalysisRunRecordsTableReferences
                                            ._providerIdTable(db),
                                    referencedColumn:
                                        $$PlotAnalysisRunRecordsTableReferences
                                            ._providerIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (plotProfileRecordsRefs)
                        await $_getPrefetchedData<
                          PlotAnalysisRunRecord,
                          $PlotAnalysisRunRecordsTable,
                          PlotProfileRecord
                        >(
                          currentTable: table,
                          referencedTable:
                              $$PlotAnalysisRunRecordsTableReferences
                                  ._plotProfileRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlotAnalysisRunRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).plotProfileRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceRunId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlotAnalysisRunRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlotAnalysisRunRecordsTable,
      PlotAnalysisRunRecord,
      $$PlotAnalysisRunRecordsTableFilterComposer,
      $$PlotAnalysisRunRecordsTableOrderingComposer,
      $$PlotAnalysisRunRecordsTableAnnotationComposer,
      $$PlotAnalysisRunRecordsTableCreateCompanionBuilder,
      $$PlotAnalysisRunRecordsTableUpdateCompanionBuilder,
      (PlotAnalysisRunRecord, $$PlotAnalysisRunRecordsTableReferences),
      PlotAnalysisRunRecord,
      PrefetchHooks Function({
        bool workflowTaskId,
        bool sampleId,
        bool providerId,
        bool plotProfileRecordsRefs,
      })
    >;
typedef $$PlotProfileRecordsTableCreateCompanionBuilder =
    PlotProfileRecordsCompanion Function({
      required String id,
      required String sourceRunId,
      required String providerId,
      required String modelName,
      required String plotName,
      required String storyEngineMarkdown,
      required String analysisReportMarkdown,
      required String plotSkeletonMarkdown,
      Value<String?> sourceSampleId,
      Value<String?> sourceTitle,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PlotProfileRecordsTableUpdateCompanionBuilder =
    PlotProfileRecordsCompanion Function({
      Value<String> id,
      Value<String> sourceRunId,
      Value<String> providerId,
      Value<String> modelName,
      Value<String> plotName,
      Value<String> storyEngineMarkdown,
      Value<String> analysisReportMarkdown,
      Value<String> plotSkeletonMarkdown,
      Value<String?> sourceSampleId,
      Value<String?> sourceTitle,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PlotProfileRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PlotProfileRecordsTable,
          PlotProfileRecord
        > {
  $$PlotProfileRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlotAnalysisRunRecordsTable _sourceRunIdTable(_$AppDatabase db) =>
      db.plotAnalysisRunRecords.createAlias(
        $_aliasNameGenerator(
          db.plotProfileRecords.sourceRunId,
          db.plotAnalysisRunRecords.id,
        ),
      );

  $$PlotAnalysisRunRecordsTableProcessedTableManager get sourceRunId {
    final $_column = $_itemColumn<String>('source_run_id')!;

    final manager = $$PlotAnalysisRunRecordsTableTableManager(
      $_db,
      $_db.plotAnalysisRunRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceRunIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProviderConfigRecordsTable _providerIdTable(_$AppDatabase db) =>
      db.providerConfigRecords.createAlias(
        $_aliasNameGenerator(
          db.plotProfileRecords.providerId,
          db.providerConfigRecords.id,
        ),
      );

  $$ProviderConfigRecordsTableProcessedTableManager get providerId {
    final $_column = $_itemColumn<String>('provider_id')!;

    final manager = $$ProviderConfigRecordsTableTableManager(
      $_db,
      $_db.providerConfigRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_providerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlotSampleRecordsTable _sourceSampleIdTable(_$AppDatabase db) =>
      db.plotSampleRecords.createAlias(
        $_aliasNameGenerator(
          db.plotProfileRecords.sourceSampleId,
          db.plotSampleRecords.id,
        ),
      );

  $$PlotSampleRecordsTableProcessedTableManager? get sourceSampleId {
    final $_column = $_itemColumn<String>('source_sample_id');
    if ($_column == null) return null;
    final manager = $$PlotSampleRecordsTableTableManager(
      $_db,
      $_db.plotSampleRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceSampleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlotProfileRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $PlotProfileRecordsTable> {
  $$PlotProfileRecordsTableFilterComposer({
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

  ColumnFilters<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plotName => $composableBuilder(
    column: $table.plotName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storyEngineMarkdown => $composableBuilder(
    column: $table.storyEngineMarkdown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get analysisReportMarkdown => $composableBuilder(
    column: $table.analysisReportMarkdown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plotSkeletonMarkdown => $composableBuilder(
    column: $table.plotSkeletonMarkdown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceTitle => $composableBuilder(
    column: $table.sourceTitle,
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

  $$PlotAnalysisRunRecordsTableFilterComposer get sourceRunId {
    final $$PlotAnalysisRunRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sourceRunId,
          referencedTable: $db.plotAnalysisRunRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlotAnalysisRunRecordsTableFilterComposer(
                $db: $db,
                $table: $db.plotAnalysisRunRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ProviderConfigRecordsTableFilterComposer get providerId {
    final $$ProviderConfigRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.providerId,
          referencedTable: $db.providerConfigRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProviderConfigRecordsTableFilterComposer(
                $db: $db,
                $table: $db.providerConfigRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$PlotSampleRecordsTableFilterComposer get sourceSampleId {
    final $$PlotSampleRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSampleId,
      referencedTable: $db.plotSampleRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlotSampleRecordsTableFilterComposer(
            $db: $db,
            $table: $db.plotSampleRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlotProfileRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlotProfileRecordsTable> {
  $$PlotProfileRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plotName => $composableBuilder(
    column: $table.plotName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storyEngineMarkdown => $composableBuilder(
    column: $table.storyEngineMarkdown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get analysisReportMarkdown => $composableBuilder(
    column: $table.analysisReportMarkdown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plotSkeletonMarkdown => $composableBuilder(
    column: $table.plotSkeletonMarkdown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceTitle => $composableBuilder(
    column: $table.sourceTitle,
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

  $$PlotAnalysisRunRecordsTableOrderingComposer get sourceRunId {
    final $$PlotAnalysisRunRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sourceRunId,
          referencedTable: $db.plotAnalysisRunRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlotAnalysisRunRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.plotAnalysisRunRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ProviderConfigRecordsTableOrderingComposer get providerId {
    final $$ProviderConfigRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.providerId,
          referencedTable: $db.providerConfigRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProviderConfigRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.providerConfigRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$PlotSampleRecordsTableOrderingComposer get sourceSampleId {
    final $$PlotSampleRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSampleId,
      referencedTable: $db.plotSampleRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlotSampleRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.plotSampleRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlotProfileRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlotProfileRecordsTable> {
  $$PlotProfileRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<String> get plotName =>
      $composableBuilder(column: $table.plotName, builder: (column) => column);

  GeneratedColumn<String> get storyEngineMarkdown => $composableBuilder(
    column: $table.storyEngineMarkdown,
    builder: (column) => column,
  );

  GeneratedColumn<String> get analysisReportMarkdown => $composableBuilder(
    column: $table.analysisReportMarkdown,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plotSkeletonMarkdown => $composableBuilder(
    column: $table.plotSkeletonMarkdown,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceTitle => $composableBuilder(
    column: $table.sourceTitle,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PlotAnalysisRunRecordsTableAnnotationComposer get sourceRunId {
    final $$PlotAnalysisRunRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sourceRunId,
          referencedTable: $db.plotAnalysisRunRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlotAnalysisRunRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.plotAnalysisRunRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ProviderConfigRecordsTableAnnotationComposer get providerId {
    final $$ProviderConfigRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.providerId,
          referencedTable: $db.providerConfigRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProviderConfigRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.providerConfigRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$PlotSampleRecordsTableAnnotationComposer get sourceSampleId {
    final $$PlotSampleRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sourceSampleId,
          referencedTable: $db.plotSampleRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlotSampleRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.plotSampleRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$PlotProfileRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlotProfileRecordsTable,
          PlotProfileRecord,
          $$PlotProfileRecordsTableFilterComposer,
          $$PlotProfileRecordsTableOrderingComposer,
          $$PlotProfileRecordsTableAnnotationComposer,
          $$PlotProfileRecordsTableCreateCompanionBuilder,
          $$PlotProfileRecordsTableUpdateCompanionBuilder,
          (PlotProfileRecord, $$PlotProfileRecordsTableReferences),
          PlotProfileRecord,
          PrefetchHooks Function({
            bool sourceRunId,
            bool providerId,
            bool sourceSampleId,
          })
        > {
  $$PlotProfileRecordsTableTableManager(
    _$AppDatabase db,
    $PlotProfileRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlotProfileRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlotProfileRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlotProfileRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceRunId = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> modelName = const Value.absent(),
                Value<String> plotName = const Value.absent(),
                Value<String> storyEngineMarkdown = const Value.absent(),
                Value<String> analysisReportMarkdown = const Value.absent(),
                Value<String> plotSkeletonMarkdown = const Value.absent(),
                Value<String?> sourceSampleId = const Value.absent(),
                Value<String?> sourceTitle = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlotProfileRecordsCompanion(
                id: id,
                sourceRunId: sourceRunId,
                providerId: providerId,
                modelName: modelName,
                plotName: plotName,
                storyEngineMarkdown: storyEngineMarkdown,
                analysisReportMarkdown: analysisReportMarkdown,
                plotSkeletonMarkdown: plotSkeletonMarkdown,
                sourceSampleId: sourceSampleId,
                sourceTitle: sourceTitle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sourceRunId,
                required String providerId,
                required String modelName,
                required String plotName,
                required String storyEngineMarkdown,
                required String analysisReportMarkdown,
                required String plotSkeletonMarkdown,
                Value<String?> sourceSampleId = const Value.absent(),
                Value<String?> sourceTitle = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PlotProfileRecordsCompanion.insert(
                id: id,
                sourceRunId: sourceRunId,
                providerId: providerId,
                modelName: modelName,
                plotName: plotName,
                storyEngineMarkdown: storyEngineMarkdown,
                analysisReportMarkdown: analysisReportMarkdown,
                plotSkeletonMarkdown: plotSkeletonMarkdown,
                sourceSampleId: sourceSampleId,
                sourceTitle: sourceTitle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlotProfileRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sourceRunId = false,
                providerId = false,
                sourceSampleId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sourceRunId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceRunId,
                                    referencedTable:
                                        $$PlotProfileRecordsTableReferences
                                            ._sourceRunIdTable(db),
                                    referencedColumn:
                                        $$PlotProfileRecordsTableReferences
                                            ._sourceRunIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (providerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.providerId,
                                    referencedTable:
                                        $$PlotProfileRecordsTableReferences
                                            ._providerIdTable(db),
                                    referencedColumn:
                                        $$PlotProfileRecordsTableReferences
                                            ._providerIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (sourceSampleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceSampleId,
                                    referencedTable:
                                        $$PlotProfileRecordsTableReferences
                                            ._sourceSampleIdTable(db),
                                    referencedColumn:
                                        $$PlotProfileRecordsTableReferences
                                            ._sourceSampleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$PlotProfileRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlotProfileRecordsTable,
      PlotProfileRecord,
      $$PlotProfileRecordsTableFilterComposer,
      $$PlotProfileRecordsTableOrderingComposer,
      $$PlotProfileRecordsTableAnnotationComposer,
      $$PlotProfileRecordsTableCreateCompanionBuilder,
      $$PlotProfileRecordsTableUpdateCompanionBuilder,
      (PlotProfileRecord, $$PlotProfileRecordsTableReferences),
      PlotProfileRecord,
      PrefetchHooks Function({
        bool sourceRunId,
        bool providerId,
        bool sourceSampleId,
      })
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WorkflowTaskRecordsTableTableManager get workflowTaskRecords =>
      $$WorkflowTaskRecordsTableTableManager(_db, _db.workflowTaskRecords);
  $$WorkflowPromptTraceRecordsTableTableManager
  get workflowPromptTraceRecords =>
      $$WorkflowPromptTraceRecordsTableTableManager(
        _db,
        _db.workflowPromptTraceRecords,
      );
  $$ProviderConfigRecordsTableTableManager get providerConfigRecords =>
      $$ProviderConfigRecordsTableTableManager(_db, _db.providerConfigRecords);
  $$ProjectRecordsTableTableManager get projectRecords =>
      $$ProjectRecordsTableTableManager(_db, _db.projectRecords);
  $$StyleSampleRecordsTableTableManager get styleSampleRecords =>
      $$StyleSampleRecordsTableTableManager(_db, _db.styleSampleRecords);
  $$StyleAnalysisRunRecordsTableTableManager get styleAnalysisRunRecords =>
      $$StyleAnalysisRunRecordsTableTableManager(
        _db,
        _db.styleAnalysisRunRecords,
      );
  $$StyleProfileRecordsTableTableManager get styleProfileRecords =>
      $$StyleProfileRecordsTableTableManager(_db, _db.styleProfileRecords);
  $$PlotSampleRecordsTableTableManager get plotSampleRecords =>
      $$PlotSampleRecordsTableTableManager(_db, _db.plotSampleRecords);
  $$PlotAnalysisRunRecordsTableTableManager get plotAnalysisRunRecords =>
      $$PlotAnalysisRunRecordsTableTableManager(
        _db,
        _db.plotAnalysisRunRecords,
      );
  $$PlotProfileRecordsTableTableManager get plotProfileRecords =>
      $$PlotProfileRecordsTableTableManager(_db, _db.plotProfileRecords);
}
