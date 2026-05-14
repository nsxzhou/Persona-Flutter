// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workflow_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkflowTask {

 String get id; String get kind; WorkflowTaskStatus get status; String get title; String? get stage; String? get errorMessage; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of WorkflowTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkflowTaskCopyWith<WorkflowTask> get copyWith => _$WorkflowTaskCopyWithImpl<WorkflowTask>(this as WorkflowTask, _$identity);

  /// Serializes this WorkflowTask to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkflowTask&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.status, status) || other.status == status)&&(identical(other.title, title) || other.title == title)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,kind,status,title,stage,errorMessage,createdAt,updatedAt);

@override
String toString() {
  return 'WorkflowTask(id: $id, kind: $kind, status: $status, title: $title, stage: $stage, errorMessage: $errorMessage, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $WorkflowTaskCopyWith<$Res>  {
  factory $WorkflowTaskCopyWith(WorkflowTask value, $Res Function(WorkflowTask) _then) = _$WorkflowTaskCopyWithImpl;
@useResult
$Res call({
 String id, String kind, WorkflowTaskStatus status, String title, String? stage, String? errorMessage, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$WorkflowTaskCopyWithImpl<$Res>
    implements $WorkflowTaskCopyWith<$Res> {
  _$WorkflowTaskCopyWithImpl(this._self, this._then);

  final WorkflowTask _self;
  final $Res Function(WorkflowTask) _then;

/// Create a copy of WorkflowTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? status = null,Object? title = null,Object? stage = freezed,Object? errorMessage = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as WorkflowTaskStatus,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,stage: freezed == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkflowTask].
extension WorkflowTaskPatterns on WorkflowTask {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkflowTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkflowTask() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkflowTask value)  $default,){
final _that = this;
switch (_that) {
case _WorkflowTask():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkflowTask value)?  $default,){
final _that = this;
switch (_that) {
case _WorkflowTask() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String kind,  WorkflowTaskStatus status,  String title,  String? stage,  String? errorMessage,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkflowTask() when $default != null:
return $default(_that.id,_that.kind,_that.status,_that.title,_that.stage,_that.errorMessage,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String kind,  WorkflowTaskStatus status,  String title,  String? stage,  String? errorMessage,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _WorkflowTask():
return $default(_that.id,_that.kind,_that.status,_that.title,_that.stage,_that.errorMessage,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String kind,  WorkflowTaskStatus status,  String title,  String? stage,  String? errorMessage,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _WorkflowTask() when $default != null:
return $default(_that.id,_that.kind,_that.status,_that.title,_that.stage,_that.errorMessage,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkflowTask implements WorkflowTask {
  const _WorkflowTask({required this.id, required this.kind, required this.status, required this.title, this.stage, this.errorMessage, required this.createdAt, required this.updatedAt});
  factory _WorkflowTask.fromJson(Map<String, dynamic> json) => _$WorkflowTaskFromJson(json);

@override final  String id;
@override final  String kind;
@override final  WorkflowTaskStatus status;
@override final  String title;
@override final  String? stage;
@override final  String? errorMessage;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of WorkflowTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkflowTaskCopyWith<_WorkflowTask> get copyWith => __$WorkflowTaskCopyWithImpl<_WorkflowTask>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkflowTaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkflowTask&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.status, status) || other.status == status)&&(identical(other.title, title) || other.title == title)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,kind,status,title,stage,errorMessage,createdAt,updatedAt);

@override
String toString() {
  return 'WorkflowTask(id: $id, kind: $kind, status: $status, title: $title, stage: $stage, errorMessage: $errorMessage, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$WorkflowTaskCopyWith<$Res> implements $WorkflowTaskCopyWith<$Res> {
  factory _$WorkflowTaskCopyWith(_WorkflowTask value, $Res Function(_WorkflowTask) _then) = __$WorkflowTaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String kind, WorkflowTaskStatus status, String title, String? stage, String? errorMessage, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$WorkflowTaskCopyWithImpl<$Res>
    implements _$WorkflowTaskCopyWith<$Res> {
  __$WorkflowTaskCopyWithImpl(this._self, this._then);

  final _WorkflowTask _self;
  final $Res Function(_WorkflowTask) _then;

/// Create a copy of WorkflowTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? status = null,Object? title = null,Object? stage = freezed,Object? errorMessage = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_WorkflowTask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as WorkflowTaskStatus,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,stage: freezed == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
