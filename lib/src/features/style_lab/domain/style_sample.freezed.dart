// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'style_sample.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StyleSample {

 String get id; StyleSampleSourceType get sourceType; String get title; String get content; int get characterCount; String? get projectId; String? get sourceFilename; String? get epubBookTitle; String? get epubAuthor; String? get epubChapterTitle; int? get epubChapterIndex; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of StyleSample
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StyleSampleCopyWith<StyleSample> get copyWith => _$StyleSampleCopyWithImpl<StyleSample>(this as StyleSample, _$identity);

  /// Serializes this StyleSample to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StyleSample&&(identical(other.id, id) || other.id == id)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.characterCount, characterCount) || other.characterCount == characterCount)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.sourceFilename, sourceFilename) || other.sourceFilename == sourceFilename)&&(identical(other.epubBookTitle, epubBookTitle) || other.epubBookTitle == epubBookTitle)&&(identical(other.epubAuthor, epubAuthor) || other.epubAuthor == epubAuthor)&&(identical(other.epubChapterTitle, epubChapterTitle) || other.epubChapterTitle == epubChapterTitle)&&(identical(other.epubChapterIndex, epubChapterIndex) || other.epubChapterIndex == epubChapterIndex)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sourceType,title,content,characterCount,projectId,sourceFilename,epubBookTitle,epubAuthor,epubChapterTitle,epubChapterIndex,createdAt,updatedAt);

@override
String toString() {
  return 'StyleSample(id: $id, sourceType: $sourceType, title: $title, content: $content, characterCount: $characterCount, projectId: $projectId, sourceFilename: $sourceFilename, epubBookTitle: $epubBookTitle, epubAuthor: $epubAuthor, epubChapterTitle: $epubChapterTitle, epubChapterIndex: $epubChapterIndex, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $StyleSampleCopyWith<$Res>  {
  factory $StyleSampleCopyWith(StyleSample value, $Res Function(StyleSample) _then) = _$StyleSampleCopyWithImpl;
@useResult
$Res call({
 String id, StyleSampleSourceType sourceType, String title, String content, int characterCount, String? projectId, String? sourceFilename, String? epubBookTitle, String? epubAuthor, String? epubChapterTitle, int? epubChapterIndex, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$StyleSampleCopyWithImpl<$Res>
    implements $StyleSampleCopyWith<$Res> {
  _$StyleSampleCopyWithImpl(this._self, this._then);

  final StyleSample _self;
  final $Res Function(StyleSample) _then;

/// Create a copy of StyleSample
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sourceType = null,Object? title = null,Object? content = null,Object? characterCount = null,Object? projectId = freezed,Object? sourceFilename = freezed,Object? epubBookTitle = freezed,Object? epubAuthor = freezed,Object? epubChapterTitle = freezed,Object? epubChapterIndex = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as StyleSampleSourceType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,characterCount: null == characterCount ? _self.characterCount : characterCount // ignore: cast_nullable_to_non_nullable
as int,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,sourceFilename: freezed == sourceFilename ? _self.sourceFilename : sourceFilename // ignore: cast_nullable_to_non_nullable
as String?,epubBookTitle: freezed == epubBookTitle ? _self.epubBookTitle : epubBookTitle // ignore: cast_nullable_to_non_nullable
as String?,epubAuthor: freezed == epubAuthor ? _self.epubAuthor : epubAuthor // ignore: cast_nullable_to_non_nullable
as String?,epubChapterTitle: freezed == epubChapterTitle ? _self.epubChapterTitle : epubChapterTitle // ignore: cast_nullable_to_non_nullable
as String?,epubChapterIndex: freezed == epubChapterIndex ? _self.epubChapterIndex : epubChapterIndex // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [StyleSample].
extension StyleSamplePatterns on StyleSample {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StyleSample value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StyleSample() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StyleSample value)  $default,){
final _that = this;
switch (_that) {
case _StyleSample():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StyleSample value)?  $default,){
final _that = this;
switch (_that) {
case _StyleSample() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  StyleSampleSourceType sourceType,  String title,  String content,  int characterCount,  String? projectId,  String? sourceFilename,  String? epubBookTitle,  String? epubAuthor,  String? epubChapterTitle,  int? epubChapterIndex,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StyleSample() when $default != null:
return $default(_that.id,_that.sourceType,_that.title,_that.content,_that.characterCount,_that.projectId,_that.sourceFilename,_that.epubBookTitle,_that.epubAuthor,_that.epubChapterTitle,_that.epubChapterIndex,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  StyleSampleSourceType sourceType,  String title,  String content,  int characterCount,  String? projectId,  String? sourceFilename,  String? epubBookTitle,  String? epubAuthor,  String? epubChapterTitle,  int? epubChapterIndex,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _StyleSample():
return $default(_that.id,_that.sourceType,_that.title,_that.content,_that.characterCount,_that.projectId,_that.sourceFilename,_that.epubBookTitle,_that.epubAuthor,_that.epubChapterTitle,_that.epubChapterIndex,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  StyleSampleSourceType sourceType,  String title,  String content,  int characterCount,  String? projectId,  String? sourceFilename,  String? epubBookTitle,  String? epubAuthor,  String? epubChapterTitle,  int? epubChapterIndex,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _StyleSample() when $default != null:
return $default(_that.id,_that.sourceType,_that.title,_that.content,_that.characterCount,_that.projectId,_that.sourceFilename,_that.epubBookTitle,_that.epubAuthor,_that.epubChapterTitle,_that.epubChapterIndex,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StyleSample implements StyleSample {
  const _StyleSample({required this.id, required this.sourceType, required this.title, required this.content, required this.characterCount, this.projectId, this.sourceFilename, this.epubBookTitle, this.epubAuthor, this.epubChapterTitle, this.epubChapterIndex, required this.createdAt, required this.updatedAt});
  factory _StyleSample.fromJson(Map<String, dynamic> json) => _$StyleSampleFromJson(json);

@override final  String id;
@override final  StyleSampleSourceType sourceType;
@override final  String title;
@override final  String content;
@override final  int characterCount;
@override final  String? projectId;
@override final  String? sourceFilename;
@override final  String? epubBookTitle;
@override final  String? epubAuthor;
@override final  String? epubChapterTitle;
@override final  int? epubChapterIndex;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of StyleSample
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StyleSampleCopyWith<_StyleSample> get copyWith => __$StyleSampleCopyWithImpl<_StyleSample>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StyleSampleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StyleSample&&(identical(other.id, id) || other.id == id)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.characterCount, characterCount) || other.characterCount == characterCount)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.sourceFilename, sourceFilename) || other.sourceFilename == sourceFilename)&&(identical(other.epubBookTitle, epubBookTitle) || other.epubBookTitle == epubBookTitle)&&(identical(other.epubAuthor, epubAuthor) || other.epubAuthor == epubAuthor)&&(identical(other.epubChapterTitle, epubChapterTitle) || other.epubChapterTitle == epubChapterTitle)&&(identical(other.epubChapterIndex, epubChapterIndex) || other.epubChapterIndex == epubChapterIndex)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sourceType,title,content,characterCount,projectId,sourceFilename,epubBookTitle,epubAuthor,epubChapterTitle,epubChapterIndex,createdAt,updatedAt);

@override
String toString() {
  return 'StyleSample(id: $id, sourceType: $sourceType, title: $title, content: $content, characterCount: $characterCount, projectId: $projectId, sourceFilename: $sourceFilename, epubBookTitle: $epubBookTitle, epubAuthor: $epubAuthor, epubChapterTitle: $epubChapterTitle, epubChapterIndex: $epubChapterIndex, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$StyleSampleCopyWith<$Res> implements $StyleSampleCopyWith<$Res> {
  factory _$StyleSampleCopyWith(_StyleSample value, $Res Function(_StyleSample) _then) = __$StyleSampleCopyWithImpl;
@override @useResult
$Res call({
 String id, StyleSampleSourceType sourceType, String title, String content, int characterCount, String? projectId, String? sourceFilename, String? epubBookTitle, String? epubAuthor, String? epubChapterTitle, int? epubChapterIndex, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$StyleSampleCopyWithImpl<$Res>
    implements _$StyleSampleCopyWith<$Res> {
  __$StyleSampleCopyWithImpl(this._self, this._then);

  final _StyleSample _self;
  final $Res Function(_StyleSample) _then;

/// Create a copy of StyleSample
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sourceType = null,Object? title = null,Object? content = null,Object? characterCount = null,Object? projectId = freezed,Object? sourceFilename = freezed,Object? epubBookTitle = freezed,Object? epubAuthor = freezed,Object? epubChapterTitle = freezed,Object? epubChapterIndex = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_StyleSample(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as StyleSampleSourceType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,characterCount: null == characterCount ? _self.characterCount : characterCount // ignore: cast_nullable_to_non_nullable
as int,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,sourceFilename: freezed == sourceFilename ? _self.sourceFilename : sourceFilename // ignore: cast_nullable_to_non_nullable
as String?,epubBookTitle: freezed == epubBookTitle ? _self.epubBookTitle : epubBookTitle // ignore: cast_nullable_to_non_nullable
as String?,epubAuthor: freezed == epubAuthor ? _self.epubAuthor : epubAuthor // ignore: cast_nullable_to_non_nullable
as String?,epubChapterTitle: freezed == epubChapterTitle ? _self.epubChapterTitle : epubChapterTitle // ignore: cast_nullable_to_non_nullable
as String?,epubChapterIndex: freezed == epubChapterIndex ? _self.epubChapterIndex : epubChapterIndex // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
