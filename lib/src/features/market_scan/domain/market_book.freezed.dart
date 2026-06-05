// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'market_book.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MarketBook {

 String get id; MarketPlatform get platform; String get platformBookId; String get title; String get author; String get description; List<String> get categories; List<String> get tags; int get totalWordCount; BookStatus get status; DateTime? get firstPublishDate; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of MarketBook
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketBookCopyWith<MarketBook> get copyWith => _$MarketBookCopyWithImpl<MarketBook>(this as MarketBook, _$identity);

  /// Serializes this MarketBook to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarketBook&&(identical(other.id, id) || other.id == id)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.platformBookId, platformBookId) || other.platformBookId == platformBookId)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.totalWordCount, totalWordCount) || other.totalWordCount == totalWordCount)&&(identical(other.status, status) || other.status == status)&&(identical(other.firstPublishDate, firstPublishDate) || other.firstPublishDate == firstPublishDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,platform,platformBookId,title,author,description,const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(tags),totalWordCount,status,firstPublishDate,createdAt,updatedAt);

@override
String toString() {
  return 'MarketBook(id: $id, platform: $platform, platformBookId: $platformBookId, title: $title, author: $author, description: $description, categories: $categories, tags: $tags, totalWordCount: $totalWordCount, status: $status, firstPublishDate: $firstPublishDate, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MarketBookCopyWith<$Res>  {
  factory $MarketBookCopyWith(MarketBook value, $Res Function(MarketBook) _then) = _$MarketBookCopyWithImpl;
@useResult
$Res call({
 String id, MarketPlatform platform, String platformBookId, String title, String author, String description, List<String> categories, List<String> tags, int totalWordCount, BookStatus status, DateTime? firstPublishDate, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$MarketBookCopyWithImpl<$Res>
    implements $MarketBookCopyWith<$Res> {
  _$MarketBookCopyWithImpl(this._self, this._then);

  final MarketBook _self;
  final $Res Function(MarketBook) _then;

/// Create a copy of MarketBook
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? platform = null,Object? platformBookId = null,Object? title = null,Object? author = null,Object? description = null,Object? categories = null,Object? tags = null,Object? totalWordCount = null,Object? status = null,Object? firstPublishDate = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as MarketPlatform,platformBookId: null == platformBookId ? _self.platformBookId : platformBookId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,totalWordCount: null == totalWordCount ? _self.totalWordCount : totalWordCount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookStatus,firstPublishDate: freezed == firstPublishDate ? _self.firstPublishDate : firstPublishDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MarketBook].
extension MarketBookPatterns on MarketBook {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarketBook value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarketBook() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarketBook value)  $default,){
final _that = this;
switch (_that) {
case _MarketBook():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarketBook value)?  $default,){
final _that = this;
switch (_that) {
case _MarketBook() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  MarketPlatform platform,  String platformBookId,  String title,  String author,  String description,  List<String> categories,  List<String> tags,  int totalWordCount,  BookStatus status,  DateTime? firstPublishDate,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarketBook() when $default != null:
return $default(_that.id,_that.platform,_that.platformBookId,_that.title,_that.author,_that.description,_that.categories,_that.tags,_that.totalWordCount,_that.status,_that.firstPublishDate,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  MarketPlatform platform,  String platformBookId,  String title,  String author,  String description,  List<String> categories,  List<String> tags,  int totalWordCount,  BookStatus status,  DateTime? firstPublishDate,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MarketBook():
return $default(_that.id,_that.platform,_that.platformBookId,_that.title,_that.author,_that.description,_that.categories,_that.tags,_that.totalWordCount,_that.status,_that.firstPublishDate,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  MarketPlatform platform,  String platformBookId,  String title,  String author,  String description,  List<String> categories,  List<String> tags,  int totalWordCount,  BookStatus status,  DateTime? firstPublishDate,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MarketBook() when $default != null:
return $default(_that.id,_that.platform,_that.platformBookId,_that.title,_that.author,_that.description,_that.categories,_that.tags,_that.totalWordCount,_that.status,_that.firstPublishDate,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MarketBook implements MarketBook {
  const _MarketBook({required this.id, required this.platform, required this.platformBookId, required this.title, required this.author, this.description = '', final  List<String> categories = const <String>[], final  List<String> tags = const <String>[], this.totalWordCount = 0, this.status = BookStatus.ongoing, this.firstPublishDate, required this.createdAt, required this.updatedAt}): _categories = categories,_tags = tags;
  factory _MarketBook.fromJson(Map<String, dynamic> json) => _$MarketBookFromJson(json);

@override final  String id;
@override final  MarketPlatform platform;
@override final  String platformBookId;
@override final  String title;
@override final  String author;
@override@JsonKey() final  String description;
 final  List<String> _categories;
@override@JsonKey() List<String> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey() final  int totalWordCount;
@override@JsonKey() final  BookStatus status;
@override final  DateTime? firstPublishDate;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of MarketBook
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarketBookCopyWith<_MarketBook> get copyWith => __$MarketBookCopyWithImpl<_MarketBook>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarketBookToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarketBook&&(identical(other.id, id) || other.id == id)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.platformBookId, platformBookId) || other.platformBookId == platformBookId)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.totalWordCount, totalWordCount) || other.totalWordCount == totalWordCount)&&(identical(other.status, status) || other.status == status)&&(identical(other.firstPublishDate, firstPublishDate) || other.firstPublishDate == firstPublishDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,platform,platformBookId,title,author,description,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_tags),totalWordCount,status,firstPublishDate,createdAt,updatedAt);

@override
String toString() {
  return 'MarketBook(id: $id, platform: $platform, platformBookId: $platformBookId, title: $title, author: $author, description: $description, categories: $categories, tags: $tags, totalWordCount: $totalWordCount, status: $status, firstPublishDate: $firstPublishDate, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MarketBookCopyWith<$Res> implements $MarketBookCopyWith<$Res> {
  factory _$MarketBookCopyWith(_MarketBook value, $Res Function(_MarketBook) _then) = __$MarketBookCopyWithImpl;
@override @useResult
$Res call({
 String id, MarketPlatform platform, String platformBookId, String title, String author, String description, List<String> categories, List<String> tags, int totalWordCount, BookStatus status, DateTime? firstPublishDate, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$MarketBookCopyWithImpl<$Res>
    implements _$MarketBookCopyWith<$Res> {
  __$MarketBookCopyWithImpl(this._self, this._then);

  final _MarketBook _self;
  final $Res Function(_MarketBook) _then;

/// Create a copy of MarketBook
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? platform = null,Object? platformBookId = null,Object? title = null,Object? author = null,Object? description = null,Object? categories = null,Object? tags = null,Object? totalWordCount = null,Object? status = null,Object? firstPublishDate = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_MarketBook(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as MarketPlatform,platformBookId: null == platformBookId ? _self.platformBookId : platformBookId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,totalWordCount: null == totalWordCount ? _self.totalWordCount : totalWordCount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookStatus,firstPublishDate: freezed == firstPublishDate ? _self.firstPublishDate : firstPublishDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
