// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'provider_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProviderConfig {

 String get id; String get name; String get baseUrl; String get apiKey; String get defaultModel; String get systemPrompt; bool get isEnabled; ProviderTestStatus get testStatus; DateTime? get lastTestedAt; String? get lastTestMessage; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of ProviderConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderConfigCopyWith<ProviderConfig> get copyWith => _$ProviderConfigCopyWithImpl<ProviderConfig>(this as ProviderConfig, _$identity);

  /// Serializes this ProviderConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.apiKey, apiKey) || other.apiKey == apiKey)&&(identical(other.defaultModel, defaultModel) || other.defaultModel == defaultModel)&&(identical(other.systemPrompt, systemPrompt) || other.systemPrompt == systemPrompt)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.testStatus, testStatus) || other.testStatus == testStatus)&&(identical(other.lastTestedAt, lastTestedAt) || other.lastTestedAt == lastTestedAt)&&(identical(other.lastTestMessage, lastTestMessage) || other.lastTestMessage == lastTestMessage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,baseUrl,apiKey,defaultModel,systemPrompt,isEnabled,testStatus,lastTestedAt,lastTestMessage,createdAt,updatedAt);

@override
String toString() {
  return 'ProviderConfig(id: $id, name: $name, baseUrl: $baseUrl, apiKey: $apiKey, defaultModel: $defaultModel, systemPrompt: $systemPrompt, isEnabled: $isEnabled, testStatus: $testStatus, lastTestedAt: $lastTestedAt, lastTestMessage: $lastTestMessage, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProviderConfigCopyWith<$Res>  {
  factory $ProviderConfigCopyWith(ProviderConfig value, $Res Function(ProviderConfig) _then) = _$ProviderConfigCopyWithImpl;
@useResult
$Res call({
 String id, String name, String baseUrl, String apiKey, String defaultModel, String systemPrompt, bool isEnabled, ProviderTestStatus testStatus, DateTime? lastTestedAt, String? lastTestMessage, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$ProviderConfigCopyWithImpl<$Res>
    implements $ProviderConfigCopyWith<$Res> {
  _$ProviderConfigCopyWithImpl(this._self, this._then);

  final ProviderConfig _self;
  final $Res Function(ProviderConfig) _then;

/// Create a copy of ProviderConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? baseUrl = null,Object? apiKey = null,Object? defaultModel = null,Object? systemPrompt = null,Object? isEnabled = null,Object? testStatus = null,Object? lastTestedAt = freezed,Object? lastTestMessage = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,apiKey: null == apiKey ? _self.apiKey : apiKey // ignore: cast_nullable_to_non_nullable
as String,defaultModel: null == defaultModel ? _self.defaultModel : defaultModel // ignore: cast_nullable_to_non_nullable
as String,systemPrompt: null == systemPrompt ? _self.systemPrompt : systemPrompt // ignore: cast_nullable_to_non_nullable
as String,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,testStatus: null == testStatus ? _self.testStatus : testStatus // ignore: cast_nullable_to_non_nullable
as ProviderTestStatus,lastTestedAt: freezed == lastTestedAt ? _self.lastTestedAt : lastTestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastTestMessage: freezed == lastTestMessage ? _self.lastTestMessage : lastTestMessage // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ProviderConfig].
extension ProviderConfigPatterns on ProviderConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderConfig value)  $default,){
final _that = this;
switch (_that) {
case _ProviderConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String baseUrl,  String apiKey,  String defaultModel,  String systemPrompt,  bool isEnabled,  ProviderTestStatus testStatus,  DateTime? lastTestedAt,  String? lastTestMessage,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderConfig() when $default != null:
return $default(_that.id,_that.name,_that.baseUrl,_that.apiKey,_that.defaultModel,_that.systemPrompt,_that.isEnabled,_that.testStatus,_that.lastTestedAt,_that.lastTestMessage,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String baseUrl,  String apiKey,  String defaultModel,  String systemPrompt,  bool isEnabled,  ProviderTestStatus testStatus,  DateTime? lastTestedAt,  String? lastTestMessage,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ProviderConfig():
return $default(_that.id,_that.name,_that.baseUrl,_that.apiKey,_that.defaultModel,_that.systemPrompt,_that.isEnabled,_that.testStatus,_that.lastTestedAt,_that.lastTestMessage,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String baseUrl,  String apiKey,  String defaultModel,  String systemPrompt,  bool isEnabled,  ProviderTestStatus testStatus,  DateTime? lastTestedAt,  String? lastTestMessage,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProviderConfig() when $default != null:
return $default(_that.id,_that.name,_that.baseUrl,_that.apiKey,_that.defaultModel,_that.systemPrompt,_that.isEnabled,_that.testStatus,_that.lastTestedAt,_that.lastTestMessage,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProviderConfig implements ProviderConfig {
  const _ProviderConfig({required this.id, required this.name, required this.baseUrl, required this.apiKey, required this.defaultModel, this.systemPrompt = '', required this.isEnabled, required this.testStatus, this.lastTestedAt, this.lastTestMessage, required this.createdAt, required this.updatedAt});
  factory _ProviderConfig.fromJson(Map<String, dynamic> json) => _$ProviderConfigFromJson(json);

@override final  String id;
@override final  String name;
@override final  String baseUrl;
@override final  String apiKey;
@override final  String defaultModel;
@override@JsonKey() final  String systemPrompt;
@override final  bool isEnabled;
@override final  ProviderTestStatus testStatus;
@override final  DateTime? lastTestedAt;
@override final  String? lastTestMessage;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of ProviderConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderConfigCopyWith<_ProviderConfig> get copyWith => __$ProviderConfigCopyWithImpl<_ProviderConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProviderConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.apiKey, apiKey) || other.apiKey == apiKey)&&(identical(other.defaultModel, defaultModel) || other.defaultModel == defaultModel)&&(identical(other.systemPrompt, systemPrompt) || other.systemPrompt == systemPrompt)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.testStatus, testStatus) || other.testStatus == testStatus)&&(identical(other.lastTestedAt, lastTestedAt) || other.lastTestedAt == lastTestedAt)&&(identical(other.lastTestMessage, lastTestMessage) || other.lastTestMessage == lastTestMessage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,baseUrl,apiKey,defaultModel,systemPrompt,isEnabled,testStatus,lastTestedAt,lastTestMessage,createdAt,updatedAt);

@override
String toString() {
  return 'ProviderConfig(id: $id, name: $name, baseUrl: $baseUrl, apiKey: $apiKey, defaultModel: $defaultModel, systemPrompt: $systemPrompt, isEnabled: $isEnabled, testStatus: $testStatus, lastTestedAt: $lastTestedAt, lastTestMessage: $lastTestMessage, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProviderConfigCopyWith<$Res> implements $ProviderConfigCopyWith<$Res> {
  factory _$ProviderConfigCopyWith(_ProviderConfig value, $Res Function(_ProviderConfig) _then) = __$ProviderConfigCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String baseUrl, String apiKey, String defaultModel, String systemPrompt, bool isEnabled, ProviderTestStatus testStatus, DateTime? lastTestedAt, String? lastTestMessage, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$ProviderConfigCopyWithImpl<$Res>
    implements _$ProviderConfigCopyWith<$Res> {
  __$ProviderConfigCopyWithImpl(this._self, this._then);

  final _ProviderConfig _self;
  final $Res Function(_ProviderConfig) _then;

/// Create a copy of ProviderConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? baseUrl = null,Object? apiKey = null,Object? defaultModel = null,Object? systemPrompt = null,Object? isEnabled = null,Object? testStatus = null,Object? lastTestedAt = freezed,Object? lastTestMessage = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ProviderConfig(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,apiKey: null == apiKey ? _self.apiKey : apiKey // ignore: cast_nullable_to_non_nullable
as String,defaultModel: null == defaultModel ? _self.defaultModel : defaultModel // ignore: cast_nullable_to_non_nullable
as String,systemPrompt: null == systemPrompt ? _self.systemPrompt : systemPrompt // ignore: cast_nullable_to_non_nullable
as String,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,testStatus: null == testStatus ? _self.testStatus : testStatus // ignore: cast_nullable_to_non_nullable
as ProviderTestStatus,lastTestedAt: freezed == lastTestedAt ? _self.lastTestedAt : lastTestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastTestMessage: freezed == lastTestMessage ? _self.lastTestMessage : lastTestMessage // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
