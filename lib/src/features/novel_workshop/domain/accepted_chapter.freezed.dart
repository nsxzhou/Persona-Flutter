// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'accepted_chapter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AcceptedChapter {

 String get id; String get projectId; String get chapterPlanId; String get sourceRunId; int get chapterIndex; String get title; String get contentMarkdown; DateTime get acceptedAt; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of AcceptedChapter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AcceptedChapterCopyWith<AcceptedChapter> get copyWith => _$AcceptedChapterCopyWithImpl<AcceptedChapter>(this as AcceptedChapter, _$identity);

  /// Serializes this AcceptedChapter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AcceptedChapter&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.chapterPlanId, chapterPlanId) || other.chapterPlanId == chapterPlanId)&&(identical(other.sourceRunId, sourceRunId) || other.sourceRunId == sourceRunId)&&(identical(other.chapterIndex, chapterIndex) || other.chapterIndex == chapterIndex)&&(identical(other.title, title) || other.title == title)&&(identical(other.contentMarkdown, contentMarkdown) || other.contentMarkdown == contentMarkdown)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,chapterPlanId,sourceRunId,chapterIndex,title,contentMarkdown,acceptedAt,createdAt,updatedAt);

@override
String toString() {
  return 'AcceptedChapter(id: $id, projectId: $projectId, chapterPlanId: $chapterPlanId, sourceRunId: $sourceRunId, chapterIndex: $chapterIndex, title: $title, contentMarkdown: $contentMarkdown, acceptedAt: $acceptedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AcceptedChapterCopyWith<$Res>  {
  factory $AcceptedChapterCopyWith(AcceptedChapter value, $Res Function(AcceptedChapter) _then) = _$AcceptedChapterCopyWithImpl;
@useResult
$Res call({
 String id, String projectId, String chapterPlanId, String sourceRunId, int chapterIndex, String title, String contentMarkdown, DateTime acceptedAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$AcceptedChapterCopyWithImpl<$Res>
    implements $AcceptedChapterCopyWith<$Res> {
  _$AcceptedChapterCopyWithImpl(this._self, this._then);

  final AcceptedChapter _self;
  final $Res Function(AcceptedChapter) _then;

/// Create a copy of AcceptedChapter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? projectId = null,Object? chapterPlanId = null,Object? sourceRunId = null,Object? chapterIndex = null,Object? title = null,Object? contentMarkdown = null,Object? acceptedAt = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,chapterPlanId: null == chapterPlanId ? _self.chapterPlanId : chapterPlanId // ignore: cast_nullable_to_non_nullable
as String,sourceRunId: null == sourceRunId ? _self.sourceRunId : sourceRunId // ignore: cast_nullable_to_non_nullable
as String,chapterIndex: null == chapterIndex ? _self.chapterIndex : chapterIndex // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,contentMarkdown: null == contentMarkdown ? _self.contentMarkdown : contentMarkdown // ignore: cast_nullable_to_non_nullable
as String,acceptedAt: null == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AcceptedChapter].
extension AcceptedChapterPatterns on AcceptedChapter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AcceptedChapter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AcceptedChapter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AcceptedChapter value)  $default,){
final _that = this;
switch (_that) {
case _AcceptedChapter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AcceptedChapter value)?  $default,){
final _that = this;
switch (_that) {
case _AcceptedChapter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String projectId,  String chapterPlanId,  String sourceRunId,  int chapterIndex,  String title,  String contentMarkdown,  DateTime acceptedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AcceptedChapter() when $default != null:
return $default(_that.id,_that.projectId,_that.chapterPlanId,_that.sourceRunId,_that.chapterIndex,_that.title,_that.contentMarkdown,_that.acceptedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String projectId,  String chapterPlanId,  String sourceRunId,  int chapterIndex,  String title,  String contentMarkdown,  DateTime acceptedAt,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AcceptedChapter():
return $default(_that.id,_that.projectId,_that.chapterPlanId,_that.sourceRunId,_that.chapterIndex,_that.title,_that.contentMarkdown,_that.acceptedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String projectId,  String chapterPlanId,  String sourceRunId,  int chapterIndex,  String title,  String contentMarkdown,  DateTime acceptedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AcceptedChapter() when $default != null:
return $default(_that.id,_that.projectId,_that.chapterPlanId,_that.sourceRunId,_that.chapterIndex,_that.title,_that.contentMarkdown,_that.acceptedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AcceptedChapter implements AcceptedChapter {
  const _AcceptedChapter({required this.id, required this.projectId, required this.chapterPlanId, required this.sourceRunId, required this.chapterIndex, required this.title, required this.contentMarkdown, required this.acceptedAt, required this.createdAt, required this.updatedAt});
  factory _AcceptedChapter.fromJson(Map<String, dynamic> json) => _$AcceptedChapterFromJson(json);

@override final  String id;
@override final  String projectId;
@override final  String chapterPlanId;
@override final  String sourceRunId;
@override final  int chapterIndex;
@override final  String title;
@override final  String contentMarkdown;
@override final  DateTime acceptedAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of AcceptedChapter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AcceptedChapterCopyWith<_AcceptedChapter> get copyWith => __$AcceptedChapterCopyWithImpl<_AcceptedChapter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AcceptedChapterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AcceptedChapter&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.chapterPlanId, chapterPlanId) || other.chapterPlanId == chapterPlanId)&&(identical(other.sourceRunId, sourceRunId) || other.sourceRunId == sourceRunId)&&(identical(other.chapterIndex, chapterIndex) || other.chapterIndex == chapterIndex)&&(identical(other.title, title) || other.title == title)&&(identical(other.contentMarkdown, contentMarkdown) || other.contentMarkdown == contentMarkdown)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,chapterPlanId,sourceRunId,chapterIndex,title,contentMarkdown,acceptedAt,createdAt,updatedAt);

@override
String toString() {
  return 'AcceptedChapter(id: $id, projectId: $projectId, chapterPlanId: $chapterPlanId, sourceRunId: $sourceRunId, chapterIndex: $chapterIndex, title: $title, contentMarkdown: $contentMarkdown, acceptedAt: $acceptedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AcceptedChapterCopyWith<$Res> implements $AcceptedChapterCopyWith<$Res> {
  factory _$AcceptedChapterCopyWith(_AcceptedChapter value, $Res Function(_AcceptedChapter) _then) = __$AcceptedChapterCopyWithImpl;
@override @useResult
$Res call({
 String id, String projectId, String chapterPlanId, String sourceRunId, int chapterIndex, String title, String contentMarkdown, DateTime acceptedAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$AcceptedChapterCopyWithImpl<$Res>
    implements _$AcceptedChapterCopyWith<$Res> {
  __$AcceptedChapterCopyWithImpl(this._self, this._then);

  final _AcceptedChapter _self;
  final $Res Function(_AcceptedChapter) _then;

/// Create a copy of AcceptedChapter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? projectId = null,Object? chapterPlanId = null,Object? sourceRunId = null,Object? chapterIndex = null,Object? title = null,Object? contentMarkdown = null,Object? acceptedAt = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_AcceptedChapter(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,chapterPlanId: null == chapterPlanId ? _self.chapterPlanId : chapterPlanId // ignore: cast_nullable_to_non_nullable
as String,sourceRunId: null == sourceRunId ? _self.sourceRunId : sourceRunId // ignore: cast_nullable_to_non_nullable
as String,chapterIndex: null == chapterIndex ? _self.chapterIndex : chapterIndex // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,contentMarkdown: null == contentMarkdown ? _self.contentMarkdown : contentMarkdown // ignore: cast_nullable_to_non_nullable
as String,acceptedAt: null == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
