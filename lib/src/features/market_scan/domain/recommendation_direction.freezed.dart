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

 String get suggestedTitle; List<RecommendationTitleCandidate> get titleCandidates; String get synopsis; List<String> get genreTags; int get targetWordCount; MarketPlatform get targetPlatform; String get targetAudience; String get coreSellingPoint; String get marketHeatSummary; String get competitionSummary; String get marketValidation; String get differentiation; String get feasibility; String get failureRisk; String get validationAction; String get detailMarkdown;
/// Create a copy of RecommendationDirection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendationDirectionCopyWith<RecommendationDirection> get copyWith => _$RecommendationDirectionCopyWithImpl<RecommendationDirection>(this as RecommendationDirection, _$identity);

  /// Serializes this RecommendationDirection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecommendationDirection&&(identical(other.suggestedTitle, suggestedTitle) || other.suggestedTitle == suggestedTitle)&&const DeepCollectionEquality().equals(other.titleCandidates, titleCandidates)&&(identical(other.synopsis, synopsis) || other.synopsis == synopsis)&&const DeepCollectionEquality().equals(other.genreTags, genreTags)&&(identical(other.targetWordCount, targetWordCount) || other.targetWordCount == targetWordCount)&&(identical(other.targetPlatform, targetPlatform) || other.targetPlatform == targetPlatform)&&(identical(other.targetAudience, targetAudience) || other.targetAudience == targetAudience)&&(identical(other.coreSellingPoint, coreSellingPoint) || other.coreSellingPoint == coreSellingPoint)&&(identical(other.marketHeatSummary, marketHeatSummary) || other.marketHeatSummary == marketHeatSummary)&&(identical(other.competitionSummary, competitionSummary) || other.competitionSummary == competitionSummary)&&(identical(other.marketValidation, marketValidation) || other.marketValidation == marketValidation)&&(identical(other.differentiation, differentiation) || other.differentiation == differentiation)&&(identical(other.feasibility, feasibility) || other.feasibility == feasibility)&&(identical(other.failureRisk, failureRisk) || other.failureRisk == failureRisk)&&(identical(other.validationAction, validationAction) || other.validationAction == validationAction)&&(identical(other.detailMarkdown, detailMarkdown) || other.detailMarkdown == detailMarkdown));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,suggestedTitle,const DeepCollectionEquality().hash(titleCandidates),synopsis,const DeepCollectionEquality().hash(genreTags),targetWordCount,targetPlatform,targetAudience,coreSellingPoint,marketHeatSummary,competitionSummary,marketValidation,differentiation,feasibility,failureRisk,validationAction,detailMarkdown);

@override
String toString() {
  return 'RecommendationDirection(suggestedTitle: $suggestedTitle, titleCandidates: $titleCandidates, synopsis: $synopsis, genreTags: $genreTags, targetWordCount: $targetWordCount, targetPlatform: $targetPlatform, targetAudience: $targetAudience, coreSellingPoint: $coreSellingPoint, marketHeatSummary: $marketHeatSummary, competitionSummary: $competitionSummary, marketValidation: $marketValidation, differentiation: $differentiation, feasibility: $feasibility, failureRisk: $failureRisk, validationAction: $validationAction, detailMarkdown: $detailMarkdown)';
}


}

/// @nodoc
abstract mixin class $RecommendationDirectionCopyWith<$Res>  {
  factory $RecommendationDirectionCopyWith(RecommendationDirection value, $Res Function(RecommendationDirection) _then) = _$RecommendationDirectionCopyWithImpl;
@useResult
$Res call({
 String suggestedTitle, List<RecommendationTitleCandidate> titleCandidates, String synopsis, List<String> genreTags, int targetWordCount, MarketPlatform targetPlatform, String targetAudience, String coreSellingPoint, String marketHeatSummary, String competitionSummary, String marketValidation, String differentiation, String feasibility, String failureRisk, String validationAction, String detailMarkdown
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
@pragma('vm:prefer-inline') @override $Res call({Object? suggestedTitle = null,Object? titleCandidates = null,Object? synopsis = null,Object? genreTags = null,Object? targetWordCount = null,Object? targetPlatform = null,Object? targetAudience = null,Object? coreSellingPoint = null,Object? marketHeatSummary = null,Object? competitionSummary = null,Object? marketValidation = null,Object? differentiation = null,Object? feasibility = null,Object? failureRisk = null,Object? validationAction = null,Object? detailMarkdown = null,}) {
  return _then(_self.copyWith(
suggestedTitle: null == suggestedTitle ? _self.suggestedTitle : suggestedTitle // ignore: cast_nullable_to_non_nullable
as String,titleCandidates: null == titleCandidates ? _self.titleCandidates : titleCandidates // ignore: cast_nullable_to_non_nullable
as List<RecommendationTitleCandidate>,synopsis: null == synopsis ? _self.synopsis : synopsis // ignore: cast_nullable_to_non_nullable
as String,genreTags: null == genreTags ? _self.genreTags : genreTags // ignore: cast_nullable_to_non_nullable
as List<String>,targetWordCount: null == targetWordCount ? _self.targetWordCount : targetWordCount // ignore: cast_nullable_to_non_nullable
as int,targetPlatform: null == targetPlatform ? _self.targetPlatform : targetPlatform // ignore: cast_nullable_to_non_nullable
as MarketPlatform,targetAudience: null == targetAudience ? _self.targetAudience : targetAudience // ignore: cast_nullable_to_non_nullable
as String,coreSellingPoint: null == coreSellingPoint ? _self.coreSellingPoint : coreSellingPoint // ignore: cast_nullable_to_non_nullable
as String,marketHeatSummary: null == marketHeatSummary ? _self.marketHeatSummary : marketHeatSummary // ignore: cast_nullable_to_non_nullable
as String,competitionSummary: null == competitionSummary ? _self.competitionSummary : competitionSummary // ignore: cast_nullable_to_non_nullable
as String,marketValidation: null == marketValidation ? _self.marketValidation : marketValidation // ignore: cast_nullable_to_non_nullable
as String,differentiation: null == differentiation ? _self.differentiation : differentiation // ignore: cast_nullable_to_non_nullable
as String,feasibility: null == feasibility ? _self.feasibility : feasibility // ignore: cast_nullable_to_non_nullable
as String,failureRisk: null == failureRisk ? _self.failureRisk : failureRisk // ignore: cast_nullable_to_non_nullable
as String,validationAction: null == validationAction ? _self.validationAction : validationAction // ignore: cast_nullable_to_non_nullable
as String,detailMarkdown: null == detailMarkdown ? _self.detailMarkdown : detailMarkdown // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String suggestedTitle,  List<RecommendationTitleCandidate> titleCandidates,  String synopsis,  List<String> genreTags,  int targetWordCount,  MarketPlatform targetPlatform,  String targetAudience,  String coreSellingPoint,  String marketHeatSummary,  String competitionSummary,  String marketValidation,  String differentiation,  String feasibility,  String failureRisk,  String validationAction,  String detailMarkdown)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecommendationDirection() when $default != null:
return $default(_that.suggestedTitle,_that.titleCandidates,_that.synopsis,_that.genreTags,_that.targetWordCount,_that.targetPlatform,_that.targetAudience,_that.coreSellingPoint,_that.marketHeatSummary,_that.competitionSummary,_that.marketValidation,_that.differentiation,_that.feasibility,_that.failureRisk,_that.validationAction,_that.detailMarkdown);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String suggestedTitle,  List<RecommendationTitleCandidate> titleCandidates,  String synopsis,  List<String> genreTags,  int targetWordCount,  MarketPlatform targetPlatform,  String targetAudience,  String coreSellingPoint,  String marketHeatSummary,  String competitionSummary,  String marketValidation,  String differentiation,  String feasibility,  String failureRisk,  String validationAction,  String detailMarkdown)  $default,) {final _that = this;
switch (_that) {
case _RecommendationDirection():
return $default(_that.suggestedTitle,_that.titleCandidates,_that.synopsis,_that.genreTags,_that.targetWordCount,_that.targetPlatform,_that.targetAudience,_that.coreSellingPoint,_that.marketHeatSummary,_that.competitionSummary,_that.marketValidation,_that.differentiation,_that.feasibility,_that.failureRisk,_that.validationAction,_that.detailMarkdown);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String suggestedTitle,  List<RecommendationTitleCandidate> titleCandidates,  String synopsis,  List<String> genreTags,  int targetWordCount,  MarketPlatform targetPlatform,  String targetAudience,  String coreSellingPoint,  String marketHeatSummary,  String competitionSummary,  String marketValidation,  String differentiation,  String feasibility,  String failureRisk,  String validationAction,  String detailMarkdown)?  $default,) {final _that = this;
switch (_that) {
case _RecommendationDirection() when $default != null:
return $default(_that.suggestedTitle,_that.titleCandidates,_that.synopsis,_that.genreTags,_that.targetWordCount,_that.targetPlatform,_that.targetAudience,_that.coreSellingPoint,_that.marketHeatSummary,_that.competitionSummary,_that.marketValidation,_that.differentiation,_that.feasibility,_that.failureRisk,_that.validationAction,_that.detailMarkdown);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecommendationDirection implements RecommendationDirection {
  const _RecommendationDirection({required this.suggestedTitle, required final  List<RecommendationTitleCandidate> titleCandidates, required this.synopsis, required final  List<String> genreTags, required this.targetWordCount, required this.targetPlatform, required this.targetAudience, required this.coreSellingPoint, required this.marketHeatSummary, required this.competitionSummary, required this.marketValidation, required this.differentiation, required this.feasibility, required this.failureRisk, required this.validationAction, required this.detailMarkdown}): _titleCandidates = titleCandidates,_genreTags = genreTags;
  factory _RecommendationDirection.fromJson(Map<String, dynamic> json) => _$RecommendationDirectionFromJson(json);

@override final  String suggestedTitle;
 final  List<RecommendationTitleCandidate> _titleCandidates;
@override List<RecommendationTitleCandidate> get titleCandidates {
  if (_titleCandidates is EqualUnmodifiableListView) return _titleCandidates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_titleCandidates);
}

@override final  String synopsis;
 final  List<String> _genreTags;
@override List<String> get genreTags {
  if (_genreTags is EqualUnmodifiableListView) return _genreTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genreTags);
}

@override final  int targetWordCount;
@override final  MarketPlatform targetPlatform;
@override final  String targetAudience;
@override final  String coreSellingPoint;
@override final  String marketHeatSummary;
@override final  String competitionSummary;
@override final  String marketValidation;
@override final  String differentiation;
@override final  String feasibility;
@override final  String failureRisk;
@override final  String validationAction;
@override final  String detailMarkdown;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecommendationDirection&&(identical(other.suggestedTitle, suggestedTitle) || other.suggestedTitle == suggestedTitle)&&const DeepCollectionEquality().equals(other._titleCandidates, _titleCandidates)&&(identical(other.synopsis, synopsis) || other.synopsis == synopsis)&&const DeepCollectionEquality().equals(other._genreTags, _genreTags)&&(identical(other.targetWordCount, targetWordCount) || other.targetWordCount == targetWordCount)&&(identical(other.targetPlatform, targetPlatform) || other.targetPlatform == targetPlatform)&&(identical(other.targetAudience, targetAudience) || other.targetAudience == targetAudience)&&(identical(other.coreSellingPoint, coreSellingPoint) || other.coreSellingPoint == coreSellingPoint)&&(identical(other.marketHeatSummary, marketHeatSummary) || other.marketHeatSummary == marketHeatSummary)&&(identical(other.competitionSummary, competitionSummary) || other.competitionSummary == competitionSummary)&&(identical(other.marketValidation, marketValidation) || other.marketValidation == marketValidation)&&(identical(other.differentiation, differentiation) || other.differentiation == differentiation)&&(identical(other.feasibility, feasibility) || other.feasibility == feasibility)&&(identical(other.failureRisk, failureRisk) || other.failureRisk == failureRisk)&&(identical(other.validationAction, validationAction) || other.validationAction == validationAction)&&(identical(other.detailMarkdown, detailMarkdown) || other.detailMarkdown == detailMarkdown));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,suggestedTitle,const DeepCollectionEquality().hash(_titleCandidates),synopsis,const DeepCollectionEquality().hash(_genreTags),targetWordCount,targetPlatform,targetAudience,coreSellingPoint,marketHeatSummary,competitionSummary,marketValidation,differentiation,feasibility,failureRisk,validationAction,detailMarkdown);

@override
String toString() {
  return 'RecommendationDirection(suggestedTitle: $suggestedTitle, titleCandidates: $titleCandidates, synopsis: $synopsis, genreTags: $genreTags, targetWordCount: $targetWordCount, targetPlatform: $targetPlatform, targetAudience: $targetAudience, coreSellingPoint: $coreSellingPoint, marketHeatSummary: $marketHeatSummary, competitionSummary: $competitionSummary, marketValidation: $marketValidation, differentiation: $differentiation, feasibility: $feasibility, failureRisk: $failureRisk, validationAction: $validationAction, detailMarkdown: $detailMarkdown)';
}


}

/// @nodoc
abstract mixin class _$RecommendationDirectionCopyWith<$Res> implements $RecommendationDirectionCopyWith<$Res> {
  factory _$RecommendationDirectionCopyWith(_RecommendationDirection value, $Res Function(_RecommendationDirection) _then) = __$RecommendationDirectionCopyWithImpl;
@override @useResult
$Res call({
 String suggestedTitle, List<RecommendationTitleCandidate> titleCandidates, String synopsis, List<String> genreTags, int targetWordCount, MarketPlatform targetPlatform, String targetAudience, String coreSellingPoint, String marketHeatSummary, String competitionSummary, String marketValidation, String differentiation, String feasibility, String failureRisk, String validationAction, String detailMarkdown
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
@override @pragma('vm:prefer-inline') $Res call({Object? suggestedTitle = null,Object? titleCandidates = null,Object? synopsis = null,Object? genreTags = null,Object? targetWordCount = null,Object? targetPlatform = null,Object? targetAudience = null,Object? coreSellingPoint = null,Object? marketHeatSummary = null,Object? competitionSummary = null,Object? marketValidation = null,Object? differentiation = null,Object? feasibility = null,Object? failureRisk = null,Object? validationAction = null,Object? detailMarkdown = null,}) {
  return _then(_RecommendationDirection(
suggestedTitle: null == suggestedTitle ? _self.suggestedTitle : suggestedTitle // ignore: cast_nullable_to_non_nullable
as String,titleCandidates: null == titleCandidates ? _self._titleCandidates : titleCandidates // ignore: cast_nullable_to_non_nullable
as List<RecommendationTitleCandidate>,synopsis: null == synopsis ? _self.synopsis : synopsis // ignore: cast_nullable_to_non_nullable
as String,genreTags: null == genreTags ? _self._genreTags : genreTags // ignore: cast_nullable_to_non_nullable
as List<String>,targetWordCount: null == targetWordCount ? _self.targetWordCount : targetWordCount // ignore: cast_nullable_to_non_nullable
as int,targetPlatform: null == targetPlatform ? _self.targetPlatform : targetPlatform // ignore: cast_nullable_to_non_nullable
as MarketPlatform,targetAudience: null == targetAudience ? _self.targetAudience : targetAudience // ignore: cast_nullable_to_non_nullable
as String,coreSellingPoint: null == coreSellingPoint ? _self.coreSellingPoint : coreSellingPoint // ignore: cast_nullable_to_non_nullable
as String,marketHeatSummary: null == marketHeatSummary ? _self.marketHeatSummary : marketHeatSummary // ignore: cast_nullable_to_non_nullable
as String,competitionSummary: null == competitionSummary ? _self.competitionSummary : competitionSummary // ignore: cast_nullable_to_non_nullable
as String,marketValidation: null == marketValidation ? _self.marketValidation : marketValidation // ignore: cast_nullable_to_non_nullable
as String,differentiation: null == differentiation ? _self.differentiation : differentiation // ignore: cast_nullable_to_non_nullable
as String,feasibility: null == feasibility ? _self.feasibility : feasibility // ignore: cast_nullable_to_non_nullable
as String,failureRisk: null == failureRisk ? _self.failureRisk : failureRisk // ignore: cast_nullable_to_non_nullable
as String,validationAction: null == validationAction ? _self.validationAction : validationAction // ignore: cast_nullable_to_non_nullable
as String,detailMarkdown: null == detailMarkdown ? _self.detailMarkdown : detailMarkdown // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RecommendationTitleCandidate {

 String get title; String get formula; String get rationale;
/// Create a copy of RecommendationTitleCandidate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendationTitleCandidateCopyWith<RecommendationTitleCandidate> get copyWith => _$RecommendationTitleCandidateCopyWithImpl<RecommendationTitleCandidate>(this as RecommendationTitleCandidate, _$identity);

  /// Serializes this RecommendationTitleCandidate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecommendationTitleCandidate&&(identical(other.title, title) || other.title == title)&&(identical(other.formula, formula) || other.formula == formula)&&(identical(other.rationale, rationale) || other.rationale == rationale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,formula,rationale);

@override
String toString() {
  return 'RecommendationTitleCandidate(title: $title, formula: $formula, rationale: $rationale)';
}


}

/// @nodoc
abstract mixin class $RecommendationTitleCandidateCopyWith<$Res>  {
  factory $RecommendationTitleCandidateCopyWith(RecommendationTitleCandidate value, $Res Function(RecommendationTitleCandidate) _then) = _$RecommendationTitleCandidateCopyWithImpl;
@useResult
$Res call({
 String title, String formula, String rationale
});




}
/// @nodoc
class _$RecommendationTitleCandidateCopyWithImpl<$Res>
    implements $RecommendationTitleCandidateCopyWith<$Res> {
  _$RecommendationTitleCandidateCopyWithImpl(this._self, this._then);

  final RecommendationTitleCandidate _self;
  final $Res Function(RecommendationTitleCandidate) _then;

/// Create a copy of RecommendationTitleCandidate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? formula = null,Object? rationale = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,formula: null == formula ? _self.formula : formula // ignore: cast_nullable_to_non_nullable
as String,rationale: null == rationale ? _self.rationale : rationale // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RecommendationTitleCandidate].
extension RecommendationTitleCandidatePatterns on RecommendationTitleCandidate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecommendationTitleCandidate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecommendationTitleCandidate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecommendationTitleCandidate value)  $default,){
final _that = this;
switch (_that) {
case _RecommendationTitleCandidate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecommendationTitleCandidate value)?  $default,){
final _that = this;
switch (_that) {
case _RecommendationTitleCandidate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String formula,  String rationale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecommendationTitleCandidate() when $default != null:
return $default(_that.title,_that.formula,_that.rationale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String formula,  String rationale)  $default,) {final _that = this;
switch (_that) {
case _RecommendationTitleCandidate():
return $default(_that.title,_that.formula,_that.rationale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String formula,  String rationale)?  $default,) {final _that = this;
switch (_that) {
case _RecommendationTitleCandidate() when $default != null:
return $default(_that.title,_that.formula,_that.rationale);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecommendationTitleCandidate implements RecommendationTitleCandidate {
  const _RecommendationTitleCandidate({required this.title, required this.formula, required this.rationale});
  factory _RecommendationTitleCandidate.fromJson(Map<String, dynamic> json) => _$RecommendationTitleCandidateFromJson(json);

@override final  String title;
@override final  String formula;
@override final  String rationale;

/// Create a copy of RecommendationTitleCandidate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendationTitleCandidateCopyWith<_RecommendationTitleCandidate> get copyWith => __$RecommendationTitleCandidateCopyWithImpl<_RecommendationTitleCandidate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecommendationTitleCandidateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecommendationTitleCandidate&&(identical(other.title, title) || other.title == title)&&(identical(other.formula, formula) || other.formula == formula)&&(identical(other.rationale, rationale) || other.rationale == rationale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,formula,rationale);

@override
String toString() {
  return 'RecommendationTitleCandidate(title: $title, formula: $formula, rationale: $rationale)';
}


}

/// @nodoc
abstract mixin class _$RecommendationTitleCandidateCopyWith<$Res> implements $RecommendationTitleCandidateCopyWith<$Res> {
  factory _$RecommendationTitleCandidateCopyWith(_RecommendationTitleCandidate value, $Res Function(_RecommendationTitleCandidate) _then) = __$RecommendationTitleCandidateCopyWithImpl;
@override @useResult
$Res call({
 String title, String formula, String rationale
});




}
/// @nodoc
class __$RecommendationTitleCandidateCopyWithImpl<$Res>
    implements _$RecommendationTitleCandidateCopyWith<$Res> {
  __$RecommendationTitleCandidateCopyWithImpl(this._self, this._then);

  final _RecommendationTitleCandidate _self;
  final $Res Function(_RecommendationTitleCandidate) _then;

/// Create a copy of RecommendationTitleCandidate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? formula = null,Object? rationale = null,}) {
  return _then(_RecommendationTitleCandidate(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,formula: null == formula ? _self.formula : formula // ignore: cast_nullable_to_non_nullable
as String,rationale: null == rationale ? _self.rationale : rationale // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
