// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OnboardingState {

 OnboardingStep get step; String get fullName; String get username; Uint8List? get photoBytes; DateTime? get dateOfBirth; String get city; Position? get primaryPosition; List<Position> get secondaryPositions; SkillLevel? get skillLevel; PreferredFoot get preferredFoot; int? get heightCm; int get yearsPlaying; List<String> get languages; Availability get availability; String get bio;/// True while checking the username or saving.
 bool get busy;/// Shown under the username field (e.g. "already taken").
 String? get usernameError;
/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingStateCopyWith<OnboardingState> get copyWith => _$OnboardingStateCopyWithImpl<OnboardingState>(this as OnboardingState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OnboardingState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingState&&(identical(other.step, _this.step) || other.step == _this.step)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.username, _this.username) || other.username == _this.username)&&const DeepCollectionEquality().equals(other.photoBytes, _this.photoBytes)&&(identical(other.dateOfBirth, _this.dateOfBirth) || other.dateOfBirth == _this.dateOfBirth)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.primaryPosition, _this.primaryPosition) || other.primaryPosition == _this.primaryPosition)&&const DeepCollectionEquality().equals(other.secondaryPositions, _this.secondaryPositions)&&(identical(other.skillLevel, _this.skillLevel) || other.skillLevel == _this.skillLevel)&&(identical(other.preferredFoot, _this.preferredFoot) || other.preferredFoot == _this.preferredFoot)&&(identical(other.heightCm, _this.heightCm) || other.heightCm == _this.heightCm)&&(identical(other.yearsPlaying, _this.yearsPlaying) || other.yearsPlaying == _this.yearsPlaying)&&const DeepCollectionEquality().equals(other.languages, _this.languages)&&(identical(other.availability, _this.availability) || other.availability == _this.availability)&&(identical(other.bio, _this.bio) || other.bio == _this.bio)&&(identical(other.busy, _this.busy) || other.busy == _this.busy)&&(identical(other.usernameError, _this.usernameError) || other.usernameError == _this.usernameError));
}


@override
int get hashCode {
  final _this = this as OnboardingState;
  return Object.hash(runtimeType,_this.step,_this.fullName,_this.username,const DeepCollectionEquality().hash(_this.photoBytes),_this.dateOfBirth,_this.city,_this.primaryPosition,const DeepCollectionEquality().hash(_this.secondaryPositions),_this.skillLevel,_this.preferredFoot,_this.heightCm,_this.yearsPlaying,const DeepCollectionEquality().hash(_this.languages),_this.availability,_this.bio,_this.busy,_this.usernameError);
}

@override
String toString() {
  final _this = this as OnboardingState;
  return 'OnboardingState(step: ${_this.step}, fullName: ${_this.fullName}, username: ${_this.username}, photoBytes: ${_this.photoBytes}, dateOfBirth: ${_this.dateOfBirth}, city: ${_this.city}, primaryPosition: ${_this.primaryPosition}, secondaryPositions: ${_this.secondaryPositions}, skillLevel: ${_this.skillLevel}, preferredFoot: ${_this.preferredFoot}, heightCm: ${_this.heightCm}, yearsPlaying: ${_this.yearsPlaying}, languages: ${_this.languages}, availability: ${_this.availability}, bio: ${_this.bio}, busy: ${_this.busy}, usernameError: ${_this.usernameError})';
}


}

/// @nodoc
abstract mixin class $OnboardingStateCopyWith<$Res>  {
  factory $OnboardingStateCopyWith(OnboardingState value, $Res Function(OnboardingState) _then) = _$OnboardingStateCopyWithImpl;
@useResult
$Res call({
 OnboardingStep step, String fullName, String username, Uint8List? photoBytes, DateTime? dateOfBirth, String city, Position? primaryPosition, List<Position> secondaryPositions, SkillLevel? skillLevel, PreferredFoot preferredFoot, int? heightCm, int yearsPlaying, List<String> languages, Availability availability, String bio, bool busy, String? usernameError
});




}
/// @nodoc
class _$OnboardingStateCopyWithImpl<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  _$OnboardingStateCopyWithImpl(this._self, this._then);

  final OnboardingState _self;
  final $Res Function(OnboardingState) _then;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? step = null,Object? fullName = null,Object? username = null,Object? photoBytes = freezed,Object? dateOfBirth = freezed,Object? city = null,Object? primaryPosition = freezed,Object? secondaryPositions = null,Object? skillLevel = freezed,Object? preferredFoot = null,Object? heightCm = freezed,Object? yearsPlaying = null,Object? languages = null,Object? availability = null,Object? bio = null,Object? busy = null,Object? usernameError = freezed,}) {
  return _then(OnboardingState(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as OnboardingStep,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,photoBytes: freezed == photoBytes ? _self.photoBytes : photoBytes // ignore: cast_nullable_to_non_nullable
as Uint8List?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,primaryPosition: freezed == primaryPosition ? _self.primaryPosition : primaryPosition // ignore: cast_nullable_to_non_nullable
as Position?,secondaryPositions: null == secondaryPositions ? _self.secondaryPositions : secondaryPositions // ignore: cast_nullable_to_non_nullable
as List<Position>,skillLevel: freezed == skillLevel ? _self.skillLevel : skillLevel // ignore: cast_nullable_to_non_nullable
as SkillLevel?,preferredFoot: null == preferredFoot ? _self.preferredFoot : preferredFoot // ignore: cast_nullable_to_non_nullable
as PreferredFoot,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as int?,yearsPlaying: null == yearsPlaying ? _self.yearsPlaying : yearsPlaying // ignore: cast_nullable_to_non_nullable
as int,languages: null == languages ? _self.languages : languages // ignore: cast_nullable_to_non_nullable
as List<String>,availability: null == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as Availability,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,usernameError: freezed == usernameError ? _self.usernameError : usernameError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingState].
extension OnboardingStatePatterns on OnboardingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingState value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingState value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OnboardingStep step,  String fullName,  String username,  Uint8List? photoBytes,  DateTime? dateOfBirth,  String city,  Position? primaryPosition,  List<Position> secondaryPositions,  SkillLevel? skillLevel,  PreferredFoot preferredFoot,  int? heightCm,  int yearsPlaying,  List<String> languages,  Availability availability,  String bio,  bool busy,  String? usernameError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
return $default(_that.step,_that.fullName,_that.username,_that.photoBytes,_that.dateOfBirth,_that.city,_that.primaryPosition,_that.secondaryPositions,_that.skillLevel,_that.preferredFoot,_that.heightCm,_that.yearsPlaying,_that.languages,_that.availability,_that.bio,_that.busy,_that.usernameError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OnboardingStep step,  String fullName,  String username,  Uint8List? photoBytes,  DateTime? dateOfBirth,  String city,  Position? primaryPosition,  List<Position> secondaryPositions,  SkillLevel? skillLevel,  PreferredFoot preferredFoot,  int? heightCm,  int yearsPlaying,  List<String> languages,  Availability availability,  String bio,  bool busy,  String? usernameError)  $default,) {final _that = this;
switch (_that) {
case _OnboardingState():
return $default(_that.step,_that.fullName,_that.username,_that.photoBytes,_that.dateOfBirth,_that.city,_that.primaryPosition,_that.secondaryPositions,_that.skillLevel,_that.preferredFoot,_that.heightCm,_that.yearsPlaying,_that.languages,_that.availability,_that.bio,_that.busy,_that.usernameError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OnboardingStep step,  String fullName,  String username,  Uint8List? photoBytes,  DateTime? dateOfBirth,  String city,  Position? primaryPosition,  List<Position> secondaryPositions,  SkillLevel? skillLevel,  PreferredFoot preferredFoot,  int? heightCm,  int yearsPlaying,  List<String> languages,  Availability availability,  String bio,  bool busy,  String? usernameError)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
return $default(_that.step,_that.fullName,_that.username,_that.photoBytes,_that.dateOfBirth,_that.city,_that.primaryPosition,_that.secondaryPositions,_that.skillLevel,_that.preferredFoot,_that.heightCm,_that.yearsPlaying,_that.languages,_that.availability,_that.bio,_that.busy,_that.usernameError);case _:
  return null;

}
}

}

/// @nodoc


class _OnboardingState implements OnboardingState {
  const _OnboardingState({this.step = OnboardingStep.basics, this.fullName = '', this.username = '', this.photoBytes, this.dateOfBirth, this.city = '', this.primaryPosition,  List<Position> secondaryPositions = const <Position>[], this.skillLevel, this.preferredFoot = PreferredFoot.right, this.heightCm, this.yearsPlaying = 0,  List<String> languages = ProfileOptions.defaultLanguages, this.availability = const Availability(), this.bio = '', this.busy = false, this.usernameError}): _secondaryPositions = secondaryPositions,_languages = languages;
  

@override@JsonKey() final  OnboardingStep step;
@override@JsonKey() final  String fullName;
@override@JsonKey() final  String username;
@override final  Uint8List? photoBytes;
@override final  DateTime? dateOfBirth;
@override@JsonKey() final  String city;
@override final  Position? primaryPosition;
 final  List<Position> _secondaryPositions;
@override@JsonKey() List<Position> get secondaryPositions {
  if (_secondaryPositions is EqualUnmodifiableListView) return _secondaryPositions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_secondaryPositions);
}

@override final  SkillLevel? skillLevel;
@override@JsonKey() final  PreferredFoot preferredFoot;
@override final  int? heightCm;
@override@JsonKey() final  int yearsPlaying;
 final  List<String> _languages;
@override@JsonKey() List<String> get languages {
  if (_languages is EqualUnmodifiableListView) return _languages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_languages);
}

@override@JsonKey() final  Availability availability;
@override@JsonKey() final  String bio;
/// True while checking the username or saving.
@override@JsonKey() final  bool busy;
/// Shown under the username field (e.g. "already taken").
@override final  String? usernameError;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingStateCopyWith<_OnboardingState> get copyWith => __$OnboardingStateCopyWithImpl<_OnboardingState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingState&&(identical(other.step, step) || other.step == step)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.username, username) || other.username == username)&&const DeepCollectionEquality().equals(other.photoBytes, photoBytes)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.city, city) || other.city == city)&&(identical(other.primaryPosition, primaryPosition) || other.primaryPosition == primaryPosition)&&const DeepCollectionEquality().equals(other.secondaryPositions, _secondaryPositions)&&(identical(other.skillLevel, skillLevel) || other.skillLevel == skillLevel)&&(identical(other.preferredFoot, preferredFoot) || other.preferredFoot == preferredFoot)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.yearsPlaying, yearsPlaying) || other.yearsPlaying == yearsPlaying)&&const DeepCollectionEquality().equals(other.languages, _languages)&&(identical(other.availability, availability) || other.availability == availability)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.usernameError, usernameError) || other.usernameError == usernameError));
}


@override
int get hashCode {
    return Object.hash(runtimeType,step,fullName,username,const DeepCollectionEquality().hash(photoBytes),dateOfBirth,city,primaryPosition,const DeepCollectionEquality().hash(_secondaryPositions),skillLevel,preferredFoot,heightCm,yearsPlaying,const DeepCollectionEquality().hash(_languages),availability,bio,busy,usernameError);
}

@override
String toString() {
    return 'OnboardingState(step: $step, fullName: $fullName, username: $username, photoBytes: $photoBytes, dateOfBirth: $dateOfBirth, city: $city, primaryPosition: $primaryPosition, secondaryPositions: $secondaryPositions, skillLevel: $skillLevel, preferredFoot: $preferredFoot, heightCm: $heightCm, yearsPlaying: $yearsPlaying, languages: $languages, availability: $availability, bio: $bio, busy: $busy, usernameError: $usernameError)';
}


}

/// @nodoc
abstract mixin class _$OnboardingStateCopyWith<$Res> implements $OnboardingStateCopyWith<$Res> {
  factory _$OnboardingStateCopyWith(_OnboardingState value, $Res Function(_OnboardingState) _then) = __$OnboardingStateCopyWithImpl;
@override @useResult
$Res call({
 OnboardingStep step, String fullName, String username, Uint8List? photoBytes, DateTime? dateOfBirth, String city, Position? primaryPosition, List<Position> secondaryPositions, SkillLevel? skillLevel, PreferredFoot preferredFoot, int? heightCm, int yearsPlaying, List<String> languages, Availability availability, String bio, bool busy, String? usernameError
});




}
/// @nodoc
class __$OnboardingStateCopyWithImpl<$Res>
    implements _$OnboardingStateCopyWith<$Res> {
  __$OnboardingStateCopyWithImpl(this._self, this._then);

  final _OnboardingState _self;
  final $Res Function(_OnboardingState) _then;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? step = null,Object? fullName = null,Object? username = null,Object? photoBytes = freezed,Object? dateOfBirth = freezed,Object? city = null,Object? primaryPosition = freezed,Object? secondaryPositions = null,Object? skillLevel = freezed,Object? preferredFoot = null,Object? heightCm = freezed,Object? yearsPlaying = null,Object? languages = null,Object? availability = null,Object? bio = null,Object? busy = null,Object? usernameError = freezed,}) {
  return _then(_OnboardingState(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as OnboardingStep,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,photoBytes: freezed == photoBytes ? _self.photoBytes : photoBytes // ignore: cast_nullable_to_non_nullable
as Uint8List?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,primaryPosition: freezed == primaryPosition ? _self.primaryPosition : primaryPosition // ignore: cast_nullable_to_non_nullable
as Position?,secondaryPositions: null == secondaryPositions ? _self._secondaryPositions : secondaryPositions // ignore: cast_nullable_to_non_nullable
as List<Position>,skillLevel: freezed == skillLevel ? _self.skillLevel : skillLevel // ignore: cast_nullable_to_non_nullable
as SkillLevel?,preferredFoot: null == preferredFoot ? _self.preferredFoot : preferredFoot // ignore: cast_nullable_to_non_nullable
as PreferredFoot,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as int?,yearsPlaying: null == yearsPlaying ? _self.yearsPlaying : yearsPlaying // ignore: cast_nullable_to_non_nullable
as int,languages: null == languages ? _self._languages : languages // ignore: cast_nullable_to_non_nullable
as List<String>,availability: null == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as Availability,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,usernameError: freezed == usernameError ? _self.usernameError : usernameError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
