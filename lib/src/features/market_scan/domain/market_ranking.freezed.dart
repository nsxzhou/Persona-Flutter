// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'market_ranking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MarketRanking {

 String get id; String get bookId; String get chartName; int get rank; String get runId; int? get favorites; int? get recommendVotes; int? get monthlyTickets; int? get commentCount; DateTime get scrapedAt; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of MarketRanking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketRankingCopyWith<MarketRanking> get copyWith => _$MarketRankingCopyWithImpl<MarketRanking>(this as MarketRanking, _$identity);

  /// Serializes this MarketRanking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarketRanking&&(identical(other.id, id) || other.id == id)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.chartName, chartName) || other.chartName == chartName)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.runId, runId) || other.runId == runId)&&(identical(other.favorites, favorites) || other.favorites == favorites)&&(identical(other.recommendVotes, recommendVotes) || other.recommendVotes == recommendVotes)&&(identical(other.monthlyTickets, monthlyTickets) || other.monthlyTickets == monthlyTickets)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.scrapedAt, scrapedAt) || other.scrapedAt == scrapedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bookId,chartName,rank,runId,favorites,recommendVotes,monthlyTickets,commentCount,scrapedAt,createdAt,updatedAt);

@override
String toString() {
  return 'MarketRanking(id: $id, bookId: $bookId, chartName: $chartName, rank: $rank, runId: $runId, favorites: $favorites, recommendVotes: $recommendVotes, monthlyTickets: $monthlyTickets, commentCount: $commentCount, scrapedAt: $scrapedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MarketRankingCopyWith<$Res>  {
  factory $MarketRankingCopyWith(MarketRanking value, $Res Function(MarketRanking) _then) = _$MarketRankingCopyWithImpl;
@useResult
$Res call({
 String id, String bookId, String chartName, int rank, String runId, int? favorites, int? recommendVotes, int? monthlyTickets, int? commentCount, DateTime scrapedAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$MarketRankingCopyWithImpl<$Res>
    implements $MarketRankingCopyWith<$Res> {
  _$MarketRankingCopyWithImpl(this._self, this._then);

  final MarketRanking _self;
  final $Res Function(MarketRanking) _then;

/// Create a copy of MarketRanking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? bookId = null,Object? chartName = null,Object? rank = null,Object? runId = null,Object? favorites = freezed,Object? recommendVotes = freezed,Object? monthlyTickets = freezed,Object? commentCount = freezed,Object? scrapedAt = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as String,chartName: null == chartName ? _self.chartName : chartName // ignore: cast_nullable_to_non_nullable
as String,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,runId: null == runId ? _self.runId : runId // ignore: cast_nullable_to_non_nullable
as String,favorites: freezed == favorites ? _self.favorites : favorites // ignore: cast_nullable_to_non_nullable
as int?,recommendVotes: freezed == recommendVotes ? _self.recommendVotes : recommendVotes // ignore: cast_nullable_to_non_nullable
as int?,monthlyTickets: freezed == monthlyTickets ? _self.monthlyTickets : monthlyTickets // ignore: cast_nullable_to_non_nullable
as int?,commentCount: freezed == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int?,scrapedAt: null == scrapedAt ? _self.scrapedAt : scrapedAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MarketRanking].
extension MarketRankingPatterns on MarketRanking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarketRanking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarketRanking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarketRanking value)  $default,){
final _that = this;
switch (_that) {
case _MarketRanking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarketRanking value)?  $default,){
final _that = this;
switch (_that) {
case _MarketRanking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String bookId,  String chartName,  int rank,  String runId,  int? favorites,  int? recommendVotes,  int? monthlyTickets,  int? commentCount,  DateTime scrapedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarketRanking() when $default != null:
return $default(_that.id,_that.bookId,_that.chartName,_that.rank,_that.runId,_that.favorites,_that.recommendVotes,_that.monthlyTickets,_that.commentCount,_that.scrapedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String bookId,  String chartName,  int rank,  String runId,  int? favorites,  int? recommendVotes,  int? monthlyTickets,  int? commentCount,  DateTime scrapedAt,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MarketRanking():
return $default(_that.id,_that.bookId,_that.chartName,_that.rank,_that.runId,_that.favorites,_that.recommendVotes,_that.monthlyTickets,_that.commentCount,_that.scrapedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String bookId,  String chartName,  int rank,  String runId,  int? favorites,  int? recommendVotes,  int? monthlyTickets,  int? commentCount,  DateTime scrapedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MarketRanking() when $default != null:
return $default(_that.id,_that.bookId,_that.chartName,_that.rank,_that.runId,_that.favorites,_that.recommendVotes,_that.monthlyTickets,_that.commentCount,_that.scrapedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MarketRanking implements MarketRanking {
  const _MarketRanking({required this.id, required this.bookId, required this.chartName, required this.rank, required this.runId, this.favorites, this.recommendVotes, this.monthlyTickets, this.commentCount, required this.scrapedAt, required this.createdAt, required this.updatedAt});
  factory _MarketRanking.fromJson(Map<String, dynamic> json) => _$MarketRankingFromJson(json);

@override final  String id;
@override final  String bookId;
@override final  String chartName;
@override final  int rank;
@override final  String runId;
@override final  int? favorites;
@override final  int? recommendVotes;
@override final  int? monthlyTickets;
@override final  int? commentCount;
@override final  DateTime scrapedAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of MarketRanking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarketRankingCopyWith<_MarketRanking> get copyWith => __$MarketRankingCopyWithImpl<_MarketRanking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarketRankingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarketRanking&&(identical(other.id, id) || other.id == id)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.chartName, chartName) || other.chartName == chartName)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.runId, runId) || other.runId == runId)&&(identical(other.favorites, favorites) || other.favorites == favorites)&&(identical(other.recommendVotes, recommendVotes) || other.recommendVotes == recommendVotes)&&(identical(other.monthlyTickets, monthlyTickets) || other.monthlyTickets == monthlyTickets)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.scrapedAt, scrapedAt) || other.scrapedAt == scrapedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bookId,chartName,rank,runId,favorites,recommendVotes,monthlyTickets,commentCount,scrapedAt,createdAt,updatedAt);

@override
String toString() {
  return 'MarketRanking(id: $id, bookId: $bookId, chartName: $chartName, rank: $rank, runId: $runId, favorites: $favorites, recommendVotes: $recommendVotes, monthlyTickets: $monthlyTickets, commentCount: $commentCount, scrapedAt: $scrapedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MarketRankingCopyWith<$Res> implements $MarketRankingCopyWith<$Res> {
  factory _$MarketRankingCopyWith(_MarketRanking value, $Res Function(_MarketRanking) _then) = __$MarketRankingCopyWithImpl;
@override @useResult
$Res call({
 String id, String bookId, String chartName, int rank, String runId, int? favorites, int? recommendVotes, int? monthlyTickets, int? commentCount, DateTime scrapedAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$MarketRankingCopyWithImpl<$Res>
    implements _$MarketRankingCopyWith<$Res> {
  __$MarketRankingCopyWithImpl(this._self, this._then);

  final _MarketRanking _self;
  final $Res Function(_MarketRanking) _then;

/// Create a copy of MarketRanking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? bookId = null,Object? chartName = null,Object? rank = null,Object? runId = null,Object? favorites = freezed,Object? recommendVotes = freezed,Object? monthlyTickets = freezed,Object? commentCount = freezed,Object? scrapedAt = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_MarketRanking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as String,chartName: null == chartName ? _self.chartName : chartName // ignore: cast_nullable_to_non_nullable
as String,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,runId: null == runId ? _self.runId : runId // ignore: cast_nullable_to_non_nullable
as String,favorites: freezed == favorites ? _self.favorites : favorites // ignore: cast_nullable_to_non_nullable
as int?,recommendVotes: freezed == recommendVotes ? _self.recommendVotes : recommendVotes // ignore: cast_nullable_to_non_nullable
as int?,monthlyTickets: freezed == monthlyTickets ? _self.monthlyTickets : monthlyTickets // ignore: cast_nullable_to_non_nullable
as int?,commentCount: freezed == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int?,scrapedAt: null == scrapedAt ? _self.scrapedAt : scrapedAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
