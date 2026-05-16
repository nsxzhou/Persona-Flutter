// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plot_sample.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlotSample {

 String get id; PlotSampleSourceType get sourceType; String get title; String get content; int get characterCount; String? get sourceFilename; String? get epubBookTitle; String? get epubAuthor; int? get epubChapterCount; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of PlotSample
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlotSampleCopyWith<PlotSample> get copyWith => _$PlotSampleCopyWithImpl<PlotSample>(this as PlotSample, _$identity);

  /// Serializes this PlotSample to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlotSample&&(identical(other.id, id) || other.id == id)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.characterCount, characterCount) || other.characterCount == characterCount)&&(identical(other.sourceFilename, sourceFilename) || other.sourceFilename == sourceFilename)&&(identical(other.epubBookTitle, epubBookTitle) || other.epubBookTitle == epubBookTitle)&&(identical(other.epubAuthor, epubAuthor) || other.epubAuthor == epubAuthor)&&(identical(other.epubChapterCount, epubChapterCount) || other.epubChapterCount == epubChapterCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sourceType,title,content,characterCount,sourceFilename,epubBookTitle,epubAuthor,epubChapterCount,createdAt,updatedAt);

@override
String toString() {
  return 'PlotSample(id: $id, sourceType: $sourceType, title: $title, content: $content, characterCount: $characterCount, sourceFilename: $sourceFilename, epubBookTitle: $epubBookTitle, epubAuthor: $epubAuthor, epubChapterCount: $epubChapterCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PlotSampleCopyWith<$Res>  {
  factory $PlotSampleCopyWith(PlotSample value, $Res Function(PlotSample) _then) = _$PlotSampleCopyWithImpl;
@useResult
$Res call({
 String id, PlotSampleSourceType sourceType, String title, String content, int characterCount, String? sourceFilename, String? epubBookTitle, String? epubAuthor, int? epubChapterCount, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$PlotSampleCopyWithImpl<$Res>
    implements $PlotSampleCopyWith<$Res> {
  _$PlotSampleCopyWithImpl(this._self, this._then);

  final PlotSample _self;
  final $Res Function(PlotSample) _then;

/// Create a copy of PlotSample
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sourceType = null,Object? title = null,Object? content = null,Object? characterCount = null,Object? sourceFilename = freezed,Object? epubBookTitle = freezed,Object? epubAuthor = freezed,Object? epubChapterCount = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as PlotSampleSourceType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,characterCount: null == characterCount ? _self.characterCount : characterCount // ignore: cast_nullable_to_non_nullable
as int,sourceFilename: freezed == sourceFilename ? _self.sourceFilename : sourceFilename // ignore: cast_nullable_to_non_nullable
as String?,epubBookTitle: freezed == epubBookTitle ? _self.epubBookTitle : epubBookTitle // ignore: cast_nullable_to_non_nullable
as String?,epubAuthor: freezed == epubAuthor ? _self.epubAuthor : epubAuthor // ignore: cast_nullable_to_non_nullable
as String?,epubChapterCount: freezed == epubChapterCount ? _self.epubChapterCount : epubChapterCount // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PlotSample].
extension PlotSamplePatterns on PlotSample {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlotSample value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlotSample() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlotSample value)  $default,){
final _that = this;
switch (_that) {
case _PlotSample():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlotSample value)?  $default,){
final _that = this;
switch (_that) {
case _PlotSample() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  PlotSampleSourceType sourceType,  String title,  String content,  int characterCount,  String? sourceFilename,  String? epubBookTitle,  String? epubAuthor,  int? epubChapterCount,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlotSample() when $default != null:
return $default(_that.id,_that.sourceType,_that.title,_that.content,_that.characterCount,_that.sourceFilename,_that.epubBookTitle,_that.epubAuthor,_that.epubChapterCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  PlotSampleSourceType sourceType,  String title,  String content,  int characterCount,  String? sourceFilename,  String? epubBookTitle,  String? epubAuthor,  int? epubChapterCount,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PlotSample():
return $default(_that.id,_that.sourceType,_that.title,_that.content,_that.characterCount,_that.sourceFilename,_that.epubBookTitle,_that.epubAuthor,_that.epubChapterCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  PlotSampleSourceType sourceType,  String title,  String content,  int characterCount,  String? sourceFilename,  String? epubBookTitle,  String? epubAuthor,  int? epubChapterCount,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PlotSample() when $default != null:
return $default(_that.id,_that.sourceType,_that.title,_that.content,_that.characterCount,_that.sourceFilename,_that.epubBookTitle,_that.epubAuthor,_that.epubChapterCount,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlotSample implements PlotSample {
  const _PlotSample({required this.id, required this.sourceType, required this.title, required this.content, required this.characterCount, this.sourceFilename, this.epubBookTitle, this.epubAuthor, this.epubChapterCount, required this.createdAt, required this.updatedAt});
  factory _PlotSample.fromJson(Map<String, dynamic> json) => _$PlotSampleFromJson(json);

@override final  String id;
@override final  PlotSampleSourceType sourceType;
@override final  String title;
@override final  String content;
@override final  int characterCount;
@override final  String? sourceFilename;
@override final  String? epubBookTitle;
@override final  String? epubAuthor;
@override final  int? epubChapterCount;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of PlotSample
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlotSampleCopyWith<_PlotSample> get copyWith => __$PlotSampleCopyWithImpl<_PlotSample>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlotSampleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlotSample&&(identical(other.id, id) || other.id == id)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.characterCount, characterCount) || other.characterCount == characterCount)&&(identical(other.sourceFilename, sourceFilename) || other.sourceFilename == sourceFilename)&&(identical(other.epubBookTitle, epubBookTitle) || other.epubBookTitle == epubBookTitle)&&(identical(other.epubAuthor, epubAuthor) || other.epubAuthor == epubAuthor)&&(identical(other.epubChapterCount, epubChapterCount) || other.epubChapterCount == epubChapterCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sourceType,title,content,characterCount,sourceFilename,epubBookTitle,epubAuthor,epubChapterCount,createdAt,updatedAt);

@override
String toString() {
  return 'PlotSample(id: $id, sourceType: $sourceType, title: $title, content: $content, characterCount: $characterCount, sourceFilename: $sourceFilename, epubBookTitle: $epubBookTitle, epubAuthor: $epubAuthor, epubChapterCount: $epubChapterCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PlotSampleCopyWith<$Res> implements $PlotSampleCopyWith<$Res> {
  factory _$PlotSampleCopyWith(_PlotSample value, $Res Function(_PlotSample) _then) = __$PlotSampleCopyWithImpl;
@override @useResult
$Res call({
 String id, PlotSampleSourceType sourceType, String title, String content, int characterCount, String? sourceFilename, String? epubBookTitle, String? epubAuthor, int? epubChapterCount, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$PlotSampleCopyWithImpl<$Res>
    implements _$PlotSampleCopyWith<$Res> {
  __$PlotSampleCopyWithImpl(this._self, this._then);

  final _PlotSample _self;
  final $Res Function(_PlotSample) _then;

/// Create a copy of PlotSample
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sourceType = null,Object? title = null,Object? content = null,Object? characterCount = null,Object? sourceFilename = freezed,Object? epubBookTitle = freezed,Object? epubAuthor = freezed,Object? epubChapterCount = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_PlotSample(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as PlotSampleSourceType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,characterCount: null == characterCount ? _self.characterCount : characterCount // ignore: cast_nullable_to_non_nullable
as int,sourceFilename: freezed == sourceFilename ? _self.sourceFilename : sourceFilename // ignore: cast_nullable_to_non_nullable
as String?,epubBookTitle: freezed == epubBookTitle ? _self.epubBookTitle : epubBookTitle // ignore: cast_nullable_to_non_nullable
as String?,epubAuthor: freezed == epubAuthor ? _self.epubAuthor : epubAuthor // ignore: cast_nullable_to_non_nullable
as String?,epubChapterCount: freezed == epubChapterCount ? _self.epubChapterCount : epubChapterCount // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
