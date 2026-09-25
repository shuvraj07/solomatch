// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'roster_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RosterEntry {

 PlayerCard get player; PositionGroup get group; DateTime? get joinedAt;
/// Create a copy of RosterEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RosterEntryCopyWith<RosterEntry> get copyWith => _$RosterEntryCopyWithImpl<RosterEntry>(this as RosterEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RosterEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RosterEntry&&(identical(other.player, _this.player) || other.player == _this.player)&&(identical(other.group, _this.group) || other.group == _this.group)&&(identical(other.joinedAt, _this.joinedAt) || other.joinedAt == _this.joinedAt));
}


@override
int get hashCode {
  final _this = this as RosterEntry;
  return Object.hash(runtimeType,_this.player,_this.group,_this.joinedAt);
}

@override
String toString() {
  final _this = this as RosterEntry;
  return 'RosterEntry(player: ${_this.player}, group: ${_this.group}, joinedAt: ${_this.joinedAt})';
}


}

/// @nodoc
abstract mixin class $RosterEntryCopyWith<$Res>  {
  factory $RosterEntryCopyWith(RosterEntry value, $Res Function(RosterEntry) _then) = _$RosterEntryCopyWithImpl;
@useResult
$Res call({
 PlayerCard player, PositionGroup group, DateTime? joinedAt
});


$PlayerCardCopyWith<$Res> get player;

}
/// @nodoc
class _$RosterEntryCopyWithImpl<$Res>
    implements $RosterEntryCopyWith<$Res> {
  _$RosterEntryCopyWithImpl(this._self, this._then);

  final RosterEntry _self;
  final $Res Function(RosterEntry) _then;

/// Create a copy of RosterEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? player = null,Object? group = null,Object? joinedAt = freezed,}) {
  return _then(RosterEntry(
player: null == player ? _self.player : player // ignore: cast_nullable_to_non_nullable
as PlayerCard,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as PositionGroup,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of RosterEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerCardCopyWith<$Res> get player {
  
  return $PlayerCardCopyWith<$Res>(_self.player, (value) {
    return _then(_self.copyWith(player: value));
  });
}
}


/// Adds pattern-matching-related methods to [RosterEntry].
extension RosterEntryPatterns on RosterEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RosterEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RosterEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RosterEntry value)  $default,){
final _that = this;
switch (_that) {
case _RosterEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RosterEntry value)?  $default,){
final _that = this;
switch (_that) {
case _RosterEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlayerCard player,  PositionGroup group,  DateTime? joinedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RosterEntry() when $default != null:
return $default(_that.player,_that.group,_that.joinedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlayerCard player,  PositionGroup group,  DateTime? joinedAt)  $default,) {final _that = this;
switch (_that) {
case _RosterEntry():
return $default(_that.player,_that.group,_that.joinedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlayerCard player,  PositionGroup group,  DateTime? joinedAt)?  $default,) {final _that = this;
switch (_that) {
case _RosterEntry() when $default != null:
return $default(_that.player,_that.group,_that.joinedAt);case _:
  return null;

}
}

}

/// @nodoc


class _RosterEntry implements RosterEntry {
  const _RosterEntry({required this.player, required this.group, this.joinedAt});
  

@override final  PlayerCard player;
@override final  PositionGroup group;
@override final  DateTime? joinedAt;

/// Create a copy of RosterEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RosterEntryCopyWith<_RosterEntry> get copyWith => __$RosterEntryCopyWithImpl<_RosterEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RosterEntry&&(identical(other.player, player) || other.player == player)&&(identical(other.group, group) || other.group == group)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,player,group,joinedAt);
}

@override
String toString() {
    return 'RosterEntry(player: $player, group: $group, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class _$RosterEntryCopyWith<$Res> implements $RosterEntryCopyWith<$Res> {
  factory _$RosterEntryCopyWith(_RosterEntry value, $Res Function(_RosterEntry) _then) = __$RosterEntryCopyWithImpl;
@override @useResult
$Res call({
 PlayerCard player, PositionGroup group, DateTime? joinedAt
});


@override $PlayerCardCopyWith<$Res> get player;

}
/// @nodoc
class __$RosterEntryCopyWithImpl<$Res>
    implements _$RosterEntryCopyWith<$Res> {
  __$RosterEntryCopyWithImpl(this._self, this._then);

  final _RosterEntry _self;
  final $Res Function(_RosterEntry) _then;

/// Create a copy of RosterEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? player = null,Object? group = null,Object? joinedAt = freezed,}) {
  return _then(_RosterEntry(
player: null == player ? _self.player : player // ignore: cast_nullable_to_non_nullable
as PlayerCard,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as PositionGroup,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of RosterEntry
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
