// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'story_bible.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StoryBible {

 String get id; String get projectId; String get authorIntent; String get currentFocus; String get worldMarkdown; String get charactersMarkdown; String get rulesMarkdown; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of StoryBible
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoryBibleCopyWith<StoryBible> get copyWith => _$StoryBibleCopyWithImpl<StoryBible>(this as StoryBible, _$identity);

  /// Serializes this StoryBible to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoryBible&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.authorIntent, authorIntent) || other.authorIntent == authorIntent)&&(identical(other.currentFocus, currentFocus) || other.currentFocus == currentFocus)&&(identical(other.worldMarkdown, worldMarkdown) || other.worldMarkdown == worldMarkdown)&&(identical(other.charactersMarkdown, charactersMarkdown) || other.charactersMarkdown == charactersMarkdown)&&(identical(other.rulesMarkdown, rulesMarkdown) || other.rulesMarkdown == rulesMarkdown)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,authorIntent,currentFocus,worldMarkdown,charactersMarkdown,rulesMarkdown,createdAt,updatedAt);

@override
String toString() {
  return 'StoryBible(id: $id, projectId: $projectId, authorIntent: $authorIntent, currentFocus: $currentFocus, worldMarkdown: $worldMarkdown, charactersMarkdown: $charactersMarkdown, rulesMarkdown: $rulesMarkdown, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $StoryBibleCopyWith<$Res>  {
  factory $StoryBibleCopyWith(StoryBible value, $Res Function(StoryBible) _then) = _$StoryBibleCopyWithImpl;
@useResult
$Res call({
 String id, String projectId, String authorIntent, String currentFocus, String worldMarkdown, String charactersMarkdown, String rulesMarkdown, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$StoryBibleCopyWithImpl<$Res>
    implements $StoryBibleCopyWith<$Res> {
  _$StoryBibleCopyWithImpl(this._self, this._then);

  final StoryBible _self;
  final $Res Function(StoryBible) _then;

/// Create a copy of StoryBible
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? projectId = null,Object? authorIntent = null,Object? currentFocus = null,Object? worldMarkdown = null,Object? charactersMarkdown = null,Object? rulesMarkdown = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,authorIntent: null == authorIntent ? _self.authorIntent : authorIntent // ignore: cast_nullable_to_non_nullable
as String,currentFocus: null == currentFocus ? _self.currentFocus : currentFocus // ignore: cast_nullable_to_non_nullable
as String,worldMarkdown: null == worldMarkdown ? _self.worldMarkdown : worldMarkdown // ignore: cast_nullable_to_non_nullable
as String,charactersMarkdown: null == charactersMarkdown ? _self.charactersMarkdown : charactersMarkdown // ignore: cast_nullable_to_non_nullable
as String,rulesMarkdown: null == rulesMarkdown ? _self.rulesMarkdown : rulesMarkdown // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [StoryBible].
extension StoryBiblePatterns on StoryBible {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoryBible value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoryBible() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoryBible value)  $default,){
final _that = this;
switch (_that) {
case _StoryBible():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoryBible value)?  $default,){
final _that = this;
switch (_that) {
case _StoryBible() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String projectId,  String authorIntent,  String currentFocus,  String worldMarkdown,  String charactersMarkdown,  String rulesMarkdown,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoryBible() when $default != null:
return $default(_that.id,_that.projectId,_that.authorIntent,_that.currentFocus,_that.worldMarkdown,_that.charactersMarkdown,_that.rulesMarkdown,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String projectId,  String authorIntent,  String currentFocus,  String worldMarkdown,  String charactersMarkdown,  String rulesMarkdown,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _StoryBible():
return $default(_that.id,_that.projectId,_that.authorIntent,_that.currentFocus,_that.worldMarkdown,_that.charactersMarkdown,_that.rulesMarkdown,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String projectId,  String authorIntent,  String currentFocus,  String worldMarkdown,  String charactersMarkdown,  String rulesMarkdown,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _StoryBible() when $default != null:
return $default(_that.id,_that.projectId,_that.authorIntent,_that.currentFocus,_that.worldMarkdown,_that.charactersMarkdown,_that.rulesMarkdown,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StoryBible implements StoryBible {
  const _StoryBible({required this.id, required this.projectId, this.authorIntent = '', this.currentFocus = '', this.worldMarkdown = '', this.charactersMarkdown = '', this.rulesMarkdown = '', required this.createdAt, required this.updatedAt});
  factory _StoryBible.fromJson(Map<String, dynamic> json) => _$StoryBibleFromJson(json);

@override final  String id;
@override final  String projectId;
@override@JsonKey() final  String authorIntent;
@override@JsonKey() final  String currentFocus;
@override@JsonKey() final  String worldMarkdown;
@override@JsonKey() final  String charactersMarkdown;
@override@JsonKey() final  String rulesMarkdown;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of StoryBible
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoryBibleCopyWith<_StoryBible> get copyWith => __$StoryBibleCopyWithImpl<_StoryBible>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoryBibleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoryBible&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.authorIntent, authorIntent) || other.authorIntent == authorIntent)&&(identical(other.currentFocus, currentFocus) || other.currentFocus == currentFocus)&&(identical(other.worldMarkdown, worldMarkdown) || other.worldMarkdown == worldMarkdown)&&(identical(other.charactersMarkdown, charactersMarkdown) || other.charactersMarkdown == charactersMarkdown)&&(identical(other.rulesMarkdown, rulesMarkdown) || other.rulesMarkdown == rulesMarkdown)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,authorIntent,currentFocus,worldMarkdown,charactersMarkdown,rulesMarkdown,createdAt,updatedAt);

@override
String toString() {
  return 'StoryBible(id: $id, projectId: $projectId, authorIntent: $authorIntent, currentFocus: $currentFocus, worldMarkdown: $worldMarkdown, charactersMarkdown: $charactersMarkdown, rulesMarkdown: $rulesMarkdown, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$StoryBibleCopyWith<$Res> implements $StoryBibleCopyWith<$Res> {
  factory _$StoryBibleCopyWith(_StoryBible value, $Res Function(_StoryBible) _then) = __$StoryBibleCopyWithImpl;
@override @useResult
$Res call({
 String id, String projectId, String authorIntent, String currentFocus, String worldMarkdown, String charactersMarkdown, String rulesMarkdown, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$StoryBibleCopyWithImpl<$Res>
    implements _$StoryBibleCopyWith<$Res> {
  __$StoryBibleCopyWithImpl(this._self, this._then);

  final _StoryBible _self;
  final $Res Function(_StoryBible) _then;

/// Create a copy of StoryBible
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? projectId = null,Object? authorIntent = null,Object? currentFocus = null,Object? worldMarkdown = null,Object? charactersMarkdown = null,Object? rulesMarkdown = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_StoryBible(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,authorIntent: null == authorIntent ? _self.authorIntent : authorIntent // ignore: cast_nullable_to_non_nullable
as String,currentFocus: null == currentFocus ? _self.currentFocus : currentFocus // ignore: cast_nullable_to_non_nullable
as String,worldMarkdown: null == worldMarkdown ? _self.worldMarkdown : worldMarkdown // ignore: cast_nullable_to_non_nullable
as String,charactersMarkdown: null == charactersMarkdown ? _self.charactersMarkdown : charactersMarkdown // ignore: cast_nullable_to_non_nullable
as String,rulesMarkdown: null == rulesMarkdown ? _self.rulesMarkdown : rulesMarkdown // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
