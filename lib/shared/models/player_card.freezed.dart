// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlayerCard {

 String get uid; String get name; String get username; String? get photoUrl; Position get primaryPosition; List<Position> get secondaryPositions; SkillLevel get skillLevel; double get ratingAvg; int get ratingCount; int get gamesPlayed;
/// Create a copy of PlayerCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerCardCopyWith<PlayerCard> get copyWith => _$PlayerCardCopyWithImpl<PlayerCard>(this as PlayerCard, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PlayerCard;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerCard&&(identical(other.uid, _this.uid) || other.uid == _this.uid)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.photoUrl, _this.photoUrl) || other.photoUrl == _this.photoUrl)&&(identical(other.primaryPosition, _this.primaryPosition) || other.primaryPosition == _this.primaryPosition)&&const DeepCollectionEquality().equals(other.secondaryPositions, _this.secondaryPositions)&&(identical(other.skillLevel, _this.skillLevel) || other.skillLevel == _this.skillLevel)&&(identical(other.ratingAvg, _this.ratingAvg) || other.ratingAvg == _this.ratingAvg)&&(identical(other.ratingCount, _this.ratingCount) || other.ratingCount == _this.ratingCount)&&(identical(other.gamesPlayed, _this.gamesPlayed) || other.gamesPlayed == _this.gamesPlayed));
}


@override
int get hashCode {
  final _this = this as PlayerCard;
  return Object.hash(runtimeType,_this.uid,_this.name,_this.username,_this.photoUrl,_this.primaryPosition,const DeepCollectionEquality().hash(_this.secondaryPositions),_this.skillLevel,_this.ratingAvg,_this.ratingCount,_this.gamesPlayed);
}

@override
String toString() {
  final _this = this as PlayerCard;
  return 'PlayerCard(uid: ${_this.uid}, name: ${_this.name}, username: ${_this.username}, photoUrl: ${_this.photoUrl}, primaryPosition: ${_this.primaryPosition}, secondaryPositions: ${_this.secondaryPositions}, skillLevel: ${_this.skillLevel}, ratingAvg: ${_this.ratingAvg}, ratingCount: ${_this.ratingCount}, gamesPlayed: ${_this.gamesPlayed})';
}


}

/// @nodoc
abstract mixin class $PlayerCardCopyWith<$Res>  {
  factory $PlayerCardCopyWith(PlayerCard value, $Res Function(PlayerCard) _then) = _$PlayerCardCopyWithImpl;
@useResult
$Res call({
 String uid, String name, String username, String? photoUrl, Position primaryPosition, List<Position> secondaryPositions, SkillLevel skillLevel, double ratingAvg, int ratingCount, int gamesPlayed
});




}
/// @nodoc
class _$PlayerCardCopyWithImpl<$Res>
    implements $PlayerCardCopyWith<$Res> {
  _$PlayerCardCopyWithImpl(this._self, this._then);

  final PlayerCard _self;
  final $Res Function(PlayerCard) _then;

/// Create a copy of PlayerCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? name = null,Object? username = null,Object? photoUrl = freezed,Object? primaryPosition = null,Object? secondaryPositions = null,Object? skillLevel = null,Object? ratingAvg = null,Object? ratingCount = null,Object? gamesPlayed = null,}) {
  return _then(PlayerCard(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,primaryPosition: null == primaryPosition ? _self.primaryPosition : primaryPosition // ignore: cast_nullable_to_non_nullable
as Position,secondaryPositions: null == secondaryPositions ? _self.secondaryPositions : secondaryPositions // ignore: cast_nullable_to_non_nullable
as List<Position>,skillLevel: null == skillLevel ? _self.skillLevel : skillLevel // ignore: cast_nullable_to_non_nullable
as SkillLevel,ratingAvg: null == ratingAvg ? _self.ratingAvg : ratingAvg // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,gamesPlayed: null == gamesPlayed ? _self.gamesPlayed : gamesPlayed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerCard].
extension PlayerCardPatterns on PlayerCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerCard value)  $default,){
final _that = this;
switch (_that) {
case _PlayerCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerCard value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String name,  String username,  String? photoUrl,  Position primaryPosition,  List<Position> secondaryPositions,  SkillLevel skillLevel,  double ratingAvg,  int ratingCount,  int gamesPlayed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerCard() when $default != null:
return $default(_that.uid,_that.name,_that.username,_that.photoUrl,_that.primaryPosition,_that.secondaryPositions,_that.skillLevel,_that.ratingAvg,_that.ratingCount,_that.gamesPlayed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String name,  String username,  String? photoUrl,  Position primaryPosition,  List<Position> secondaryPositions,  SkillLevel skillLevel,  double ratingAvg,  int ratingCount,  int gamesPlayed)  $default,) {final _that = this;
switch (_that) {
case _PlayerCard():
return $default(_that.uid,_that.name,_that.username,_that.photoUrl,_that.primaryPosition,_that.secondaryPositions,_that.skillLevel,_that.ratingAvg,_that.ratingCount,_that.gamesPlayed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String name,  String username,  String? photoUrl,  Position primaryPosition,  List<Position> secondaryPositions,  SkillLevel skillLevel,  double ratingAvg,  int ratingCount,  int gamesPlayed)?  $default,) {final _that = this;
switch (_that) {
case _PlayerCard() when $default != null:
return $default(_that.uid,_that.name,_that.username,_that.photoUrl,_that.primaryPosition,_that.secondaryPositions,_that.skillLevel,_that.ratingAvg,_that.ratingCount,_that.gamesPlayed);case _:
  return null;

}
}

}

/// @nodoc


class _PlayerCard implements PlayerCard {
  const _PlayerCard({required this.uid, required this.name, required this.username, this.photoUrl, required this.primaryPosition,  List<Position> secondaryPositions = const <Position>[], required this.skillLevel, this.ratingAvg = 0, this.ratingCount = 0, this.gamesPlayed = 0}): _secondaryPositions = secondaryPositions;
  

@override final  String uid;
@override final  String name;
@override final  String username;
@override final  String? photoUrl;
@override final  Position primaryPosition;
 final  List<Position> _secondaryPositions;
@override@JsonKey() List<Position> get secondaryPositions {
  if (_secondaryPositions is EqualUnmodifiableListView) return _secondaryPositions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_secondaryPositions);
}

@override final  SkillLevel skillLevel;
@override@JsonKey() final  double ratingAvg;
@override@JsonKey() final  int ratingCount;
@override@JsonKey() final  int gamesPlayed;

/// Create a copy of PlayerCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerCardCopyWith<_PlayerCard> get copyWith => __$PlayerCardCopyWithImpl<_PlayerCard>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerCard&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.name, name) || other.name == name)&&(identical(other.username, username) || other.username == username)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.primaryPosition, primaryPosition) || other.primaryPosition == primaryPosition)&&const DeepCollectionEquality().equals(other.secondaryPositions, _secondaryPositions)&&(identical(other.skillLevel, skillLevel) || other.skillLevel == skillLevel)&&(identical(other.ratingAvg, ratingAvg) || other.ratingAvg == ratingAvg)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.gamesPlayed, gamesPlayed) || other.gamesPlayed == gamesPlayed));
}


@override
int get hashCode {
    return Object.hash(runtimeType,uid,name,username,photoUrl,primaryPosition,const DeepCollectionEquality().hash(_secondaryPositions),skillLevel,ratingAvg,ratingCount,gamesPlayed);
}

@override
String toString() {
    return 'PlayerCard(uid: $uid, name: $name, username: $username, photoUrl: $photoUrl, primaryPosition: $primaryPosition, secondaryPositions: $secondaryPositions, skillLevel: $skillLevel, ratingAvg: $ratingAvg, ratingCount: $ratingCount, gamesPlayed: $gamesPlayed)';
}


}

/// @nodoc
abstract mixin class _$PlayerCardCopyWith<$Res> implements $PlayerCardCopyWith<$Res> {
  factory _$PlayerCardCopyWith(_PlayerCard value, $Res Function(_PlayerCard) _then) = __$PlayerCardCopyWithImpl;
@override @useResult
$Res call({
 String uid, String name, String username, String? photoUrl, Position primaryPosition, List<Position> secondaryPositions, SkillLevel skillLevel, double ratingAvg, int ratingCount, int gamesPlayed
});




}
/// @nodoc
class __$PlayerCardCopyWithImpl<$Res>
    implements _$PlayerCardCopyWith<$Res> {
  __$PlayerCardCopyWithImpl(this._self, this._then);

  final _PlayerCard _self;
  final $Res Function(_PlayerCard) _then;

/// Create a copy of PlayerCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? name = null,Object? username = null,Object? photoUrl = freezed,Object? primaryPosition = null,Object? secondaryPositions = null,Object? skillLevel = null,Object? ratingAvg = null,Object? ratingCount = null,Object? gamesPlayed = null,}) {
  return _then(_PlayerCard(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,primaryPosition: null == primaryPosition ? _self.primaryPosition : primaryPosition // ignore: cast_nullable_to_non_nullable
as Position,secondaryPositions: null == secondaryPositions ? _self._secondaryPositions : secondaryPositions // ignore: cast_nullable_to_non_nullable
as List<Position>,skillLevel: null == skillLevel ? _self.skillLevel : skillLevel // ignore: cast_nullable_to_non_nullable
as SkillLevel,ratingAvg: null == ratingAvg ? _self.ratingAvg : ratingAvg // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,gamesPlayed: null == gamesPlayed ? _self.gamesPlayed : gamesPlayed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
