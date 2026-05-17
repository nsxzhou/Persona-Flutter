// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plot_analysis_run.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlotAnalysisRun {

 String get id; String get workflowTaskId; String get sampleId; String get providerId; String get modelName; String get plotName; String? get projectId; PlotAnalysisStatus get status; PlotAnalysisStage? get stage; String? get errorMessage; String get logs; String? get analysisReportMarkdown; String? get plotSkeletonMarkdown; String? get storyEngineMarkdown; String? get profileId; int get chunkCount; int get characterCount; DateTime get createdAt; DateTime get updatedAt; DateTime? get startedAt; DateTime? get completedAt;
/// Create a copy of PlotAnalysisRun
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlotAnalysisRunCopyWith<PlotAnalysisRun> get copyWith => _$PlotAnalysisRunCopyWithImpl<PlotAnalysisRun>(this as PlotAnalysisRun, _$identity);

  /// Serializes this PlotAnalysisRun to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlotAnalysisRun&&(identical(other.id, id) || other.id == id)&&(identical(other.workflowTaskId, workflowTaskId) || other.workflowTaskId == workflowTaskId)&&(identical(other.sampleId, sampleId) || other.sampleId == sampleId)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.plotName, plotName) || other.plotName == plotName)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.status, status) || other.status == status)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.logs, logs) || other.logs == logs)&&(identical(other.analysisReportMarkdown, analysisReportMarkdown) || other.analysisReportMarkdown == analysisReportMarkdown)&&(identical(other.plotSkeletonMarkdown, plotSkeletonMarkdown) || other.plotSkeletonMarkdown == plotSkeletonMarkdown)&&(identical(other.storyEngineMarkdown, storyEngineMarkdown) || other.storyEngineMarkdown == storyEngineMarkdown)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.chunkCount, chunkCount) || other.chunkCount == chunkCount)&&(identical(other.characterCount, characterCount) || other.characterCount == characterCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,workflowTaskId,sampleId,providerId,modelName,plotName,projectId,status,stage,errorMessage,logs,analysisReportMarkdown,plotSkeletonMarkdown,storyEngineMarkdown,profileId,chunkCount,characterCount,createdAt,updatedAt,startedAt,completedAt]);

@override
String toString() {
  return 'PlotAnalysisRun(id: $id, workflowTaskId: $workflowTaskId, sampleId: $sampleId, providerId: $providerId, modelName: $modelName, plotName: $plotName, projectId: $projectId, status: $status, stage: $stage, errorMessage: $errorMessage, logs: $logs, analysisReportMarkdown: $analysisReportMarkdown, plotSkeletonMarkdown: $plotSkeletonMarkdown, storyEngineMarkdown: $storyEngineMarkdown, profileId: $profileId, chunkCount: $chunkCount, characterCount: $characterCount, createdAt: $createdAt, updatedAt: $updatedAt, startedAt: $startedAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $PlotAnalysisRunCopyWith<$Res>  {
  factory $PlotAnalysisRunCopyWith(PlotAnalysisRun value, $Res Function(PlotAnalysisRun) _then) = _$PlotAnalysisRunCopyWithImpl;
@useResult
$Res call({
 String id, String workflowTaskId, String sampleId, String providerId, String modelName, String plotName, String? projectId, PlotAnalysisStatus status, PlotAnalysisStage? stage, String? errorMessage, String logs, String? analysisReportMarkdown, String? plotSkeletonMarkdown, String? storyEngineMarkdown, String? profileId, int chunkCount, int characterCount, DateTime createdAt, DateTime updatedAt, DateTime? startedAt, DateTime? completedAt
});




}
/// @nodoc
class _$PlotAnalysisRunCopyWithImpl<$Res>
    implements $PlotAnalysisRunCopyWith<$Res> {
  _$PlotAnalysisRunCopyWithImpl(this._self, this._then);

  final PlotAnalysisRun _self;
  final $Res Function(PlotAnalysisRun) _then;

/// Create a copy of PlotAnalysisRun
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workflowTaskId = null,Object? sampleId = null,Object? providerId = null,Object? modelName = null,Object? plotName = null,Object? projectId = freezed,Object? status = null,Object? stage = freezed,Object? errorMessage = freezed,Object? logs = null,Object? analysisReportMarkdown = freezed,Object? plotSkeletonMarkdown = freezed,Object? storyEngineMarkdown = freezed,Object? profileId = freezed,Object? chunkCount = null,Object? characterCount = null,Object? createdAt = null,Object? updatedAt = null,Object? startedAt = freezed,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workflowTaskId: null == workflowTaskId ? _self.workflowTaskId : workflowTaskId // ignore: cast_nullable_to_non_nullable
as String,sampleId: null == sampleId ? _self.sampleId : sampleId // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,plotName: null == plotName ? _self.plotName : plotName // ignore: cast_nullable_to_non_nullable
as String,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PlotAnalysisStatus,stage: freezed == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as PlotAnalysisStage?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,logs: null == logs ? _self.logs : logs // ignore: cast_nullable_to_non_nullable
as String,analysisReportMarkdown: freezed == analysisReportMarkdown ? _self.analysisReportMarkdown : analysisReportMarkdown // ignore: cast_nullable_to_non_nullable
as String?,plotSkeletonMarkdown: freezed == plotSkeletonMarkdown ? _self.plotSkeletonMarkdown : plotSkeletonMarkdown // ignore: cast_nullable_to_non_nullable
as String?,storyEngineMarkdown: freezed == storyEngineMarkdown ? _self.storyEngineMarkdown : storyEngineMarkdown // ignore: cast_nullable_to_non_nullable
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


/// Adds pattern-matching-related methods to [PlotAnalysisRun].
extension PlotAnalysisRunPatterns on PlotAnalysisRun {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlotAnalysisRun value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlotAnalysisRun() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlotAnalysisRun value)  $default,){
final _that = this;
switch (_that) {
case _PlotAnalysisRun():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlotAnalysisRun value)?  $default,){
final _that = this;
switch (_that) {
case _PlotAnalysisRun() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String workflowTaskId,  String sampleId,  String providerId,  String modelName,  String plotName,  String? projectId,  PlotAnalysisStatus status,  PlotAnalysisStage? stage,  String? errorMessage,  String logs,  String? analysisReportMarkdown,  String? plotSkeletonMarkdown,  String? storyEngineMarkdown,  String? profileId,  int chunkCount,  int characterCount,  DateTime createdAt,  DateTime updatedAt,  DateTime? startedAt,  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlotAnalysisRun() when $default != null:
return $default(_that.id,_that.workflowTaskId,_that.sampleId,_that.providerId,_that.modelName,_that.plotName,_that.projectId,_that.status,_that.stage,_that.errorMessage,_that.logs,_that.analysisReportMarkdown,_that.plotSkeletonMarkdown,_that.storyEngineMarkdown,_that.profileId,_that.chunkCount,_that.characterCount,_that.createdAt,_that.updatedAt,_that.startedAt,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String workflowTaskId,  String sampleId,  String providerId,  String modelName,  String plotName,  String? projectId,  PlotAnalysisStatus status,  PlotAnalysisStage? stage,  String? errorMessage,  String logs,  String? analysisReportMarkdown,  String? plotSkeletonMarkdown,  String? storyEngineMarkdown,  String? profileId,  int chunkCount,  int characterCount,  DateTime createdAt,  DateTime updatedAt,  DateTime? startedAt,  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _PlotAnalysisRun():
return $default(_that.id,_that.workflowTaskId,_that.sampleId,_that.providerId,_that.modelName,_that.plotName,_that.projectId,_that.status,_that.stage,_that.errorMessage,_that.logs,_that.analysisReportMarkdown,_that.plotSkeletonMarkdown,_that.storyEngineMarkdown,_that.profileId,_that.chunkCount,_that.characterCount,_that.createdAt,_that.updatedAt,_that.startedAt,_that.completedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String workflowTaskId,  String sampleId,  String providerId,  String modelName,  String plotName,  String? projectId,  PlotAnalysisStatus status,  PlotAnalysisStage? stage,  String? errorMessage,  String logs,  String? analysisReportMarkdown,  String? plotSkeletonMarkdown,  String? storyEngineMarkdown,  String? profileId,  int chunkCount,  int characterCount,  DateTime createdAt,  DateTime updatedAt,  DateTime? startedAt,  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _PlotAnalysisRun() when $default != null:
return $default(_that.id,_that.workflowTaskId,_that.sampleId,_that.providerId,_that.modelName,_that.plotName,_that.projectId,_that.status,_that.stage,_that.errorMessage,_that.logs,_that.analysisReportMarkdown,_that.plotSkeletonMarkdown,_that.storyEngineMarkdown,_that.profileId,_that.chunkCount,_that.characterCount,_that.createdAt,_that.updatedAt,_that.startedAt,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlotAnalysisRun implements PlotAnalysisRun {
  const _PlotAnalysisRun({required this.id, required this.workflowTaskId, required this.sampleId, required this.providerId, required this.modelName, required this.plotName, this.projectId, required this.status, this.stage, this.errorMessage, this.logs = '', this.analysisReportMarkdown, this.plotSkeletonMarkdown, this.storyEngineMarkdown, this.profileId, required this.chunkCount, required this.characterCount, required this.createdAt, required this.updatedAt, this.startedAt, this.completedAt});
  factory _PlotAnalysisRun.fromJson(Map<String, dynamic> json) => _$PlotAnalysisRunFromJson(json);

@override final  String id;
@override final  String workflowTaskId;
@override final  String sampleId;
@override final  String providerId;
@override final  String modelName;
@override final  String plotName;
@override final  String? projectId;
@override final  PlotAnalysisStatus status;
@override final  PlotAnalysisStage? stage;
@override final  String? errorMessage;
@override@JsonKey() final  String logs;
@override final  String? analysisReportMarkdown;
@override final  String? plotSkeletonMarkdown;
@override final  String? storyEngineMarkdown;
@override final  String? profileId;
@override final  int chunkCount;
@override final  int characterCount;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? startedAt;
@override final  DateTime? completedAt;

/// Create a copy of PlotAnalysisRun
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlotAnalysisRunCopyWith<_PlotAnalysisRun> get copyWith => __$PlotAnalysisRunCopyWithImpl<_PlotAnalysisRun>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlotAnalysisRunToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlotAnalysisRun&&(identical(other.id, id) || other.id == id)&&(identical(other.workflowTaskId, workflowTaskId) || other.workflowTaskId == workflowTaskId)&&(identical(other.sampleId, sampleId) || other.sampleId == sampleId)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.plotName, plotName) || other.plotName == plotName)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.status, status) || other.status == status)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.logs, logs) || other.logs == logs)&&(identical(other.analysisReportMarkdown, analysisReportMarkdown) || other.analysisReportMarkdown == analysisReportMarkdown)&&(identical(other.plotSkeletonMarkdown, plotSkeletonMarkdown) || other.plotSkeletonMarkdown == plotSkeletonMarkdown)&&(identical(other.storyEngineMarkdown, storyEngineMarkdown) || other.storyEngineMarkdown == storyEngineMarkdown)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.chunkCount, chunkCount) || other.chunkCount == chunkCount)&&(identical(other.characterCount, characterCount) || other.characterCount == characterCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,workflowTaskId,sampleId,providerId,modelName,plotName,projectId,status,stage,errorMessage,logs,analysisReportMarkdown,plotSkeletonMarkdown,storyEngineMarkdown,profileId,chunkCount,characterCount,createdAt,updatedAt,startedAt,completedAt]);

@override
String toString() {
  return 'PlotAnalysisRun(id: $id, workflowTaskId: $workflowTaskId, sampleId: $sampleId, providerId: $providerId, modelName: $modelName, plotName: $plotName, projectId: $projectId, status: $status, stage: $stage, errorMessage: $errorMessage, logs: $logs, analysisReportMarkdown: $analysisReportMarkdown, plotSkeletonMarkdown: $plotSkeletonMarkdown, storyEngineMarkdown: $storyEngineMarkdown, profileId: $profileId, chunkCount: $chunkCount, characterCount: $characterCount, createdAt: $createdAt, updatedAt: $updatedAt, startedAt: $startedAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$PlotAnalysisRunCopyWith<$Res> implements $PlotAnalysisRunCopyWith<$Res> {
  factory _$PlotAnalysisRunCopyWith(_PlotAnalysisRun value, $Res Function(_PlotAnalysisRun) _then) = __$PlotAnalysisRunCopyWithImpl;
@override @useResult
$Res call({
 String id, String workflowTaskId, String sampleId, String providerId, String modelName, String plotName, String? projectId, PlotAnalysisStatus status, PlotAnalysisStage? stage, String? errorMessage, String logs, String? analysisReportMarkdown, String? plotSkeletonMarkdown, String? storyEngineMarkdown, String? profileId, int chunkCount, int characterCount, DateTime createdAt, DateTime updatedAt, DateTime? startedAt, DateTime? completedAt
});




}
/// @nodoc
class __$PlotAnalysisRunCopyWithImpl<$Res>
    implements _$PlotAnalysisRunCopyWith<$Res> {
  __$PlotAnalysisRunCopyWithImpl(this._self, this._then);

  final _PlotAnalysisRun _self;
  final $Res Function(_PlotAnalysisRun) _then;

/// Create a copy of PlotAnalysisRun
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workflowTaskId = null,Object? sampleId = null,Object? providerId = null,Object? modelName = null,Object? plotName = null,Object? projectId = freezed,Object? status = null,Object? stage = freezed,Object? errorMessage = freezed,Object? logs = null,Object? analysisReportMarkdown = freezed,Object? plotSkeletonMarkdown = freezed,Object? storyEngineMarkdown = freezed,Object? profileId = freezed,Object? chunkCount = null,Object? characterCount = null,Object? createdAt = null,Object? updatedAt = null,Object? startedAt = freezed,Object? completedAt = freezed,}) {
  return _then(_PlotAnalysisRun(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workflowTaskId: null == workflowTaskId ? _self.workflowTaskId : workflowTaskId // ignore: cast_nullable_to_non_nullable
as String,sampleId: null == sampleId ? _self.sampleId : sampleId // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,plotName: null == plotName ? _self.plotName : plotName // ignore: cast_nullable_to_non_nullable
as String,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PlotAnalysisStatus,stage: freezed == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as PlotAnalysisStage?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,logs: null == logs ? _self.logs : logs // ignore: cast_nullable_to_non_nullable
as String,analysisReportMarkdown: freezed == analysisReportMarkdown ? _self.analysisReportMarkdown : analysisReportMarkdown // ignore: cast_nullable_to_non_nullable
as String?,plotSkeletonMarkdown: freezed == plotSkeletonMarkdown ? _self.plotSkeletonMarkdown : plotSkeletonMarkdown // ignore: cast_nullable_to_non_nullable
as String?,storyEngineMarkdown: freezed == storyEngineMarkdown ? _self.storyEngineMarkdown : storyEngineMarkdown // ignore: cast_nullable_to_non_nullable
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
