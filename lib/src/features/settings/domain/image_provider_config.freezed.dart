// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image_provider_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImageProviderConfig {

 String get id; String get name; String get baseUrl; String get apiKey; String get defaultModel; List<String> get modelNames; ImageAspectRatioPreset get defaultAspectRatio; ImageSizePreset get defaultSize; ImageQualityPreset get defaultQuality; ImageResponseFormat get defaultResponseFormat; bool get isEnabled; ProviderTestStatus get testStatus; DateTime? get lastTestedAt; String? get lastTestMessage; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of ImageProviderConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageProviderConfigCopyWith<ImageProviderConfig> get copyWith => _$ImageProviderConfigCopyWithImpl<ImageProviderConfig>(this as ImageProviderConfig, _$identity);

  /// Serializes this ImageProviderConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageProviderConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.apiKey, apiKey) || other.apiKey == apiKey)&&(identical(other.defaultModel, defaultModel) || other.defaultModel == defaultModel)&&const DeepCollectionEquality().equals(other.modelNames, modelNames)&&(identical(other.defaultAspectRatio, defaultAspectRatio) || other.defaultAspectRatio == defaultAspectRatio)&&(identical(other.defaultSize, defaultSize) || other.defaultSize == defaultSize)&&(identical(other.defaultQuality, defaultQuality) || other.defaultQuality == defaultQuality)&&(identical(other.defaultResponseFormat, defaultResponseFormat) || other.defaultResponseFormat == defaultResponseFormat)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.testStatus, testStatus) || other.testStatus == testStatus)&&(identical(other.lastTestedAt, lastTestedAt) || other.lastTestedAt == lastTestedAt)&&(identical(other.lastTestMessage, lastTestMessage) || other.lastTestMessage == lastTestMessage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,baseUrl,apiKey,defaultModel,const DeepCollectionEquality().hash(modelNames),defaultAspectRatio,defaultSize,defaultQuality,defaultResponseFormat,isEnabled,testStatus,lastTestedAt,lastTestMessage,createdAt,updatedAt);

@override
String toString() {
  return 'ImageProviderConfig(id: $id, name: $name, baseUrl: $baseUrl, apiKey: $apiKey, defaultModel: $defaultModel, modelNames: $modelNames, defaultAspectRatio: $defaultAspectRatio, defaultSize: $defaultSize, defaultQuality: $defaultQuality, defaultResponseFormat: $defaultResponseFormat, isEnabled: $isEnabled, testStatus: $testStatus, lastTestedAt: $lastTestedAt, lastTestMessage: $lastTestMessage, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ImageProviderConfigCopyWith<$Res>  {
  factory $ImageProviderConfigCopyWith(ImageProviderConfig value, $Res Function(ImageProviderConfig) _then) = _$ImageProviderConfigCopyWithImpl;
@useResult
$Res call({
 String id, String name, String baseUrl, String apiKey, String defaultModel, List<String> modelNames, ImageAspectRatioPreset defaultAspectRatio, ImageSizePreset defaultSize, ImageQualityPreset defaultQuality, ImageResponseFormat defaultResponseFormat, bool isEnabled, ProviderTestStatus testStatus, DateTime? lastTestedAt, String? lastTestMessage, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$ImageProviderConfigCopyWithImpl<$Res>
    implements $ImageProviderConfigCopyWith<$Res> {
  _$ImageProviderConfigCopyWithImpl(this._self, this._then);

  final ImageProviderConfig _self;
  final $Res Function(ImageProviderConfig) _then;

/// Create a copy of ImageProviderConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? baseUrl = null,Object? apiKey = null,Object? defaultModel = null,Object? modelNames = null,Object? defaultAspectRatio = null,Object? defaultSize = null,Object? defaultQuality = null,Object? defaultResponseFormat = null,Object? isEnabled = null,Object? testStatus = null,Object? lastTestedAt = freezed,Object? lastTestMessage = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,apiKey: null == apiKey ? _self.apiKey : apiKey // ignore: cast_nullable_to_non_nullable
as String,defaultModel: null == defaultModel ? _self.defaultModel : defaultModel // ignore: cast_nullable_to_non_nullable
as String,modelNames: null == modelNames ? _self.modelNames : modelNames // ignore: cast_nullable_to_non_nullable
as List<String>,defaultAspectRatio: null == defaultAspectRatio ? _self.defaultAspectRatio : defaultAspectRatio // ignore: cast_nullable_to_non_nullable
as ImageAspectRatioPreset,defaultSize: null == defaultSize ? _self.defaultSize : defaultSize // ignore: cast_nullable_to_non_nullable
as ImageSizePreset,defaultQuality: null == defaultQuality ? _self.defaultQuality : defaultQuality // ignore: cast_nullable_to_non_nullable
as ImageQualityPreset,defaultResponseFormat: null == defaultResponseFormat ? _self.defaultResponseFormat : defaultResponseFormat // ignore: cast_nullable_to_non_nullable
as ImageResponseFormat,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,testStatus: null == testStatus ? _self.testStatus : testStatus // ignore: cast_nullable_to_non_nullable
as ProviderTestStatus,lastTestedAt: freezed == lastTestedAt ? _self.lastTestedAt : lastTestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastTestMessage: freezed == lastTestMessage ? _self.lastTestMessage : lastTestMessage // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ImageProviderConfig].
extension ImageProviderConfigPatterns on ImageProviderConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageProviderConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageProviderConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageProviderConfig value)  $default,){
final _that = this;
switch (_that) {
case _ImageProviderConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageProviderConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ImageProviderConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String baseUrl,  String apiKey,  String defaultModel,  List<String> modelNames,  ImageAspectRatioPreset defaultAspectRatio,  ImageSizePreset defaultSize,  ImageQualityPreset defaultQuality,  ImageResponseFormat defaultResponseFormat,  bool isEnabled,  ProviderTestStatus testStatus,  DateTime? lastTestedAt,  String? lastTestMessage,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageProviderConfig() when $default != null:
return $default(_that.id,_that.name,_that.baseUrl,_that.apiKey,_that.defaultModel,_that.modelNames,_that.defaultAspectRatio,_that.defaultSize,_that.defaultQuality,_that.defaultResponseFormat,_that.isEnabled,_that.testStatus,_that.lastTestedAt,_that.lastTestMessage,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String baseUrl,  String apiKey,  String defaultModel,  List<String> modelNames,  ImageAspectRatioPreset defaultAspectRatio,  ImageSizePreset defaultSize,  ImageQualityPreset defaultQuality,  ImageResponseFormat defaultResponseFormat,  bool isEnabled,  ProviderTestStatus testStatus,  DateTime? lastTestedAt,  String? lastTestMessage,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ImageProviderConfig():
return $default(_that.id,_that.name,_that.baseUrl,_that.apiKey,_that.defaultModel,_that.modelNames,_that.defaultAspectRatio,_that.defaultSize,_that.defaultQuality,_that.defaultResponseFormat,_that.isEnabled,_that.testStatus,_that.lastTestedAt,_that.lastTestMessage,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String baseUrl,  String apiKey,  String defaultModel,  List<String> modelNames,  ImageAspectRatioPreset defaultAspectRatio,  ImageSizePreset defaultSize,  ImageQualityPreset defaultQuality,  ImageResponseFormat defaultResponseFormat,  bool isEnabled,  ProviderTestStatus testStatus,  DateTime? lastTestedAt,  String? lastTestMessage,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ImageProviderConfig() when $default != null:
return $default(_that.id,_that.name,_that.baseUrl,_that.apiKey,_that.defaultModel,_that.modelNames,_that.defaultAspectRatio,_that.defaultSize,_that.defaultQuality,_that.defaultResponseFormat,_that.isEnabled,_that.testStatus,_that.lastTestedAt,_that.lastTestMessage,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImageProviderConfig implements ImageProviderConfig {
  const _ImageProviderConfig({required this.id, required this.name, required this.baseUrl, required this.apiKey, required this.defaultModel, final  List<String> modelNames = const <String>[], this.defaultAspectRatio = ImageAspectRatioPreset.square, this.defaultSize = ImageSizePreset.oneK, this.defaultQuality = ImageQualityPreset.auto, this.defaultResponseFormat = ImageResponseFormat.url, required this.isEnabled, required this.testStatus, this.lastTestedAt, this.lastTestMessage, required this.createdAt, required this.updatedAt}): _modelNames = modelNames;
  factory _ImageProviderConfig.fromJson(Map<String, dynamic> json) => _$ImageProviderConfigFromJson(json);

@override final  String id;
@override final  String name;
@override final  String baseUrl;
@override final  String apiKey;
@override final  String defaultModel;
 final  List<String> _modelNames;
@override@JsonKey() List<String> get modelNames {
  if (_modelNames is EqualUnmodifiableListView) return _modelNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_modelNames);
}

@override@JsonKey() final  ImageAspectRatioPreset defaultAspectRatio;
@override@JsonKey() final  ImageSizePreset defaultSize;
@override@JsonKey() final  ImageQualityPreset defaultQuality;
@override@JsonKey() final  ImageResponseFormat defaultResponseFormat;
@override final  bool isEnabled;
@override final  ProviderTestStatus testStatus;
@override final  DateTime? lastTestedAt;
@override final  String? lastTestMessage;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of ImageProviderConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageProviderConfigCopyWith<_ImageProviderConfig> get copyWith => __$ImageProviderConfigCopyWithImpl<_ImageProviderConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImageProviderConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageProviderConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.apiKey, apiKey) || other.apiKey == apiKey)&&(identical(other.defaultModel, defaultModel) || other.defaultModel == defaultModel)&&const DeepCollectionEquality().equals(other._modelNames, _modelNames)&&(identical(other.defaultAspectRatio, defaultAspectRatio) || other.defaultAspectRatio == defaultAspectRatio)&&(identical(other.defaultSize, defaultSize) || other.defaultSize == defaultSize)&&(identical(other.defaultQuality, defaultQuality) || other.defaultQuality == defaultQuality)&&(identical(other.defaultResponseFormat, defaultResponseFormat) || other.defaultResponseFormat == defaultResponseFormat)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.testStatus, testStatus) || other.testStatus == testStatus)&&(identical(other.lastTestedAt, lastTestedAt) || other.lastTestedAt == lastTestedAt)&&(identical(other.lastTestMessage, lastTestMessage) || other.lastTestMessage == lastTestMessage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,baseUrl,apiKey,defaultModel,const DeepCollectionEquality().hash(_modelNames),defaultAspectRatio,defaultSize,defaultQuality,defaultResponseFormat,isEnabled,testStatus,lastTestedAt,lastTestMessage,createdAt,updatedAt);

@override
String toString() {
  return 'ImageProviderConfig(id: $id, name: $name, baseUrl: $baseUrl, apiKey: $apiKey, defaultModel: $defaultModel, modelNames: $modelNames, defaultAspectRatio: $defaultAspectRatio, defaultSize: $defaultSize, defaultQuality: $defaultQuality, defaultResponseFormat: $defaultResponseFormat, isEnabled: $isEnabled, testStatus: $testStatus, lastTestedAt: $lastTestedAt, lastTestMessage: $lastTestMessage, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ImageProviderConfigCopyWith<$Res> implements $ImageProviderConfigCopyWith<$Res> {
  factory _$ImageProviderConfigCopyWith(_ImageProviderConfig value, $Res Function(_ImageProviderConfig) _then) = __$ImageProviderConfigCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String baseUrl, String apiKey, String defaultModel, List<String> modelNames, ImageAspectRatioPreset defaultAspectRatio, ImageSizePreset defaultSize, ImageQualityPreset defaultQuality, ImageResponseFormat defaultResponseFormat, bool isEnabled, ProviderTestStatus testStatus, DateTime? lastTestedAt, String? lastTestMessage, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$ImageProviderConfigCopyWithImpl<$Res>
    implements _$ImageProviderConfigCopyWith<$Res> {
  __$ImageProviderConfigCopyWithImpl(this._self, this._then);

  final _ImageProviderConfig _self;
  final $Res Function(_ImageProviderConfig) _then;

/// Create a copy of ImageProviderConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? baseUrl = null,Object? apiKey = null,Object? defaultModel = null,Object? modelNames = null,Object? defaultAspectRatio = null,Object? defaultSize = null,Object? defaultQuality = null,Object? defaultResponseFormat = null,Object? isEnabled = null,Object? testStatus = null,Object? lastTestedAt = freezed,Object? lastTestMessage = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ImageProviderConfig(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,apiKey: null == apiKey ? _self.apiKey : apiKey // ignore: cast_nullable_to_non_nullable
as String,defaultModel: null == defaultModel ? _self.defaultModel : defaultModel // ignore: cast_nullable_to_non_nullable
as String,modelNames: null == modelNames ? _self._modelNames : modelNames // ignore: cast_nullable_to_non_nullable
as List<String>,defaultAspectRatio: null == defaultAspectRatio ? _self.defaultAspectRatio : defaultAspectRatio // ignore: cast_nullable_to_non_nullable
as ImageAspectRatioPreset,defaultSize: null == defaultSize ? _self.defaultSize : defaultSize // ignore: cast_nullable_to_non_nullable
as ImageSizePreset,defaultQuality: null == defaultQuality ? _self.defaultQuality : defaultQuality // ignore: cast_nullable_to_non_nullable
as ImageQualityPreset,defaultResponseFormat: null == defaultResponseFormat ? _self.defaultResponseFormat : defaultResponseFormat // ignore: cast_nullable_to_non_nullable
as ImageResponseFormat,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
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
