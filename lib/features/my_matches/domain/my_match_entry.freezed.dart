// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_match_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MyMatchEntry {

 String get matchId; MyMatchRole get role; String get title; DateTime get startAt; String get venueName;/// Only for [MyMatchRole.player].
 RequestStatus? get requestStatus;
/// Create a copy of MyMatchEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyMatchEntryCopyWith<MyMatchEntry> get copyWith => _$MyMatchEntryCopyWithImpl<MyMatchEntry>(this as MyMatchEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MyMatchEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyMatchEntry&&(identical(other.matchId, _this.matchId) || other.matchId == _this.matchId)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.startAt, _this.startAt) || other.startAt == _this.startAt)&&(identical(other.venueName, _this.venueName) || other.venueName == _this.venueName)&&(identical(other.requestStatus, _this.requestStatus) || other.requestStatus == _this.requestStatus));
}


@override
int get hashCode {
  final _this = this as MyMatchEntry;
  return Object.hash(runtimeType,_this.matchId,_this.role,_this.title,_this.startAt,_this.venueName,_this.requestStatus);
}

@override
String toString() {
  final _this = this as MyMatchEntry;
  return 'MyMatchEntry(matchId: ${_this.matchId}, role: ${_this.role}, title: ${_this.title}, startAt: ${_this.startAt}, venueName: ${_this.venueName}, requestStatus: ${_this.requestStatus})';
}


}

/// @nodoc
abstract mixin class $MyMatchEntryCopyWith<$Res>  {
  factory $MyMatchEntryCopyWith(MyMatchEntry value, $Res Function(MyMatchEntry) _then) = _$MyMatchEntryCopyWithImpl;
@useResult
$Res call({
 String matchId, MyMatchRole role, String title, DateTime startAt, String venueName, RequestStatus? requestStatus
});




}
/// @nodoc
class _$MyMatchEntryCopyWithImpl<$Res>
    implements $MyMatchEntryCopyWith<$Res> {
  _$MyMatchEntryCopyWithImpl(this._self, this._then);

  final MyMatchEntry _self;
  final $Res Function(MyMatchEntry) _then;

/// Create a copy of MyMatchEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? matchId = null,Object? role = null,Object? title = null,Object? startAt = null,Object? venueName = null,Object? requestStatus = freezed,}) {
  return _then(MyMatchEntry(
matchId: null == matchId ? _self.matchId : matchId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MyMatchRole,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,venueName: null == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String,requestStatus: freezed == requestStatus ? _self.requestStatus : requestStatus // ignore: cast_nullable_to_non_nullable
as RequestStatus?,
  ));
}

}


/// Adds pattern-matching-related methods to [MyMatchEntry].
extension MyMatchEntryPatterns on MyMatchEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyMatchEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyMatchEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyMatchEntry value)  $default,){
final _that = this;
switch (_that) {
case _MyMatchEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyMatchEntry value)?  $default,){
final _that = this;
switch (_that) {
case _MyMatchEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String matchId,  MyMatchRole role,  String title,  DateTime startAt,  String venueName,  RequestStatus? requestStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyMatchEntry() when $default != null:
return $default(_that.matchId,_that.role,_that.title,_that.startAt,_that.venueName,_that.requestStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String matchId,  MyMatchRole role,  String title,  DateTime startAt,  String venueName,  RequestStatus? requestStatus)  $default,) {final _that = this;
switch (_that) {
case _MyMatchEntry():
return $default(_that.matchId,_that.role,_that.title,_that.startAt,_that.venueName,_that.requestStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String matchId,  MyMatchRole role,  String title,  DateTime startAt,  String venueName,  RequestStatus? requestStatus)?  $default,) {final _that = this;
switch (_that) {
case _MyMatchEntry() when $default != null:
return $default(_that.matchId,_that.role,_that.title,_that.startAt,_that.venueName,_that.requestStatus);case _:
  return null;

}
}

}

/// @nodoc


class _MyMatchEntry implements MyMatchEntry {
  const _MyMatchEntry({required this.matchId, required this.role, required this.title, required this.startAt, this.venueName = '', this.requestStatus});
  

@override final  String matchId;
@override final  MyMatchRole role;
@override final  String title;
@override final  DateTime startAt;
@override@JsonKey() final  String venueName;
/// Only for [MyMatchRole.player].
@override final  RequestStatus? requestStatus;

/// Create a copy of MyMatchEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyMatchEntryCopyWith<_MyMatchEntry> get copyWith => __$MyMatchEntryCopyWithImpl<_MyMatchEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyMatchEntry&&(identical(other.matchId, matchId) || other.matchId == matchId)&&(identical(other.role, role) || other.role == role)&&(identical(other.title, title) || other.title == title)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.requestStatus, requestStatus) || other.requestStatus == requestStatus));
}


@override
int get hashCode {
    return Object.hash(runtimeType,matchId,role,title,startAt,venueName,requestStatus);
}

@override
String toString() {
    return 'MyMatchEntry(matchId: $matchId, role: $role, title: $title, startAt: $startAt, venueName: $venueName, requestStatus: $requestStatus)';
}


}

/// @nodoc
abstract mixin class _$MyMatchEntryCopyWith<$Res> implements $MyMatchEntryCopyWith<$Res> {
  factory _$MyMatchEntryCopyWith(_MyMatchEntry value, $Res Function(_MyMatchEntry) _then) = __$MyMatchEntryCopyWithImpl;
@override @useResult
$Res call({
 String matchId, MyMatchRole role, String title, DateTime startAt, String venueName, RequestStatus? requestStatus
});




}
/// @nodoc
class __$MyMatchEntryCopyWithImpl<$Res>
    implements _$MyMatchEntryCopyWith<$Res> {
  __$MyMatchEntryCopyWithImpl(this._self, this._then);

  final _MyMatchEntry _self;
  final $Res Function(_MyMatchEntry) _then;

/// Create a copy of MyMatchEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? matchId = null,Object? role = null,Object? title = null,Object? startAt = null,Object? venueName = null,Object? requestStatus = freezed,}) {
  return _then(_MyMatchEntry(
matchId: null == matchId ? _self.matchId : matchId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MyMatchRole,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,venueName: null == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String,requestStatus: freezed == requestStatus ? _self.requestStatus : requestStatus // ignore: cast_nullable_to_non_nullable
as RequestStatus?,
  ));
}


}

// dart format on
