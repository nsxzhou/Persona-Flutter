// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chapter_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChapterPlan {

 String get id; String get projectId; int get chapterIndex; String get title; String get goal; String get targetBeat; String get mustInclude; String get mustAvoid; String get hook; String get payoff; ChapterPlanStatus get status; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of ChapterPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChapterPlanCopyWith<ChapterPlan> get copyWith => _$ChapterPlanCopyWithImpl<ChapterPlan>(this as ChapterPlan, _$identity);

  /// Serializes this ChapterPlan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChapterPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.chapterIndex, chapterIndex) || other.chapterIndex == chapterIndex)&&(identical(other.title, title) || other.title == title)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.targetBeat, targetBeat) || other.targetBeat == targetBeat)&&(identical(other.mustInclude, mustInclude) || other.mustInclude == mustInclude)&&(identical(other.mustAvoid, mustAvoid) || other.mustAvoid == mustAvoid)&&(identical(other.hook, hook) || other.hook == hook)&&(identical(other.payoff, payoff) || other.payoff == payoff)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,chapterIndex,title,goal,targetBeat,mustInclude,mustAvoid,hook,payoff,status,createdAt,updatedAt);

@override
String toString() {
  return 'ChapterPlan(id: $id, projectId: $projectId, chapterIndex: $chapterIndex, title: $title, goal: $goal, targetBeat: $targetBeat, mustInclude: $mustInclude, mustAvoid: $mustAvoid, hook: $hook, payoff: $payoff, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ChapterPlanCopyWith<$Res>  {
  factory $ChapterPlanCopyWith(ChapterPlan value, $Res Function(ChapterPlan) _then) = _$ChapterPlanCopyWithImpl;
@useResult
$Res call({
 String id, String projectId, int chapterIndex, String title, String goal, String targetBeat, String mustInclude, String mustAvoid, String hook, String payoff, ChapterPlanStatus status, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$ChapterPlanCopyWithImpl<$Res>
    implements $ChapterPlanCopyWith<$Res> {
  _$ChapterPlanCopyWithImpl(this._self, this._then);

  final ChapterPlan _self;
  final $Res Function(ChapterPlan) _then;

/// Create a copy of ChapterPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? projectId = null,Object? chapterIndex = null,Object? title = null,Object? goal = null,Object? targetBeat = null,Object? mustInclude = null,Object? mustAvoid = null,Object? hook = null,Object? payoff = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,chapterIndex: null == chapterIndex ? _self.chapterIndex : chapterIndex // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as String,targetBeat: null == targetBeat ? _self.targetBeat : targetBeat // ignore: cast_nullable_to_non_nullable
as String,mustInclude: null == mustInclude ? _self.mustInclude : mustInclude // ignore: cast_nullable_to_non_nullable
as String,mustAvoid: null == mustAvoid ? _self.mustAvoid : mustAvoid // ignore: cast_nullable_to_non_nullable
as String,hook: null == hook ? _self.hook : hook // ignore: cast_nullable_to_non_nullable
as String,payoff: null == payoff ? _self.payoff : payoff // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChapterPlanStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ChapterPlan].
extension ChapterPlanPatterns on ChapterPlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChapterPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChapterPlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChapterPlan value)  $default,){
final _that = this;
switch (_that) {
case _ChapterPlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChapterPlan value)?  $default,){
final _that = this;
switch (_that) {
case _ChapterPlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String projectId,  int chapterIndex,  String title,  String goal,  String targetBeat,  String mustInclude,  String mustAvoid,  String hook,  String payoff,  ChapterPlanStatus status,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChapterPlan() when $default != null:
return $default(_that.id,_that.projectId,_that.chapterIndex,_that.title,_that.goal,_that.targetBeat,_that.mustInclude,_that.mustAvoid,_that.hook,_that.payoff,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String projectId,  int chapterIndex,  String title,  String goal,  String targetBeat,  String mustInclude,  String mustAvoid,  String hook,  String payoff,  ChapterPlanStatus status,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ChapterPlan():
return $default(_that.id,_that.projectId,_that.chapterIndex,_that.title,_that.goal,_that.targetBeat,_that.mustInclude,_that.mustAvoid,_that.hook,_that.payoff,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String projectId,  int chapterIndex,  String title,  String goal,  String targetBeat,  String mustInclude,  String mustAvoid,  String hook,  String payoff,  ChapterPlanStatus status,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ChapterPlan() when $default != null:
return $default(_that.id,_that.projectId,_that.chapterIndex,_that.title,_that.goal,_that.targetBeat,_that.mustInclude,_that.mustAvoid,_that.hook,_that.payoff,_that.status,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChapterPlan implements ChapterPlan {
  const _ChapterPlan({required this.id, required this.projectId, required this.chapterIndex, required this.title, this.goal = '', this.targetBeat = '', this.mustInclude = '', this.mustAvoid = '', this.hook = '', this.payoff = '', required this.status, required this.createdAt, required this.updatedAt});
  factory _ChapterPlan.fromJson(Map<String, dynamic> json) => _$ChapterPlanFromJson(json);

@override final  String id;
@override final  String projectId;
@override final  int chapterIndex;
@override final  String title;
@override@JsonKey() final  String goal;
@override@JsonKey() final  String targetBeat;
@override@JsonKey() final  String mustInclude;
@override@JsonKey() final  String mustAvoid;
@override@JsonKey() final  String hook;
@override@JsonKey() final  String payoff;
@override final  ChapterPlanStatus status;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of ChapterPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChapterPlanCopyWith<_ChapterPlan> get copyWith => __$ChapterPlanCopyWithImpl<_ChapterPlan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChapterPlanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChapterPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.chapterIndex, chapterIndex) || other.chapterIndex == chapterIndex)&&(identical(other.title, title) || other.title == title)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.targetBeat, targetBeat) || other.targetBeat == targetBeat)&&(identical(other.mustInclude, mustInclude) || other.mustInclude == mustInclude)&&(identical(other.mustAvoid, mustAvoid) || other.mustAvoid == mustAvoid)&&(identical(other.hook, hook) || other.hook == hook)&&(identical(other.payoff, payoff) || other.payoff == payoff)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,chapterIndex,title,goal,targetBeat,mustInclude,mustAvoid,hook,payoff,status,createdAt,updatedAt);

@override
String toString() {
  return 'ChapterPlan(id: $id, projectId: $projectId, chapterIndex: $chapterIndex, title: $title, goal: $goal, targetBeat: $targetBeat, mustInclude: $mustInclude, mustAvoid: $mustAvoid, hook: $hook, payoff: $payoff, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ChapterPlanCopyWith<$Res> implements $ChapterPlanCopyWith<$Res> {
  factory _$ChapterPlanCopyWith(_ChapterPlan value, $Res Function(_ChapterPlan) _then) = __$ChapterPlanCopyWithImpl;
@override @useResult
$Res call({
 String id, String projectId, int chapterIndex, String title, String goal, String targetBeat, String mustInclude, String mustAvoid, String hook, String payoff, ChapterPlanStatus status, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$ChapterPlanCopyWithImpl<$Res>
    implements _$ChapterPlanCopyWith<$Res> {
  __$ChapterPlanCopyWithImpl(this._self, this._then);

  final _ChapterPlan _self;
  final $Res Function(_ChapterPlan) _then;

/// Create a copy of ChapterPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? projectId = null,Object? chapterIndex = null,Object? title = null,Object? goal = null,Object? targetBeat = null,Object? mustInclude = null,Object? mustAvoid = null,Object? hook = null,Object? payoff = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ChapterPlan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,chapterIndex: null == chapterIndex ? _self.chapterIndex : chapterIndex // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as String,targetBeat: null == targetBeat ? _self.targetBeat : targetBeat // ignore: cast_nullable_to_non_nullable
as String,mustInclude: null == mustInclude ? _self.mustInclude : mustInclude // ignore: cast_nullable_to_non_nullable
as String,mustAvoid: null == mustAvoid ? _self.mustAvoid : mustAvoid // ignore: cast_nullable_to_non_nullable
as String,hook: null == hook ? _self.hook : hook // ignore: cast_nullable_to_non_nullable
as String,payoff: null == payoff ? _self.payoff : payoff // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChapterPlanStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
