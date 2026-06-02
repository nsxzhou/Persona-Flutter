// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reader_settings_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReaderSettings {

 double get fontSize; double get lineHeight; double get columnWidth; bool get dark;
/// Create a copy of ReaderSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReaderSettingsCopyWith<ReaderSettings> get copyWith => _$ReaderSettingsCopyWithImpl<ReaderSettings>(this as ReaderSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReaderSettings&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.lineHeight, lineHeight) || other.lineHeight == lineHeight)&&(identical(other.columnWidth, columnWidth) || other.columnWidth == columnWidth)&&(identical(other.dark, dark) || other.dark == dark));
}


@override
int get hashCode => Object.hash(runtimeType,fontSize,lineHeight,columnWidth,dark);

@override
String toString() {
  return 'ReaderSettings(fontSize: $fontSize, lineHeight: $lineHeight, columnWidth: $columnWidth, dark: $dark)';
}


}

/// @nodoc
abstract mixin class $ReaderSettingsCopyWith<$Res>  {
  factory $ReaderSettingsCopyWith(ReaderSettings value, $Res Function(ReaderSettings) _then) = _$ReaderSettingsCopyWithImpl;
@useResult
$Res call({
 double fontSize, double lineHeight, double columnWidth, bool dark
});




}
/// @nodoc
class _$ReaderSettingsCopyWithImpl<$Res>
    implements $ReaderSettingsCopyWith<$Res> {
  _$ReaderSettingsCopyWithImpl(this._self, this._then);

  final ReaderSettings _self;
  final $Res Function(ReaderSettings) _then;

/// Create a copy of ReaderSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fontSize = null,Object? lineHeight = null,Object? columnWidth = null,Object? dark = null,}) {
  return _then(_self.copyWith(
fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double,lineHeight: null == lineHeight ? _self.lineHeight : lineHeight // ignore: cast_nullable_to_non_nullable
as double,columnWidth: null == columnWidth ? _self.columnWidth : columnWidth // ignore: cast_nullable_to_non_nullable
as double,dark: null == dark ? _self.dark : dark // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ReaderSettings].
extension ReaderSettingsPatterns on ReaderSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReaderSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReaderSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReaderSettings value)  $default,){
final _that = this;
switch (_that) {
case _ReaderSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReaderSettings value)?  $default,){
final _that = this;
switch (_that) {
case _ReaderSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double fontSize,  double lineHeight,  double columnWidth,  bool dark)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReaderSettings() when $default != null:
return $default(_that.fontSize,_that.lineHeight,_that.columnWidth,_that.dark);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double fontSize,  double lineHeight,  double columnWidth,  bool dark)  $default,) {final _that = this;
switch (_that) {
case _ReaderSettings():
return $default(_that.fontSize,_that.lineHeight,_that.columnWidth,_that.dark);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double fontSize,  double lineHeight,  double columnWidth,  bool dark)?  $default,) {final _that = this;
switch (_that) {
case _ReaderSettings() when $default != null:
return $default(_that.fontSize,_that.lineHeight,_that.columnWidth,_that.dark);case _:
  return null;

}
}

}

/// @nodoc


class _ReaderSettings implements ReaderSettings {
  const _ReaderSettings({this.fontSize = 19, this.lineHeight = 1.9, this.columnWidth = 760, this.dark = false});
  

@override@JsonKey() final  double fontSize;
@override@JsonKey() final  double lineHeight;
@override@JsonKey() final  double columnWidth;
@override@JsonKey() final  bool dark;

/// Create a copy of ReaderSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReaderSettingsCopyWith<_ReaderSettings> get copyWith => __$ReaderSettingsCopyWithImpl<_ReaderSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReaderSettings&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.lineHeight, lineHeight) || other.lineHeight == lineHeight)&&(identical(other.columnWidth, columnWidth) || other.columnWidth == columnWidth)&&(identical(other.dark, dark) || other.dark == dark));
}


@override
int get hashCode => Object.hash(runtimeType,fontSize,lineHeight,columnWidth,dark);

@override
String toString() {
  return 'ReaderSettings(fontSize: $fontSize, lineHeight: $lineHeight, columnWidth: $columnWidth, dark: $dark)';
}


}

/// @nodoc
abstract mixin class _$ReaderSettingsCopyWith<$Res> implements $ReaderSettingsCopyWith<$Res> {
  factory _$ReaderSettingsCopyWith(_ReaderSettings value, $Res Function(_ReaderSettings) _then) = __$ReaderSettingsCopyWithImpl;
@override @useResult
$Res call({
 double fontSize, double lineHeight, double columnWidth, bool dark
});




}
/// @nodoc
class __$ReaderSettingsCopyWithImpl<$Res>
    implements _$ReaderSettingsCopyWith<$Res> {
  __$ReaderSettingsCopyWithImpl(this._self, this._then);

  final _ReaderSettings _self;
  final $Res Function(_ReaderSettings) _then;

/// Create a copy of ReaderSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fontSize = null,Object? lineHeight = null,Object? columnWidth = null,Object? dark = null,}) {
  return _then(_ReaderSettings(
fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double,lineHeight: null == lineHeight ? _self.lineHeight : lineHeight // ignore: cast_nullable_to_non_nullable
as double,columnWidth: null == columnWidth ? _self.columnWidth : columnWidth // ignore: cast_nullable_to_non_nullable
as double,dark: null == dark ? _self.dark : dark // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
