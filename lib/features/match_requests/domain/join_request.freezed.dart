// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'join_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$JoinRequest {

 String get matchId; PlayerCard get player; PositionGroup get preferredGroup; String get message; RequestStatus get status;/// Slot the organizer placed them in, once accepted.
 PositionGroup? get assignedGroup; DateTime? get createdAt;
/// Create a copy of JoinRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JoinRequestCopyWith<JoinRequest> get copyWith => _$JoinRequestCopyWithImpl<JoinRequest>(this as JoinRequest, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as JoinRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JoinRequest&&(identical(other.matchId, _this.matchId) || other.matchId == _this.matchId)&&(identical(other.player, _this.player) || other.player == _this.player)&&(identical(other.preferredGroup, _this.preferredGroup) || other.preferredGroup == _this.preferredGroup)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.assignedGroup, _this.assignedGroup) || other.assignedGroup == _this.assignedGroup)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as JoinRequest;
  return Object.hash(runtimeType,_this.matchId,_this.player,_this.preferredGroup,_this.message,_this.status,_this.assignedGroup,_this.createdAt);
}

@override
String toString() {
  final _this = this as JoinRequest;
  return 'JoinRequest(matchId: ${_this.matchId}, player: ${_this.player}, preferredGroup: ${_this.preferredGroup}, message: ${_this.message}, status: ${_this.status}, assignedGroup: ${_this.assignedGroup}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $JoinRequestCopyWith<$Res>  {
  factory $JoinRequestCopyWith(JoinRequest value, $Res Function(JoinRequest) _then) = _$JoinRequestCopyWithImpl;
@useResult
$Res call({
 String matchId, PlayerCard player, PositionGroup preferredGroup, String message, RequestStatus status, PositionGroup? assignedGroup, DateTime? createdAt
});


$PlayerCardCopyWith<$Res> get player;

}
/// @nodoc
class _$JoinRequestCopyWithImpl<$Res>
    implements $JoinRequestCopyWith<$Res> {
  _$JoinRequestCopyWithImpl(this._self, this._then);

  final JoinRequest _self;
  final $Res Function(JoinRequest) _then;

/// Create a copy of JoinRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? matchId = null,Object? player = null,Object? preferredGroup = null,Object? message = null,Object? status = null,Object? assignedGroup = freezed,Object? createdAt = freezed,}) {
  return _then(JoinRequest(
matchId: null == matchId ? _self.matchId : matchId // ignore: cast_nullable_to_non_nullable
as String,player: null == player ? _self.player : player // ignore: cast_nullable_to_non_nullable
as PlayerCard,preferredGroup: null == preferredGroup ? _self.preferredGroup : preferredGroup // ignore: cast_nullable_to_non_nullable
as PositionGroup,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequestStatus,assignedGroup: freezed == assignedGroup ? _self.assignedGroup : assignedGroup // ignore: cast_nullable_to_non_nullable
as PositionGroup?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of JoinRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerCardCopyWith<$Res> get player {
  
  return $PlayerCardCopyWith<$Res>(_self.player, (value) {
    return _then(_self.copyWith(player: value));
  });
}
}


/// Adds pattern-matching-related methods to [JoinRequest].
extension JoinRequestPatterns on JoinRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JoinRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JoinRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JoinRequest value)  $default,){
final _that = this;
switch (_that) {
case _JoinRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JoinRequest value)?  $default,){
final _that = this;
switch (_that) {
case _JoinRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String matchId,  PlayerCard player,  PositionGroup preferredGroup,  String message,  RequestStatus status,  PositionGroup? assignedGroup,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JoinRequest() when $default != null:
return $default(_that.matchId,_that.player,_that.preferredGroup,_that.message,_that.status,_that.assignedGroup,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String matchId,  PlayerCard player,  PositionGroup preferredGroup,  String message,  RequestStatus status,  PositionGroup? assignedGroup,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _JoinRequest():
return $default(_that.matchId,_that.player,_that.preferredGroup,_that.message,_that.status,_that.assignedGroup,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String matchId,  PlayerCard player,  PositionGroup preferredGroup,  String message,  RequestStatus status,  PositionGroup? assignedGroup,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _JoinRequest() when $default != null:
return $default(_that.matchId,_that.player,_that.preferredGroup,_that.message,_that.status,_that.assignedGroup,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _JoinRequest extends JoinRequest {
  const _JoinRequest({required this.matchId, required this.player, required this.preferredGroup, this.message = '', required this.status, this.assignedGroup, this.createdAt}): super._();
  

@override final  String matchId;
@override final  PlayerCard player;
@override final  PositionGroup preferredGroup;
@override@JsonKey() final  String message;
@override final  RequestStatus status;
/// Slot the organizer placed them in, once accepted.
@override final  PositionGroup? assignedGroup;
@override final  DateTime? createdAt;

/// Create a copy of JoinRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JoinRequestCopyWith<_JoinRequest> get copyWith => __$JoinRequestCopyWithImpl<_JoinRequest>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _JoinRequest&&(identical(other.matchId, matchId) || other.matchId == matchId)&&(identical(other.player, player) || other.player == player)&&(identical(other.preferredGroup, preferredGroup) || other.preferredGroup == preferredGroup)&&(identical(other.message, message) || other.message == message)&&(identical(other.status, status) || other.status == status)&&(identical(other.assignedGroup, assignedGroup) || other.assignedGroup == assignedGroup)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,matchId,player,preferredGroup,message,status,assignedGroup,createdAt);
}

@override
String toString() {
    return 'JoinRequest(matchId: $matchId, player: $player, preferredGroup: $preferredGroup, message: $message, status: $status, assignedGroup: $assignedGroup, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$JoinRequestCopyWith<$Res> implements $JoinRequestCopyWith<$Res> {
  factory _$JoinRequestCopyWith(_JoinRequest value, $Res Function(_JoinRequest) _then) = __$JoinRequestCopyWithImpl;
@override @useResult
$Res call({
 String matchId, PlayerCard player, PositionGroup preferredGroup, String message, RequestStatus status, PositionGroup? assignedGroup, DateTime? createdAt
});


@override $PlayerCardCopyWith<$Res> get player;

}
/// @nodoc
class __$JoinRequestCopyWithImpl<$Res>
    implements _$JoinRequestCopyWith<$Res> {
  __$JoinRequestCopyWithImpl(this._self, this._then);

  final _JoinRequest _self;
  final $Res Function(_JoinRequest) _then;

/// Create a copy of JoinRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? matchId = null,Object? player = null,Object? preferredGroup = null,Object? message = null,Object? status = null,Object? assignedGroup = freezed,Object? createdAt = freezed,}) {
  return _then(_JoinRequest(
matchId: null == matchId ? _self.matchId : matchId // ignore: cast_nullable_to_non_nullable
as String,player: null == player ? _self.player : player // ignore: cast_nullable_to_non_nullable
as PlayerCard,preferredGroup: null == preferredGroup ? _self.preferredGroup : preferredGroup // ignore: cast_nullable_to_non_nullable
as PositionGroup,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequestStatus,assignedGroup: freezed == assignedGroup ? _self.assignedGroup : assignedGroup // ignore: cast_nullable_to_non_nullable
as PositionGroup?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of JoinRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerCardCopyWith<$Res> get player {
  
  return $PlayerCardCopyWith<$Res>(_self.player, (value) {
    return _then(_self.copyWith(player: value));
  });
}
}

// dart format on
