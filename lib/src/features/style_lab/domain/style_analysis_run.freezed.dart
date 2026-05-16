// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'style_analysis_run.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StyleAnalysisRun {

 String get id; String get workflowTaskId; String get sampleId; String get providerId; String get modelName; String get styleName; String? get projectId; StyleAnalysisStatus get status; StyleAnalysisStage? get stage; String? get errorMessage; String get logs; String? get analysisReportMarkdown; String? get voiceProfileMarkdown; String? get profileId; int get chunkCount; int get characterCount; DateTime get createdAt; DateTime get updatedAt; DateTime? get startedAt; DateTime? get completedAt;
/// Create a copy of StyleAnalysisRun
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StyleAnalysisRunCopyWith<StyleAnalysisRun> get copyWith => _$StyleAnalysisRunCopyWithImpl<StyleAnalysisRun>(this as StyleAnalysisRun, _$identity);

  /// Serializes this StyleAnalysisRun to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StyleAnalysisRun&&(identical(other.id, id) || other.id == id)&&(identical(other.workflowTaskId, workflowTaskId) || other.workflowTaskId == workflowTaskId)&&(identical(other.sampleId, sampleId) || other.sampleId == sampleId)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.styleName, styleName) || other.styleName == styleName)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.status, status) || other.status == status)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.logs, logs) || other.logs == logs)&&(identical(other.analysisReportMarkdown, analysisReportMarkdown) || other.analysisReportMarkdown == analysisReportMarkdown)&&(identical(other.voiceProfileMarkdown, voiceProfileMarkdown) || other.voiceProfileMarkdown == voiceProfileMarkdown)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.chunkCount, chunkCount) || other.chunkCount == chunkCount)&&(identical(other.characterCount, characterCount) || other.characterCount == characterCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,workflowTaskId,sampleId,providerId,modelName,styleName,projectId,status,stage,errorMessage,logs,analysisReportMarkdown,voiceProfileMarkdown,profileId,chunkCount,characterCount,createdAt,updatedAt,startedAt,completedAt]);

@override
String toString() {
  return 'StyleAnalysisRun(id: $id, workflowTaskId: $workflowTaskId, sampleId: $sampleId, providerId: $providerId, modelName: $modelName, styleName: $styleName, projectId: $projectId, status: $status, stage: $stage, errorMessage: $errorMessage, logs: $logs, analysisReportMarkdown: $analysisReportMarkdown, voiceProfileMarkdown: $voiceProfileMarkdown, profileId: $profileId, chunkCount: $chunkCount, characterCount: $characterCount, createdAt: $createdAt, updatedAt: $updatedAt, startedAt: $startedAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $StyleAnalysisRunCopyWith<$Res>  {
  factory $StyleAnalysisRunCopyWith(StyleAnalysisRun value, $Res Function(StyleAnalysisRun) _then) = _$StyleAnalysisRunCopyWithImpl;
@useResult
$Res call({
 String id, String workflowTaskId, String sampleId, String providerId, String modelName, String styleName, String? projectId, StyleAnalysisStatus status, StyleAnalysisStage? stage, String? errorMessage, String logs, String? analysisReportMarkdown, String? voiceProfileMarkdown, String? profileId, int chunkCount, int characterCount, DateTime createdAt, DateTime updatedAt, DateTime? startedAt, DateTime? completedAt
});




}
/// @nodoc
class _$StyleAnalysisRunCopyWithImpl<$Res>
    implements $StyleAnalysisRunCopyWith<$Res> {
  _$StyleAnalysisRunCopyWithImpl(this._self, this._then);

  final StyleAnalysisRun _self;
  final $Res Function(StyleAnalysisRun) _then;

/// Create a copy of StyleAnalysisRun
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workflowTaskId = null,Object? sampleId = null,Object? providerId = null,Object? modelName = null,Object? styleName = null,Object? projectId = freezed,Object? status = null,Object? stage = freezed,Object? errorMessage = freezed,Object? logs = null,Object? analysisReportMarkdown = freezed,Object? voiceProfileMarkdown = freezed,Object? profileId = freezed,Object? chunkCount = null,Object? characterCount = null,Object? createdAt = null,Object? updatedAt = null,Object? startedAt = freezed,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workflowTaskId: null == workflowTaskId ? _self.workflowTaskId : workflowTaskId // ignore: cast_nullable_to_non_nullable
as String,sampleId: null == sampleId ? _self.sampleId : sampleId // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,styleName: null == styleName ? _self.styleName : styleName // ignore: cast_nullable_to_non_nullable
as String,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StyleAnalysisStatus,stage: freezed == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as StyleAnalysisStage?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,logs: null == logs ? _self.logs : logs // ignore: cast_nullable_to_non_nullable
as String,analysisReportMarkdown: freezed == analysisReportMarkdown ? _self.analysisReportMarkdown : analysisReportMarkdown // ignore: cast_nullable_to_non_nullable
as String?,voiceProfileMarkdown: freezed == voiceProfileMarkdown ? _self.voiceProfileMarkdown : voiceProfileMarkdown // ignore: cast_nullable_to_non_nullable
as String?,profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String?,chunkCount: null == chunkCount ? _self.chunkCount : chunkCount // ignore: cast_nullable_to_non_nullable
as int,characterCount: null == characterCount ? _self.characterCount : characterCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [StyleAnalysisRun].
extension StyleAnalysisRunPatterns on StyleAnalysisRun {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StyleAnalysisRun value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StyleAnalysisRun() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StyleAnalysisRun value)  $default,){
final _that = this;
switch (_that) {
case _StyleAnalysisRun():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StyleAnalysisRun value)?  $default,){
final _that = this;
switch (_that) {
case _StyleAnalysisRun() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String workflowTaskId,  String sampleId,  String providerId,  String modelName,  String styleName,  String? projectId,  StyleAnalysisStatus status,  StyleAnalysisStage? stage,  String? errorMessage,  String logs,  String? analysisReportMarkdown,  String? voiceProfileMarkdown,  String? profileId,  int chunkCount,  int characterCount,  DateTime createdAt,  DateTime updatedAt,  DateTime? startedAt,  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StyleAnalysisRun() when $default != null:
return $default(_that.id,_that.workflowTaskId,_that.sampleId,_that.providerId,_that.modelName,_that.styleName,_that.projectId,_that.status,_that.stage,_that.errorMessage,_that.logs,_that.analysisReportMarkdown,_that.voiceProfileMarkdown,_that.profileId,_that.chunkCount,_that.characterCount,_that.createdAt,_that.updatedAt,_that.startedAt,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String workflowTaskId,  String sampleId,  String providerId,  String modelName,  String styleName,  String? projectId,  StyleAnalysisStatus status,  StyleAnalysisStage? stage,  String? errorMessage,  String logs,  String? analysisReportMarkdown,  String? voiceProfileMarkdown,  String? profileId,  int chunkCount,  int characterCount,  DateTime createdAt,  DateTime updatedAt,  DateTime? startedAt,  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _StyleAnalysisRun():
return $default(_that.id,_that.workflowTaskId,_that.sampleId,_that.providerId,_that.modelName,_that.styleName,_that.projectId,_that.status,_that.stage,_that.errorMessage,_that.logs,_that.analysisReportMarkdown,_that.voiceProfileMarkdown,_that.profileId,_that.chunkCount,_that.characterCount,_that.createdAt,_that.updatedAt,_that.startedAt,_that.completedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String workflowTaskId,  String sampleId,  String providerId,  String modelName,  String styleName,  String? projectId,  StyleAnalysisStatus status,  StyleAnalysisStage? stage,  String? errorMessage,  String logs,  String? analysisReportMarkdown,  String? voiceProfileMarkdown,  String? profileId,  int chunkCount,  int characterCount,  DateTime createdAt,  DateTime updatedAt,  DateTime? startedAt,  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _StyleAnalysisRun() when $default != null:
return $default(_that.id,_that.workflowTaskId,_that.sampleId,_that.providerId,_that.modelName,_that.styleName,_that.projectId,_that.status,_that.stage,_that.errorMessage,_that.logs,_that.analysisReportMarkdown,_that.voiceProfileMarkdown,_that.profileId,_that.chunkCount,_that.characterCount,_that.createdAt,_that.updatedAt,_that.startedAt,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StyleAnalysisRun implements StyleAnalysisRun {
  const _StyleAnalysisRun({required this.id, required this.workflowTaskId, required this.sampleId, required this.providerId, required this.modelName, required this.styleName, this.projectId, required this.status, this.stage, this.errorMessage, this.logs = '', this.analysisReportMarkdown, this.voiceProfileMarkdown, this.profileId, required this.chunkCount, required this.characterCount, required this.createdAt, required this.updatedAt, this.startedAt, this.completedAt});
  factory _StyleAnalysisRun.fromJson(Map<String, dynamic> json) => _$StyleAnalysisRunFromJson(json);

@override final  String id;
@override final  String workflowTaskId;
@override final  String sampleId;
@override final  String providerId;
@override final  String modelName;
@override final  String styleName;
@override final  String? projectId;
@override final  StyleAnalysisStatus status;
@override final  StyleAnalysisStage? stage;
@override final  String? errorMessage;
@override@JsonKey() final  String logs;
@override final  String? analysisReportMarkdown;
@override final  String? voiceProfileMarkdown;
@override final  String? profileId;
@override final  int chunkCount;
@override final  int characterCount;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? startedAt;
@override final  DateTime? completedAt;

/// Create a copy of StyleAnalysisRun
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StyleAnalysisRunCopyWith<_StyleAnalysisRun> get copyWith => __$StyleAnalysisRunCopyWithImpl<_StyleAnalysisRun>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StyleAnalysisRunToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StyleAnalysisRun&&(identical(other.id, id) || other.id == id)&&(identical(other.workflowTaskId, workflowTaskId) || other.workflowTaskId == workflowTaskId)&&(identical(other.sampleId, sampleId) || other.sampleId == sampleId)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.styleName, styleName) || other.styleName == styleName)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.status, status) || other.status == status)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.logs, logs) || other.logs == logs)&&(identical(other.analysisReportMarkdown, analysisReportMarkdown) || other.analysisReportMarkdown == analysisReportMarkdown)&&(identical(other.voiceProfileMarkdown, voiceProfileMarkdown) || other.voiceProfileMarkdown == voiceProfileMarkdown)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.chunkCount, chunkCount) || other.chunkCount == chunkCount)&&(identical(other.characterCount, characterCount) || other.characterCount == characterCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,workflowTaskId,sampleId,providerId,modelName,styleName,projectId,status,stage,errorMessage,logs,analysisReportMarkdown,voiceProfileMarkdown,profileId,chunkCount,characterCount,createdAt,updatedAt,startedAt,completedAt]);

@override
String toString() {
  return 'StyleAnalysisRun(id: $id, workflowTaskId: $workflowTaskId, sampleId: $sampleId, providerId: $providerId, modelName: $modelName, styleName: $styleName, projectId: $projectId, status: $status, stage: $stage, errorMessage: $errorMessage, logs: $logs, analysisReportMarkdown: $analysisReportMarkdown, voiceProfileMarkdown: $voiceProfileMarkdown, profileId: $profileId, chunkCount: $chunkCount, characterCount: $characterCount, createdAt: $createdAt, updatedAt: $updatedAt, startedAt: $startedAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$StyleAnalysisRunCopyWith<$Res> implements $StyleAnalysisRunCopyWith<$Res> {
  factory _$StyleAnalysisRunCopyWith(_StyleAnalysisRun value, $Res Function(_StyleAnalysisRun) _then) = __$StyleAnalysisRunCopyWithImpl;
@override @useResult
$Res call({
 String id, String workflowTaskId, String sampleId, String providerId, String modelName, String styleName, String? projectId, StyleAnalysisStatus status, StyleAnalysisStage? stage, String? errorMessage, String logs, String? analysisReportMarkdown, String? voiceProfileMarkdown, String? profileId, int chunkCount, int characterCount, DateTime createdAt, DateTime updatedAt, DateTime? startedAt, DateTime? completedAt
});




}
/// @nodoc
class __$StyleAnalysisRunCopyWithImpl<$Res>
    implements _$StyleAnalysisRunCopyWith<$Res> {
  __$StyleAnalysisRunCopyWithImpl(this._self, this._then);

  final _StyleAnalysisRun _self;
  final $Res Function(_StyleAnalysisRun) _then;

/// Create a copy of StyleAnalysisRun
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workflowTaskId = null,Object? sampleId = null,Object? providerId = null,Object? modelName = null,Object? styleName = null,Object? projectId = freezed,Object? status = null,Object? stage = freezed,Object? errorMessage = freezed,Object? logs = null,Object? analysisReportMarkdown = freezed,Object? voiceProfileMarkdown = freezed,Object? profileId = freezed,Object? chunkCount = null,Object? characterCount = null,Object? createdAt = null,Object? updatedAt = null,Object? startedAt = freezed,Object? completedAt = freezed,}) {
  return _then(_StyleAnalysisRun(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workflowTaskId: null == workflowTaskId ? _self.workflowTaskId : workflowTaskId // ignore: cast_nullable_to_non_nullable
as String,sampleId: null == sampleId ? _self.sampleId : sampleId // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,styleName: null == styleName ? _self.styleName : styleName // ignore: cast_nullable_to_non_nullable
as String,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StyleAnalysisStatus,stage: freezed == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as StyleAnalysisStage?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,logs: null == logs ? _self.logs : logs // ignore: cast_nullable_to_non_nullable
as String,analysisReportMarkdown: freezed == analysisReportMarkdown ? _self.analysisReportMarkdown : analysisReportMarkdown // ignore: cast_nullable_to_non_nullable
as String?,voiceProfileMarkdown: freezed == voiceProfileMarkdown ? _self.voiceProfileMarkdown : voiceProfileMarkdown // ignore: cast_nullable_to_non_nullable
as String?,profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String?,chunkCount: null == chunkCount ? _self.chunkCount : chunkCount // ignore: cast_nullable_to_non_nullable
as int,characterCount: null == characterCount ? _self.characterCount : characterCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
