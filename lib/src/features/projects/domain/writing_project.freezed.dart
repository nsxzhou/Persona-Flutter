// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'writing_project.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WritingProject {

 String get id; String get title; String get description; ProjectStatus get status; String? get defaultProviderId; String? get defaultModelName; String? get styleProfileId; String? get plotProfileId; String get language; int get targetLength; int get totalTargetLength; String get narrativePerspective; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of WritingProject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WritingProjectCopyWith<WritingProject> get copyWith => _$WritingProjectCopyWithImpl<WritingProject>(this as WritingProject, _$identity);

  /// Serializes this WritingProject to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WritingProject&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.defaultProviderId, defaultProviderId) || other.defaultProviderId == defaultProviderId)&&(identical(other.defaultModelName, defaultModelName) || other.defaultModelName == defaultModelName)&&(identical(other.styleProfileId, styleProfileId) || other.styleProfileId == styleProfileId)&&(identical(other.plotProfileId, plotProfileId) || other.plotProfileId == plotProfileId)&&(identical(other.language, language) || other.language == language)&&(identical(other.targetLength, targetLength) || other.targetLength == targetLength)&&(identical(other.totalTargetLength, totalTargetLength) || other.totalTargetLength == totalTargetLength)&&(identical(other.narrativePerspective, narrativePerspective) || other.narrativePerspective == narrativePerspective)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,status,defaultProviderId,defaultModelName,styleProfileId,plotProfileId,language,targetLength,totalTargetLength,narrativePerspective,createdAt,updatedAt);

@override
String toString() {
  return 'WritingProject(id: $id, title: $title, description: $description, status: $status, defaultProviderId: $defaultProviderId, defaultModelName: $defaultModelName, styleProfileId: $styleProfileId, plotProfileId: $plotProfileId, language: $language, targetLength: $targetLength, totalTargetLength: $totalTargetLength, narrativePerspective: $narrativePerspective, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $WritingProjectCopyWith<$Res>  {
  factory $WritingProjectCopyWith(WritingProject value, $Res Function(WritingProject) _then) = _$WritingProjectCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, ProjectStatus status, String? defaultProviderId, String? defaultModelName, String? styleProfileId, String? plotProfileId, String language, int targetLength, int totalTargetLength, String narrativePerspective, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$WritingProjectCopyWithImpl<$Res>
    implements $WritingProjectCopyWith<$Res> {
  _$WritingProjectCopyWithImpl(this._self, this._then);

  final WritingProject _self;
  final $Res Function(WritingProject) _then;

/// Create a copy of WritingProject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? status = null,Object? defaultProviderId = freezed,Object? defaultModelName = freezed,Object? styleProfileId = freezed,Object? plotProfileId = freezed,Object? language = null,Object? targetLength = null,Object? totalTargetLength = null,Object? narrativePerspective = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProjectStatus,defaultProviderId: freezed == defaultProviderId ? _self.defaultProviderId : defaultProviderId // ignore: cast_nullable_to_non_nullable
as String?,defaultModelName: freezed == defaultModelName ? _self.defaultModelName : defaultModelName // ignore: cast_nullable_to_non_nullable
as String?,styleProfileId: freezed == styleProfileId ? _self.styleProfileId : styleProfileId // ignore: cast_nullable_to_non_nullable
as String?,plotProfileId: freezed == plotProfileId ? _self.plotProfileId : plotProfileId // ignore: cast_nullable_to_non_nullable
as String?,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,targetLength: null == targetLength ? _self.targetLength : targetLength // ignore: cast_nullable_to_non_nullable
as int,totalTargetLength: null == totalTargetLength ? _self.totalTargetLength : totalTargetLength // ignore: cast_nullable_to_non_nullable
as int,narrativePerspective: null == narrativePerspective ? _self.narrativePerspective : narrativePerspective // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [WritingProject].
extension WritingProjectPatterns on WritingProject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WritingProject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WritingProject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WritingProject value)  $default,){
final _that = this;
switch (_that) {
case _WritingProject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WritingProject value)?  $default,){
final _that = this;
switch (_that) {
case _WritingProject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  ProjectStatus status,  String? defaultProviderId,  String? defaultModelName,  String? styleProfileId,  String? plotProfileId,  String language,  int targetLength,  int totalTargetLength,  String narrativePerspective,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WritingProject() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.status,_that.defaultProviderId,_that.defaultModelName,_that.styleProfileId,_that.plotProfileId,_that.language,_that.targetLength,_that.totalTargetLength,_that.narrativePerspective,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  ProjectStatus status,  String? defaultProviderId,  String? defaultModelName,  String? styleProfileId,  String? plotProfileId,  String language,  int targetLength,  int totalTargetLength,  String narrativePerspective,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _WritingProject():
return $default(_that.id,_that.title,_that.description,_that.status,_that.defaultProviderId,_that.defaultModelName,_that.styleProfileId,_that.plotProfileId,_that.language,_that.targetLength,_that.totalTargetLength,_that.narrativePerspective,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  ProjectStatus status,  String? defaultProviderId,  String? defaultModelName,  String? styleProfileId,  String? plotProfileId,  String language,  int targetLength,  int totalTargetLength,  String narrativePerspective,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _WritingProject() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.status,_that.defaultProviderId,_that.defaultModelName,_that.styleProfileId,_that.plotProfileId,_that.language,_that.targetLength,_that.totalTargetLength,_that.narrativePerspective,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WritingProject implements WritingProject {
  const _WritingProject({required this.id, required this.title, this.description = '', required this.status, this.defaultProviderId, this.defaultModelName, this.styleProfileId, this.plotProfileId, this.language = defaultProjectLanguage, this.targetLength = defaultProjectTargetLength, this.totalTargetLength = defaultProjectTotalTargetLength, this.narrativePerspective = defaultProjectNarrativePerspective, required this.createdAt, required this.updatedAt});
  factory _WritingProject.fromJson(Map<String, dynamic> json) => _$WritingProjectFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey() final  String description;
@override final  ProjectStatus status;
@override final  String? defaultProviderId;
@override final  String? defaultModelName;
@override final  String? styleProfileId;
@override final  String? plotProfileId;
@override@JsonKey() final  String language;
@override@JsonKey() final  int targetLength;
@override@JsonKey() final  int totalTargetLength;
@override@JsonKey() final  String narrativePerspective;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of WritingProject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WritingProjectCopyWith<_WritingProject> get copyWith => __$WritingProjectCopyWithImpl<_WritingProject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WritingProjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WritingProject&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.defaultProviderId, defaultProviderId) || other.defaultProviderId == defaultProviderId)&&(identical(other.defaultModelName, defaultModelName) || other.defaultModelName == defaultModelName)&&(identical(other.styleProfileId, styleProfileId) || other.styleProfileId == styleProfileId)&&(identical(other.plotProfileId, plotProfileId) || other.plotProfileId == plotProfileId)&&(identical(other.language, language) || other.language == language)&&(identical(other.targetLength, targetLength) || other.targetLength == targetLength)&&(identical(other.totalTargetLength, totalTargetLength) || other.totalTargetLength == totalTargetLength)&&(identical(other.narrativePerspective, narrativePerspective) || other.narrativePerspective == narrativePerspective)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,status,defaultProviderId,defaultModelName,styleProfileId,plotProfileId,language,targetLength,totalTargetLength,narrativePerspective,createdAt,updatedAt);

@override
String toString() {
  return 'WritingProject(id: $id, title: $title, description: $description, status: $status, defaultProviderId: $defaultProviderId, defaultModelName: $defaultModelName, styleProfileId: $styleProfileId, plotProfileId: $plotProfileId, language: $language, targetLength: $targetLength, totalTargetLength: $totalTargetLength, narrativePerspective: $narrativePerspective, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$WritingProjectCopyWith<$Res> implements $WritingProjectCopyWith<$Res> {
  factory _$WritingProjectCopyWith(_WritingProject value, $Res Function(_WritingProject) _then) = __$WritingProjectCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, ProjectStatus status, String? defaultProviderId, String? defaultModelName, String? styleProfileId, String? plotProfileId, String language, int targetLength, int totalTargetLength, String narrativePerspective, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$WritingProjectCopyWithImpl<$Res>
    implements _$WritingProjectCopyWith<$Res> {
  __$WritingProjectCopyWithImpl(this._self, this._then);

  final _WritingProject _self;
  final $Res Function(_WritingProject) _then;

/// Create a copy of WritingProject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? status = null,Object? defaultProviderId = freezed,Object? defaultModelName = freezed,Object? styleProfileId = freezed,Object? plotProfileId = freezed,Object? language = null,Object? targetLength = null,Object? totalTargetLength = null,Object? narrativePerspective = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_WritingProject(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProjectStatus,defaultProviderId: freezed == defaultProviderId ? _self.defaultProviderId : defaultProviderId // ignore: cast_nullable_to_non_nullable
as String?,defaultModelName: freezed == defaultModelName ? _self.defaultModelName : defaultModelName // ignore: cast_nullable_to_non_nullable
as String?,styleProfileId: freezed == styleProfileId ? _self.styleProfileId : styleProfileId // ignore: cast_nullable_to_non_nullable
as String?,plotProfileId: freezed == plotProfileId ? _self.plotProfileId : plotProfileId // ignore: cast_nullable_to_non_nullable
as String?,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,targetLength: null == targetLength ? _self.targetLength : targetLength // ignore: cast_nullable_to_non_nullable
as int,totalTargetLength: null == totalTargetLength ? _self.totalTargetLength : totalTargetLength // ignore: cast_nullable_to_non_nullable
as int,narrativePerspective: null == narrativePerspective ? _self.narrativePerspective : narrativePerspective // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
