// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlayerStats {

 int get gamesPlayed; int get gamesOrganized; double get ratingAvg; int get ratingCount; int get goals; int get assists; int get yellowCards; int get redCards; int get motmAwards;
/// Create a copy of PlayerStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerStatsCopyWith<PlayerStats> get copyWith => _$PlayerStatsCopyWithImpl<PlayerStats>(this as PlayerStats, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PlayerStats;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerStats&&(identical(other.gamesPlayed, _this.gamesPlayed) || other.gamesPlayed == _this.gamesPlayed)&&(identical(other.gamesOrganized, _this.gamesOrganized) || other.gamesOrganized == _this.gamesOrganized)&&(identical(other.ratingAvg, _this.ratingAvg) || other.ratingAvg == _this.ratingAvg)&&(identical(other.ratingCount, _this.ratingCount) || other.ratingCount == _this.ratingCount)&&(identical(other.goals, _this.goals) || other.goals == _this.goals)&&(identical(other.assists, _this.assists) || other.assists == _this.assists)&&(identical(other.yellowCards, _this.yellowCards) || other.yellowCards == _this.yellowCards)&&(identical(other.redCards, _this.redCards) || other.redCards == _this.redCards)&&(identical(other.motmAwards, _this.motmAwards) || other.motmAwards == _this.motmAwards));
}


@override
int get hashCode {
  final _this = this as PlayerStats;
  return Object.hash(runtimeType,_this.gamesPlayed,_this.gamesOrganized,_this.ratingAvg,_this.ratingCount,_this.goals,_this.assists,_this.yellowCards,_this.redCards,_this.motmAwards);
}

@override
String toString() {
  final _this = this as PlayerStats;
  return 'PlayerStats(gamesPlayed: ${_this.gamesPlayed}, gamesOrganized: ${_this.gamesOrganized}, ratingAvg: ${_this.ratingAvg}, ratingCount: ${_this.ratingCount}, goals: ${_this.goals}, assists: ${_this.assists}, yellowCards: ${_this.yellowCards}, redCards: ${_this.redCards}, motmAwards: ${_this.motmAwards})';
}


}

/// @nodoc
abstract mixin class $PlayerStatsCopyWith<$Res>  {
  factory $PlayerStatsCopyWith(PlayerStats value, $Res Function(PlayerStats) _then) = _$PlayerStatsCopyWithImpl;
@useResult
$Res call({
 int gamesPlayed, int gamesOrganized, double ratingAvg, int ratingCount, int goals, int assists, int yellowCards, int redCards, int motmAwards
});




}
/// @nodoc
class _$PlayerStatsCopyWithImpl<$Res>
    implements $PlayerStatsCopyWith<$Res> {
  _$PlayerStatsCopyWithImpl(this._self, this._then);

  final PlayerStats _self;
  final $Res Function(PlayerStats) _then;

/// Create a copy of PlayerStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gamesPlayed = null,Object? gamesOrganized = null,Object? ratingAvg = null,Object? ratingCount = null,Object? goals = null,Object? assists = null,Object? yellowCards = null,Object? redCards = null,Object? motmAwards = null,}) {
  return _then(PlayerStats(
gamesPlayed: null == gamesPlayed ? _self.gamesPlayed : gamesPlayed // ignore: cast_nullable_to_non_nullable
as int,gamesOrganized: null == gamesOrganized ? _self.gamesOrganized : gamesOrganized // ignore: cast_nullable_to_non_nullable
as int,ratingAvg: null == ratingAvg ? _self.ratingAvg : ratingAvg // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as int,assists: null == assists ? _self.assists : assists // ignore: cast_nullable_to_non_nullable
as int,yellowCards: null == yellowCards ? _self.yellowCards : yellowCards // ignore: cast_nullable_to_non_nullable
as int,redCards: null == redCards ? _self.redCards : redCards // ignore: cast_nullable_to_non_nullable
as int,motmAwards: null == motmAwards ? _self.motmAwards : motmAwards // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerStats].
extension PlayerStatsPatterns on PlayerStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerStats value)  $default,){
final _that = this;
switch (_that) {
case _PlayerStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerStats value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int gamesPlayed,  int gamesOrganized,  double ratingAvg,  int ratingCount,  int goals,  int assists,  int yellowCards,  int redCards,  int motmAwards)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerStats() when $default != null:
return $default(_that.gamesPlayed,_that.gamesOrganized,_that.ratingAvg,_that.ratingCount,_that.goals,_that.assists,_that.yellowCards,_that.redCards,_that.motmAwards);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int gamesPlayed,  int gamesOrganized,  double ratingAvg,  int ratingCount,  int goals,  int assists,  int yellowCards,  int redCards,  int motmAwards)  $default,) {final _that = this;
switch (_that) {
case _PlayerStats():
return $default(_that.gamesPlayed,_that.gamesOrganized,_that.ratingAvg,_that.ratingCount,_that.goals,_that.assists,_that.yellowCards,_that.redCards,_that.motmAwards);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int gamesPlayed,  int gamesOrganized,  double ratingAvg,  int ratingCount,  int goals,  int assists,  int yellowCards,  int redCards,  int motmAwards)?  $default,) {final _that = this;
switch (_that) {
case _PlayerStats() when $default != null:
return $default(_that.gamesPlayed,_that.gamesOrganized,_that.ratingAvg,_that.ratingCount,_that.goals,_that.assists,_that.yellowCards,_that.redCards,_that.motmAwards);case _:
  return null;

}
}

}

/// @nodoc


class _PlayerStats extends PlayerStats {
  const _PlayerStats({this.gamesPlayed = 0, this.gamesOrganized = 0, this.ratingAvg = 0, this.ratingCount = 0, this.goals = 0, this.assists = 0, this.yellowCards = 0, this.redCards = 0, this.motmAwards = 0}): super._();
  

@override@JsonKey() final  int gamesPlayed;
@override@JsonKey() final  int gamesOrganized;
@override@JsonKey() final  double ratingAvg;
@override@JsonKey() final  int ratingCount;
@override@JsonKey() final  int goals;
@override@JsonKey() final  int assists;
@override@JsonKey() final  int yellowCards;
@override@JsonKey() final  int redCards;
@override@JsonKey() final  int motmAwards;

/// Create a copy of PlayerStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerStatsCopyWith<_PlayerStats> get copyWith => __$PlayerStatsCopyWithImpl<_PlayerStats>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerStats&&(identical(other.gamesPlayed, gamesPlayed) || other.gamesPlayed == gamesPlayed)&&(identical(other.gamesOrganized, gamesOrganized) || other.gamesOrganized == gamesOrganized)&&(identical(other.ratingAvg, ratingAvg) || other.ratingAvg == ratingAvg)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.goals, goals) || other.goals == goals)&&(identical(other.assists, assists) || other.assists == assists)&&(identical(other.yellowCards, yellowCards) || other.yellowCards == yellowCards)&&(identical(other.redCards, redCards) || other.redCards == redCards)&&(identical(other.motmAwards, motmAwards) || other.motmAwards == motmAwards));
}


@override
int get hashCode {
    return Object.hash(runtimeType,gamesPlayed,gamesOrganized,ratingAvg,ratingCount,goals,assists,yellowCards,redCards,motmAwards);
}

@override
String toString() {
    return 'PlayerStats(gamesPlayed: $gamesPlayed, gamesOrganized: $gamesOrganized, ratingAvg: $ratingAvg, ratingCount: $ratingCount, goals: $goals, assists: $assists, yellowCards: $yellowCards, redCards: $redCards, motmAwards: $motmAwards)';
}


}

/// @nodoc
abstract mixin class _$PlayerStatsCopyWith<$Res> implements $PlayerStatsCopyWith<$Res> {
  factory _$PlayerStatsCopyWith(_PlayerStats value, $Res Function(_PlayerStats) _then) = __$PlayerStatsCopyWithImpl;
@override @useResult
$Res call({
 int gamesPlayed, int gamesOrganized, double ratingAvg, int ratingCount, int goals, int assists, int yellowCards, int redCards, int motmAwards
});




}
/// @nodoc
class __$PlayerStatsCopyWithImpl<$Res>
    implements _$PlayerStatsCopyWith<$Res> {
  __$PlayerStatsCopyWithImpl(this._self, this._then);

  final _PlayerStats _self;
  final $Res Function(_PlayerStats) _then;

/// Create a copy of PlayerStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gamesPlayed = null,Object? gamesOrganized = null,Object? ratingAvg = null,Object? ratingCount = null,Object? goals = null,Object? assists = null,Object? yellowCards = null,Object? redCards = null,Object? motmAwards = null,}) {
  return _then(_PlayerStats(
gamesPlayed: null == gamesPlayed ? _self.gamesPlayed : gamesPlayed // ignore: cast_nullable_to_non_nullable
as int,gamesOrganized: null == gamesOrganized ? _self.gamesOrganized : gamesOrganized // ignore: cast_nullable_to_non_nullable
as int,ratingAvg: null == ratingAvg ? _self.ratingAvg : ratingAvg // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as int,assists: null == assists ? _self.assists : assists // ignore: cast_nullable_to_non_nullable
as int,yellowCards: null == yellowCards ? _self.yellowCards : yellowCards // ignore: cast_nullable_to_non_nullable
as int,redCards: null == redCards ? _self.redCards : redCards // ignore: cast_nullable_to_non_nullable
as int,motmAwards: null == motmAwards ? _self.motmAwards : motmAwards // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
