// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chapter_draft_run.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChapterDraftRun {

 String get id; String get workflowTaskId; String get projectId; String get chapterPlanId; String get providerId; String get modelName; ChapterDraftRunStatus get status; ChapterDraftRunStage? get stage; String get contractMarkdown; String get draftMarkdown; String get auditMarkdown; String get revisedMarkdown; String? get errorMessage; String get logs; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of ChapterDraftRun
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChapterDraftRunCopyWith<ChapterDraftRun> get copyWith => _$ChapterDraftRunCopyWithImpl<ChapterDraftRun>(this as ChapterDraftRun, _$identity);

  /// Serializes this ChapterDraftRun to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChapterDraftRun&&(identical(other.id, id) || other.id == id)&&(identical(other.workflowTaskId, workflowTaskId) || other.workflowTaskId == workflowTaskId)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.chapterPlanId, chapterPlanId) || other.chapterPlanId == chapterPlanId)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.status, status) || other.status == status)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.contractMarkdown, contractMarkdown) || other.contractMarkdown == contractMarkdown)&&(identical(other.draftMarkdown, draftMarkdown) || other.draftMarkdown == draftMarkdown)&&(identical(other.auditMarkdown, auditMarkdown) || other.auditMarkdown == auditMarkdown)&&(identical(other.revisedMarkdown, revisedMarkdown) || other.revisedMarkdown == revisedMarkdown)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.logs, logs) || other.logs == logs)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workflowTaskId,projectId,chapterPlanId,providerId,modelName,status,stage,contractMarkdown,draftMarkdown,auditMarkdown,revisedMarkdown,errorMessage,logs,createdAt,updatedAt);

@override
String toString() {
  return 'ChapterDraftRun(id: $id, workflowTaskId: $workflowTaskId, projectId: $projectId, chapterPlanId: $chapterPlanId, providerId: $providerId, modelName: $modelName, status: $status, stage: $stage, contractMarkdown: $contractMarkdown, draftMarkdown: $draftMarkdown, auditMarkdown: $auditMarkdown, revisedMarkdown: $revisedMarkdown, errorMessage: $errorMessage, logs: $logs, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ChapterDraftRunCopyWith<$Res>  {
  factory $ChapterDraftRunCopyWith(ChapterDraftRun value, $Res Function(ChapterDraftRun) _then) = _$ChapterDraftRunCopyWithImpl;
@useResult
$Res call({
 String id, String workflowTaskId, String projectId, String chapterPlanId, String providerId, String modelName, ChapterDraftRunStatus status, ChapterDraftRunStage? stage, String contractMarkdown, String draftMarkdown, String auditMarkdown, String revisedMarkdown, String? errorMessage, String logs, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$ChapterDraftRunCopyWithImpl<$Res>
    implements $ChapterDraftRunCopyWith<$Res> {
  _$ChapterDraftRunCopyWithImpl(this._self, this._then);

  final ChapterDraftRun _self;
  final $Res Function(ChapterDraftRun) _then;

/// Create a copy of ChapterDraftRun
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workflowTaskId = null,Object? projectId = null,Object? chapterPlanId = null,Object? providerId = null,Object? modelName = null,Object? status = null,Object? stage = freezed,Object? contractMarkdown = null,Object? draftMarkdown = null,Object? auditMarkdown = null,Object? revisedMarkdown = null,Object? errorMessage = freezed,Object? logs = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workflowTaskId: null == workflowTaskId ? _self.workflowTaskId : workflowTaskId // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,chapterPlanId: null == chapterPlanId ? _self.chapterPlanId : chapterPlanId // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChapterDraftRunStatus,stage: freezed == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as ChapterDraftRunStage?,contractMarkdown: null == contractMarkdown ? _self.contractMarkdown : contractMarkdown // ignore: cast_nullable_to_non_nullable
as String,draftMarkdown: null == draftMarkdown ? _self.draftMarkdown : draftMarkdown // ignore: cast_nullable_to_non_nullable
as String,auditMarkdown: null == auditMarkdown ? _self.auditMarkdown : auditMarkdown // ignore: cast_nullable_to_non_nullable
as String,revisedMarkdown: null == revisedMarkdown ? _self.revisedMarkdown : revisedMarkdown // ignore: cast_nullable_to_non_nullable
as String,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,logs: null == logs ? _self.logs : logs // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ChapterDraftRun].
extension ChapterDraftRunPatterns on ChapterDraftRun {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChapterDraftRun value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChapterDraftRun() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChapterDraftRun value)  $default,){
final _that = this;
switch (_that) {
case _ChapterDraftRun():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChapterDraftRun value)?  $default,){
final _that = this;
switch (_that) {
case _ChapterDraftRun() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String workflowTaskId,  String projectId,  String chapterPlanId,  String providerId,  String modelName,  ChapterDraftRunStatus status,  ChapterDraftRunStage? stage,  String contractMarkdown,  String draftMarkdown,  String auditMarkdown,  String revisedMarkdown,  String? errorMessage,  String logs,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChapterDraftRun() when $default != null:
return $default(_that.id,_that.workflowTaskId,_that.projectId,_that.chapterPlanId,_that.providerId,_that.modelName,_that.status,_that.stage,_that.contractMarkdown,_that.draftMarkdown,_that.auditMarkdown,_that.revisedMarkdown,_that.errorMessage,_that.logs,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String workflowTaskId,  String projectId,  String chapterPlanId,  String providerId,  String modelName,  ChapterDraftRunStatus status,  ChapterDraftRunStage? stage,  String contractMarkdown,  String draftMarkdown,  String auditMarkdown,  String revisedMarkdown,  String? errorMessage,  String logs,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ChapterDraftRun():
return $default(_that.id,_that.workflowTaskId,_that.projectId,_that.chapterPlanId,_that.providerId,_that.modelName,_that.status,_that.stage,_that.contractMarkdown,_that.draftMarkdown,_that.auditMarkdown,_that.revisedMarkdown,_that.errorMessage,_that.logs,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String workflowTaskId,  String projectId,  String chapterPlanId,  String providerId,  String modelName,  ChapterDraftRunStatus status,  ChapterDraftRunStage? stage,  String contractMarkdown,  String draftMarkdown,  String auditMarkdown,  String revisedMarkdown,  String? errorMessage,  String logs,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ChapterDraftRun() when $default != null:
return $default(_that.id,_that.workflowTaskId,_that.projectId,_that.chapterPlanId,_that.providerId,_that.modelName,_that.status,_that.stage,_that.contractMarkdown,_that.draftMarkdown,_that.auditMarkdown,_that.revisedMarkdown,_that.errorMessage,_that.logs,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChapterDraftRun implements ChapterDraftRun {
  const _ChapterDraftRun({required this.id, required this.workflowTaskId, required this.projectId, required this.chapterPlanId, required this.providerId, required this.modelName, required this.status, this.stage, this.contractMarkdown = '', this.draftMarkdown = '', this.auditMarkdown = '', this.revisedMarkdown = '', this.errorMessage, this.logs = '', required this.createdAt, required this.updatedAt});
  factory _ChapterDraftRun.fromJson(Map<String, dynamic> json) => _$ChapterDraftRunFromJson(json);

@override final  String id;
@override final  String workflowTaskId;
@override final  String projectId;
@override final  String chapterPlanId;
@override final  String providerId;
@override final  String modelName;
@override final  ChapterDraftRunStatus status;
@override final  ChapterDraftRunStage? stage;
@override@JsonKey() final  String contractMarkdown;
@override@JsonKey() final  String draftMarkdown;
@override@JsonKey() final  String auditMarkdown;
@override@JsonKey() final  String revisedMarkdown;
@override final  String? errorMessage;
@override@JsonKey() final  String logs;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of ChapterDraftRun
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChapterDraftRunCopyWith<_ChapterDraftRun> get copyWith => __$ChapterDraftRunCopyWithImpl<_ChapterDraftRun>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChapterDraftRunToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChapterDraftRun&&(identical(other.id, id) || other.id == id)&&(identical(other.workflowTaskId, workflowTaskId) || other.workflowTaskId == workflowTaskId)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.chapterPlanId, chapterPlanId) || other.chapterPlanId == chapterPlanId)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.status, status) || other.status == status)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.contractMarkdown, contractMarkdown) || other.contractMarkdown == contractMarkdown)&&(identical(other.draftMarkdown, draftMarkdown) || other.draftMarkdown == draftMarkdown)&&(identical(other.auditMarkdown, auditMarkdown) || other.auditMarkdown == auditMarkdown)&&(identical(other.revisedMarkdown, revisedMarkdown) || other.revisedMarkdown == revisedMarkdown)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.logs, logs) || other.logs == logs)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workflowTaskId,projectId,chapterPlanId,providerId,modelName,status,stage,contractMarkdown,draftMarkdown,auditMarkdown,revisedMarkdown,errorMessage,logs,createdAt,updatedAt);

@override
String toString() {
  return 'ChapterDraftRun(id: $id, workflowTaskId: $workflowTaskId, projectId: $projectId, chapterPlanId: $chapterPlanId, providerId: $providerId, modelName: $modelName, status: $status, stage: $stage, contractMarkdown: $contractMarkdown, draftMarkdown: $draftMarkdown, auditMarkdown: $auditMarkdown, revisedMarkdown: $revisedMarkdown, errorMessage: $errorMessage, logs: $logs, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ChapterDraftRunCopyWith<$Res> implements $ChapterDraftRunCopyWith<$Res> {
  factory _$ChapterDraftRunCopyWith(_ChapterDraftRun value, $Res Function(_ChapterDraftRun) _then) = __$ChapterDraftRunCopyWithImpl;
@override @useResult
$Res call({
 String id, String workflowTaskId, String projectId, String chapterPlanId, String providerId, String modelName, ChapterDraftRunStatus status, ChapterDraftRunStage? stage, String contractMarkdown, String draftMarkdown, String auditMarkdown, String revisedMarkdown, String? errorMessage, String logs, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$ChapterDraftRunCopyWithImpl<$Res>
    implements _$ChapterDraftRunCopyWith<$Res> {
  __$ChapterDraftRunCopyWithImpl(this._self, this._then);

  final _ChapterDraftRun _self;
  final $Res Function(_ChapterDraftRun) _then;

/// Create a copy of ChapterDraftRun
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workflowTaskId = null,Object? projectId = null,Object? chapterPlanId = null,Object? providerId = null,Object? modelName = null,Object? status = null,Object? stage = freezed,Object? contractMarkdown = null,Object? draftMarkdown = null,Object? auditMarkdown = null,Object? revisedMarkdown = null,Object? errorMessage = freezed,Object? logs = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ChapterDraftRun(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workflowTaskId: null == workflowTaskId ? _self.workflowTaskId : workflowTaskId // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,chapterPlanId: null == chapterPlanId ? _self.chapterPlanId : chapterPlanId // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChapterDraftRunStatus,stage: freezed == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as ChapterDraftRunStage?,contractMarkdown: null == contractMarkdown ? _self.contractMarkdown : contractMarkdown // ignore: cast_nullable_to_non_nullable
as String,draftMarkdown: null == draftMarkdown ? _self.draftMarkdown : draftMarkdown // ignore: cast_nullable_to_non_nullable
as String,auditMarkdown: null == auditMarkdown ? _self.auditMarkdown : auditMarkdown // ignore: cast_nullable_to_non_nullable
as String,revisedMarkdown: null == revisedMarkdown ? _self.revisedMarkdown : revisedMarkdown // ignore: cast_nullable_to_non_nullable
as String,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,logs: null == logs ? _self.logs : logs // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
