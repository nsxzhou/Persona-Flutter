// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'market_scan_run.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MarketScanRun {

 String get id; String get platform; MarketScanRunStatus get status; DateTime get startedAt; DateTime? get completedAt; int get itemCount; String? get errorMessage; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of MarketScanRun
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketScanRunCopyWith<MarketScanRun> get copyWith => _$MarketScanRunCopyWithImpl<MarketScanRun>(this as MarketScanRun, _$identity);

  /// Serializes this MarketScanRun to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarketScanRun&&(identical(other.id, id) || other.id == id)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,platform,status,startedAt,completedAt,itemCount,errorMessage,createdAt,updatedAt);

@override
String toString() {
  return 'MarketScanRun(id: $id, platform: $platform, status: $status, startedAt: $startedAt, completedAt: $completedAt, itemCount: $itemCount, errorMessage: $errorMessage, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MarketScanRunCopyWith<$Res>  {
  factory $MarketScanRunCopyWith(MarketScanRun value, $Res Function(MarketScanRun) _then) = _$MarketScanRunCopyWithImpl;
@useResult
$Res call({
 String id, String platform, MarketScanRunStatus status, DateTime startedAt, DateTime? completedAt, int itemCount, String? errorMessage, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$MarketScanRunCopyWithImpl<$Res>
    implements $MarketScanRunCopyWith<$Res> {
  _$MarketScanRunCopyWithImpl(this._self, this._then);

  final MarketScanRun _self;
  final $Res Function(MarketScanRun) _then;

/// Create a copy of MarketScanRun
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? platform = null,Object? status = null,Object? startedAt = null,Object? completedAt = freezed,Object? itemCount = null,Object? errorMessage = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MarketScanRunStatus,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,itemCount: null == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MarketScanRun].
extension MarketScanRunPatterns on MarketScanRun {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarketScanRun value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarketScanRun() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarketScanRun value)  $default,){
final _that = this;
switch (_that) {
case _MarketScanRun():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarketScanRun value)?  $default,){
final _that = this;
switch (_that) {
case _MarketScanRun() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String platform,  MarketScanRunStatus status,  DateTime startedAt,  DateTime? completedAt,  int itemCount,  String? errorMessage,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarketScanRun() when $default != null:
return $default(_that.id,_that.platform,_that.status,_that.startedAt,_that.completedAt,_that.itemCount,_that.errorMessage,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String platform,  MarketScanRunStatus status,  DateTime startedAt,  DateTime? completedAt,  int itemCount,  String? errorMessage,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MarketScanRun():
return $default(_that.id,_that.platform,_that.status,_that.startedAt,_that.completedAt,_that.itemCount,_that.errorMessage,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String platform,  MarketScanRunStatus status,  DateTime startedAt,  DateTime? completedAt,  int itemCount,  String? errorMessage,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MarketScanRun() when $default != null:
return $default(_that.id,_that.platform,_that.status,_that.startedAt,_that.completedAt,_that.itemCount,_that.errorMessage,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MarketScanRun implements MarketScanRun {
  const _MarketScanRun({required this.id, required this.platform, required this.status, required this.startedAt, this.completedAt, this.itemCount = 0, this.errorMessage, required this.createdAt, required this.updatedAt});
  factory _MarketScanRun.fromJson(Map<String, dynamic> json) => _$MarketScanRunFromJson(json);

@override final  String id;
@override final  String platform;
@override final  MarketScanRunStatus status;
@override final  DateTime startedAt;
@override final  DateTime? completedAt;
@override@JsonKey() final  int itemCount;
@override final  String? errorMessage;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of MarketScanRun
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarketScanRunCopyWith<_MarketScanRun> get copyWith => __$MarketScanRunCopyWithImpl<_MarketScanRun>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarketScanRunToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarketScanRun&&(identical(other.id, id) || other.id == id)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,platform,status,startedAt,completedAt,itemCount,errorMessage,createdAt,updatedAt);

@override
String toString() {
  return 'MarketScanRun(id: $id, platform: $platform, status: $status, startedAt: $startedAt, completedAt: $completedAt, itemCount: $itemCount, errorMessage: $errorMessage, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MarketScanRunCopyWith<$Res> implements $MarketScanRunCopyWith<$Res> {
  factory _$MarketScanRunCopyWith(_MarketScanRun value, $Res Function(_MarketScanRun) _then) = __$MarketScanRunCopyWithImpl;
@override @useResult
$Res call({
 String id, String platform, MarketScanRunStatus status, DateTime startedAt, DateTime? completedAt, int itemCount, String? errorMessage, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$MarketScanRunCopyWithImpl<$Res>
    implements _$MarketScanRunCopyWith<$Res> {
  __$MarketScanRunCopyWithImpl(this._self, this._then);

  final _MarketScanRun _self;
  final $Res Function(_MarketScanRun) _then;

/// Create a copy of MarketScanRun
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? platform = null,Object? status = null,Object? startedAt = null,Object? completedAt = freezed,Object? itemCount = null,Object? errorMessage = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_MarketScanRun(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MarketScanRunStatus,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,itemCount: null == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
