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

class $ProviderModelRecordsTable extends ProviderModelRecords
    with TableInfo<$ProviderModelRecordsTable, ProviderModelRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProviderModelRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    providerId,
    modelName,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'provider_model_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProviderModelRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
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
  Set<GeneratedColumn> get $primaryKey => {providerId, modelName};
  @override
  ProviderModelRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProviderModelRecord(
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      modelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
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
  $ProviderModelRecordsTable createAlias(String alias) {
    return $ProviderModelRecordsTable(attachedDatabase, alias);
  }
}

class ProviderModelRecord extends DataClass
    implements Insertable<ProviderModelRecord> {
  final String providerId;
  final String modelName;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ProviderModelRecord({
    required this.providerId,
    required this.modelName,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['provider_id'] = Variable<String>(providerId);
    map['model_name'] = Variable<String>(modelName);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProviderModelRecordsCompanion toCompanion(bool nullToAbsent) {
    return ProviderModelRecordsCompanion(
      providerId: Value(providerId),
      modelName: Value(modelName),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProviderModelRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProviderModelRecord(
      providerId: serializer.fromJson<String>(json['providerId']),
      modelName: serializer.fromJson<String>(json['modelName']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'providerId': serializer.toJson<String>(providerId),
      'modelName': serializer.toJson<String>(modelName),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProviderModelRecord copyWith({
    String? providerId,
    String? modelName,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ProviderModelRecord(
    providerId: providerId ?? this.providerId,
    modelName: modelName ?? this.modelName,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProviderModelRecord copyWithCompanion(ProviderModelRecordsCompanion data) {
    return ProviderModelRecord(
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProviderModelRecord(')
          ..write('providerId: $providerId, ')
          ..write('modelName: $modelName, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(providerId, modelName, sortOrder, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProviderModelRecord &&
          other.providerId == this.providerId &&
          other.modelName == this.modelName &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProviderModelRecordsCompanion
    extends UpdateCompanion<ProviderModelRecord> {
  final Value<String> providerId;
  final Value<String> modelName;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProviderModelRecordsCompanion({
    this.providerId = const Value.absent(),
    this.modelName = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProviderModelRecordsCompanion.insert({
    required String providerId,
    required String modelName,
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : providerId = Value(providerId),
       modelName = Value(modelName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProviderModelRecord> custom({
    Expression<String>? providerId,
    Expression<String>? modelName,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (providerId != null) 'provider_id': providerId,
      if (modelName != null) 'model_name': modelName,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProviderModelRecordsCompanion copyWith({
    Value<String>? providerId,
    Value<String>? modelName,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProviderModelRecordsCompanion(
      providerId: providerId ?? this.providerId,
      modelName: modelName ?? this.modelName,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
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
    return (StringBuffer('ProviderModelRecordsCompanion(')
          ..write('providerId: $providerId, ')
          ..write('modelName: $modelName, ')
          ..write('sortOrder: $sortOrder, ')
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
  static const VerificationMeta _defaultProviderIdMeta = const VerificationMeta(
    'defaultProviderId',
  );
  @override
  late final GeneratedColumn<String> defaultProviderId =
      GeneratedColumn<String>(
        'default_provider_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _defaultModelNameMeta = const VerificationMeta(
    'defaultModelName',
  );
  @override
  late final GeneratedColumn<String> defaultModelName = GeneratedColumn<String>(
    'default_model_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _styleProfileIdMeta = const VerificationMeta(
    'styleProfileId',
  );
  @override
  late final GeneratedColumn<String> styleProfileId = GeneratedColumn<String>(
    'style_profile_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plotProfileIdMeta = const VerificationMeta(
    'plotProfileId',
  );
  @override
  late final GeneratedColumn<String> plotProfileId = GeneratedColumn<String>(
    'plot_profile_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('简体中文'),
  );
  static const VerificationMeta _targetLengthMeta = const VerificationMeta(
    'targetLength',
  );
  @override
  late final GeneratedColumn<int> targetLength = GeneratedColumn<int>(
    'target_length',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3000),
  );
  static const VerificationMeta _narrativePerspectiveMeta =
      const VerificationMeta('narrativePerspective');
  @override
  late final GeneratedColumn<String> narrativePerspective =
      GeneratedColumn<String>(
        'narrative_perspective',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('第三人称有限视角'),
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
    defaultProviderId,
    defaultModelName,
    styleProfileId,
    plotProfileId,
    language,
    targetLength,
    narrativePerspective,
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
    if (data.containsKey('default_provider_id')) {
      context.handle(
        _defaultProviderIdMeta,
        defaultProviderId.isAcceptableOrUnknown(
          data['default_provider_id']!,
          _defaultProviderIdMeta,
        ),
      );
    }
    if (data.containsKey('default_model_name')) {
      context.handle(
        _defaultModelNameMeta,
        defaultModelName.isAcceptableOrUnknown(
          data['default_model_name']!,
          _defaultModelNameMeta,
        ),
      );
    }
    if (data.containsKey('style_profile_id')) {
      context.handle(
        _styleProfileIdMeta,
        styleProfileId.isAcceptableOrUnknown(
          data['style_profile_id']!,
          _styleProfileIdMeta,
        ),
      );
    }
    if (data.containsKey('plot_profile_id')) {
      context.handle(
        _plotProfileIdMeta,
        plotProfileId.isAcceptableOrUnknown(
          data['plot_profile_id']!,
          _plotProfileIdMeta,
        ),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('target_length')) {
      context.handle(
        _targetLengthMeta,
        targetLength.isAcceptableOrUnknown(
          data['target_length']!,
          _targetLengthMeta,
        ),
      );
    }
    if (data.containsKey('narrative_perspective')) {
      context.handle(
        _narrativePerspectiveMeta,
        narrativePerspective.isAcceptableOrUnknown(
          data['narrative_perspective']!,
          _narrativePerspectiveMeta,
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
      defaultProviderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_provider_id'],
      ),
      defaultModelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_model_name'],
      ),
      styleProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}style_profile_id'],
      ),
      plotProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plot_profile_id'],
      ),
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      targetLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_length'],
      )!,
      narrativePerspective: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}narrative_perspective'],
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
  final String? defaultProviderId;
  final String? defaultModelName;
  final String? styleProfileId;
  final String? plotProfileId;
  final String language;
  final int targetLength;
  final String narrativePerspective;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ProjectRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.defaultProviderId,
    this.defaultModelName,
    this.styleProfileId,
    this.plotProfileId,
    required this.language,
    required this.targetLength,
    required this.narrativePerspective,
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
    if (!nullToAbsent || defaultProviderId != null) {
      map['default_provider_id'] = Variable<String>(defaultProviderId);
    }
    if (!nullToAbsent || defaultModelName != null) {
      map['default_model_name'] = Variable<String>(defaultModelName);
    }
    if (!nullToAbsent || styleProfileId != null) {
      map['style_profile_id'] = Variable<String>(styleProfileId);
    }
    if (!nullToAbsent || plotProfileId != null) {
      map['plot_profile_id'] = Variable<String>(plotProfileId);
    }
    map['language'] = Variable<String>(language);
    map['target_length'] = Variable<int>(targetLength);
    map['narrative_perspective'] = Variable<String>(narrativePerspective);
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
      defaultProviderId: defaultProviderId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultProviderId),
      defaultModelName: defaultModelName == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultModelName),
      styleProfileId: styleProfileId == null && nullToAbsent
          ? const Value.absent()
          : Value(styleProfileId),
      plotProfileId: plotProfileId == null && nullToAbsent
          ? const Value.absent()
          : Value(plotProfileId),
      language: Value(language),
      targetLength: Value(targetLength),
      narrativePerspective: Value(narrativePerspective),
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
      defaultProviderId: serializer.fromJson<String?>(
        json['defaultProviderId'],
      ),
      defaultModelName: serializer.fromJson<String?>(json['defaultModelName']),
      styleProfileId: serializer.fromJson<String?>(json['styleProfileId']),
      plotProfileId: serializer.fromJson<String?>(json['plotProfileId']),
      language: serializer.fromJson<String>(json['language']),
      targetLength: serializer.fromJson<int>(json['targetLength']),
      narrativePerspective: serializer.fromJson<String>(
        json['narrativePerspective'],
      ),
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
      'defaultProviderId': serializer.toJson<String?>(defaultProviderId),
      'defaultModelName': serializer.toJson<String?>(defaultModelName),
      'styleProfileId': serializer.toJson<String?>(styleProfileId),
      'plotProfileId': serializer.toJson<String?>(plotProfileId),
      'language': serializer.toJson<String>(language),
      'targetLength': serializer.toJson<int>(targetLength),
      'narrativePerspective': serializer.toJson<String>(narrativePerspective),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProjectRecord copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    Value<String?> defaultProviderId = const Value.absent(),
    Value<String?> defaultModelName = const Value.absent(),
    Value<String?> styleProfileId = const Value.absent(),
    Value<String?> plotProfileId = const Value.absent(),
    String? language,
    int? targetLength,
    String? narrativePerspective,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ProjectRecord(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    status: status ?? this.status,
    defaultProviderId: defaultProviderId.present
        ? defaultProviderId.value
        : this.defaultProviderId,
    defaultModelName: defaultModelName.present
        ? defaultModelName.value
        : this.defaultModelName,
    styleProfileId: styleProfileId.present
        ? styleProfileId.value
        : this.styleProfileId,
    plotProfileId: plotProfileId.present
        ? plotProfileId.value
        : this.plotProfileId,
    language: language ?? this.language,
    targetLength: targetLength ?? this.targetLength,
    narrativePerspective: narrativePerspective ?? this.narrativePerspective,
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
      defaultProviderId: data.defaultProviderId.present
          ? data.defaultProviderId.value
          : this.defaultProviderId,
      defaultModelName: data.defaultModelName.present
          ? data.defaultModelName.value
          : this.defaultModelName,
      styleProfileId: data.styleProfileId.present
          ? data.styleProfileId.value
          : this.styleProfileId,
      plotProfileId: data.plotProfileId.present
          ? data.plotProfileId.value
          : this.plotProfileId,
      language: data.language.present ? data.language.value : this.language,
      targetLength: data.targetLength.present
          ? data.targetLength.value
          : this.targetLength,
      narrativePerspective: data.narrativePerspective.present
          ? data.narrativePerspective.value
          : this.narrativePerspective,
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
          ..write('defaultProviderId: $defaultProviderId, ')
          ..write('defaultModelName: $defaultModelName, ')
          ..write('styleProfileId: $styleProfileId, ')
          ..write('plotProfileId: $plotProfileId, ')
          ..write('language: $language, ')
          ..write('targetLength: $targetLength, ')
          ..write('narrativePerspective: $narrativePerspective, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    status,
    defaultProviderId,
    defaultModelName,
    styleProfileId,
    plotProfileId,
    language,
    targetLength,
    narrativePerspective,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectRecord &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.status == this.status &&
          other.defaultProviderId == this.defaultProviderId &&
          other.defaultModelName == this.defaultModelName &&
          other.styleProfileId == this.styleProfileId &&
          other.plotProfileId == this.plotProfileId &&
          other.language == this.language &&
          other.targetLength == this.targetLength &&
          other.narrativePerspective == this.narrativePerspective &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProjectRecordsCompanion extends UpdateCompanion<ProjectRecord> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<String> status;
  final Value<String?> defaultProviderId;
  final Value<String?> defaultModelName;
  final Value<String?> styleProfileId;
  final Value<String?> plotProfileId;
  final Value<String> language;
  final Value<int> targetLength;
  final Value<String> narrativePerspective;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProjectRecordsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.defaultProviderId = const Value.absent(),
    this.defaultModelName = const Value.absent(),
    this.styleProfileId = const Value.absent(),
    this.plotProfileId = const Value.absent(),
    this.language = const Value.absent(),
    this.targetLength = const Value.absent(),
    this.narrativePerspective = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectRecordsCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    required String status,
    this.defaultProviderId = const Value.absent(),
    this.defaultModelName = const Value.absent(),
    this.styleProfileId = const Value.absent(),
    this.plotProfileId = const Value.absent(),
    this.language = const Value.absent(),
    this.targetLength = const Value.absent(),
    this.narrativePerspective = const Value.absent(),
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
    Expression<String>? defaultProviderId,
    Expression<String>? defaultModelName,
    Expression<String>? styleProfileId,
    Expression<String>? plotProfileId,
    Expression<String>? language,
    Expression<int>? targetLength,
    Expression<String>? narrativePerspective,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (defaultProviderId != null) 'default_provider_id': defaultProviderId,
      if (defaultModelName != null) 'default_model_name': defaultModelName,
      if (styleProfileId != null) 'style_profile_id': styleProfileId,
      if (plotProfileId != null) 'plot_profile_id': plotProfileId,
      if (language != null) 'language': language,
      if (targetLength != null) 'target_length': targetLength,
      if (narrativePerspective != null)
        'narrative_perspective': narrativePerspective,
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
    Value<String?>? defaultProviderId,
    Value<String?>? defaultModelName,
    Value<String?>? styleProfileId,
    Value<String?>? plotProfileId,
    Value<String>? language,
    Value<int>? targetLength,
    Value<String>? narrativePerspective,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProjectRecordsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      defaultProviderId: defaultProviderId ?? this.defaultProviderId,
      defaultModelName: defaultModelName ?? this.defaultModelName,
      styleProfileId: styleProfileId ?? this.styleProfileId,
      plotProfileId: plotProfileId ?? this.plotProfileId,
      language: language ?? this.language,
      targetLength: targetLength ?? this.targetLength,
      narrativePerspective: narrativePerspective ?? this.narrativePerspective,
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
    if (defaultProviderId.present) {
      map['default_provider_id'] = Variable<String>(defaultProviderId.value);
    }
    if (defaultModelName.present) {
      map['default_model_name'] = Variable<String>(defaultModelName.value);
    }
    if (styleProfileId.present) {
      map['style_profile_id'] = Variable<String>(styleProfileId.value);
    }
    if (plotProfileId.present) {
      map['plot_profile_id'] = Variable<String>(plotProfileId.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (targetLength.present) {
      map['target_length'] = Variable<int>(targetLength.value);
    }
    if (narrativePerspective.present) {
      map['narrative_perspective'] = Variable<String>(
        narrativePerspective.value,
      );
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
          ..write('defaultProviderId: $defaultProviderId, ')
          ..write('defaultModelName: $defaultModelName, ')
          ..write('styleProfileId: $styleProfileId, ')
          ..write('plotProfileId: $plotProfileId, ')
          ..write('language: $language, ')
          ..write('targetLength: $targetLength, ')
          ..write('narrativePerspective: $narrativePerspective, ')
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
    projectId,
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
  final String? projectId;
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
    this.projectId,
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
      projectId: serializer.fromJson<String?>(json['projectId']),
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
      'projectId': serializer.toJson<String?>(projectId),
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
    Value<String?> projectId = const Value.absent(),
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
    projectId: projectId.present ? projectId.value : this.projectId,
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
          ..write('projectId: $projectId, ')
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
    projectId,
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
          other.projectId == this.projectId &&
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
  final Value<String?> projectId;
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
    this.projectId = const Value.absent(),
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
    this.projectId = const Value.absent(),
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
    Expression<String>? projectId,
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
      if (projectId != null) 'project_id': projectId,
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
    Value<String?>? projectId,
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
      projectId: projectId ?? this.projectId,
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
          ..write('projectId: $projectId, ')
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
    projectId,
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
  final String? projectId;
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
    this.projectId,
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
      projectId: serializer.fromJson<String?>(json['projectId']),
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
      'projectId': serializer.toJson<String?>(projectId),
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
    Value<String?> projectId = const Value.absent(),
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
    projectId: projectId.present ? projectId.value : this.projectId,
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
          ..write('projectId: $projectId, ')
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
  int get hashCode => Object.hashAll([
    id,
    workflowTaskId,
    sampleId,
    providerId,
    modelName,
    plotName,
    projectId,
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
  ]);
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
          other.projectId == this.projectId &&
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
  final Value<String?> projectId;
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
    this.projectId = const Value.absent(),
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
    this.projectId = const Value.absent(),
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
    Expression<String>? projectId,
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
      if (projectId != null) 'project_id': projectId,
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
    Value<String?>? projectId,
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
      projectId: projectId ?? this.projectId,
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
          ..write('projectId: $projectId, ')
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
  final String? projectId;
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
    map['plot_name'] = Variable<String>(plotName);
    map['story_engine_markdown'] = Variable<String>(storyEngineMarkdown);
    map['analysis_report_markdown'] = Variable<String>(analysisReportMarkdown);
    map['plot_skeleton_markdown'] = Variable<String>(plotSkeletonMarkdown);
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
      'plotName': serializer.toJson<String>(plotName),
      'storyEngineMarkdown': serializer.toJson<String>(storyEngineMarkdown),
      'analysisReportMarkdown': serializer.toJson<String>(
        analysisReportMarkdown,
      ),
      'plotSkeletonMarkdown': serializer.toJson<String>(plotSkeletonMarkdown),
      'projectId': serializer.toJson<String?>(projectId),
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
    Value<String?> projectId = const Value.absent(),
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
    projectId: projectId.present ? projectId.value : this.projectId,
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
    return (StringBuffer('PlotProfileRecord(')
          ..write('id: $id, ')
          ..write('sourceRunId: $sourceRunId, ')
          ..write('providerId: $providerId, ')
          ..write('modelName: $modelName, ')
          ..write('plotName: $plotName, ')
          ..write('storyEngineMarkdown: $storyEngineMarkdown, ')
          ..write('analysisReportMarkdown: $analysisReportMarkdown, ')
          ..write('plotSkeletonMarkdown: $plotSkeletonMarkdown, ')
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
    plotName,
    storyEngineMarkdown,
    analysisReportMarkdown,
    plotSkeletonMarkdown,
    projectId,
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
          other.projectId == this.projectId &&
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
  final Value<String?> projectId;
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
    this.projectId = const Value.absent(),
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
      if (plotName != null) 'plot_name': plotName,
      if (storyEngineMarkdown != null)
        'story_engine_markdown': storyEngineMarkdown,
      if (analysisReportMarkdown != null)
        'analysis_report_markdown': analysisReportMarkdown,
      if (plotSkeletonMarkdown != null)
        'plot_skeleton_markdown': plotSkeletonMarkdown,
      if (projectId != null) 'project_id': projectId,
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
    Value<String?>? projectId,
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
    return (StringBuffer('PlotProfileRecordsCompanion(')
          ..write('id: $id, ')
          ..write('sourceRunId: $sourceRunId, ')
          ..write('providerId: $providerId, ')
          ..write('modelName: $modelName, ')
          ..write('plotName: $plotName, ')
          ..write('storyEngineMarkdown: $storyEngineMarkdown, ')
          ..write('analysisReportMarkdown: $analysisReportMarkdown, ')
          ..write('plotSkeletonMarkdown: $plotSkeletonMarkdown, ')
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

class $ProjectRuntimeMemoryRecordsTable extends ProjectRuntimeMemoryRecords
    with
        TableInfo<
          $ProjectRuntimeMemoryRecordsTable,
          ProjectRuntimeMemoryRecord
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectRuntimeMemoryRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _charactersStatusMeta = const VerificationMeta(
    'charactersStatus',
  );
  @override
  late final GeneratedColumn<String> charactersStatus = GeneratedColumn<String>(
    'characters_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _runtimeStateMeta = const VerificationMeta(
    'runtimeState',
  );
  @override
  late final GeneratedColumn<String> runtimeState = GeneratedColumn<String>(
    'runtime_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _runtimeThreadsMeta = const VerificationMeta(
    'runtimeThreads',
  );
  @override
  late final GeneratedColumn<String> runtimeThreads = GeneratedColumn<String>(
    'runtime_threads',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _storySummaryMeta = const VerificationMeta(
    'storySummary',
  );
  @override
  late final GeneratedColumn<String> storySummary = GeneratedColumn<String>(
    'story_summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    projectId,
    charactersStatus,
    runtimeState,
    runtimeThreads,
    storySummary,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_runtime_memory_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectRuntimeMemoryRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('characters_status')) {
      context.handle(
        _charactersStatusMeta,
        charactersStatus.isAcceptableOrUnknown(
          data['characters_status']!,
          _charactersStatusMeta,
        ),
      );
    }
    if (data.containsKey('runtime_state')) {
      context.handle(
        _runtimeStateMeta,
        runtimeState.isAcceptableOrUnknown(
          data['runtime_state']!,
          _runtimeStateMeta,
        ),
      );
    }
    if (data.containsKey('runtime_threads')) {
      context.handle(
        _runtimeThreadsMeta,
        runtimeThreads.isAcceptableOrUnknown(
          data['runtime_threads']!,
          _runtimeThreadsMeta,
        ),
      );
    }
    if (data.containsKey('story_summary')) {
      context.handle(
        _storySummaryMeta,
        storySummary.isAcceptableOrUnknown(
          data['story_summary']!,
          _storySummaryMeta,
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
  Set<GeneratedColumn> get $primaryKey => {projectId};
  @override
  ProjectRuntimeMemoryRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectRuntimeMemoryRecord(
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      charactersStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}characters_status'],
      )!,
      runtimeState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}runtime_state'],
      )!,
      runtimeThreads: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}runtime_threads'],
      )!,
      storySummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}story_summary'],
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
  $ProjectRuntimeMemoryRecordsTable createAlias(String alias) {
    return $ProjectRuntimeMemoryRecordsTable(attachedDatabase, alias);
  }
}

class ProjectRuntimeMemoryRecord extends DataClass
    implements Insertable<ProjectRuntimeMemoryRecord> {
  final String projectId;
  final String charactersStatus;
  final String runtimeState;
  final String runtimeThreads;
  final String storySummary;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ProjectRuntimeMemoryRecord({
    required this.projectId,
    required this.charactersStatus,
    required this.runtimeState,
    required this.runtimeThreads,
    required this.storySummary,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['project_id'] = Variable<String>(projectId);
    map['characters_status'] = Variable<String>(charactersStatus);
    map['runtime_state'] = Variable<String>(runtimeState);
    map['runtime_threads'] = Variable<String>(runtimeThreads);
    map['story_summary'] = Variable<String>(storySummary);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProjectRuntimeMemoryRecordsCompanion toCompanion(bool nullToAbsent) {
    return ProjectRuntimeMemoryRecordsCompanion(
      projectId: Value(projectId),
      charactersStatus: Value(charactersStatus),
      runtimeState: Value(runtimeState),
      runtimeThreads: Value(runtimeThreads),
      storySummary: Value(storySummary),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProjectRuntimeMemoryRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectRuntimeMemoryRecord(
      projectId: serializer.fromJson<String>(json['projectId']),
      charactersStatus: serializer.fromJson<String>(json['charactersStatus']),
      runtimeState: serializer.fromJson<String>(json['runtimeState']),
      runtimeThreads: serializer.fromJson<String>(json['runtimeThreads']),
      storySummary: serializer.fromJson<String>(json['storySummary']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'projectId': serializer.toJson<String>(projectId),
      'charactersStatus': serializer.toJson<String>(charactersStatus),
      'runtimeState': serializer.toJson<String>(runtimeState),
      'runtimeThreads': serializer.toJson<String>(runtimeThreads),
      'storySummary': serializer.toJson<String>(storySummary),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProjectRuntimeMemoryRecord copyWith({
    String? projectId,
    String? charactersStatus,
    String? runtimeState,
    String? runtimeThreads,
    String? storySummary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ProjectRuntimeMemoryRecord(
    projectId: projectId ?? this.projectId,
    charactersStatus: charactersStatus ?? this.charactersStatus,
    runtimeState: runtimeState ?? this.runtimeState,
    runtimeThreads: runtimeThreads ?? this.runtimeThreads,
    storySummary: storySummary ?? this.storySummary,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProjectRuntimeMemoryRecord copyWithCompanion(
    ProjectRuntimeMemoryRecordsCompanion data,
  ) {
    return ProjectRuntimeMemoryRecord(
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      charactersStatus: data.charactersStatus.present
          ? data.charactersStatus.value
          : this.charactersStatus,
      runtimeState: data.runtimeState.present
          ? data.runtimeState.value
          : this.runtimeState,
      runtimeThreads: data.runtimeThreads.present
          ? data.runtimeThreads.value
          : this.runtimeThreads,
      storySummary: data.storySummary.present
          ? data.storySummary.value
          : this.storySummary,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectRuntimeMemoryRecord(')
          ..write('projectId: $projectId, ')
          ..write('charactersStatus: $charactersStatus, ')
          ..write('runtimeState: $runtimeState, ')
          ..write('runtimeThreads: $runtimeThreads, ')
          ..write('storySummary: $storySummary, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    projectId,
    charactersStatus,
    runtimeState,
    runtimeThreads,
    storySummary,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectRuntimeMemoryRecord &&
          other.projectId == this.projectId &&
          other.charactersStatus == this.charactersStatus &&
          other.runtimeState == this.runtimeState &&
          other.runtimeThreads == this.runtimeThreads &&
          other.storySummary == this.storySummary &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProjectRuntimeMemoryRecordsCompanion
    extends UpdateCompanion<ProjectRuntimeMemoryRecord> {
  final Value<String> projectId;
  final Value<String> charactersStatus;
  final Value<String> runtimeState;
  final Value<String> runtimeThreads;
  final Value<String> storySummary;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProjectRuntimeMemoryRecordsCompanion({
    this.projectId = const Value.absent(),
    this.charactersStatus = const Value.absent(),
    this.runtimeState = const Value.absent(),
    this.runtimeThreads = const Value.absent(),
    this.storySummary = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectRuntimeMemoryRecordsCompanion.insert({
    required String projectId,
    this.charactersStatus = const Value.absent(),
    this.runtimeState = const Value.absent(),
    this.runtimeThreads = const Value.absent(),
    this.storySummary = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : projectId = Value(projectId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProjectRuntimeMemoryRecord> custom({
    Expression<String>? projectId,
    Expression<String>? charactersStatus,
    Expression<String>? runtimeState,
    Expression<String>? runtimeThreads,
    Expression<String>? storySummary,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (projectId != null) 'project_id': projectId,
      if (charactersStatus != null) 'characters_status': charactersStatus,
      if (runtimeState != null) 'runtime_state': runtimeState,
      if (runtimeThreads != null) 'runtime_threads': runtimeThreads,
      if (storySummary != null) 'story_summary': storySummary,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectRuntimeMemoryRecordsCompanion copyWith({
    Value<String>? projectId,
    Value<String>? charactersStatus,
    Value<String>? runtimeState,
    Value<String>? runtimeThreads,
    Value<String>? storySummary,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProjectRuntimeMemoryRecordsCompanion(
      projectId: projectId ?? this.projectId,
      charactersStatus: charactersStatus ?? this.charactersStatus,
      runtimeState: runtimeState ?? this.runtimeState,
      runtimeThreads: runtimeThreads ?? this.runtimeThreads,
      storySummary: storySummary ?? this.storySummary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (charactersStatus.present) {
      map['characters_status'] = Variable<String>(charactersStatus.value);
    }
    if (runtimeState.present) {
      map['runtime_state'] = Variable<String>(runtimeState.value);
    }
    if (runtimeThreads.present) {
      map['runtime_threads'] = Variable<String>(runtimeThreads.value);
    }
    if (storySummary.present) {
      map['story_summary'] = Variable<String>(storySummary.value);
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
    return (StringBuffer('ProjectRuntimeMemoryRecordsCompanion(')
          ..write('projectId: $projectId, ')
          ..write('charactersStatus: $charactersStatus, ')
          ..write('runtimeState: $runtimeState, ')
          ..write('runtimeThreads: $runtimeThreads, ')
          ..write('storySummary: $storySummary, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChapterPlanRecordsTable extends ChapterPlanRecords
    with TableInfo<$ChapterPlanRecordsTable, ChapterPlanRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChapterPlanRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES project_records (id)',
    ),
  );
  static const VerificationMeta _chapterIndexMeta = const VerificationMeta(
    'chapterIndex',
  );
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
    'chapter_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _objectiveMeta = const VerificationMeta(
    'objective',
  );
  @override
  late final GeneratedColumn<String> objective = GeneratedColumn<String>(
    'objective',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _pressureSourceMeta = const VerificationMeta(
    'pressureSource',
  );
  @override
  late final GeneratedColumn<String> pressureSource = GeneratedColumn<String>(
    'pressure_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _payoffTargetMeta = const VerificationMeta(
    'payoffTarget',
  );
  @override
  late final GeneratedColumn<String> payoffTarget = GeneratedColumn<String>(
    'payoff_target',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _relationshipShiftMeta = const VerificationMeta(
    'relationshipShift',
  );
  @override
  late final GeneratedColumn<String> relationshipShift =
      GeneratedColumn<String>(
        'relationship_shift',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _hookTypeMeta = const VerificationMeta(
    'hookType',
  );
  @override
  late final GeneratedColumn<String> hookType = GeneratedColumn<String>(
    'hook_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    projectId,
    chapterIndex,
    title,
    objective,
    pressureSource,
    payoffTarget,
    relationshipShift,
    hookType,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapter_plan_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChapterPlanRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
        _chapterIndexMeta,
        chapterIndex.isAcceptableOrUnknown(
          data['chapter_index']!,
          _chapterIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterIndexMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('objective')) {
      context.handle(
        _objectiveMeta,
        objective.isAcceptableOrUnknown(data['objective']!, _objectiveMeta),
      );
    }
    if (data.containsKey('pressure_source')) {
      context.handle(
        _pressureSourceMeta,
        pressureSource.isAcceptableOrUnknown(
          data['pressure_source']!,
          _pressureSourceMeta,
        ),
      );
    }
    if (data.containsKey('payoff_target')) {
      context.handle(
        _payoffTargetMeta,
        payoffTarget.isAcceptableOrUnknown(
          data['payoff_target']!,
          _payoffTargetMeta,
        ),
      );
    }
    if (data.containsKey('relationship_shift')) {
      context.handle(
        _relationshipShiftMeta,
        relationshipShift.isAcceptableOrUnknown(
          data['relationship_shift']!,
          _relationshipShiftMeta,
        ),
      );
    }
    if (data.containsKey('hook_type')) {
      context.handle(
        _hookTypeMeta,
        hookType.isAcceptableOrUnknown(data['hook_type']!, _hookTypeMeta),
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {projectId, chapterIndex},
  ];
  @override
  ChapterPlanRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterPlanRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      chapterIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_index'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      objective: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}objective'],
      )!,
      pressureSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pressure_source'],
      )!,
      payoffTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payoff_target'],
      )!,
      relationshipShift: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relationship_shift'],
      )!,
      hookType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hook_type'],
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
  $ChapterPlanRecordsTable createAlias(String alias) {
    return $ChapterPlanRecordsTable(attachedDatabase, alias);
  }
}

class ChapterPlanRecord extends DataClass
    implements Insertable<ChapterPlanRecord> {
  final String id;
  final String projectId;
  final int chapterIndex;
  final String title;
  final String objective;
  final String pressureSource;
  final String payoffTarget;
  final String relationshipShift;
  final String hookType;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ChapterPlanRecord({
    required this.id,
    required this.projectId,
    required this.chapterIndex,
    required this.title,
    required this.objective,
    required this.pressureSource,
    required this.payoffTarget,
    required this.relationshipShift,
    required this.hookType,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['chapter_index'] = Variable<int>(chapterIndex);
    map['title'] = Variable<String>(title);
    map['objective'] = Variable<String>(objective);
    map['pressure_source'] = Variable<String>(pressureSource);
    map['payoff_target'] = Variable<String>(payoffTarget);
    map['relationship_shift'] = Variable<String>(relationshipShift);
    map['hook_type'] = Variable<String>(hookType);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChapterPlanRecordsCompanion toCompanion(bool nullToAbsent) {
    return ChapterPlanRecordsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      chapterIndex: Value(chapterIndex),
      title: Value(title),
      objective: Value(objective),
      pressureSource: Value(pressureSource),
      payoffTarget: Value(payoffTarget),
      relationshipShift: Value(relationshipShift),
      hookType: Value(hookType),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ChapterPlanRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterPlanRecord(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      title: serializer.fromJson<String>(json['title']),
      objective: serializer.fromJson<String>(json['objective']),
      pressureSource: serializer.fromJson<String>(json['pressureSource']),
      payoffTarget: serializer.fromJson<String>(json['payoffTarget']),
      relationshipShift: serializer.fromJson<String>(json['relationshipShift']),
      hookType: serializer.fromJson<String>(json['hookType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'title': serializer.toJson<String>(title),
      'objective': serializer.toJson<String>(objective),
      'pressureSource': serializer.toJson<String>(pressureSource),
      'payoffTarget': serializer.toJson<String>(payoffTarget),
      'relationshipShift': serializer.toJson<String>(relationshipShift),
      'hookType': serializer.toJson<String>(hookType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ChapterPlanRecord copyWith({
    String? id,
    String? projectId,
    int? chapterIndex,
    String? title,
    String? objective,
    String? pressureSource,
    String? payoffTarget,
    String? relationshipShift,
    String? hookType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ChapterPlanRecord(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    title: title ?? this.title,
    objective: objective ?? this.objective,
    pressureSource: pressureSource ?? this.pressureSource,
    payoffTarget: payoffTarget ?? this.payoffTarget,
    relationshipShift: relationshipShift ?? this.relationshipShift,
    hookType: hookType ?? this.hookType,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ChapterPlanRecord copyWithCompanion(ChapterPlanRecordsCompanion data) {
    return ChapterPlanRecord(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      title: data.title.present ? data.title.value : this.title,
      objective: data.objective.present ? data.objective.value : this.objective,
      pressureSource: data.pressureSource.present
          ? data.pressureSource.value
          : this.pressureSource,
      payoffTarget: data.payoffTarget.present
          ? data.payoffTarget.value
          : this.payoffTarget,
      relationshipShift: data.relationshipShift.present
          ? data.relationshipShift.value
          : this.relationshipShift,
      hookType: data.hookType.present ? data.hookType.value : this.hookType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterPlanRecord(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('title: $title, ')
          ..write('objective: $objective, ')
          ..write('pressureSource: $pressureSource, ')
          ..write('payoffTarget: $payoffTarget, ')
          ..write('relationshipShift: $relationshipShift, ')
          ..write('hookType: $hookType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    chapterIndex,
    title,
    objective,
    pressureSource,
    payoffTarget,
    relationshipShift,
    hookType,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterPlanRecord &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.chapterIndex == this.chapterIndex &&
          other.title == this.title &&
          other.objective == this.objective &&
          other.pressureSource == this.pressureSource &&
          other.payoffTarget == this.payoffTarget &&
          other.relationshipShift == this.relationshipShift &&
          other.hookType == this.hookType &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ChapterPlanRecordsCompanion extends UpdateCompanion<ChapterPlanRecord> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<int> chapterIndex;
  final Value<String> title;
  final Value<String> objective;
  final Value<String> pressureSource;
  final Value<String> payoffTarget;
  final Value<String> relationshipShift;
  final Value<String> hookType;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ChapterPlanRecordsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.title = const Value.absent(),
    this.objective = const Value.absent(),
    this.pressureSource = const Value.absent(),
    this.payoffTarget = const Value.absent(),
    this.relationshipShift = const Value.absent(),
    this.hookType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChapterPlanRecordsCompanion.insert({
    required String id,
    required String projectId,
    required int chapterIndex,
    this.title = const Value.absent(),
    this.objective = const Value.absent(),
    this.pressureSource = const Value.absent(),
    this.payoffTarget = const Value.absent(),
    this.relationshipShift = const Value.absent(),
    this.hookType = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       chapterIndex = Value(chapterIndex),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ChapterPlanRecord> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<int>? chapterIndex,
    Expression<String>? title,
    Expression<String>? objective,
    Expression<String>? pressureSource,
    Expression<String>? payoffTarget,
    Expression<String>? relationshipShift,
    Expression<String>? hookType,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (title != null) 'title': title,
      if (objective != null) 'objective': objective,
      if (pressureSource != null) 'pressure_source': pressureSource,
      if (payoffTarget != null) 'payoff_target': payoffTarget,
      if (relationshipShift != null) 'relationship_shift': relationshipShift,
      if (hookType != null) 'hook_type': hookType,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChapterPlanRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<int>? chapterIndex,
    Value<String>? title,
    Value<String>? objective,
    Value<String>? pressureSource,
    Value<String>? payoffTarget,
    Value<String>? relationshipShift,
    Value<String>? hookType,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ChapterPlanRecordsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      title: title ?? this.title,
      objective: objective ?? this.objective,
      pressureSource: pressureSource ?? this.pressureSource,
      payoffTarget: payoffTarget ?? this.payoffTarget,
      relationshipShift: relationshipShift ?? this.relationshipShift,
      hookType: hookType ?? this.hookType,
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
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (objective.present) {
      map['objective'] = Variable<String>(objective.value);
    }
    if (pressureSource.present) {
      map['pressure_source'] = Variable<String>(pressureSource.value);
    }
    if (payoffTarget.present) {
      map['payoff_target'] = Variable<String>(payoffTarget.value);
    }
    if (relationshipShift.present) {
      map['relationship_shift'] = Variable<String>(relationshipShift.value);
    }
    if (hookType.present) {
      map['hook_type'] = Variable<String>(hookType.value);
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
    return (StringBuffer('ChapterPlanRecordsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('title: $title, ')
          ..write('objective: $objective, ')
          ..write('pressureSource: $pressureSource, ')
          ..write('payoffTarget: $payoffTarget, ')
          ..write('relationshipShift: $relationshipShift, ')
          ..write('hookType: $hookType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectChapterRecordsTable extends ProjectChapterRecords
    with TableInfo<$ProjectChapterRecordsTable, ProjectChapterRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectChapterRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES project_records (id)',
    ),
  );
  static const VerificationMeta _chapterPlanIdMeta = const VerificationMeta(
    'chapterPlanId',
  );
  @override
  late final GeneratedColumn<String> chapterPlanId = GeneratedColumn<String>(
    'chapter_plan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES chapter_plan_records (id)',
    ),
  );
  static const VerificationMeta _chapterIndexMeta = const VerificationMeta(
    'chapterIndex',
  );
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
    'chapter_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _contentMarkdownMeta = const VerificationMeta(
    'contentMarkdown',
  );
  @override
  late final GeneratedColumn<String> contentMarkdown = GeneratedColumn<String>(
    'content_markdown',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _continuityVerdictMeta = const VerificationMeta(
    'continuityVerdict',
  );
  @override
  late final GeneratedColumn<String> continuityVerdict =
      GeneratedColumn<String>(
        'continuity_verdict',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('pass'),
      );
  static const VerificationMeta _continuityReportMarkdownMeta =
      const VerificationMeta('continuityReportMarkdown');
  @override
  late final GeneratedColumn<String> continuityReportMarkdown =
      GeneratedColumn<String>(
        'continuity_report_markdown',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _memorySyncStatusMeta = const VerificationMeta(
    'memorySyncStatus',
  );
  @override
  late final GeneratedColumn<String> memorySyncStatus = GeneratedColumn<String>(
    'memory_sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('idle'),
  );
  static const VerificationMeta _memorySyncContentHashMeta =
      const VerificationMeta('memorySyncContentHash');
  @override
  late final GeneratedColumn<String> memorySyncContentHash =
      GeneratedColumn<String>(
        'memory_sync_content_hash',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _memorySyncProposedCharactersStatusMeta =
      const VerificationMeta('memorySyncProposedCharactersStatus');
  @override
  late final GeneratedColumn<String> memorySyncProposedCharactersStatus =
      GeneratedColumn<String>(
        'memory_sync_proposed_characters_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _memorySyncProposedRuntimeStateMeta =
      const VerificationMeta('memorySyncProposedRuntimeState');
  @override
  late final GeneratedColumn<String> memorySyncProposedRuntimeState =
      GeneratedColumn<String>(
        'memory_sync_proposed_runtime_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _memorySyncProposedRuntimeThreadsMeta =
      const VerificationMeta('memorySyncProposedRuntimeThreads');
  @override
  late final GeneratedColumn<String> memorySyncProposedRuntimeThreads =
      GeneratedColumn<String>(
        'memory_sync_proposed_runtime_threads',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _memorySyncProposedStorySummaryMeta =
      const VerificationMeta('memorySyncProposedStorySummary');
  @override
  late final GeneratedColumn<String> memorySyncProposedStorySummary =
      GeneratedColumn<String>(
        'memory_sync_proposed_story_summary',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
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
    projectId,
    chapterPlanId,
    chapterIndex,
    title,
    contentMarkdown,
    contentHash,
    continuityVerdict,
    continuityReportMarkdown,
    memorySyncStatus,
    memorySyncContentHash,
    memorySyncProposedCharactersStatus,
    memorySyncProposedRuntimeState,
    memorySyncProposedRuntimeThreads,
    memorySyncProposedStorySummary,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_chapter_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectChapterRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('chapter_plan_id')) {
      context.handle(
        _chapterPlanIdMeta,
        chapterPlanId.isAcceptableOrUnknown(
          data['chapter_plan_id']!,
          _chapterPlanIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterPlanIdMeta);
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
        _chapterIndexMeta,
        chapterIndex.isAcceptableOrUnknown(
          data['chapter_index']!,
          _chapterIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterIndexMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('content_markdown')) {
      context.handle(
        _contentMarkdownMeta,
        contentMarkdown.isAcceptableOrUnknown(
          data['content_markdown']!,
          _contentMarkdownMeta,
        ),
      );
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    }
    if (data.containsKey('continuity_verdict')) {
      context.handle(
        _continuityVerdictMeta,
        continuityVerdict.isAcceptableOrUnknown(
          data['continuity_verdict']!,
          _continuityVerdictMeta,
        ),
      );
    }
    if (data.containsKey('continuity_report_markdown')) {
      context.handle(
        _continuityReportMarkdownMeta,
        continuityReportMarkdown.isAcceptableOrUnknown(
          data['continuity_report_markdown']!,
          _continuityReportMarkdownMeta,
        ),
      );
    }
    if (data.containsKey('memory_sync_status')) {
      context.handle(
        _memorySyncStatusMeta,
        memorySyncStatus.isAcceptableOrUnknown(
          data['memory_sync_status']!,
          _memorySyncStatusMeta,
        ),
      );
    }
    if (data.containsKey('memory_sync_content_hash')) {
      context.handle(
        _memorySyncContentHashMeta,
        memorySyncContentHash.isAcceptableOrUnknown(
          data['memory_sync_content_hash']!,
          _memorySyncContentHashMeta,
        ),
      );
    }
    if (data.containsKey('memory_sync_proposed_characters_status')) {
      context.handle(
        _memorySyncProposedCharactersStatusMeta,
        memorySyncProposedCharactersStatus.isAcceptableOrUnknown(
          data['memory_sync_proposed_characters_status']!,
          _memorySyncProposedCharactersStatusMeta,
        ),
      );
    }
    if (data.containsKey('memory_sync_proposed_runtime_state')) {
      context.handle(
        _memorySyncProposedRuntimeStateMeta,
        memorySyncProposedRuntimeState.isAcceptableOrUnknown(
          data['memory_sync_proposed_runtime_state']!,
          _memorySyncProposedRuntimeStateMeta,
        ),
      );
    }
    if (data.containsKey('memory_sync_proposed_runtime_threads')) {
      context.handle(
        _memorySyncProposedRuntimeThreadsMeta,
        memorySyncProposedRuntimeThreads.isAcceptableOrUnknown(
          data['memory_sync_proposed_runtime_threads']!,
          _memorySyncProposedRuntimeThreadsMeta,
        ),
      );
    }
    if (data.containsKey('memory_sync_proposed_story_summary')) {
      context.handle(
        _memorySyncProposedStorySummaryMeta,
        memorySyncProposedStorySummary.isAcceptableOrUnknown(
          data['memory_sync_proposed_story_summary']!,
          _memorySyncProposedStorySummaryMeta,
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {projectId, chapterIndex},
  ];
  @override
  ProjectChapterRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectChapterRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      chapterPlanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_plan_id'],
      )!,
      chapterIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_index'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      contentMarkdown: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_markdown'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      continuityVerdict: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}continuity_verdict'],
      )!,
      continuityReportMarkdown: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}continuity_report_markdown'],
      )!,
      memorySyncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memory_sync_status'],
      )!,
      memorySyncContentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memory_sync_content_hash'],
      )!,
      memorySyncProposedCharactersStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memory_sync_proposed_characters_status'],
      )!,
      memorySyncProposedRuntimeState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memory_sync_proposed_runtime_state'],
      )!,
      memorySyncProposedRuntimeThreads: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memory_sync_proposed_runtime_threads'],
      )!,
      memorySyncProposedStorySummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memory_sync_proposed_story_summary'],
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
  $ProjectChapterRecordsTable createAlias(String alias) {
    return $ProjectChapterRecordsTable(attachedDatabase, alias);
  }
}

class ProjectChapterRecord extends DataClass
    implements Insertable<ProjectChapterRecord> {
  final String id;
  final String projectId;
  final String chapterPlanId;
  final int chapterIndex;
  final String title;
  final String contentMarkdown;
  final String contentHash;
  final String continuityVerdict;
  final String continuityReportMarkdown;
  final String memorySyncStatus;
  final String memorySyncContentHash;
  final String memorySyncProposedCharactersStatus;
  final String memorySyncProposedRuntimeState;
  final String memorySyncProposedRuntimeThreads;
  final String memorySyncProposedStorySummary;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ProjectChapterRecord({
    required this.id,
    required this.projectId,
    required this.chapterPlanId,
    required this.chapterIndex,
    required this.title,
    required this.contentMarkdown,
    required this.contentHash,
    required this.continuityVerdict,
    required this.continuityReportMarkdown,
    required this.memorySyncStatus,
    required this.memorySyncContentHash,
    required this.memorySyncProposedCharactersStatus,
    required this.memorySyncProposedRuntimeState,
    required this.memorySyncProposedRuntimeThreads,
    required this.memorySyncProposedStorySummary,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['chapter_plan_id'] = Variable<String>(chapterPlanId);
    map['chapter_index'] = Variable<int>(chapterIndex);
    map['title'] = Variable<String>(title);
    map['content_markdown'] = Variable<String>(contentMarkdown);
    map['content_hash'] = Variable<String>(contentHash);
    map['continuity_verdict'] = Variable<String>(continuityVerdict);
    map['continuity_report_markdown'] = Variable<String>(
      continuityReportMarkdown,
    );
    map['memory_sync_status'] = Variable<String>(memorySyncStatus);
    map['memory_sync_content_hash'] = Variable<String>(memorySyncContentHash);
    map['memory_sync_proposed_characters_status'] = Variable<String>(
      memorySyncProposedCharactersStatus,
    );
    map['memory_sync_proposed_runtime_state'] = Variable<String>(
      memorySyncProposedRuntimeState,
    );
    map['memory_sync_proposed_runtime_threads'] = Variable<String>(
      memorySyncProposedRuntimeThreads,
    );
    map['memory_sync_proposed_story_summary'] = Variable<String>(
      memorySyncProposedStorySummary,
    );
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProjectChapterRecordsCompanion toCompanion(bool nullToAbsent) {
    return ProjectChapterRecordsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      chapterPlanId: Value(chapterPlanId),
      chapterIndex: Value(chapterIndex),
      title: Value(title),
      contentMarkdown: Value(contentMarkdown),
      contentHash: Value(contentHash),
      continuityVerdict: Value(continuityVerdict),
      continuityReportMarkdown: Value(continuityReportMarkdown),
      memorySyncStatus: Value(memorySyncStatus),
      memorySyncContentHash: Value(memorySyncContentHash),
      memorySyncProposedCharactersStatus: Value(
        memorySyncProposedCharactersStatus,
      ),
      memorySyncProposedRuntimeState: Value(memorySyncProposedRuntimeState),
      memorySyncProposedRuntimeThreads: Value(memorySyncProposedRuntimeThreads),
      memorySyncProposedStorySummary: Value(memorySyncProposedStorySummary),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProjectChapterRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectChapterRecord(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      chapterPlanId: serializer.fromJson<String>(json['chapterPlanId']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      title: serializer.fromJson<String>(json['title']),
      contentMarkdown: serializer.fromJson<String>(json['contentMarkdown']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      continuityVerdict: serializer.fromJson<String>(json['continuityVerdict']),
      continuityReportMarkdown: serializer.fromJson<String>(
        json['continuityReportMarkdown'],
      ),
      memorySyncStatus: serializer.fromJson<String>(json['memorySyncStatus']),
      memorySyncContentHash: serializer.fromJson<String>(
        json['memorySyncContentHash'],
      ),
      memorySyncProposedCharactersStatus: serializer.fromJson<String>(
        json['memorySyncProposedCharactersStatus'],
      ),
      memorySyncProposedRuntimeState: serializer.fromJson<String>(
        json['memorySyncProposedRuntimeState'],
      ),
      memorySyncProposedRuntimeThreads: serializer.fromJson<String>(
        json['memorySyncProposedRuntimeThreads'],
      ),
      memorySyncProposedStorySummary: serializer.fromJson<String>(
        json['memorySyncProposedStorySummary'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'chapterPlanId': serializer.toJson<String>(chapterPlanId),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'title': serializer.toJson<String>(title),
      'contentMarkdown': serializer.toJson<String>(contentMarkdown),
      'contentHash': serializer.toJson<String>(contentHash),
      'continuityVerdict': serializer.toJson<String>(continuityVerdict),
      'continuityReportMarkdown': serializer.toJson<String>(
        continuityReportMarkdown,
      ),
      'memorySyncStatus': serializer.toJson<String>(memorySyncStatus),
      'memorySyncContentHash': serializer.toJson<String>(memorySyncContentHash),
      'memorySyncProposedCharactersStatus': serializer.toJson<String>(
        memorySyncProposedCharactersStatus,
      ),
      'memorySyncProposedRuntimeState': serializer.toJson<String>(
        memorySyncProposedRuntimeState,
      ),
      'memorySyncProposedRuntimeThreads': serializer.toJson<String>(
        memorySyncProposedRuntimeThreads,
      ),
      'memorySyncProposedStorySummary': serializer.toJson<String>(
        memorySyncProposedStorySummary,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProjectChapterRecord copyWith({
    String? id,
    String? projectId,
    String? chapterPlanId,
    int? chapterIndex,
    String? title,
    String? contentMarkdown,
    String? contentHash,
    String? continuityVerdict,
    String? continuityReportMarkdown,
    String? memorySyncStatus,
    String? memorySyncContentHash,
    String? memorySyncProposedCharactersStatus,
    String? memorySyncProposedRuntimeState,
    String? memorySyncProposedRuntimeThreads,
    String? memorySyncProposedStorySummary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ProjectChapterRecord(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    chapterPlanId: chapterPlanId ?? this.chapterPlanId,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    title: title ?? this.title,
    contentMarkdown: contentMarkdown ?? this.contentMarkdown,
    contentHash: contentHash ?? this.contentHash,
    continuityVerdict: continuityVerdict ?? this.continuityVerdict,
    continuityReportMarkdown:
        continuityReportMarkdown ?? this.continuityReportMarkdown,
    memorySyncStatus: memorySyncStatus ?? this.memorySyncStatus,
    memorySyncContentHash: memorySyncContentHash ?? this.memorySyncContentHash,
    memorySyncProposedCharactersStatus:
        memorySyncProposedCharactersStatus ??
        this.memorySyncProposedCharactersStatus,
    memorySyncProposedRuntimeState:
        memorySyncProposedRuntimeState ?? this.memorySyncProposedRuntimeState,
    memorySyncProposedRuntimeThreads:
        memorySyncProposedRuntimeThreads ??
        this.memorySyncProposedRuntimeThreads,
    memorySyncProposedStorySummary:
        memorySyncProposedStorySummary ?? this.memorySyncProposedStorySummary,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProjectChapterRecord copyWithCompanion(ProjectChapterRecordsCompanion data) {
    return ProjectChapterRecord(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      chapterPlanId: data.chapterPlanId.present
          ? data.chapterPlanId.value
          : this.chapterPlanId,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      title: data.title.present ? data.title.value : this.title,
      contentMarkdown: data.contentMarkdown.present
          ? data.contentMarkdown.value
          : this.contentMarkdown,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      continuityVerdict: data.continuityVerdict.present
          ? data.continuityVerdict.value
          : this.continuityVerdict,
      continuityReportMarkdown: data.continuityReportMarkdown.present
          ? data.continuityReportMarkdown.value
          : this.continuityReportMarkdown,
      memorySyncStatus: data.memorySyncStatus.present
          ? data.memorySyncStatus.value
          : this.memorySyncStatus,
      memorySyncContentHash: data.memorySyncContentHash.present
          ? data.memorySyncContentHash.value
          : this.memorySyncContentHash,
      memorySyncProposedCharactersStatus:
          data.memorySyncProposedCharactersStatus.present
          ? data.memorySyncProposedCharactersStatus.value
          : this.memorySyncProposedCharactersStatus,
      memorySyncProposedRuntimeState:
          data.memorySyncProposedRuntimeState.present
          ? data.memorySyncProposedRuntimeState.value
          : this.memorySyncProposedRuntimeState,
      memorySyncProposedRuntimeThreads:
          data.memorySyncProposedRuntimeThreads.present
          ? data.memorySyncProposedRuntimeThreads.value
          : this.memorySyncProposedRuntimeThreads,
      memorySyncProposedStorySummary:
          data.memorySyncProposedStorySummary.present
          ? data.memorySyncProposedStorySummary.value
          : this.memorySyncProposedStorySummary,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectChapterRecord(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('chapterPlanId: $chapterPlanId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('title: $title, ')
          ..write('contentMarkdown: $contentMarkdown, ')
          ..write('contentHash: $contentHash, ')
          ..write('continuityVerdict: $continuityVerdict, ')
          ..write('continuityReportMarkdown: $continuityReportMarkdown, ')
          ..write('memorySyncStatus: $memorySyncStatus, ')
          ..write('memorySyncContentHash: $memorySyncContentHash, ')
          ..write(
            'memorySyncProposedCharactersStatus: $memorySyncProposedCharactersStatus, ',
          )
          ..write(
            'memorySyncProposedRuntimeState: $memorySyncProposedRuntimeState, ',
          )
          ..write(
            'memorySyncProposedRuntimeThreads: $memorySyncProposedRuntimeThreads, ',
          )
          ..write(
            'memorySyncProposedStorySummary: $memorySyncProposedStorySummary, ',
          )
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    chapterPlanId,
    chapterIndex,
    title,
    contentMarkdown,
    contentHash,
    continuityVerdict,
    continuityReportMarkdown,
    memorySyncStatus,
    memorySyncContentHash,
    memorySyncProposedCharactersStatus,
    memorySyncProposedRuntimeState,
    memorySyncProposedRuntimeThreads,
    memorySyncProposedStorySummary,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectChapterRecord &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.chapterPlanId == this.chapterPlanId &&
          other.chapterIndex == this.chapterIndex &&
          other.title == this.title &&
          other.contentMarkdown == this.contentMarkdown &&
          other.contentHash == this.contentHash &&
          other.continuityVerdict == this.continuityVerdict &&
          other.continuityReportMarkdown == this.continuityReportMarkdown &&
          other.memorySyncStatus == this.memorySyncStatus &&
          other.memorySyncContentHash == this.memorySyncContentHash &&
          other.memorySyncProposedCharactersStatus ==
              this.memorySyncProposedCharactersStatus &&
          other.memorySyncProposedRuntimeState ==
              this.memorySyncProposedRuntimeState &&
          other.memorySyncProposedRuntimeThreads ==
              this.memorySyncProposedRuntimeThreads &&
          other.memorySyncProposedStorySummary ==
              this.memorySyncProposedStorySummary &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProjectChapterRecordsCompanion
    extends UpdateCompanion<ProjectChapterRecord> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> chapterPlanId;
  final Value<int> chapterIndex;
  final Value<String> title;
  final Value<String> contentMarkdown;
  final Value<String> contentHash;
  final Value<String> continuityVerdict;
  final Value<String> continuityReportMarkdown;
  final Value<String> memorySyncStatus;
  final Value<String> memorySyncContentHash;
  final Value<String> memorySyncProposedCharactersStatus;
  final Value<String> memorySyncProposedRuntimeState;
  final Value<String> memorySyncProposedRuntimeThreads;
  final Value<String> memorySyncProposedStorySummary;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProjectChapterRecordsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.chapterPlanId = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.title = const Value.absent(),
    this.contentMarkdown = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.continuityVerdict = const Value.absent(),
    this.continuityReportMarkdown = const Value.absent(),
    this.memorySyncStatus = const Value.absent(),
    this.memorySyncContentHash = const Value.absent(),
    this.memorySyncProposedCharactersStatus = const Value.absent(),
    this.memorySyncProposedRuntimeState = const Value.absent(),
    this.memorySyncProposedRuntimeThreads = const Value.absent(),
    this.memorySyncProposedStorySummary = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectChapterRecordsCompanion.insert({
    required String id,
    required String projectId,
    required String chapterPlanId,
    required int chapterIndex,
    this.title = const Value.absent(),
    this.contentMarkdown = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.continuityVerdict = const Value.absent(),
    this.continuityReportMarkdown = const Value.absent(),
    this.memorySyncStatus = const Value.absent(),
    this.memorySyncContentHash = const Value.absent(),
    this.memorySyncProposedCharactersStatus = const Value.absent(),
    this.memorySyncProposedRuntimeState = const Value.absent(),
    this.memorySyncProposedRuntimeThreads = const Value.absent(),
    this.memorySyncProposedStorySummary = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       chapterPlanId = Value(chapterPlanId),
       chapterIndex = Value(chapterIndex),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProjectChapterRecord> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? chapterPlanId,
    Expression<int>? chapterIndex,
    Expression<String>? title,
    Expression<String>? contentMarkdown,
    Expression<String>? contentHash,
    Expression<String>? continuityVerdict,
    Expression<String>? continuityReportMarkdown,
    Expression<String>? memorySyncStatus,
    Expression<String>? memorySyncContentHash,
    Expression<String>? memorySyncProposedCharactersStatus,
    Expression<String>? memorySyncProposedRuntimeState,
    Expression<String>? memorySyncProposedRuntimeThreads,
    Expression<String>? memorySyncProposedStorySummary,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (chapterPlanId != null) 'chapter_plan_id': chapterPlanId,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (title != null) 'title': title,
      if (contentMarkdown != null) 'content_markdown': contentMarkdown,
      if (contentHash != null) 'content_hash': contentHash,
      if (continuityVerdict != null) 'continuity_verdict': continuityVerdict,
      if (continuityReportMarkdown != null)
        'continuity_report_markdown': continuityReportMarkdown,
      if (memorySyncStatus != null) 'memory_sync_status': memorySyncStatus,
      if (memorySyncContentHash != null)
        'memory_sync_content_hash': memorySyncContentHash,
      if (memorySyncProposedCharactersStatus != null)
        'memory_sync_proposed_characters_status':
            memorySyncProposedCharactersStatus,
      if (memorySyncProposedRuntimeState != null)
        'memory_sync_proposed_runtime_state': memorySyncProposedRuntimeState,
      if (memorySyncProposedRuntimeThreads != null)
        'memory_sync_proposed_runtime_threads':
            memorySyncProposedRuntimeThreads,
      if (memorySyncProposedStorySummary != null)
        'memory_sync_proposed_story_summary': memorySyncProposedStorySummary,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectChapterRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? chapterPlanId,
    Value<int>? chapterIndex,
    Value<String>? title,
    Value<String>? contentMarkdown,
    Value<String>? contentHash,
    Value<String>? continuityVerdict,
    Value<String>? continuityReportMarkdown,
    Value<String>? memorySyncStatus,
    Value<String>? memorySyncContentHash,
    Value<String>? memorySyncProposedCharactersStatus,
    Value<String>? memorySyncProposedRuntimeState,
    Value<String>? memorySyncProposedRuntimeThreads,
    Value<String>? memorySyncProposedStorySummary,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProjectChapterRecordsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      chapterPlanId: chapterPlanId ?? this.chapterPlanId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      title: title ?? this.title,
      contentMarkdown: contentMarkdown ?? this.contentMarkdown,
      contentHash: contentHash ?? this.contentHash,
      continuityVerdict: continuityVerdict ?? this.continuityVerdict,
      continuityReportMarkdown:
          continuityReportMarkdown ?? this.continuityReportMarkdown,
      memorySyncStatus: memorySyncStatus ?? this.memorySyncStatus,
      memorySyncContentHash:
          memorySyncContentHash ?? this.memorySyncContentHash,
      memorySyncProposedCharactersStatus:
          memorySyncProposedCharactersStatus ??
          this.memorySyncProposedCharactersStatus,
      memorySyncProposedRuntimeState:
          memorySyncProposedRuntimeState ?? this.memorySyncProposedRuntimeState,
      memorySyncProposedRuntimeThreads:
          memorySyncProposedRuntimeThreads ??
          this.memorySyncProposedRuntimeThreads,
      memorySyncProposedStorySummary:
          memorySyncProposedStorySummary ?? this.memorySyncProposedStorySummary,
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
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (chapterPlanId.present) {
      map['chapter_plan_id'] = Variable<String>(chapterPlanId.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (contentMarkdown.present) {
      map['content_markdown'] = Variable<String>(contentMarkdown.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (continuityVerdict.present) {
      map['continuity_verdict'] = Variable<String>(continuityVerdict.value);
    }
    if (continuityReportMarkdown.present) {
      map['continuity_report_markdown'] = Variable<String>(
        continuityReportMarkdown.value,
      );
    }
    if (memorySyncStatus.present) {
      map['memory_sync_status'] = Variable<String>(memorySyncStatus.value);
    }
    if (memorySyncContentHash.present) {
      map['memory_sync_content_hash'] = Variable<String>(
        memorySyncContentHash.value,
      );
    }
    if (memorySyncProposedCharactersStatus.present) {
      map['memory_sync_proposed_characters_status'] = Variable<String>(
        memorySyncProposedCharactersStatus.value,
      );
    }
    if (memorySyncProposedRuntimeState.present) {
      map['memory_sync_proposed_runtime_state'] = Variable<String>(
        memorySyncProposedRuntimeState.value,
      );
    }
    if (memorySyncProposedRuntimeThreads.present) {
      map['memory_sync_proposed_runtime_threads'] = Variable<String>(
        memorySyncProposedRuntimeThreads.value,
      );
    }
    if (memorySyncProposedStorySummary.present) {
      map['memory_sync_proposed_story_summary'] = Variable<String>(
        memorySyncProposedStorySummary.value,
      );
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
    return (StringBuffer('ProjectChapterRecordsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('chapterPlanId: $chapterPlanId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('title: $title, ')
          ..write('contentMarkdown: $contentMarkdown, ')
          ..write('contentHash: $contentHash, ')
          ..write('continuityVerdict: $continuityVerdict, ')
          ..write('continuityReportMarkdown: $continuityReportMarkdown, ')
          ..write('memorySyncStatus: $memorySyncStatus, ')
          ..write('memorySyncContentHash: $memorySyncContentHash, ')
          ..write(
            'memorySyncProposedCharactersStatus: $memorySyncProposedCharactersStatus, ',
          )
          ..write(
            'memorySyncProposedRuntimeState: $memorySyncProposedRuntimeState, ',
          )
          ..write(
            'memorySyncProposedRuntimeThreads: $memorySyncProposedRuntimeThreads, ',
          )
          ..write(
            'memorySyncProposedStorySummary: $memorySyncProposedStorySummary, ',
          )
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChapterGenerationRunRecordsTable extends ChapterGenerationRunRecords
    with
        TableInfo<
          $ChapterGenerationRunRecordsTable,
          ChapterGenerationRunRecord
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChapterGenerationRunRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES project_records (id)',
    ),
  );
  static const VerificationMeta _chapterPlanIdMeta = const VerificationMeta(
    'chapterPlanId',
  );
  @override
  late final GeneratedColumn<String> chapterPlanId = GeneratedColumn<String>(
    'chapter_plan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES project_chapter_records (id)',
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
  static const VerificationMeta _contextWarningsMarkdownMeta =
      const VerificationMeta('contextWarningsMarkdown');
  @override
  late final GeneratedColumn<String> contextWarningsMarkdown =
      GeneratedColumn<String>(
        'context_warnings_markdown',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
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
    projectId,
    chapterPlanId,
    chapterId,
    providerId,
    modelName,
    status,
    stage,
    errorMessage,
    logs,
    contextWarningsMarkdown,
    createdAt,
    updatedAt,
    startedAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapter_generation_run_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChapterGenerationRunRecord> instance, {
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
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('chapter_plan_id')) {
      context.handle(
        _chapterPlanIdMeta,
        chapterPlanId.isAcceptableOrUnknown(
          data['chapter_plan_id']!,
          _chapterPlanIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterPlanIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
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
    if (data.containsKey('context_warnings_markdown')) {
      context.handle(
        _contextWarningsMarkdownMeta,
        contextWarningsMarkdown.isAcceptableOrUnknown(
          data['context_warnings_markdown']!,
          _contextWarningsMarkdownMeta,
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
  ChapterGenerationRunRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterGenerationRunRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workflowTaskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workflow_task_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      chapterPlanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_plan_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      ),
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      modelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_name'],
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
      contextWarningsMarkdown: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_warnings_markdown'],
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
  $ChapterGenerationRunRecordsTable createAlias(String alias) {
    return $ChapterGenerationRunRecordsTable(attachedDatabase, alias);
  }
}

class ChapterGenerationRunRecord extends DataClass
    implements Insertable<ChapterGenerationRunRecord> {
  final String id;
  final String workflowTaskId;
  final String projectId;
  final String chapterPlanId;
  final String? chapterId;
  final String providerId;
  final String modelName;
  final String status;
  final String? stage;
  final String? errorMessage;
  final String logs;
  final String contextWarningsMarkdown;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  const ChapterGenerationRunRecord({
    required this.id,
    required this.workflowTaskId,
    required this.projectId,
    required this.chapterPlanId,
    this.chapterId,
    required this.providerId,
    required this.modelName,
    required this.status,
    this.stage,
    this.errorMessage,
    required this.logs,
    required this.contextWarningsMarkdown,
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
    map['project_id'] = Variable<String>(projectId);
    map['chapter_plan_id'] = Variable<String>(chapterPlanId);
    if (!nullToAbsent || chapterId != null) {
      map['chapter_id'] = Variable<String>(chapterId);
    }
    map['provider_id'] = Variable<String>(providerId);
    map['model_name'] = Variable<String>(modelName);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || stage != null) {
      map['stage'] = Variable<String>(stage);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['logs'] = Variable<String>(logs);
    map['context_warnings_markdown'] = Variable<String>(
      contextWarningsMarkdown,
    );
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

  ChapterGenerationRunRecordsCompanion toCompanion(bool nullToAbsent) {
    return ChapterGenerationRunRecordsCompanion(
      id: Value(id),
      workflowTaskId: Value(workflowTaskId),
      projectId: Value(projectId),
      chapterPlanId: Value(chapterPlanId),
      chapterId: chapterId == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterId),
      providerId: Value(providerId),
      modelName: Value(modelName),
      status: Value(status),
      stage: stage == null && nullToAbsent
          ? const Value.absent()
          : Value(stage),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      logs: Value(logs),
      contextWarningsMarkdown: Value(contextWarningsMarkdown),
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

  factory ChapterGenerationRunRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterGenerationRunRecord(
      id: serializer.fromJson<String>(json['id']),
      workflowTaskId: serializer.fromJson<String>(json['workflowTaskId']),
      projectId: serializer.fromJson<String>(json['projectId']),
      chapterPlanId: serializer.fromJson<String>(json['chapterPlanId']),
      chapterId: serializer.fromJson<String?>(json['chapterId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      modelName: serializer.fromJson<String>(json['modelName']),
      status: serializer.fromJson<String>(json['status']),
      stage: serializer.fromJson<String?>(json['stage']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      logs: serializer.fromJson<String>(json['logs']),
      contextWarningsMarkdown: serializer.fromJson<String>(
        json['contextWarningsMarkdown'],
      ),
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
      'projectId': serializer.toJson<String>(projectId),
      'chapterPlanId': serializer.toJson<String>(chapterPlanId),
      'chapterId': serializer.toJson<String?>(chapterId),
      'providerId': serializer.toJson<String>(providerId),
      'modelName': serializer.toJson<String>(modelName),
      'status': serializer.toJson<String>(status),
      'stage': serializer.toJson<String?>(stage),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'logs': serializer.toJson<String>(logs),
      'contextWarningsMarkdown': serializer.toJson<String>(
        contextWarningsMarkdown,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  ChapterGenerationRunRecord copyWith({
    String? id,
    String? workflowTaskId,
    String? projectId,
    String? chapterPlanId,
    Value<String?> chapterId = const Value.absent(),
    String? providerId,
    String? modelName,
    String? status,
    Value<String?> stage = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    String? logs,
    String? contextWarningsMarkdown,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
  }) => ChapterGenerationRunRecord(
    id: id ?? this.id,
    workflowTaskId: workflowTaskId ?? this.workflowTaskId,
    projectId: projectId ?? this.projectId,
    chapterPlanId: chapterPlanId ?? this.chapterPlanId,
    chapterId: chapterId.present ? chapterId.value : this.chapterId,
    providerId: providerId ?? this.providerId,
    modelName: modelName ?? this.modelName,
    status: status ?? this.status,
    stage: stage.present ? stage.value : this.stage,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    logs: logs ?? this.logs,
    contextWarningsMarkdown:
        contextWarningsMarkdown ?? this.contextWarningsMarkdown,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  ChapterGenerationRunRecord copyWithCompanion(
    ChapterGenerationRunRecordsCompanion data,
  ) {
    return ChapterGenerationRunRecord(
      id: data.id.present ? data.id.value : this.id,
      workflowTaskId: data.workflowTaskId.present
          ? data.workflowTaskId.value
          : this.workflowTaskId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      chapterPlanId: data.chapterPlanId.present
          ? data.chapterPlanId.value
          : this.chapterPlanId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      status: data.status.present ? data.status.value : this.status,
      stage: data.stage.present ? data.stage.value : this.stage,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      logs: data.logs.present ? data.logs.value : this.logs,
      contextWarningsMarkdown: data.contextWarningsMarkdown.present
          ? data.contextWarningsMarkdown.value
          : this.contextWarningsMarkdown,
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
    return (StringBuffer('ChapterGenerationRunRecord(')
          ..write('id: $id, ')
          ..write('workflowTaskId: $workflowTaskId, ')
          ..write('projectId: $projectId, ')
          ..write('chapterPlanId: $chapterPlanId, ')
          ..write('chapterId: $chapterId, ')
          ..write('providerId: $providerId, ')
          ..write('modelName: $modelName, ')
          ..write('status: $status, ')
          ..write('stage: $stage, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('logs: $logs, ')
          ..write('contextWarningsMarkdown: $contextWarningsMarkdown, ')
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
    projectId,
    chapterPlanId,
    chapterId,
    providerId,
    modelName,
    status,
    stage,
    errorMessage,
    logs,
    contextWarningsMarkdown,
    createdAt,
    updatedAt,
    startedAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterGenerationRunRecord &&
          other.id == this.id &&
          other.workflowTaskId == this.workflowTaskId &&
          other.projectId == this.projectId &&
          other.chapterPlanId == this.chapterPlanId &&
          other.chapterId == this.chapterId &&
          other.providerId == this.providerId &&
          other.modelName == this.modelName &&
          other.status == this.status &&
          other.stage == this.stage &&
          other.errorMessage == this.errorMessage &&
          other.logs == this.logs &&
          other.contextWarningsMarkdown == this.contextWarningsMarkdown &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt);
}

class ChapterGenerationRunRecordsCompanion
    extends UpdateCompanion<ChapterGenerationRunRecord> {
  final Value<String> id;
  final Value<String> workflowTaskId;
  final Value<String> projectId;
  final Value<String> chapterPlanId;
  final Value<String?> chapterId;
  final Value<String> providerId;
  final Value<String> modelName;
  final Value<String> status;
  final Value<String?> stage;
  final Value<String?> errorMessage;
  final Value<String> logs;
  final Value<String> contextWarningsMarkdown;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const ChapterGenerationRunRecordsCompanion({
    this.id = const Value.absent(),
    this.workflowTaskId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.chapterPlanId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.modelName = const Value.absent(),
    this.status = const Value.absent(),
    this.stage = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.logs = const Value.absent(),
    this.contextWarningsMarkdown = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChapterGenerationRunRecordsCompanion.insert({
    required String id,
    required String workflowTaskId,
    required String projectId,
    required String chapterPlanId,
    this.chapterId = const Value.absent(),
    required String providerId,
    required String modelName,
    required String status,
    this.stage = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.logs = const Value.absent(),
    this.contextWarningsMarkdown = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workflowTaskId = Value(workflowTaskId),
       projectId = Value(projectId),
       chapterPlanId = Value(chapterPlanId),
       providerId = Value(providerId),
       modelName = Value(modelName),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ChapterGenerationRunRecord> custom({
    Expression<String>? id,
    Expression<String>? workflowTaskId,
    Expression<String>? projectId,
    Expression<String>? chapterPlanId,
    Expression<String>? chapterId,
    Expression<String>? providerId,
    Expression<String>? modelName,
    Expression<String>? status,
    Expression<String>? stage,
    Expression<String>? errorMessage,
    Expression<String>? logs,
    Expression<String>? contextWarningsMarkdown,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workflowTaskId != null) 'workflow_task_id': workflowTaskId,
      if (projectId != null) 'project_id': projectId,
      if (chapterPlanId != null) 'chapter_plan_id': chapterPlanId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (providerId != null) 'provider_id': providerId,
      if (modelName != null) 'model_name': modelName,
      if (status != null) 'status': status,
      if (stage != null) 'stage': stage,
      if (errorMessage != null) 'error_message': errorMessage,
      if (logs != null) 'logs': logs,
      if (contextWarningsMarkdown != null)
        'context_warnings_markdown': contextWarningsMarkdown,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChapterGenerationRunRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? workflowTaskId,
    Value<String>? projectId,
    Value<String>? chapterPlanId,
    Value<String?>? chapterId,
    Value<String>? providerId,
    Value<String>? modelName,
    Value<String>? status,
    Value<String?>? stage,
    Value<String?>? errorMessage,
    Value<String>? logs,
    Value<String>? contextWarningsMarkdown,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return ChapterGenerationRunRecordsCompanion(
      id: id ?? this.id,
      workflowTaskId: workflowTaskId ?? this.workflowTaskId,
      projectId: projectId ?? this.projectId,
      chapterPlanId: chapterPlanId ?? this.chapterPlanId,
      chapterId: chapterId ?? this.chapterId,
      providerId: providerId ?? this.providerId,
      modelName: modelName ?? this.modelName,
      status: status ?? this.status,
      stage: stage ?? this.stage,
      errorMessage: errorMessage ?? this.errorMessage,
      logs: logs ?? this.logs,
      contextWarningsMarkdown:
          contextWarningsMarkdown ?? this.contextWarningsMarkdown,
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
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (chapterPlanId.present) {
      map['chapter_plan_id'] = Variable<String>(chapterPlanId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
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
    if (contextWarningsMarkdown.present) {
      map['context_warnings_markdown'] = Variable<String>(
        contextWarningsMarkdown.value,
      );
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
    return (StringBuffer('ChapterGenerationRunRecordsCompanion(')
          ..write('id: $id, ')
          ..write('workflowTaskId: $workflowTaskId, ')
          ..write('projectId: $projectId, ')
          ..write('chapterPlanId: $chapterPlanId, ')
          ..write('chapterId: $chapterId, ')
          ..write('providerId: $providerId, ')
          ..write('modelName: $modelName, ')
          ..write('status: $status, ')
          ..write('stage: $stage, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('logs: $logs, ')
          ..write('contextWarningsMarkdown: $contextWarningsMarkdown, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
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
  late final $ProviderModelRecordsTable providerModelRecords =
      $ProviderModelRecordsTable(this);
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
  late final $ProjectRuntimeMemoryRecordsTable projectRuntimeMemoryRecords =
      $ProjectRuntimeMemoryRecordsTable(this);
  late final $ChapterPlanRecordsTable chapterPlanRecords =
      $ChapterPlanRecordsTable(this);
  late final $ProjectChapterRecordsTable projectChapterRecords =
      $ProjectChapterRecordsTable(this);
  late final $ChapterGenerationRunRecordsTable chapterGenerationRunRecords =
      $ChapterGenerationRunRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    workflowTaskRecords,
    workflowPromptTraceRecords,
    providerConfigRecords,
    providerModelRecords,
    projectRecords,
    styleSampleRecords,
    styleAnalysisRunRecords,
    styleProfileRecords,
    plotSampleRecords,
    plotAnalysisRunRecords,
    plotProfileRecords,
    projectRuntimeMemoryRecords,
    chapterPlanRecords,
    projectChapterRecords,
    chapterGenerationRunRecords,
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

  static MultiTypedResultKey<
    $ChapterGenerationRunRecordsTable,
    List<ChapterGenerationRunRecord>
  >
  _chapterGenerationRunRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.chapterGenerationRunRecords,
        aliasName: $_aliasNameGenerator(
          db.workflowTaskRecords.id,
          db.chapterGenerationRunRecords.workflowTaskId,
        ),
      );

  $$ChapterGenerationRunRecordsTableProcessedTableManager
  get chapterGenerationRunRecordsRefs {
    final manager = $$ChapterGenerationRunRecordsTableTableManager(
      $_db,
      $_db.chapterGenerationRunRecords,
    ).filter((f) => f.workflowTaskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _chapterGenerationRunRecordsRefsTable($_db),
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

  Expression<bool> chapterGenerationRunRecordsRefs(
    Expression<bool> Function(
      $$ChapterGenerationRunRecordsTableFilterComposer f,
    )
    f,
  ) {
    final $$ChapterGenerationRunRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.chapterGenerationRunRecords,
          getReferencedColumn: (t) => t.workflowTaskId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ChapterGenerationRunRecordsTableFilterComposer(
                $db: $db,
                $table: $db.chapterGenerationRunRecords,
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

  Expression<T> chapterGenerationRunRecordsRefs<T extends Object>(
    Expression<T> Function(
      $$ChapterGenerationRunRecordsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$ChapterGenerationRunRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.chapterGenerationRunRecords,
          getReferencedColumn: (t) => t.workflowTaskId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ChapterGenerationRunRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.chapterGenerationRunRecords,
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
            bool chapterGenerationRunRecordsRefs,
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
                chapterGenerationRunRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workflowPromptTraceRecordsRefs)
                      db.workflowPromptTraceRecords,
                    if (styleAnalysisRunRecordsRefs) db.styleAnalysisRunRecords,
                    if (plotAnalysisRunRecordsRefs) db.plotAnalysisRunRecords,
                    if (chapterGenerationRunRecordsRefs)
                      db.chapterGenerationRunRecords,
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
                      if (chapterGenerationRunRecordsRefs)
                        await $_getPrefetchedData<
                          WorkflowTaskRecord,
                          $WorkflowTaskRecordsTable,
                          ChapterGenerationRunRecord
                        >(
                          currentTable: table,
                          referencedTable: $$WorkflowTaskRecordsTableReferences
                              ._chapterGenerationRunRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkflowTaskRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).chapterGenerationRunRecordsRefs,
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
        bool chapterGenerationRunRecordsRefs,
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
    $ProviderModelRecordsTable,
    List<ProviderModelRecord>
  >
  _providerModelRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.providerModelRecords,
        aliasName: $_aliasNameGenerator(
          db.providerConfigRecords.id,
          db.providerModelRecords.providerId,
        ),
      );

  $$ProviderModelRecordsTableProcessedTableManager
  get providerModelRecordsRefs {
    final manager = $$ProviderModelRecordsTableTableManager(
      $_db,
      $_db.providerModelRecords,
    ).filter((f) => f.providerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _providerModelRecordsRefsTable($_db),
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

  Expression<bool> providerModelRecordsRefs(
    Expression<bool> Function($$ProviderModelRecordsTableFilterComposer f) f,
  ) {
    final $$ProviderModelRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.providerModelRecords,
      getReferencedColumn: (t) => t.providerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProviderModelRecordsTableFilterComposer(
            $db: $db,
            $table: $db.providerModelRecords,
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

  Expression<T> providerModelRecordsRefs<T extends Object>(
    Expression<T> Function($$ProviderModelRecordsTableAnnotationComposer a) f,
  ) {
    final $$ProviderModelRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.providerModelRecords,
          getReferencedColumn: (t) => t.providerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProviderModelRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.providerModelRecords,
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
            bool providerModelRecordsRefs,
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
                providerModelRecordsRefs = false,
                styleAnalysisRunRecordsRefs = false,
                styleProfileRecordsRefs = false,
                plotAnalysisRunRecordsRefs = false,
                plotProfileRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (providerModelRecordsRefs) db.providerModelRecords,
                    if (styleAnalysisRunRecordsRefs) db.styleAnalysisRunRecords,
                    if (styleProfileRecordsRefs) db.styleProfileRecords,
                    if (plotAnalysisRunRecordsRefs) db.plotAnalysisRunRecords,
                    if (plotProfileRecordsRefs) db.plotProfileRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (providerModelRecordsRefs)
                        await $_getPrefetchedData<
                          ProviderConfigRecord,
                          $ProviderConfigRecordsTable,
                          ProviderModelRecord
                        >(
                          currentTable: table,
                          referencedTable:
                              $$ProviderConfigRecordsTableReferences
                                  ._providerModelRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProviderConfigRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).providerModelRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.providerId == item.id,
                              ),
                          typedResults: items,
                        ),
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
        bool providerModelRecordsRefs,
        bool styleAnalysisRunRecordsRefs,
        bool styleProfileRecordsRefs,
        bool plotAnalysisRunRecordsRefs,
        bool plotProfileRecordsRefs,
      })
    >;
typedef $$ProviderModelRecordsTableCreateCompanionBuilder =
    ProviderModelRecordsCompanion Function({
      required String providerId,
      required String modelName,
      Value<int> sortOrder,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ProviderModelRecordsTableUpdateCompanionBuilder =
    ProviderModelRecordsCompanion Function({
      Value<String> providerId,
      Value<String> modelName,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ProviderModelRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ProviderModelRecordsTable,
          ProviderModelRecord
        > {
  $$ProviderModelRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProviderConfigRecordsTable _providerIdTable(_$AppDatabase db) =>
      db.providerConfigRecords.createAlias(
        $_aliasNameGenerator(
          db.providerModelRecords.providerId,
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
}

class $$ProviderModelRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ProviderModelRecordsTable> {
  $$ProviderModelRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
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
}

class $$ProviderModelRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProviderModelRecordsTable> {
  $$ProviderModelRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
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

class $$ProviderModelRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProviderModelRecordsTable> {
  $$ProviderModelRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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
}

class $$ProviderModelRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProviderModelRecordsTable,
          ProviderModelRecord,
          $$ProviderModelRecordsTableFilterComposer,
          $$ProviderModelRecordsTableOrderingComposer,
          $$ProviderModelRecordsTableAnnotationComposer,
          $$ProviderModelRecordsTableCreateCompanionBuilder,
          $$ProviderModelRecordsTableUpdateCompanionBuilder,
          (ProviderModelRecord, $$ProviderModelRecordsTableReferences),
          ProviderModelRecord,
          PrefetchHooks Function({bool providerId})
        > {
  $$ProviderModelRecordsTableTableManager(
    _$AppDatabase db,
    $ProviderModelRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProviderModelRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProviderModelRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProviderModelRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> providerId = const Value.absent(),
                Value<String> modelName = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProviderModelRecordsCompanion(
                providerId: providerId,
                modelName: modelName,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String providerId,
                required String modelName,
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProviderModelRecordsCompanion.insert(
                providerId: providerId,
                modelName: modelName,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProviderModelRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({providerId = false}) {
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
                    if (providerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.providerId,
                                referencedTable:
                                    $$ProviderModelRecordsTableReferences
                                        ._providerIdTable(db),
                                referencedColumn:
                                    $$ProviderModelRecordsTableReferences
                                        ._providerIdTable(db)
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

typedef $$ProviderModelRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProviderModelRecordsTable,
      ProviderModelRecord,
      $$ProviderModelRecordsTableFilterComposer,
      $$ProviderModelRecordsTableOrderingComposer,
      $$ProviderModelRecordsTableAnnotationComposer,
      $$ProviderModelRecordsTableCreateCompanionBuilder,
      $$ProviderModelRecordsTableUpdateCompanionBuilder,
      (ProviderModelRecord, $$ProviderModelRecordsTableReferences),
      ProviderModelRecord,
      PrefetchHooks Function({bool providerId})
    >;
typedef $$ProjectRecordsTableCreateCompanionBuilder =
    ProjectRecordsCompanion Function({
      required String id,
      required String title,
      Value<String> description,
      required String status,
      Value<String?> defaultProviderId,
      Value<String?> defaultModelName,
      Value<String?> styleProfileId,
      Value<String?> plotProfileId,
      Value<String> language,
      Value<int> targetLength,
      Value<String> narrativePerspective,
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
      Value<String?> defaultProviderId,
      Value<String?> defaultModelName,
      Value<String?> styleProfileId,
      Value<String?> plotProfileId,
      Value<String> language,
      Value<int> targetLength,
      Value<String> narrativePerspective,
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

  static MultiTypedResultKey<$PlotSampleRecordsTable, List<PlotSampleRecord>>
  _plotSampleRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.plotSampleRecords,
        aliasName: $_aliasNameGenerator(
          db.projectRecords.id,
          db.plotSampleRecords.projectId,
        ),
      );

  $$PlotSampleRecordsTableProcessedTableManager get plotSampleRecordsRefs {
    final manager = $$PlotSampleRecordsTableTableManager(
      $_db,
      $_db.plotSampleRecords,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _plotSampleRecordsRefsTable($_db),
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
          db.projectRecords.id,
          db.plotAnalysisRunRecords.projectId,
        ),
      );

  $$PlotAnalysisRunRecordsTableProcessedTableManager
  get plotAnalysisRunRecordsRefs {
    final manager = $$PlotAnalysisRunRecordsTableTableManager(
      $_db,
      $_db.plotAnalysisRunRecords,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

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
          db.projectRecords.id,
          db.plotProfileRecords.projectId,
        ),
      );

  $$PlotProfileRecordsTableProcessedTableManager get plotProfileRecordsRefs {
    final manager = $$PlotProfileRecordsTableTableManager(
      $_db,
      $_db.plotProfileRecords,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _plotProfileRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChapterPlanRecordsTable, List<ChapterPlanRecord>>
  _chapterPlanRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.chapterPlanRecords,
        aliasName: $_aliasNameGenerator(
          db.projectRecords.id,
          db.chapterPlanRecords.projectId,
        ),
      );

  $$ChapterPlanRecordsTableProcessedTableManager get chapterPlanRecordsRefs {
    final manager = $$ChapterPlanRecordsTableTableManager(
      $_db,
      $_db.chapterPlanRecords,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _chapterPlanRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ProjectChapterRecordsTable,
    List<ProjectChapterRecord>
  >
  _projectChapterRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.projectChapterRecords,
        aliasName: $_aliasNameGenerator(
          db.projectRecords.id,
          db.projectChapterRecords.projectId,
        ),
      );

  $$ProjectChapterRecordsTableProcessedTableManager
  get projectChapterRecordsRefs {
    final manager = $$ProjectChapterRecordsTableTableManager(
      $_db,
      $_db.projectChapterRecords,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _projectChapterRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ChapterGenerationRunRecordsTable,
    List<ChapterGenerationRunRecord>
  >
  _chapterGenerationRunRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.chapterGenerationRunRecords,
        aliasName: $_aliasNameGenerator(
          db.projectRecords.id,
          db.chapterGenerationRunRecords.projectId,
        ),
      );

  $$ChapterGenerationRunRecordsTableProcessedTableManager
  get chapterGenerationRunRecordsRefs {
    final manager = $$ChapterGenerationRunRecordsTableTableManager(
      $_db,
      $_db.chapterGenerationRunRecords,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _chapterGenerationRunRecordsRefsTable($_db),
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

  ColumnFilters<String> get defaultProviderId => $composableBuilder(
    column: $table.defaultProviderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultModelName => $composableBuilder(
    column: $table.defaultModelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get styleProfileId => $composableBuilder(
    column: $table.styleProfileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plotProfileId => $composableBuilder(
    column: $table.plotProfileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetLength => $composableBuilder(
    column: $table.targetLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get narrativePerspective => $composableBuilder(
    column: $table.narrativePerspective,
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

  Expression<bool> plotSampleRecordsRefs(
    Expression<bool> Function($$PlotSampleRecordsTableFilterComposer f) f,
  ) {
    final $$PlotSampleRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plotSampleRecords,
      getReferencedColumn: (t) => t.projectId,
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
          getReferencedColumn: (t) => t.projectId,
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
      getReferencedColumn: (t) => t.projectId,
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

  Expression<bool> chapterPlanRecordsRefs(
    Expression<bool> Function($$ChapterPlanRecordsTableFilterComposer f) f,
  ) {
    final $$ChapterPlanRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chapterPlanRecords,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChapterPlanRecordsTableFilterComposer(
            $db: $db,
            $table: $db.chapterPlanRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> projectChapterRecordsRefs(
    Expression<bool> Function($$ProjectChapterRecordsTableFilterComposer f) f,
  ) {
    final $$ProjectChapterRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.projectChapterRecords,
          getReferencedColumn: (t) => t.projectId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProjectChapterRecordsTableFilterComposer(
                $db: $db,
                $table: $db.projectChapterRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> chapterGenerationRunRecordsRefs(
    Expression<bool> Function(
      $$ChapterGenerationRunRecordsTableFilterComposer f,
    )
    f,
  ) {
    final $$ChapterGenerationRunRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.chapterGenerationRunRecords,
          getReferencedColumn: (t) => t.projectId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ChapterGenerationRunRecordsTableFilterComposer(
                $db: $db,
                $table: $db.chapterGenerationRunRecords,
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

  ColumnOrderings<String> get defaultProviderId => $composableBuilder(
    column: $table.defaultProviderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultModelName => $composableBuilder(
    column: $table.defaultModelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get styleProfileId => $composableBuilder(
    column: $table.styleProfileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plotProfileId => $composableBuilder(
    column: $table.plotProfileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetLength => $composableBuilder(
    column: $table.targetLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get narrativePerspective => $composableBuilder(
    column: $table.narrativePerspective,
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

  GeneratedColumn<String> get defaultProviderId => $composableBuilder(
    column: $table.defaultProviderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultModelName => $composableBuilder(
    column: $table.defaultModelName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get styleProfileId => $composableBuilder(
    column: $table.styleProfileId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plotProfileId => $composableBuilder(
    column: $table.plotProfileId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<int> get targetLength => $composableBuilder(
    column: $table.targetLength,
    builder: (column) => column,
  );

  GeneratedColumn<String> get narrativePerspective => $composableBuilder(
    column: $table.narrativePerspective,
    builder: (column) => column,
  );

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

  Expression<T> plotSampleRecordsRefs<T extends Object>(
    Expression<T> Function($$PlotSampleRecordsTableAnnotationComposer a) f,
  ) {
    final $$PlotSampleRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.plotSampleRecords,
          getReferencedColumn: (t) => t.projectId,
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
          getReferencedColumn: (t) => t.projectId,
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
          getReferencedColumn: (t) => t.projectId,
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

  Expression<T> chapterPlanRecordsRefs<T extends Object>(
    Expression<T> Function($$ChapterPlanRecordsTableAnnotationComposer a) f,
  ) {
    final $$ChapterPlanRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.chapterPlanRecords,
          getReferencedColumn: (t) => t.projectId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ChapterPlanRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.chapterPlanRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> projectChapterRecordsRefs<T extends Object>(
    Expression<T> Function($$ProjectChapterRecordsTableAnnotationComposer a) f,
  ) {
    final $$ProjectChapterRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.projectChapterRecords,
          getReferencedColumn: (t) => t.projectId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProjectChapterRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.projectChapterRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> chapterGenerationRunRecordsRefs<T extends Object>(
    Expression<T> Function(
      $$ChapterGenerationRunRecordsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$ChapterGenerationRunRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.chapterGenerationRunRecords,
          getReferencedColumn: (t) => t.projectId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ChapterGenerationRunRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.chapterGenerationRunRecords,
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
            bool plotSampleRecordsRefs,
            bool plotAnalysisRunRecordsRefs,
            bool plotProfileRecordsRefs,
            bool chapterPlanRecordsRefs,
            bool projectChapterRecordsRefs,
            bool chapterGenerationRunRecordsRefs,
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
                Value<String?> defaultProviderId = const Value.absent(),
                Value<String?> defaultModelName = const Value.absent(),
                Value<String?> styleProfileId = const Value.absent(),
                Value<String?> plotProfileId = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<int> targetLength = const Value.absent(),
                Value<String> narrativePerspective = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectRecordsCompanion(
                id: id,
                title: title,
                description: description,
                status: status,
                defaultProviderId: defaultProviderId,
                defaultModelName: defaultModelName,
                styleProfileId: styleProfileId,
                plotProfileId: plotProfileId,
                language: language,
                targetLength: targetLength,
                narrativePerspective: narrativePerspective,
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
                Value<String?> defaultProviderId = const Value.absent(),
                Value<String?> defaultModelName = const Value.absent(),
                Value<String?> styleProfileId = const Value.absent(),
                Value<String?> plotProfileId = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<int> targetLength = const Value.absent(),
                Value<String> narrativePerspective = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProjectRecordsCompanion.insert(
                id: id,
                title: title,
                description: description,
                status: status,
                defaultProviderId: defaultProviderId,
                defaultModelName: defaultModelName,
                styleProfileId: styleProfileId,
                plotProfileId: plotProfileId,
                language: language,
                targetLength: targetLength,
                narrativePerspective: narrativePerspective,
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
                plotSampleRecordsRefs = false,
                plotAnalysisRunRecordsRefs = false,
                plotProfileRecordsRefs = false,
                chapterPlanRecordsRefs = false,
                projectChapterRecordsRefs = false,
                chapterGenerationRunRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (styleSampleRecordsRefs) db.styleSampleRecords,
                    if (styleAnalysisRunRecordsRefs) db.styleAnalysisRunRecords,
                    if (styleProfileRecordsRefs) db.styleProfileRecords,
                    if (plotSampleRecordsRefs) db.plotSampleRecords,
                    if (plotAnalysisRunRecordsRefs) db.plotAnalysisRunRecords,
                    if (plotProfileRecordsRefs) db.plotProfileRecords,
                    if (chapterPlanRecordsRefs) db.chapterPlanRecords,
                    if (projectChapterRecordsRefs) db.projectChapterRecords,
                    if (chapterGenerationRunRecordsRefs)
                      db.chapterGenerationRunRecords,
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
                      if (plotSampleRecordsRefs)
                        await $_getPrefetchedData<
                          ProjectRecord,
                          $ProjectRecordsTable,
                          PlotSampleRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectRecordsTableReferences
                              ._plotSampleRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).plotSampleRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (plotAnalysisRunRecordsRefs)
                        await $_getPrefetchedData<
                          ProjectRecord,
                          $ProjectRecordsTable,
                          PlotAnalysisRunRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectRecordsTableReferences
                              ._plotAnalysisRunRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).plotAnalysisRunRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (plotProfileRecordsRefs)
                        await $_getPrefetchedData<
                          ProjectRecord,
                          $ProjectRecordsTable,
                          PlotProfileRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectRecordsTableReferences
                              ._plotProfileRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).plotProfileRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (chapterPlanRecordsRefs)
                        await $_getPrefetchedData<
                          ProjectRecord,
                          $ProjectRecordsTable,
                          ChapterPlanRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectRecordsTableReferences
                              ._chapterPlanRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).chapterPlanRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (projectChapterRecordsRefs)
                        await $_getPrefetchedData<
                          ProjectRecord,
                          $ProjectRecordsTable,
                          ProjectChapterRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectRecordsTableReferences
                              ._projectChapterRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).projectChapterRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (chapterGenerationRunRecordsRefs)
                        await $_getPrefetchedData<
                          ProjectRecord,
                          $ProjectRecordsTable,
                          ChapterGenerationRunRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectRecordsTableReferences
                              ._chapterGenerationRunRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).chapterGenerationRunRecordsRefs,
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
        bool plotSampleRecordsRefs,
        bool plotAnalysisRunRecordsRefs,
        bool plotProfileRecordsRefs,
        bool chapterPlanRecordsRefs,
        bool projectChapterRecordsRefs,
        bool chapterGenerationRunRecordsRefs,
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
      Value<String?> projectId,
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
      Value<String?> projectId,
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

  static $ProjectRecordsTable _projectIdTable(_$AppDatabase db) =>
      db.projectRecords.createAlias(
        $_aliasNameGenerator(
          db.plotSampleRecords.projectId,
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
            bool projectId,
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
                Value<String?> projectId = const Value.absent(),
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
                projectId: projectId,
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
                Value<String?> projectId = const Value.absent(),
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
                projectId: projectId,
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
                projectId = false,
                plotAnalysisRunRecordsRefs = false,
                plotProfileRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (plotAnalysisRunRecordsRefs) db.plotAnalysisRunRecords,
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
                        if (projectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.projectId,
                                    referencedTable:
                                        $$PlotSampleRecordsTableReferences
                                            ._projectIdTable(db),
                                    referencedColumn:
                                        $$PlotSampleRecordsTableReferences
                                            ._projectIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
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
        bool projectId,
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
      Value<String?> projectId,
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
      Value<String?> projectId,
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

  static $ProjectRecordsTable _projectIdTable(_$AppDatabase db) =>
      db.projectRecords.createAlias(
        $_aliasNameGenerator(
          db.plotAnalysisRunRecords.projectId,
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
            bool projectId,
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
                Value<String?> projectId = const Value.absent(),
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
                projectId: projectId,
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
                Value<String?> projectId = const Value.absent(),
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
                projectId: projectId,
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
                projectId = false,
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
                        if (projectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.projectId,
                                    referencedTable:
                                        $$PlotAnalysisRunRecordsTableReferences
                                            ._projectIdTable(db),
                                    referencedColumn:
                                        $$PlotAnalysisRunRecordsTableReferences
                                            ._projectIdTable(db)
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
        bool projectId,
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
      Value<String?> projectId,
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
      Value<String?> projectId,
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

  static $ProjectRecordsTable _projectIdTable(_$AppDatabase db) =>
      db.projectRecords.createAlias(
        $_aliasNameGenerator(
          db.plotProfileRecords.projectId,
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
            bool projectId,
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
                Value<String?> projectId = const Value.absent(),
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
                required String plotName,
                required String storyEngineMarkdown,
                required String analysisReportMarkdown,
                required String plotSkeletonMarkdown,
                Value<String?> projectId = const Value.absent(),
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
                  $$PlotProfileRecordsTableReferences(db, table, e),
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
                        if (projectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.projectId,
                                    referencedTable:
                                        $$PlotProfileRecordsTableReferences
                                            ._projectIdTable(db),
                                    referencedColumn:
                                        $$PlotProfileRecordsTableReferences
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
        bool projectId,
        bool sourceSampleId,
      })
    >;
typedef $$ProjectRuntimeMemoryRecordsTableCreateCompanionBuilder =
    ProjectRuntimeMemoryRecordsCompanion Function({
      required String projectId,
      Value<String> charactersStatus,
      Value<String> runtimeState,
      Value<String> runtimeThreads,
      Value<String> storySummary,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ProjectRuntimeMemoryRecordsTableUpdateCompanionBuilder =
    ProjectRuntimeMemoryRecordsCompanion Function({
      Value<String> projectId,
      Value<String> charactersStatus,
      Value<String> runtimeState,
      Value<String> runtimeThreads,
      Value<String> storySummary,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ProjectRuntimeMemoryRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectRuntimeMemoryRecordsTable> {
  $$ProjectRuntimeMemoryRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get charactersStatus => $composableBuilder(
    column: $table.charactersStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get runtimeState => $composableBuilder(
    column: $table.runtimeState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get runtimeThreads => $composableBuilder(
    column: $table.runtimeThreads,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storySummary => $composableBuilder(
    column: $table.storySummary,
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

class $$ProjectRuntimeMemoryRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectRuntimeMemoryRecordsTable> {
  $$ProjectRuntimeMemoryRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get charactersStatus => $composableBuilder(
    column: $table.charactersStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get runtimeState => $composableBuilder(
    column: $table.runtimeState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get runtimeThreads => $composableBuilder(
    column: $table.runtimeThreads,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storySummary => $composableBuilder(
    column: $table.storySummary,
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

class $$ProjectRuntimeMemoryRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectRuntimeMemoryRecordsTable> {
  $$ProjectRuntimeMemoryRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get charactersStatus => $composableBuilder(
    column: $table.charactersStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get runtimeState => $composableBuilder(
    column: $table.runtimeState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get runtimeThreads => $composableBuilder(
    column: $table.runtimeThreads,
    builder: (column) => column,
  );

  GeneratedColumn<String> get storySummary => $composableBuilder(
    column: $table.storySummary,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProjectRuntimeMemoryRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectRuntimeMemoryRecordsTable,
          ProjectRuntimeMemoryRecord,
          $$ProjectRuntimeMemoryRecordsTableFilterComposer,
          $$ProjectRuntimeMemoryRecordsTableOrderingComposer,
          $$ProjectRuntimeMemoryRecordsTableAnnotationComposer,
          $$ProjectRuntimeMemoryRecordsTableCreateCompanionBuilder,
          $$ProjectRuntimeMemoryRecordsTableUpdateCompanionBuilder,
          (
            ProjectRuntimeMemoryRecord,
            BaseReferences<
              _$AppDatabase,
              $ProjectRuntimeMemoryRecordsTable,
              ProjectRuntimeMemoryRecord
            >,
          ),
          ProjectRuntimeMemoryRecord,
          PrefetchHooks Function()
        > {
  $$ProjectRuntimeMemoryRecordsTableTableManager(
    _$AppDatabase db,
    $ProjectRuntimeMemoryRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectRuntimeMemoryRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ProjectRuntimeMemoryRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProjectRuntimeMemoryRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> projectId = const Value.absent(),
                Value<String> charactersStatus = const Value.absent(),
                Value<String> runtimeState = const Value.absent(),
                Value<String> runtimeThreads = const Value.absent(),
                Value<String> storySummary = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectRuntimeMemoryRecordsCompanion(
                projectId: projectId,
                charactersStatus: charactersStatus,
                runtimeState: runtimeState,
                runtimeThreads: runtimeThreads,
                storySummary: storySummary,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String projectId,
                Value<String> charactersStatus = const Value.absent(),
                Value<String> runtimeState = const Value.absent(),
                Value<String> runtimeThreads = const Value.absent(),
                Value<String> storySummary = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProjectRuntimeMemoryRecordsCompanion.insert(
                projectId: projectId,
                charactersStatus: charactersStatus,
                runtimeState: runtimeState,
                runtimeThreads: runtimeThreads,
                storySummary: storySummary,
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

typedef $$ProjectRuntimeMemoryRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectRuntimeMemoryRecordsTable,
      ProjectRuntimeMemoryRecord,
      $$ProjectRuntimeMemoryRecordsTableFilterComposer,
      $$ProjectRuntimeMemoryRecordsTableOrderingComposer,
      $$ProjectRuntimeMemoryRecordsTableAnnotationComposer,
      $$ProjectRuntimeMemoryRecordsTableCreateCompanionBuilder,
      $$ProjectRuntimeMemoryRecordsTableUpdateCompanionBuilder,
      (
        ProjectRuntimeMemoryRecord,
        BaseReferences<
          _$AppDatabase,
          $ProjectRuntimeMemoryRecordsTable,
          ProjectRuntimeMemoryRecord
        >,
      ),
      ProjectRuntimeMemoryRecord,
      PrefetchHooks Function()
    >;
typedef $$ChapterPlanRecordsTableCreateCompanionBuilder =
    ChapterPlanRecordsCompanion Function({
      required String id,
      required String projectId,
      required int chapterIndex,
      Value<String> title,
      Value<String> objective,
      Value<String> pressureSource,
      Value<String> payoffTarget,
      Value<String> relationshipShift,
      Value<String> hookType,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ChapterPlanRecordsTableUpdateCompanionBuilder =
    ChapterPlanRecordsCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<int> chapterIndex,
      Value<String> title,
      Value<String> objective,
      Value<String> pressureSource,
      Value<String> payoffTarget,
      Value<String> relationshipShift,
      Value<String> hookType,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ChapterPlanRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ChapterPlanRecordsTable,
          ChapterPlanRecord
        > {
  $$ChapterPlanRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProjectRecordsTable _projectIdTable(_$AppDatabase db) =>
      db.projectRecords.createAlias(
        $_aliasNameGenerator(
          db.chapterPlanRecords.projectId,
          db.projectRecords.id,
        ),
      );

  $$ProjectRecordsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

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
    $ProjectChapterRecordsTable,
    List<ProjectChapterRecord>
  >
  _projectChapterRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.projectChapterRecords,
        aliasName: $_aliasNameGenerator(
          db.chapterPlanRecords.id,
          db.projectChapterRecords.chapterPlanId,
        ),
      );

  $$ProjectChapterRecordsTableProcessedTableManager
  get projectChapterRecordsRefs {
    final manager = $$ProjectChapterRecordsTableTableManager(
      $_db,
      $_db.projectChapterRecords,
    ).filter((f) => f.chapterPlanId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _projectChapterRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChapterPlanRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ChapterPlanRecordsTable> {
  $$ChapterPlanRecordsTableFilterComposer({
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

  ColumnFilters<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get objective => $composableBuilder(
    column: $table.objective,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pressureSource => $composableBuilder(
    column: $table.pressureSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payoffTarget => $composableBuilder(
    column: $table.payoffTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationshipShift => $composableBuilder(
    column: $table.relationshipShift,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hookType => $composableBuilder(
    column: $table.hookType,
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

  Expression<bool> projectChapterRecordsRefs(
    Expression<bool> Function($$ProjectChapterRecordsTableFilterComposer f) f,
  ) {
    final $$ProjectChapterRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.projectChapterRecords,
          getReferencedColumn: (t) => t.chapterPlanId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProjectChapterRecordsTableFilterComposer(
                $db: $db,
                $table: $db.projectChapterRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ChapterPlanRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChapterPlanRecordsTable> {
  $$ChapterPlanRecordsTableOrderingComposer({
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

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get objective => $composableBuilder(
    column: $table.objective,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pressureSource => $composableBuilder(
    column: $table.pressureSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payoffTarget => $composableBuilder(
    column: $table.payoffTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationshipShift => $composableBuilder(
    column: $table.relationshipShift,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hookType => $composableBuilder(
    column: $table.hookType,
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

class $$ChapterPlanRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChapterPlanRecordsTable> {
  $$ChapterPlanRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get objective =>
      $composableBuilder(column: $table.objective, builder: (column) => column);

  GeneratedColumn<String> get pressureSource => $composableBuilder(
    column: $table.pressureSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payoffTarget => $composableBuilder(
    column: $table.payoffTarget,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relationshipShift => $composableBuilder(
    column: $table.relationshipShift,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hookType =>
      $composableBuilder(column: $table.hookType, builder: (column) => column);

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

  Expression<T> projectChapterRecordsRefs<T extends Object>(
    Expression<T> Function($$ProjectChapterRecordsTableAnnotationComposer a) f,
  ) {
    final $$ProjectChapterRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.projectChapterRecords,
          getReferencedColumn: (t) => t.chapterPlanId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProjectChapterRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.projectChapterRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ChapterPlanRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChapterPlanRecordsTable,
          ChapterPlanRecord,
          $$ChapterPlanRecordsTableFilterComposer,
          $$ChapterPlanRecordsTableOrderingComposer,
          $$ChapterPlanRecordsTableAnnotationComposer,
          $$ChapterPlanRecordsTableCreateCompanionBuilder,
          $$ChapterPlanRecordsTableUpdateCompanionBuilder,
          (ChapterPlanRecord, $$ChapterPlanRecordsTableReferences),
          ChapterPlanRecord,
          PrefetchHooks Function({
            bool projectId,
            bool projectChapterRecordsRefs,
          })
        > {
  $$ChapterPlanRecordsTableTableManager(
    _$AppDatabase db,
    $ChapterPlanRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChapterPlanRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChapterPlanRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChapterPlanRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<int> chapterIndex = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> objective = const Value.absent(),
                Value<String> pressureSource = const Value.absent(),
                Value<String> payoffTarget = const Value.absent(),
                Value<String> relationshipShift = const Value.absent(),
                Value<String> hookType = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChapterPlanRecordsCompanion(
                id: id,
                projectId: projectId,
                chapterIndex: chapterIndex,
                title: title,
                objective: objective,
                pressureSource: pressureSource,
                payoffTarget: payoffTarget,
                relationshipShift: relationshipShift,
                hookType: hookType,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required int chapterIndex,
                Value<String> title = const Value.absent(),
                Value<String> objective = const Value.absent(),
                Value<String> pressureSource = const Value.absent(),
                Value<String> payoffTarget = const Value.absent(),
                Value<String> relationshipShift = const Value.absent(),
                Value<String> hookType = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ChapterPlanRecordsCompanion.insert(
                id: id,
                projectId: projectId,
                chapterIndex: chapterIndex,
                title: title,
                objective: objective,
                pressureSource: pressureSource,
                payoffTarget: payoffTarget,
                relationshipShift: relationshipShift,
                hookType: hookType,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChapterPlanRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({projectId = false, projectChapterRecordsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (projectChapterRecordsRefs) db.projectChapterRecords,
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
                                        $$ChapterPlanRecordsTableReferences
                                            ._projectIdTable(db),
                                    referencedColumn:
                                        $$ChapterPlanRecordsTableReferences
                                            ._projectIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (projectChapterRecordsRefs)
                        await $_getPrefetchedData<
                          ChapterPlanRecord,
                          $ChapterPlanRecordsTable,
                          ProjectChapterRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ChapterPlanRecordsTableReferences
                              ._projectChapterRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChapterPlanRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).projectChapterRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chapterPlanId == item.id,
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

typedef $$ChapterPlanRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChapterPlanRecordsTable,
      ChapterPlanRecord,
      $$ChapterPlanRecordsTableFilterComposer,
      $$ChapterPlanRecordsTableOrderingComposer,
      $$ChapterPlanRecordsTableAnnotationComposer,
      $$ChapterPlanRecordsTableCreateCompanionBuilder,
      $$ChapterPlanRecordsTableUpdateCompanionBuilder,
      (ChapterPlanRecord, $$ChapterPlanRecordsTableReferences),
      ChapterPlanRecord,
      PrefetchHooks Function({bool projectId, bool projectChapterRecordsRefs})
    >;
typedef $$ProjectChapterRecordsTableCreateCompanionBuilder =
    ProjectChapterRecordsCompanion Function({
      required String id,
      required String projectId,
      required String chapterPlanId,
      required int chapterIndex,
      Value<String> title,
      Value<String> contentMarkdown,
      Value<String> contentHash,
      Value<String> continuityVerdict,
      Value<String> continuityReportMarkdown,
      Value<String> memorySyncStatus,
      Value<String> memorySyncContentHash,
      Value<String> memorySyncProposedCharactersStatus,
      Value<String> memorySyncProposedRuntimeState,
      Value<String> memorySyncProposedRuntimeThreads,
      Value<String> memorySyncProposedStorySummary,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ProjectChapterRecordsTableUpdateCompanionBuilder =
    ProjectChapterRecordsCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> chapterPlanId,
      Value<int> chapterIndex,
      Value<String> title,
      Value<String> contentMarkdown,
      Value<String> contentHash,
      Value<String> continuityVerdict,
      Value<String> continuityReportMarkdown,
      Value<String> memorySyncStatus,
      Value<String> memorySyncContentHash,
      Value<String> memorySyncProposedCharactersStatus,
      Value<String> memorySyncProposedRuntimeState,
      Value<String> memorySyncProposedRuntimeThreads,
      Value<String> memorySyncProposedStorySummary,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ProjectChapterRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ProjectChapterRecordsTable,
          ProjectChapterRecord
        > {
  $$ProjectChapterRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProjectRecordsTable _projectIdTable(_$AppDatabase db) =>
      db.projectRecords.createAlias(
        $_aliasNameGenerator(
          db.projectChapterRecords.projectId,
          db.projectRecords.id,
        ),
      );

  $$ProjectRecordsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

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

  static $ChapterPlanRecordsTable _chapterPlanIdTable(_$AppDatabase db) =>
      db.chapterPlanRecords.createAlias(
        $_aliasNameGenerator(
          db.projectChapterRecords.chapterPlanId,
          db.chapterPlanRecords.id,
        ),
      );

  $$ChapterPlanRecordsTableProcessedTableManager get chapterPlanId {
    final $_column = $_itemColumn<String>('chapter_plan_id')!;

    final manager = $$ChapterPlanRecordsTableTableManager(
      $_db,
      $_db.chapterPlanRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chapterPlanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ChapterGenerationRunRecordsTable,
    List<ChapterGenerationRunRecord>
  >
  _chapterGenerationRunRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.chapterGenerationRunRecords,
        aliasName: $_aliasNameGenerator(
          db.projectChapterRecords.id,
          db.chapterGenerationRunRecords.chapterId,
        ),
      );

  $$ChapterGenerationRunRecordsTableProcessedTableManager
  get chapterGenerationRunRecordsRefs {
    final manager = $$ChapterGenerationRunRecordsTableTableManager(
      $_db,
      $_db.chapterGenerationRunRecords,
    ).filter((f) => f.chapterId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _chapterGenerationRunRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProjectChapterRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectChapterRecordsTable> {
  $$ProjectChapterRecordsTableFilterComposer({
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

  ColumnFilters<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentMarkdown => $composableBuilder(
    column: $table.contentMarkdown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get continuityVerdict => $composableBuilder(
    column: $table.continuityVerdict,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get continuityReportMarkdown => $composableBuilder(
    column: $table.continuityReportMarkdown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memorySyncStatus => $composableBuilder(
    column: $table.memorySyncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memorySyncContentHash => $composableBuilder(
    column: $table.memorySyncContentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memorySyncProposedCharactersStatus =>
      $composableBuilder(
        column: $table.memorySyncProposedCharactersStatus,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<String> get memorySyncProposedRuntimeState =>
      $composableBuilder(
        column: $table.memorySyncProposedRuntimeState,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<String> get memorySyncProposedRuntimeThreads =>
      $composableBuilder(
        column: $table.memorySyncProposedRuntimeThreads,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<String> get memorySyncProposedStorySummary =>
      $composableBuilder(
        column: $table.memorySyncProposedStorySummary,
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

  $$ChapterPlanRecordsTableFilterComposer get chapterPlanId {
    final $$ChapterPlanRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterPlanId,
      referencedTable: $db.chapterPlanRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChapterPlanRecordsTableFilterComposer(
            $db: $db,
            $table: $db.chapterPlanRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> chapterGenerationRunRecordsRefs(
    Expression<bool> Function(
      $$ChapterGenerationRunRecordsTableFilterComposer f,
    )
    f,
  ) {
    final $$ChapterGenerationRunRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.chapterGenerationRunRecords,
          getReferencedColumn: (t) => t.chapterId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ChapterGenerationRunRecordsTableFilterComposer(
                $db: $db,
                $table: $db.chapterGenerationRunRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ProjectChapterRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectChapterRecordsTable> {
  $$ProjectChapterRecordsTableOrderingComposer({
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

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentMarkdown => $composableBuilder(
    column: $table.contentMarkdown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get continuityVerdict => $composableBuilder(
    column: $table.continuityVerdict,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get continuityReportMarkdown => $composableBuilder(
    column: $table.continuityReportMarkdown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memorySyncStatus => $composableBuilder(
    column: $table.memorySyncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memorySyncContentHash => $composableBuilder(
    column: $table.memorySyncContentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memorySyncProposedCharactersStatus =>
      $composableBuilder(
        column: $table.memorySyncProposedCharactersStatus,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get memorySyncProposedRuntimeState =>
      $composableBuilder(
        column: $table.memorySyncProposedRuntimeState,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get memorySyncProposedRuntimeThreads =>
      $composableBuilder(
        column: $table.memorySyncProposedRuntimeThreads,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get memorySyncProposedStorySummary =>
      $composableBuilder(
        column: $table.memorySyncProposedStorySummary,
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

  $$ChapterPlanRecordsTableOrderingComposer get chapterPlanId {
    final $$ChapterPlanRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterPlanId,
      referencedTable: $db.chapterPlanRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChapterPlanRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.chapterPlanRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectChapterRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectChapterRecordsTable> {
  $$ProjectChapterRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get contentMarkdown => $composableBuilder(
    column: $table.contentMarkdown,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get continuityVerdict => $composableBuilder(
    column: $table.continuityVerdict,
    builder: (column) => column,
  );

  GeneratedColumn<String> get continuityReportMarkdown => $composableBuilder(
    column: $table.continuityReportMarkdown,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memorySyncStatus => $composableBuilder(
    column: $table.memorySyncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memorySyncContentHash => $composableBuilder(
    column: $table.memorySyncContentHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memorySyncProposedCharactersStatus =>
      $composableBuilder(
        column: $table.memorySyncProposedCharactersStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get memorySyncProposedRuntimeState =>
      $composableBuilder(
        column: $table.memorySyncProposedRuntimeState,
        builder: (column) => column,
      );

  GeneratedColumn<String> get memorySyncProposedRuntimeThreads =>
      $composableBuilder(
        column: $table.memorySyncProposedRuntimeThreads,
        builder: (column) => column,
      );

  GeneratedColumn<String> get memorySyncProposedStorySummary =>
      $composableBuilder(
        column: $table.memorySyncProposedStorySummary,
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

  $$ChapterPlanRecordsTableAnnotationComposer get chapterPlanId {
    final $$ChapterPlanRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.chapterPlanId,
          referencedTable: $db.chapterPlanRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ChapterPlanRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.chapterPlanRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> chapterGenerationRunRecordsRefs<T extends Object>(
    Expression<T> Function(
      $$ChapterGenerationRunRecordsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$ChapterGenerationRunRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.chapterGenerationRunRecords,
          getReferencedColumn: (t) => t.chapterId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ChapterGenerationRunRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.chapterGenerationRunRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ProjectChapterRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectChapterRecordsTable,
          ProjectChapterRecord,
          $$ProjectChapterRecordsTableFilterComposer,
          $$ProjectChapterRecordsTableOrderingComposer,
          $$ProjectChapterRecordsTableAnnotationComposer,
          $$ProjectChapterRecordsTableCreateCompanionBuilder,
          $$ProjectChapterRecordsTableUpdateCompanionBuilder,
          (ProjectChapterRecord, $$ProjectChapterRecordsTableReferences),
          ProjectChapterRecord,
          PrefetchHooks Function({
            bool projectId,
            bool chapterPlanId,
            bool chapterGenerationRunRecordsRefs,
          })
        > {
  $$ProjectChapterRecordsTableTableManager(
    _$AppDatabase db,
    $ProjectChapterRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectChapterRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ProjectChapterRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProjectChapterRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> chapterPlanId = const Value.absent(),
                Value<int> chapterIndex = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> contentMarkdown = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<String> continuityVerdict = const Value.absent(),
                Value<String> continuityReportMarkdown = const Value.absent(),
                Value<String> memorySyncStatus = const Value.absent(),
                Value<String> memorySyncContentHash = const Value.absent(),
                Value<String> memorySyncProposedCharactersStatus =
                    const Value.absent(),
                Value<String> memorySyncProposedRuntimeState =
                    const Value.absent(),
                Value<String> memorySyncProposedRuntimeThreads =
                    const Value.absent(),
                Value<String> memorySyncProposedStorySummary =
                    const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectChapterRecordsCompanion(
                id: id,
                projectId: projectId,
                chapterPlanId: chapterPlanId,
                chapterIndex: chapterIndex,
                title: title,
                contentMarkdown: contentMarkdown,
                contentHash: contentHash,
                continuityVerdict: continuityVerdict,
                continuityReportMarkdown: continuityReportMarkdown,
                memorySyncStatus: memorySyncStatus,
                memorySyncContentHash: memorySyncContentHash,
                memorySyncProposedCharactersStatus:
                    memorySyncProposedCharactersStatus,
                memorySyncProposedRuntimeState: memorySyncProposedRuntimeState,
                memorySyncProposedRuntimeThreads:
                    memorySyncProposedRuntimeThreads,
                memorySyncProposedStorySummary: memorySyncProposedStorySummary,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String chapterPlanId,
                required int chapterIndex,
                Value<String> title = const Value.absent(),
                Value<String> contentMarkdown = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<String> continuityVerdict = const Value.absent(),
                Value<String> continuityReportMarkdown = const Value.absent(),
                Value<String> memorySyncStatus = const Value.absent(),
                Value<String> memorySyncContentHash = const Value.absent(),
                Value<String> memorySyncProposedCharactersStatus =
                    const Value.absent(),
                Value<String> memorySyncProposedRuntimeState =
                    const Value.absent(),
                Value<String> memorySyncProposedRuntimeThreads =
                    const Value.absent(),
                Value<String> memorySyncProposedStorySummary =
                    const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProjectChapterRecordsCompanion.insert(
                id: id,
                projectId: projectId,
                chapterPlanId: chapterPlanId,
                chapterIndex: chapterIndex,
                title: title,
                contentMarkdown: contentMarkdown,
                contentHash: contentHash,
                continuityVerdict: continuityVerdict,
                continuityReportMarkdown: continuityReportMarkdown,
                memorySyncStatus: memorySyncStatus,
                memorySyncContentHash: memorySyncContentHash,
                memorySyncProposedCharactersStatus:
                    memorySyncProposedCharactersStatus,
                memorySyncProposedRuntimeState: memorySyncProposedRuntimeState,
                memorySyncProposedRuntimeThreads:
                    memorySyncProposedRuntimeThreads,
                memorySyncProposedStorySummary: memorySyncProposedStorySummary,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProjectChapterRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                projectId = false,
                chapterPlanId = false,
                chapterGenerationRunRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (chapterGenerationRunRecordsRefs)
                      db.chapterGenerationRunRecords,
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
                                        $$ProjectChapterRecordsTableReferences
                                            ._projectIdTable(db),
                                    referencedColumn:
                                        $$ProjectChapterRecordsTableReferences
                                            ._projectIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (chapterPlanId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.chapterPlanId,
                                    referencedTable:
                                        $$ProjectChapterRecordsTableReferences
                                            ._chapterPlanIdTable(db),
                                    referencedColumn:
                                        $$ProjectChapterRecordsTableReferences
                                            ._chapterPlanIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (chapterGenerationRunRecordsRefs)
                        await $_getPrefetchedData<
                          ProjectChapterRecord,
                          $ProjectChapterRecordsTable,
                          ChapterGenerationRunRecord
                        >(
                          currentTable: table,
                          referencedTable:
                              $$ProjectChapterRecordsTableReferences
                                  ._chapterGenerationRunRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectChapterRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).chapterGenerationRunRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chapterId == item.id,
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

typedef $$ProjectChapterRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectChapterRecordsTable,
      ProjectChapterRecord,
      $$ProjectChapterRecordsTableFilterComposer,
      $$ProjectChapterRecordsTableOrderingComposer,
      $$ProjectChapterRecordsTableAnnotationComposer,
      $$ProjectChapterRecordsTableCreateCompanionBuilder,
      $$ProjectChapterRecordsTableUpdateCompanionBuilder,
      (ProjectChapterRecord, $$ProjectChapterRecordsTableReferences),
      ProjectChapterRecord,
      PrefetchHooks Function({
        bool projectId,
        bool chapterPlanId,
        bool chapterGenerationRunRecordsRefs,
      })
    >;
typedef $$ChapterGenerationRunRecordsTableCreateCompanionBuilder =
    ChapterGenerationRunRecordsCompanion Function({
      required String id,
      required String workflowTaskId,
      required String projectId,
      required String chapterPlanId,
      Value<String?> chapterId,
      required String providerId,
      required String modelName,
      required String status,
      Value<String?> stage,
      Value<String?> errorMessage,
      Value<String> logs,
      Value<String> contextWarningsMarkdown,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$ChapterGenerationRunRecordsTableUpdateCompanionBuilder =
    ChapterGenerationRunRecordsCompanion Function({
      Value<String> id,
      Value<String> workflowTaskId,
      Value<String> projectId,
      Value<String> chapterPlanId,
      Value<String?> chapterId,
      Value<String> providerId,
      Value<String> modelName,
      Value<String> status,
      Value<String?> stage,
      Value<String?> errorMessage,
      Value<String> logs,
      Value<String> contextWarningsMarkdown,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

final class $$ChapterGenerationRunRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ChapterGenerationRunRecordsTable,
          ChapterGenerationRunRecord
        > {
  $$ChapterGenerationRunRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkflowTaskRecordsTable _workflowTaskIdTable(_$AppDatabase db) =>
      db.workflowTaskRecords.createAlias(
        $_aliasNameGenerator(
          db.chapterGenerationRunRecords.workflowTaskId,
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

  static $ProjectRecordsTable _projectIdTable(_$AppDatabase db) =>
      db.projectRecords.createAlias(
        $_aliasNameGenerator(
          db.chapterGenerationRunRecords.projectId,
          db.projectRecords.id,
        ),
      );

  $$ProjectRecordsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

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

  static $ProjectChapterRecordsTable _chapterIdTable(_$AppDatabase db) =>
      db.projectChapterRecords.createAlias(
        $_aliasNameGenerator(
          db.chapterGenerationRunRecords.chapterId,
          db.projectChapterRecords.id,
        ),
      );

  $$ProjectChapterRecordsTableProcessedTableManager? get chapterId {
    final $_column = $_itemColumn<String>('chapter_id');
    if ($_column == null) return null;
    final manager = $$ProjectChapterRecordsTableTableManager(
      $_db,
      $_db.projectChapterRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChapterGenerationRunRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ChapterGenerationRunRecordsTable> {
  $$ChapterGenerationRunRecordsTableFilterComposer({
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

  ColumnFilters<String> get chapterPlanId => $composableBuilder(
    column: $table.chapterPlanId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelName => $composableBuilder(
    column: $table.modelName,
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

  ColumnFilters<String> get contextWarningsMarkdown => $composableBuilder(
    column: $table.contextWarningsMarkdown,
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

  $$ProjectChapterRecordsTableFilterComposer get chapterId {
    final $$ProjectChapterRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.chapterId,
          referencedTable: $db.projectChapterRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProjectChapterRecordsTableFilterComposer(
                $db: $db,
                $table: $db.projectChapterRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ChapterGenerationRunRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChapterGenerationRunRecordsTable> {
  $$ChapterGenerationRunRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get chapterPlanId => $composableBuilder(
    column: $table.chapterPlanId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelName => $composableBuilder(
    column: $table.modelName,
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

  ColumnOrderings<String> get contextWarningsMarkdown => $composableBuilder(
    column: $table.contextWarningsMarkdown,
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

  $$ProjectChapterRecordsTableOrderingComposer get chapterId {
    final $$ProjectChapterRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.chapterId,
          referencedTable: $db.projectChapterRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProjectChapterRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.projectChapterRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ChapterGenerationRunRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChapterGenerationRunRecordsTable> {
  $$ChapterGenerationRunRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get chapterPlanId => $composableBuilder(
    column: $table.chapterPlanId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

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

  GeneratedColumn<String> get contextWarningsMarkdown => $composableBuilder(
    column: $table.contextWarningsMarkdown,
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

  $$ProjectChapterRecordsTableAnnotationComposer get chapterId {
    final $$ProjectChapterRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.chapterId,
          referencedTable: $db.projectChapterRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProjectChapterRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.projectChapterRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ChapterGenerationRunRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChapterGenerationRunRecordsTable,
          ChapterGenerationRunRecord,
          $$ChapterGenerationRunRecordsTableFilterComposer,
          $$ChapterGenerationRunRecordsTableOrderingComposer,
          $$ChapterGenerationRunRecordsTableAnnotationComposer,
          $$ChapterGenerationRunRecordsTableCreateCompanionBuilder,
          $$ChapterGenerationRunRecordsTableUpdateCompanionBuilder,
          (
            ChapterGenerationRunRecord,
            $$ChapterGenerationRunRecordsTableReferences,
          ),
          ChapterGenerationRunRecord,
          PrefetchHooks Function({
            bool workflowTaskId,
            bool projectId,
            bool chapterId,
          })
        > {
  $$ChapterGenerationRunRecordsTableTableManager(
    _$AppDatabase db,
    $ChapterGenerationRunRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChapterGenerationRunRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ChapterGenerationRunRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ChapterGenerationRunRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workflowTaskId = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> chapterPlanId = const Value.absent(),
                Value<String?> chapterId = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> modelName = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> stage = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String> logs = const Value.absent(),
                Value<String> contextWarningsMarkdown = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChapterGenerationRunRecordsCompanion(
                id: id,
                workflowTaskId: workflowTaskId,
                projectId: projectId,
                chapterPlanId: chapterPlanId,
                chapterId: chapterId,
                providerId: providerId,
                modelName: modelName,
                status: status,
                stage: stage,
                errorMessage: errorMessage,
                logs: logs,
                contextWarningsMarkdown: contextWarningsMarkdown,
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
                required String projectId,
                required String chapterPlanId,
                Value<String?> chapterId = const Value.absent(),
                required String providerId,
                required String modelName,
                required String status,
                Value<String?> stage = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String> logs = const Value.absent(),
                Value<String> contextWarningsMarkdown = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChapterGenerationRunRecordsCompanion.insert(
                id: id,
                workflowTaskId: workflowTaskId,
                projectId: projectId,
                chapterPlanId: chapterPlanId,
                chapterId: chapterId,
                providerId: providerId,
                modelName: modelName,
                status: status,
                stage: stage,
                errorMessage: errorMessage,
                logs: logs,
                contextWarningsMarkdown: contextWarningsMarkdown,
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
                  $$ChapterGenerationRunRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workflowTaskId = false, projectId = false, chapterId = false}) {
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
                                    $$ChapterGenerationRunRecordsTableReferences
                                        ._workflowTaskIdTable(db),
                                referencedColumn:
                                    $$ChapterGenerationRunRecordsTableReferences
                                        ._workflowTaskIdTable(db)
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
                                    $$ChapterGenerationRunRecordsTableReferences
                                        ._projectIdTable(db),
                                referencedColumn:
                                    $$ChapterGenerationRunRecordsTableReferences
                                        ._projectIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (chapterId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.chapterId,
                                referencedTable:
                                    $$ChapterGenerationRunRecordsTableReferences
                                        ._chapterIdTable(db),
                                referencedColumn:
                                    $$ChapterGenerationRunRecordsTableReferences
                                        ._chapterIdTable(db)
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

typedef $$ChapterGenerationRunRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChapterGenerationRunRecordsTable,
      ChapterGenerationRunRecord,
      $$ChapterGenerationRunRecordsTableFilterComposer,
      $$ChapterGenerationRunRecordsTableOrderingComposer,
      $$ChapterGenerationRunRecordsTableAnnotationComposer,
      $$ChapterGenerationRunRecordsTableCreateCompanionBuilder,
      $$ChapterGenerationRunRecordsTableUpdateCompanionBuilder,
      (
        ChapterGenerationRunRecord,
        $$ChapterGenerationRunRecordsTableReferences,
      ),
      ChapterGenerationRunRecord,
      PrefetchHooks Function({
        bool workflowTaskId,
        bool projectId,
        bool chapterId,
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
  $$ProviderModelRecordsTableTableManager get providerModelRecords =>
      $$ProviderModelRecordsTableTableManager(_db, _db.providerModelRecords);
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
  $$ProjectRuntimeMemoryRecordsTableTableManager
  get projectRuntimeMemoryRecords =>
      $$ProjectRuntimeMemoryRecordsTableTableManager(
        _db,
        _db.projectRuntimeMemoryRecords,
      );
  $$ChapterPlanRecordsTableTableManager get chapterPlanRecords =>
      $$ChapterPlanRecordsTableTableManager(_db, _db.chapterPlanRecords);
  $$ProjectChapterRecordsTableTableManager get projectChapterRecords =>
      $$ProjectChapterRecordsTableTableManager(_db, _db.projectChapterRecords);
  $$ChapterGenerationRunRecordsTableTableManager
  get chapterGenerationRunRecords =>
      $$ChapterGenerationRunRecordsTableTableManager(
        _db,
        _db.chapterGenerationRunRecords,
      );
}
