// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'style_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StyleProfile {

 String get id; String get sourceRunId; String get providerId; String get modelName; String get styleName; String get profileMarkdown; String get analysisReportMarkdown; String? get projectId; String? get sourceSampleId; String? get sourceTitle; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of StyleProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StyleProfileCopyWith<StyleProfile> get copyWith => _$StyleProfileCopyWithImpl<StyleProfile>(this as StyleProfile, _$identity);

  /// Serializes this StyleProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StyleProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.sourceRunId, sourceRunId) || other.sourceRunId == sourceRunId)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.styleName, styleName) || other.styleName == styleName)&&(identical(other.profileMarkdown, profileMarkdown) || other.profileMarkdown == profileMarkdown)&&(identical(other.analysisReportMarkdown, analysisReportMarkdown) || other.analysisReportMarkdown == analysisReportMarkdown)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.sourceSampleId, sourceSampleId) || other.sourceSampleId == sourceSampleId)&&(identical(other.sourceTitle, sourceTitle) || other.sourceTitle == sourceTitle)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sourceRunId,providerId,modelName,styleName,profileMarkdown,analysisReportMarkdown,projectId,sourceSampleId,sourceTitle,createdAt,updatedAt);

@override
String toString() {
  return 'StyleProfile(id: $id, sourceRunId: $sourceRunId, providerId: $providerId, modelName: $modelName, styleName: $styleName, profileMarkdown: $profileMarkdown, analysisReportMarkdown: $analysisReportMarkdown, projectId: $projectId, sourceSampleId: $sourceSampleId, sourceTitle: $sourceTitle, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $StyleProfileCopyWith<$Res>  {
  factory $StyleProfileCopyWith(StyleProfile value, $Res Function(StyleProfile) _then) = _$StyleProfileCopyWithImpl;
@useResult
$Res call({
 String id, String sourceRunId, String providerId, String modelName, String styleName, String profileMarkdown, String analysisReportMarkdown, String? projectId, String? sourceSampleId, String? sourceTitle, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$StyleProfileCopyWithImpl<$Res>
    implements $StyleProfileCopyWith<$Res> {
  _$StyleProfileCopyWithImpl(this._self, this._then);

  final StyleProfile _self;
  final $Res Function(StyleProfile) _then;

/// Create a copy of StyleProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sourceRunId = null,Object? providerId = null,Object? modelName = null,Object? styleName = null,Object? profileMarkdown = null,Object? analysisReportMarkdown = null,Object? projectId = freezed,Object? sourceSampleId = freezed,Object? sourceTitle = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sourceRunId: null == sourceRunId ? _self.sourceRunId : sourceRunId // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,styleName: null == styleName ? _self.styleName : styleName // ignore: cast_nullable_to_non_nullable
as String,profileMarkdown: null == profileMarkdown ? _self.profileMarkdown : profileMarkdown // ignore: cast_nullable_to_non_nullable
as String,analysisReportMarkdown: null == analysisReportMarkdown ? _self.analysisReportMarkdown : analysisReportMarkdown // ignore: cast_nullable_to_non_nullable
as String,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,sourceSampleId: freezed == sourceSampleId ? _self.sourceSampleId : sourceSampleId // ignore: cast_nullable_to_non_nullable
as String?,sourceTitle: freezed == sourceTitle ? _self.sourceTitle : sourceTitle // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [StyleProfile].
extension StyleProfilePatterns on StyleProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StyleProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StyleProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StyleProfile value)  $default,){
final _that = this;
switch (_that) {
case _StyleProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StyleProfile value)?  $default,){
final _that = this;
switch (_that) {
case _StyleProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sourceRunId,  String providerId,  String modelName,  String styleName,  String profileMarkdown,  String analysisReportMarkdown,  String? projectId,  String? sourceSampleId,  String? sourceTitle,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StyleProfile() when $default != null:
return $default(_that.id,_that.sourceRunId,_that.providerId,_that.modelName,_that.styleName,_that.profileMarkdown,_that.analysisReportMarkdown,_that.projectId,_that.sourceSampleId,_that.sourceTitle,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sourceRunId,  String providerId,  String modelName,  String styleName,  String profileMarkdown,  String analysisReportMarkdown,  String? projectId,  String? sourceSampleId,  String? sourceTitle,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _StyleProfile():
return $default(_that.id,_that.sourceRunId,_that.providerId,_that.modelName,_that.styleName,_that.profileMarkdown,_that.analysisReportMarkdown,_that.projectId,_that.sourceSampleId,_that.sourceTitle,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sourceRunId,  String providerId,  String modelName,  String styleName,  String profileMarkdown,  String analysisReportMarkdown,  String? projectId,  String? sourceSampleId,  String? sourceTitle,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _StyleProfile() when $default != null:
return $default(_that.id,_that.sourceRunId,_that.providerId,_that.modelName,_that.styleName,_that.profileMarkdown,_that.analysisReportMarkdown,_that.projectId,_that.sourceSampleId,_that.sourceTitle,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StyleProfile implements StyleProfile {
  const _StyleProfile({required this.id, required this.sourceRunId, required this.providerId, required this.modelName, required this.styleName, required this.profileMarkdown, required this.analysisReportMarkdown, this.projectId, this.sourceSampleId, this.sourceTitle, required this.createdAt, required this.updatedAt});
  factory _StyleProfile.fromJson(Map<String, dynamic> json) => _$StyleProfileFromJson(json);

@override final  String id;
@override final  String sourceRunId;
@override final  String providerId;
@override final  String modelName;
@override final  String styleName;
@override final  String profileMarkdown;
@override final  String analysisReportMarkdown;
@override final  String? projectId;
@override final  String? sourceSampleId;
@override final  String? sourceTitle;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of StyleProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StyleProfileCopyWith<_StyleProfile> get copyWith => __$StyleProfileCopyWithImpl<_StyleProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StyleProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StyleProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.sourceRunId, sourceRunId) || other.sourceRunId == sourceRunId)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.styleName, styleName) || other.styleName == styleName)&&(identical(other.profileMarkdown, profileMarkdown) || other.profileMarkdown == profileMarkdown)&&(identical(other.analysisReportMarkdown, analysisReportMarkdown) || other.analysisReportMarkdown == analysisReportMarkdown)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.sourceSampleId, sourceSampleId) || other.sourceSampleId == sourceSampleId)&&(identical(other.sourceTitle, sourceTitle) || other.sourceTitle == sourceTitle)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sourceRunId,providerId,modelName,styleName,profileMarkdown,analysisReportMarkdown,projectId,sourceSampleId,sourceTitle,createdAt,updatedAt);

@override
String toString() {
  return 'StyleProfile(id: $id, sourceRunId: $sourceRunId, providerId: $providerId, modelName: $modelName, styleName: $styleName, profileMarkdown: $profileMarkdown, analysisReportMarkdown: $analysisReportMarkdown, projectId: $projectId, sourceSampleId: $sourceSampleId, sourceTitle: $sourceTitle, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$StyleProfileCopyWith<$Res> implements $StyleProfileCopyWith<$Res> {
  factory _$StyleProfileCopyWith(_StyleProfile value, $Res Function(_StyleProfile) _then) = __$StyleProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String sourceRunId, String providerId, String modelName, String styleName, String profileMarkdown, String analysisReportMarkdown, String? projectId, String? sourceSampleId, String? sourceTitle, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$StyleProfileCopyWithImpl<$Res>
    implements _$StyleProfileCopyWith<$Res> {
  __$StyleProfileCopyWithImpl(this._self, this._then);

  final _StyleProfile _self;
  final $Res Function(_StyleProfile) _then;

/// Create a copy of StyleProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sourceRunId = null,Object? providerId = null,Object? modelName = null,Object? styleName = null,Object? profileMarkdown = null,Object? analysisReportMarkdown = null,Object? projectId = freezed,Object? sourceSampleId = freezed,Object? sourceTitle = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_StyleProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sourceRunId: null == sourceRunId ? _self.sourceRunId : sourceRunId // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,styleName: null == styleName ? _self.styleName : styleName // ignore: cast_nullable_to_non_nullable
as String,profileMarkdown: null == profileMarkdown ? _self.profileMarkdown : profileMarkdown // ignore: cast_nullable_to_non_nullable
as String,analysisReportMarkdown: null == analysisReportMarkdown ? _self.analysisReportMarkdown : analysisReportMarkdown // ignore: cast_nullable_to_non_nullable
as String,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,sourceSampleId: freezed == sourceSampleId ? _self.sourceSampleId : sourceSampleId // ignore: cast_nullable_to_non_nullable
as String?,sourceTitle: freezed == sourceTitle ? _self.sourceTitle : sourceTitle // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
