// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlayerProfile {

 String get uid; String get fullName;/// Lowercase, unique across players (enforced via `usernames/{username}`).
 String get username; String? get photoUrl; DateTime get dateOfBirth; String get city; String get bio; Position get primaryPosition; List<Position> get secondaryPositions; SkillLevel get skillLevel; PreferredFoot get preferredFoot; int? get heightCm; int get yearsPlaying; List<String> get languages; Availability get availability; PlayerStats get stats;
/// Create a copy of PlayerProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerProfileCopyWith<PlayerProfile> get copyWith => _$PlayerProfileCopyWithImpl<PlayerProfile>(this as PlayerProfile, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PlayerProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerProfile&&(identical(other.uid, _this.uid) || other.uid == _this.uid)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.photoUrl, _this.photoUrl) || other.photoUrl == _this.photoUrl)&&(identical(other.dateOfBirth, _this.dateOfBirth) || other.dateOfBirth == _this.dateOfBirth)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.bio, _this.bio) || other.bio == _this.bio)&&(identical(other.primaryPosition, _this.primaryPosition) || other.primaryPosition == _this.primaryPosition)&&const DeepCollectionEquality().equals(other.secondaryPositions, _this.secondaryPositions)&&(identical(other.skillLevel, _this.skillLevel) || other.skillLevel == _this.skillLevel)&&(identical(other.preferredFoot, _this.preferredFoot) || other.preferredFoot == _this.preferredFoot)&&(identical(other.heightCm, _this.heightCm) || other.heightCm == _this.heightCm)&&(identical(other.yearsPlaying, _this.yearsPlaying) || other.yearsPlaying == _this.yearsPlaying)&&const DeepCollectionEquality().equals(other.languages, _this.languages)&&(identical(other.availability, _this.availability) || other.availability == _this.availability)&&(identical(other.stats, _this.stats) || other.stats == _this.stats));
}


@override
int get hashCode {
  final _this = this as PlayerProfile;
  return Object.hash(runtimeType,_this.uid,_this.fullName,_this.username,_this.photoUrl,_this.dateOfBirth,_this.city,_this.bio,_this.primaryPosition,const DeepCollectionEquality().hash(_this.secondaryPositions),_this.skillLevel,_this.preferredFoot,_this.heightCm,_this.yearsPlaying,const DeepCollectionEquality().hash(_this.languages),_this.availability,_this.stats);
}

@override
String toString() {
  final _this = this as PlayerProfile;
  return 'PlayerProfile(uid: ${_this.uid}, fullName: ${_this.fullName}, username: ${_this.username}, photoUrl: ${_this.photoUrl}, dateOfBirth: ${_this.dateOfBirth}, city: ${_this.city}, bio: ${_this.bio}, primaryPosition: ${_this.primaryPosition}, secondaryPositions: ${_this.secondaryPositions}, skillLevel: ${_this.skillLevel}, preferredFoot: ${_this.preferredFoot}, heightCm: ${_this.heightCm}, yearsPlaying: ${_this.yearsPlaying}, languages: ${_this.languages}, availability: ${_this.availability}, stats: ${_this.stats})';
}


}

/// @nodoc
abstract mixin class $PlayerProfileCopyWith<$Res>  {
  factory $PlayerProfileCopyWith(PlayerProfile value, $Res Function(PlayerProfile) _then) = _$PlayerProfileCopyWithImpl;
@useResult
$Res call({
 String uid, String fullName, String username, String? photoUrl, DateTime dateOfBirth, String city, String bio, Position primaryPosition, List<Position> secondaryPositions, SkillLevel skillLevel, PreferredFoot preferredFoot, int? heightCm, int yearsPlaying, List<String> languages, Availability availability, PlayerStats stats
});


$PlayerStatsCopyWith<$Res> get stats;

}
/// @nodoc
class _$PlayerProfileCopyWithImpl<$Res>
    implements $PlayerProfileCopyWith<$Res> {
  _$PlayerProfileCopyWithImpl(this._self, this._then);

  final PlayerProfile _self;
  final $Res Function(PlayerProfile) _then;

/// Create a copy of PlayerProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? fullName = null,Object? username = null,Object? photoUrl = freezed,Object? dateOfBirth = null,Object? city = null,Object? bio = null,Object? primaryPosition = null,Object? secondaryPositions = null,Object? skillLevel = null,Object? preferredFoot = null,Object? heightCm = freezed,Object? yearsPlaying = null,Object? languages = null,Object? availability = null,Object? stats = null,}) {
  return _then(PlayerProfile(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: null == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,primaryPosition: null == primaryPosition ? _self.primaryPosition : primaryPosition // ignore: cast_nullable_to_non_nullable
as Position,secondaryPositions: null == secondaryPositions ? _self.secondaryPositions : secondaryPositions // ignore: cast_nullable_to_non_nullable
as List<Position>,skillLevel: null == skillLevel ? _self.skillLevel : skillLevel // ignore: cast_nullable_to_non_nullable
as SkillLevel,preferredFoot: null == preferredFoot ? _self.preferredFoot : preferredFoot // ignore: cast_nullable_to_non_nullable
as PreferredFoot,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as int?,yearsPlaying: null == yearsPlaying ? _self.yearsPlaying : yearsPlaying // ignore: cast_nullable_to_non_nullable
as int,languages: null == languages ? _self.languages : languages // ignore: cast_nullable_to_non_nullable
as List<String>,availability: null == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as Availability,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as PlayerStats,
  ));
}
/// Create a copy of PlayerProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerStatsCopyWith<$Res> get stats {
  
  return $PlayerStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlayerProfile].
extension PlayerProfilePatterns on PlayerProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerProfile value)  $default,){
final _that = this;
switch (_that) {
case _PlayerProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerProfile value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String fullName,  String username,  String? photoUrl,  DateTime dateOfBirth,  String city,  String bio,  Position primaryPosition,  List<Position> secondaryPositions,  SkillLevel skillLevel,  PreferredFoot preferredFoot,  int? heightCm,  int yearsPlaying,  List<String> languages,  Availability availability,  PlayerStats stats)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerProfile() when $default != null:
return $default(_that.uid,_that.fullName,_that.username,_that.photoUrl,_that.dateOfBirth,_that.city,_that.bio,_that.primaryPosition,_that.secondaryPositions,_that.skillLevel,_that.preferredFoot,_that.heightCm,_that.yearsPlaying,_that.languages,_that.availability,_that.stats);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String fullName,  String username,  String? photoUrl,  DateTime dateOfBirth,  String city,  String bio,  Position primaryPosition,  List<Position> secondaryPositions,  SkillLevel skillLevel,  PreferredFoot preferredFoot,  int? heightCm,  int yearsPlaying,  List<String> languages,  Availability availability,  PlayerStats stats)  $default,) {final _that = this;
switch (_that) {
case _PlayerProfile():
return $default(_that.uid,_that.fullName,_that.username,_that.photoUrl,_that.dateOfBirth,_that.city,_that.bio,_that.primaryPosition,_that.secondaryPositions,_that.skillLevel,_that.preferredFoot,_that.heightCm,_that.yearsPlaying,_that.languages,_that.availability,_that.stats);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String fullName,  String username,  String? photoUrl,  DateTime dateOfBirth,  String city,  String bio,  Position primaryPosition,  List<Position> secondaryPositions,  SkillLevel skillLevel,  PreferredFoot preferredFoot,  int? heightCm,  int yearsPlaying,  List<String> languages,  Availability availability,  PlayerStats stats)?  $default,) {final _that = this;
switch (_that) {
case _PlayerProfile() when $default != null:
return $default(_that.uid,_that.fullName,_that.username,_that.photoUrl,_that.dateOfBirth,_that.city,_that.bio,_that.primaryPosition,_that.secondaryPositions,_that.skillLevel,_that.preferredFoot,_that.heightCm,_that.yearsPlaying,_that.languages,_that.availability,_that.stats);case _:
  return null;

}
}

}

/// @nodoc


class _PlayerProfile implements PlayerProfile {
  const _PlayerProfile({required this.uid, required this.fullName, required this.username, this.photoUrl, required this.dateOfBirth, required this.city, this.bio = '', required this.primaryPosition,  List<Position> secondaryPositions = const <Position>[], required this.skillLevel, required this.preferredFoot, this.heightCm, this.yearsPlaying = 0,  List<String> languages = const <String>[], this.availability = const Availability(), this.stats = const PlayerStats()}): _secondaryPositions = secondaryPositions,_languages = languages;
  

@override final  String uid;
@override final  String fullName;
/// Lowercase, unique across players (enforced via `usernames/{username}`).
@override final  String username;
@override final  String? photoUrl;
@override final  DateTime dateOfBirth;
@override final  String city;
@override@JsonKey() final  String bio;
@override final  Position primaryPosition;
 final  List<Position> _secondaryPositions;
@override@JsonKey() List<Position> get secondaryPositions {
  if (_secondaryPositions is EqualUnmodifiableListView) return _secondaryPositions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_secondaryPositions);
}

@override final  SkillLevel skillLevel;
@override final  PreferredFoot preferredFoot;
@override final  int? heightCm;
@override@JsonKey() final  int yearsPlaying;
 final  List<String> _languages;
@override@JsonKey() List<String> get languages {
  if (_languages is EqualUnmodifiableListView) return _languages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_languages);
}

@override@JsonKey() final  Availability availability;
@override@JsonKey() final  PlayerStats stats;

/// Create a copy of PlayerProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerProfileCopyWith<_PlayerProfile> get copyWith => __$PlayerProfileCopyWithImpl<_PlayerProfile>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerProfile&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.username, username) || other.username == username)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.city, city) || other.city == city)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.primaryPosition, primaryPosition) || other.primaryPosition == primaryPosition)&&const DeepCollectionEquality().equals(other.secondaryPositions, _secondaryPositions)&&(identical(other.skillLevel, skillLevel) || other.skillLevel == skillLevel)&&(identical(other.preferredFoot, preferredFoot) || other.preferredFoot == preferredFoot)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.yearsPlaying, yearsPlaying) || other.yearsPlaying == yearsPlaying)&&const DeepCollectionEquality().equals(other.languages, _languages)&&(identical(other.availability, availability) || other.availability == availability)&&(identical(other.stats, stats) || other.stats == stats));
}


@override
int get hashCode {
    return Object.hash(runtimeType,uid,fullName,username,photoUrl,dateOfBirth,city,bio,primaryPosition,const DeepCollectionEquality().hash(_secondaryPositions),skillLevel,preferredFoot,heightCm,yearsPlaying,const DeepCollectionEquality().hash(_languages),availability,stats);
}

@override
String toString() {
    return 'PlayerProfile(uid: $uid, fullName: $fullName, username: $username, photoUrl: $photoUrl, dateOfBirth: $dateOfBirth, city: $city, bio: $bio, primaryPosition: $primaryPosition, secondaryPositions: $secondaryPositions, skillLevel: $skillLevel, preferredFoot: $preferredFoot, heightCm: $heightCm, yearsPlaying: $yearsPlaying, languages: $languages, availability: $availability, stats: $stats)';
}


}

/// @nodoc
abstract mixin class _$PlayerProfileCopyWith<$Res> implements $PlayerProfileCopyWith<$Res> {
  factory _$PlayerProfileCopyWith(_PlayerProfile value, $Res Function(_PlayerProfile) _then) = __$PlayerProfileCopyWithImpl;
@override @useResult
$Res call({
 String uid, String fullName, String username, String? photoUrl, DateTime dateOfBirth, String city, String bio, Position primaryPosition, List<Position> secondaryPositions, SkillLevel skillLevel, PreferredFoot preferredFoot, int? heightCm, int yearsPlaying, List<String> languages, Availability availability, PlayerStats stats
});


@override $PlayerStatsCopyWith<$Res> get stats;

}
/// @nodoc
class __$PlayerProfileCopyWithImpl<$Res>
    implements _$PlayerProfileCopyWith<$Res> {
  __$PlayerProfileCopyWithImpl(this._self, this._then);

  final _PlayerProfile _self;
  final $Res Function(_PlayerProfile) _then;

/// Create a copy of PlayerProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? fullName = null,Object? username = null,Object? photoUrl = freezed,Object? dateOfBirth = null,Object? city = null,Object? bio = null,Object? primaryPosition = null,Object? secondaryPositions = null,Object? skillLevel = null,Object? preferredFoot = null,Object? heightCm = freezed,Object? yearsPlaying = null,Object? languages = null,Object? availability = null,Object? stats = null,}) {
  return _then(_PlayerProfile(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: null == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,primaryPosition: null == primaryPosition ? _self.primaryPosition : primaryPosition // ignore: cast_nullable_to_non_nullable
as Position,secondaryPositions: null == secondaryPositions ? _self._secondaryPositions : secondaryPositions // ignore: cast_nullable_to_non_nullable
as List<Position>,skillLevel: null == skillLevel ? _self.skillLevel : skillLevel // ignore: cast_nullable_to_non_nullable
as SkillLevel,preferredFoot: null == preferredFoot ? _self.preferredFoot : preferredFoot // ignore: cast_nullable_to_non_nullable
as PreferredFoot,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as int?,yearsPlaying: null == yearsPlaying ? _self.yearsPlaying : yearsPlaying // ignore: cast_nullable_to_non_nullable
as int,languages: null == languages ? _self._languages : languages // ignore: cast_nullable_to_non_nullable
as List<String>,availability: null == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as Availability,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as PlayerStats,
  ));
}

/// Create a copy of PlayerProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerStatsCopyWith<$Res> get stats {
  
  return $PlayerStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}

// dart format on
