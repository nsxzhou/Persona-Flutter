// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'memory_projection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MemoryProjection {

 String get id; String get projectId; String get recentSummary; String get globalSummary; String get factLedgerMarkdown; String get characterStatesMarkdown; String get unresolvedHooksMarkdown; String? get updatedFromChapterId; DateTime get updatedAt;
/// Create a copy of MemoryProjection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemoryProjectionCopyWith<MemoryProjection> get copyWith => _$MemoryProjectionCopyWithImpl<MemoryProjection>(this as MemoryProjection, _$identity);

  /// Serializes this MemoryProjection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemoryProjection&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.recentSummary, recentSummary) || other.recentSummary == recentSummary)&&(identical(other.globalSummary, globalSummary) || other.globalSummary == globalSummary)&&(identical(other.factLedgerMarkdown, factLedgerMarkdown) || other.factLedgerMarkdown == factLedgerMarkdown)&&(identical(other.characterStatesMarkdown, characterStatesMarkdown) || other.characterStatesMarkdown == characterStatesMarkdown)&&(identical(other.unresolvedHooksMarkdown, unresolvedHooksMarkdown) || other.unresolvedHooksMarkdown == unresolvedHooksMarkdown)&&(identical(other.updatedFromChapterId, updatedFromChapterId) || other.updatedFromChapterId == updatedFromChapterId)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,recentSummary,globalSummary,factLedgerMarkdown,characterStatesMarkdown,unresolvedHooksMarkdown,updatedFromChapterId,updatedAt);

@override
String toString() {
  return 'MemoryProjection(id: $id, projectId: $projectId, recentSummary: $recentSummary, globalSummary: $globalSummary, factLedgerMarkdown: $factLedgerMarkdown, characterStatesMarkdown: $characterStatesMarkdown, unresolvedHooksMarkdown: $unresolvedHooksMarkdown, updatedFromChapterId: $updatedFromChapterId, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MemoryProjectionCopyWith<$Res>  {
  factory $MemoryProjectionCopyWith(MemoryProjection value, $Res Function(MemoryProjection) _then) = _$MemoryProjectionCopyWithImpl;
@useResult
$Res call({
 String id, String projectId, String recentSummary, String globalSummary, String factLedgerMarkdown, String characterStatesMarkdown, String unresolvedHooksMarkdown, String? updatedFromChapterId, DateTime updatedAt
});




}
/// @nodoc
class _$MemoryProjectionCopyWithImpl<$Res>
    implements $MemoryProjectionCopyWith<$Res> {
  _$MemoryProjectionCopyWithImpl(this._self, this._then);

  final MemoryProjection _self;
  final $Res Function(MemoryProjection) _then;

/// Create a copy of MemoryProjection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? projectId = null,Object? recentSummary = null,Object? globalSummary = null,Object? factLedgerMarkdown = null,Object? characterStatesMarkdown = null,Object? unresolvedHooksMarkdown = null,Object? updatedFromChapterId = freezed,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,recentSummary: null == recentSummary ? _self.recentSummary : recentSummary // ignore: cast_nullable_to_non_nullable
as String,globalSummary: null == globalSummary ? _self.globalSummary : globalSummary // ignore: cast_nullable_to_non_nullable
as String,factLedgerMarkdown: null == factLedgerMarkdown ? _self.factLedgerMarkdown : factLedgerMarkdown // ignore: cast_nullable_to_non_nullable
as String,characterStatesMarkdown: null == characterStatesMarkdown ? _self.characterStatesMarkdown : characterStatesMarkdown // ignore: cast_nullable_to_non_nullable
as String,unresolvedHooksMarkdown: null == unresolvedHooksMarkdown ? _self.unresolvedHooksMarkdown : unresolvedHooksMarkdown // ignore: cast_nullable_to_non_nullable
as String,updatedFromChapterId: freezed == updatedFromChapterId ? _self.updatedFromChapterId : updatedFromChapterId // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MemoryProjection].
extension MemoryProjectionPatterns on MemoryProjection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemoryProjection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemoryProjection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemoryProjection value)  $default,){
final _that = this;
switch (_that) {
case _MemoryProjection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemoryProjection value)?  $default,){
final _that = this;
switch (_that) {
case _MemoryProjection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String projectId,  String recentSummary,  String globalSummary,  String factLedgerMarkdown,  String characterStatesMarkdown,  String unresolvedHooksMarkdown,  String? updatedFromChapterId,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemoryProjection() when $default != null:
return $default(_that.id,_that.projectId,_that.recentSummary,_that.globalSummary,_that.factLedgerMarkdown,_that.characterStatesMarkdown,_that.unresolvedHooksMarkdown,_that.updatedFromChapterId,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String projectId,  String recentSummary,  String globalSummary,  String factLedgerMarkdown,  String characterStatesMarkdown,  String unresolvedHooksMarkdown,  String? updatedFromChapterId,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MemoryProjection():
return $default(_that.id,_that.projectId,_that.recentSummary,_that.globalSummary,_that.factLedgerMarkdown,_that.characterStatesMarkdown,_that.unresolvedHooksMarkdown,_that.updatedFromChapterId,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String projectId,  String recentSummary,  String globalSummary,  String factLedgerMarkdown,  String characterStatesMarkdown,  String unresolvedHooksMarkdown,  String? updatedFromChapterId,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MemoryProjection() when $default != null:
return $default(_that.id,_that.projectId,_that.recentSummary,_that.globalSummary,_that.factLedgerMarkdown,_that.characterStatesMarkdown,_that.unresolvedHooksMarkdown,_that.updatedFromChapterId,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemoryProjection implements MemoryProjection {
  const _MemoryProjection({required this.id, required this.projectId, this.recentSummary = '', this.globalSummary = '', this.factLedgerMarkdown = '', this.characterStatesMarkdown = '', this.unresolvedHooksMarkdown = '', this.updatedFromChapterId, required this.updatedAt});
  factory _MemoryProjection.fromJson(Map<String, dynamic> json) => _$MemoryProjectionFromJson(json);

@override final  String id;
@override final  String projectId;
@override@JsonKey() final  String recentSummary;
@override@JsonKey() final  String globalSummary;
@override@JsonKey() final  String factLedgerMarkdown;
@override@JsonKey() final  String characterStatesMarkdown;
@override@JsonKey() final  String unresolvedHooksMarkdown;
@override final  String? updatedFromChapterId;
@override final  DateTime updatedAt;

/// Create a copy of MemoryProjection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemoryProjectionCopyWith<_MemoryProjection> get copyWith => __$MemoryProjectionCopyWithImpl<_MemoryProjection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemoryProjectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemoryProjection&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.recentSummary, recentSummary) || other.recentSummary == recentSummary)&&(identical(other.globalSummary, globalSummary) || other.globalSummary == globalSummary)&&(identical(other.factLedgerMarkdown, factLedgerMarkdown) || other.factLedgerMarkdown == factLedgerMarkdown)&&(identical(other.characterStatesMarkdown, characterStatesMarkdown) || other.characterStatesMarkdown == characterStatesMarkdown)&&(identical(other.unresolvedHooksMarkdown, unresolvedHooksMarkdown) || other.unresolvedHooksMarkdown == unresolvedHooksMarkdown)&&(identical(other.updatedFromChapterId, updatedFromChapterId) || other.updatedFromChapterId == updatedFromChapterId)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,recentSummary,globalSummary,factLedgerMarkdown,characterStatesMarkdown,unresolvedHooksMarkdown,updatedFromChapterId,updatedAt);

@override
String toString() {
  return 'MemoryProjection(id: $id, projectId: $projectId, recentSummary: $recentSummary, globalSummary: $globalSummary, factLedgerMarkdown: $factLedgerMarkdown, characterStatesMarkdown: $characterStatesMarkdown, unresolvedHooksMarkdown: $unresolvedHooksMarkdown, updatedFromChapterId: $updatedFromChapterId, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MemoryProjectionCopyWith<$Res> implements $MemoryProjectionCopyWith<$Res> {
  factory _$MemoryProjectionCopyWith(_MemoryProjection value, $Res Function(_MemoryProjection) _then) = __$MemoryProjectionCopyWithImpl;
@override @useResult
$Res call({
 String id, String projectId, String recentSummary, String globalSummary, String factLedgerMarkdown, String characterStatesMarkdown, String unresolvedHooksMarkdown, String? updatedFromChapterId, DateTime updatedAt
});




}
/// @nodoc
class __$MemoryProjectionCopyWithImpl<$Res>
    implements _$MemoryProjectionCopyWith<$Res> {
  __$MemoryProjectionCopyWithImpl(this._self, this._then);

  final _MemoryProjection _self;
  final $Res Function(_MemoryProjection) _then;

/// Create a copy of MemoryProjection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? projectId = null,Object? recentSummary = null,Object? globalSummary = null,Object? factLedgerMarkdown = null,Object? characterStatesMarkdown = null,Object? unresolvedHooksMarkdown = null,Object? updatedFromChapterId = freezed,Object? updatedAt = null,}) {
  return _then(_MemoryProjection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,recentSummary: null == recentSummary ? _self.recentSummary : recentSummary // ignore: cast_nullable_to_non_nullable
as String,globalSummary: null == globalSummary ? _self.globalSummary : globalSummary // ignore: cast_nullable_to_non_nullable
as String,factLedgerMarkdown: null == factLedgerMarkdown ? _self.factLedgerMarkdown : factLedgerMarkdown // ignore: cast_nullable_to_non_nullable
as String,characterStatesMarkdown: null == characterStatesMarkdown ? _self.characterStatesMarkdown : characterStatesMarkdown // ignore: cast_nullable_to_non_nullable
as String,unresolvedHooksMarkdown: null == unresolvedHooksMarkdown ? _self.unresolvedHooksMarkdown : unresolvedHooksMarkdown // ignore: cast_nullable_to_non_nullable
as String,updatedFromChapterId: freezed == updatedFromChapterId ? _self.updatedFromChapterId : updatedFromChapterId // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
