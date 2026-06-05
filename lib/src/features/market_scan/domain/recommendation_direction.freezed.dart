// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation_direction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecommendationDirection {

 String get suggestedTitle; String get synopsis; List<String> get genreTags; int get targetWordCount; String get marketHeatSummary; String get competitionSummary;
/// Create a copy of RecommendationDirection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendationDirectionCopyWith<RecommendationDirection> get copyWith => _$RecommendationDirectionCopyWithImpl<RecommendationDirection>(this as RecommendationDirection, _$identity);

  /// Serializes this RecommendationDirection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecommendationDirection&&(identical(other.suggestedTitle, suggestedTitle) || other.suggestedTitle == suggestedTitle)&&(identical(other.synopsis, synopsis) || other.synopsis == synopsis)&&const DeepCollectionEquality().equals(other.genreTags, genreTags)&&(identical(other.targetWordCount, targetWordCount) || other.targetWordCount == targetWordCount)&&(identical(other.marketHeatSummary, marketHeatSummary) || other.marketHeatSummary == marketHeatSummary)&&(identical(other.competitionSummary, competitionSummary) || other.competitionSummary == competitionSummary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,suggestedTitle,synopsis,const DeepCollectionEquality().hash(genreTags),targetWordCount,marketHeatSummary,competitionSummary);

@override
String toString() {
  return 'RecommendationDirection(suggestedTitle: $suggestedTitle, synopsis: $synopsis, genreTags: $genreTags, targetWordCount: $targetWordCount, marketHeatSummary: $marketHeatSummary, competitionSummary: $competitionSummary)';
}


}

/// @nodoc
abstract mixin class $RecommendationDirectionCopyWith<$Res>  {
  factory $RecommendationDirectionCopyWith(RecommendationDirection value, $Res Function(RecommendationDirection) _then) = _$RecommendationDirectionCopyWithImpl;
@useResult
$Res call({
 String suggestedTitle, String synopsis, List<String> genreTags, int targetWordCount, String marketHeatSummary, String competitionSummary
});




}
/// @nodoc
class _$RecommendationDirectionCopyWithImpl<$Res>
    implements $RecommendationDirectionCopyWith<$Res> {
  _$RecommendationDirectionCopyWithImpl(this._self, this._then);

  final RecommendationDirection _self;
  final $Res Function(RecommendationDirection) _then;

/// Create a copy of RecommendationDirection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? suggestedTitle = null,Object? synopsis = null,Object? genreTags = null,Object? targetWordCount = null,Object? marketHeatSummary = null,Object? competitionSummary = null,}) {
  return _then(_self.copyWith(
suggestedTitle: null == suggestedTitle ? _self.suggestedTitle : suggestedTitle // ignore: cast_nullable_to_non_nullable
as String,synopsis: null == synopsis ? _self.synopsis : synopsis // ignore: cast_nullable_to_non_nullable
as String,genreTags: null == genreTags ? _self.genreTags : genreTags // ignore: cast_nullable_to_non_nullable
as List<String>,targetWordCount: null == targetWordCount ? _self.targetWordCount : targetWordCount // ignore: cast_nullable_to_non_nullable
as int,marketHeatSummary: null == marketHeatSummary ? _self.marketHeatSummary : marketHeatSummary // ignore: cast_nullable_to_non_nullable
as String,competitionSummary: null == competitionSummary ? _self.competitionSummary : competitionSummary // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RecommendationDirection].
extension RecommendationDirectionPatterns on RecommendationDirection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecommendationDirection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecommendationDirection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecommendationDirection value)  $default,){
final _that = this;
switch (_that) {
case _RecommendationDirection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecommendationDirection value)?  $default,){
final _that = this;
switch (_that) {
case _RecommendationDirection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String suggestedTitle,  String synopsis,  List<String> genreTags,  int targetWordCount,  String marketHeatSummary,  String competitionSummary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecommendationDirection() when $default != null:
return $default(_that.suggestedTitle,_that.synopsis,_that.genreTags,_that.targetWordCount,_that.marketHeatSummary,_that.competitionSummary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String suggestedTitle,  String synopsis,  List<String> genreTags,  int targetWordCount,  String marketHeatSummary,  String competitionSummary)  $default,) {final _that = this;
switch (_that) {
case _RecommendationDirection():
return $default(_that.suggestedTitle,_that.synopsis,_that.genreTags,_that.targetWordCount,_that.marketHeatSummary,_that.competitionSummary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String suggestedTitle,  String synopsis,  List<String> genreTags,  int targetWordCount,  String marketHeatSummary,  String competitionSummary)?  $default,) {final _that = this;
switch (_that) {
case _RecommendationDirection() when $default != null:
return $default(_that.suggestedTitle,_that.synopsis,_that.genreTags,_that.targetWordCount,_that.marketHeatSummary,_that.competitionSummary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecommendationDirection implements RecommendationDirection {
  const _RecommendationDirection({required this.suggestedTitle, required this.synopsis, required final  List<String> genreTags, required this.targetWordCount, required this.marketHeatSummary, required this.competitionSummary}): _genreTags = genreTags;
  factory _RecommendationDirection.fromJson(Map<String, dynamic> json) => _$RecommendationDirectionFromJson(json);

@override final  String suggestedTitle;
@override final  String synopsis;
 final  List<String> _genreTags;
@override List<String> get genreTags {
  if (_genreTags is EqualUnmodifiableListView) return _genreTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genreTags);
}

@override final  int targetWordCount;
@override final  String marketHeatSummary;
@override final  String competitionSummary;

/// Create a copy of RecommendationDirection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendationDirectionCopyWith<_RecommendationDirection> get copyWith => __$RecommendationDirectionCopyWithImpl<_RecommendationDirection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecommendationDirectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecommendationDirection&&(identical(other.suggestedTitle, suggestedTitle) || other.suggestedTitle == suggestedTitle)&&(identical(other.synopsis, synopsis) || other.synopsis == synopsis)&&const DeepCollectionEquality().equals(other._genreTags, _genreTags)&&(identical(other.targetWordCount, targetWordCount) || other.targetWordCount == targetWordCount)&&(identical(other.marketHeatSummary, marketHeatSummary) || other.marketHeatSummary == marketHeatSummary)&&(identical(other.competitionSummary, competitionSummary) || other.competitionSummary == competitionSummary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,suggestedTitle,synopsis,const DeepCollectionEquality().hash(_genreTags),targetWordCount,marketHeatSummary,competitionSummary);

@override
String toString() {
  return 'RecommendationDirection(suggestedTitle: $suggestedTitle, synopsis: $synopsis, genreTags: $genreTags, targetWordCount: $targetWordCount, marketHeatSummary: $marketHeatSummary, competitionSummary: $competitionSummary)';
}


}

/// @nodoc
abstract mixin class _$RecommendationDirectionCopyWith<$Res> implements $RecommendationDirectionCopyWith<$Res> {
  factory _$RecommendationDirectionCopyWith(_RecommendationDirection value, $Res Function(_RecommendationDirection) _then) = __$RecommendationDirectionCopyWithImpl;
@override @useResult
$Res call({
 String suggestedTitle, String synopsis, List<String> genreTags, int targetWordCount, String marketHeatSummary, String competitionSummary
});




}
/// @nodoc
class __$RecommendationDirectionCopyWithImpl<$Res>
    implements _$RecommendationDirectionCopyWith<$Res> {
  __$RecommendationDirectionCopyWithImpl(this._self, this._then);

  final _RecommendationDirection _self;
  final $Res Function(_RecommendationDirection) _then;

/// Create a copy of RecommendationDirection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? suggestedTitle = null,Object? synopsis = null,Object? genreTags = null,Object? targetWordCount = null,Object? marketHeatSummary = null,Object? competitionSummary = null,}) {
  return _then(_RecommendationDirection(
suggestedTitle: null == suggestedTitle ? _self.suggestedTitle : suggestedTitle // ignore: cast_nullable_to_non_nullable
as String,synopsis: null == synopsis ? _self.synopsis : synopsis // ignore: cast_nullable_to_non_nullable
as String,genreTags: null == genreTags ? _self._genreTags : genreTags // ignore: cast_nullable_to_non_nullable
as List<String>,targetWordCount: null == targetWordCount ? _self.targetWordCount : targetWordCount // ignore: cast_nullable_to_non_nullable
as int,marketHeatSummary: null == marketHeatSummary ? _self.marketHeatSummary : marketHeatSummary // ignore: cast_nullable_to_non_nullable
as String,competitionSummary: null == competitionSummary ? _self.competitionSummary : competitionSummary // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
