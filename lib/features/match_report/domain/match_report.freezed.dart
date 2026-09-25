// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlayerMatchLine {

 int get goals; int get assists;/// 0–2.
 int get yellowCards; bool get redCard;
/// Create a copy of PlayerMatchLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerMatchLineCopyWith<PlayerMatchLine> get copyWith => _$PlayerMatchLineCopyWithImpl<PlayerMatchLine>(this as PlayerMatchLine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PlayerMatchLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerMatchLine&&(identical(other.goals, _this.goals) || other.goals == _this.goals)&&(identical(other.assists, _this.assists) || other.assists == _this.assists)&&(identical(other.yellowCards, _this.yellowCards) || other.yellowCards == _this.yellowCards)&&(identical(other.redCard, _this.redCard) || other.redCard == _this.redCard));
}


@override
int get hashCode {
  final _this = this as PlayerMatchLine;
  return Object.hash(runtimeType,_this.goals,_this.assists,_this.yellowCards,_this.redCard);
}

@override
String toString() {
  final _this = this as PlayerMatchLine;
  return 'PlayerMatchLine(goals: ${_this.goals}, assists: ${_this.assists}, yellowCards: ${_this.yellowCards}, redCard: ${_this.redCard})';
}


}

/// @nodoc
abstract mixin class $PlayerMatchLineCopyWith<$Res>  {
  factory $PlayerMatchLineCopyWith(PlayerMatchLine value, $Res Function(PlayerMatchLine) _then) = _$PlayerMatchLineCopyWithImpl;
@useResult
$Res call({
 int goals, int assists, int yellowCards, bool redCard
});




}
/// @nodoc
class _$PlayerMatchLineCopyWithImpl<$Res>
    implements $PlayerMatchLineCopyWith<$Res> {
  _$PlayerMatchLineCopyWithImpl(this._self, this._then);

  final PlayerMatchLine _self;
  final $Res Function(PlayerMatchLine) _then;

/// Create a copy of PlayerMatchLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? goals = null,Object? assists = null,Object? yellowCards = null,Object? redCard = null,}) {
  return _then(PlayerMatchLine(
goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as int,assists: null == assists ? _self.assists : assists // ignore: cast_nullable_to_non_nullable
as int,yellowCards: null == yellowCards ? _self.yellowCards : yellowCards // ignore: cast_nullable_to_non_nullable
as int,redCard: null == redCard ? _self.redCard : redCard // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerMatchLine].
extension PlayerMatchLinePatterns on PlayerMatchLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerMatchLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerMatchLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerMatchLine value)  $default,){
final _that = this;
switch (_that) {
case _PlayerMatchLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerMatchLine value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerMatchLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int goals,  int assists,  int yellowCards,  bool redCard)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerMatchLine() when $default != null:
return $default(_that.goals,_that.assists,_that.yellowCards,_that.redCard);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int goals,  int assists,  int yellowCards,  bool redCard)  $default,) {final _that = this;
switch (_that) {
case _PlayerMatchLine():
return $default(_that.goals,_that.assists,_that.yellowCards,_that.redCard);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int goals,  int assists,  int yellowCards,  bool redCard)?  $default,) {final _that = this;
switch (_that) {
case _PlayerMatchLine() when $default != null:
return $default(_that.goals,_that.assists,_that.yellowCards,_that.redCard);case _:
  return null;

}
}

}

/// @nodoc


class _PlayerMatchLine extends PlayerMatchLine {
  const _PlayerMatchLine({this.goals = 0, this.assists = 0, this.yellowCards = 0, this.redCard = false}): super._();
  

@override@JsonKey() final  int goals;
@override@JsonKey() final  int assists;
/// 0–2.
@override@JsonKey() final  int yellowCards;
@override@JsonKey() final  bool redCard;

/// Create a copy of PlayerMatchLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerMatchLineCopyWith<_PlayerMatchLine> get copyWith => __$PlayerMatchLineCopyWithImpl<_PlayerMatchLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerMatchLine&&(identical(other.goals, goals) || other.goals == goals)&&(identical(other.assists, assists) || other.assists == assists)&&(identical(other.yellowCards, yellowCards) || other.yellowCards == yellowCards)&&(identical(other.redCard, redCard) || other.redCard == redCard));
}


@override
int get hashCode {
    return Object.hash(runtimeType,goals,assists,yellowCards,redCard);
}

@override
String toString() {
    return 'PlayerMatchLine(goals: $goals, assists: $assists, yellowCards: $yellowCards, redCard: $redCard)';
}


}

/// @nodoc
abstract mixin class _$PlayerMatchLineCopyWith<$Res> implements $PlayerMatchLineCopyWith<$Res> {
  factory _$PlayerMatchLineCopyWith(_PlayerMatchLine value, $Res Function(_PlayerMatchLine) _then) = __$PlayerMatchLineCopyWithImpl;
@override @useResult
$Res call({
 int goals, int assists, int yellowCards, bool redCard
});




}
/// @nodoc
class __$PlayerMatchLineCopyWithImpl<$Res>
    implements _$PlayerMatchLineCopyWith<$Res> {
  __$PlayerMatchLineCopyWithImpl(this._self, this._then);

  final _PlayerMatchLine _self;
  final $Res Function(_PlayerMatchLine) _then;

/// Create a copy of PlayerMatchLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? goals = null,Object? assists = null,Object? yellowCards = null,Object? redCard = null,}) {
  return _then(_PlayerMatchLine(
goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as int,assists: null == assists ? _self.assists : assists // ignore: cast_nullable_to_non_nullable
as int,yellowCards: null == yellowCards ? _self.yellowCards : yellowCards // ignore: cast_nullable_to_non_nullable
as int,redCard: null == redCard ? _self.redCard : redCard // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$MatchReport {

 Map<String, PlayerMatchLine> get players; DateTime? get submittedAt;
/// Create a copy of MatchReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchReportCopyWith<MatchReport> get copyWith => _$MatchReportCopyWithImpl<MatchReport>(this as MatchReport, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MatchReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchReport&&const DeepCollectionEquality().equals(other.players, _this.players)&&(identical(other.submittedAt, _this.submittedAt) || other.submittedAt == _this.submittedAt));
}


@override
int get hashCode {
  final _this = this as MatchReport;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.players),_this.submittedAt);
}

@override
String toString() {
  final _this = this as MatchReport;
  return 'MatchReport(players: ${_this.players}, submittedAt: ${_this.submittedAt})';
}


}

/// @nodoc
abstract mixin class $MatchReportCopyWith<$Res>  {
  factory $MatchReportCopyWith(MatchReport value, $Res Function(MatchReport) _then) = _$MatchReportCopyWithImpl;
@useResult
$Res call({
 Map<String, PlayerMatchLine> players, DateTime? submittedAt
});




}
/// @nodoc
class _$MatchReportCopyWithImpl<$Res>
    implements $MatchReportCopyWith<$Res> {
  _$MatchReportCopyWithImpl(this._self, this._then);

  final MatchReport _self;
  final $Res Function(MatchReport) _then;

/// Create a copy of MatchReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? players = null,Object? submittedAt = freezed,}) {
  return _then(MatchReport(
players: null == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as Map<String, PlayerMatchLine>,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MatchReport].
extension MatchReportPatterns on MatchReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchReport value)  $default,){
final _that = this;
switch (_that) {
case _MatchReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchReport value)?  $default,){
final _that = this;
switch (_that) {
case _MatchReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, PlayerMatchLine> players,  DateTime? submittedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchReport() when $default != null:
return $default(_that.players,_that.submittedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, PlayerMatchLine> players,  DateTime? submittedAt)  $default,) {final _that = this;
switch (_that) {
case _MatchReport():
return $default(_that.players,_that.submittedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, PlayerMatchLine> players,  DateTime? submittedAt)?  $default,) {final _that = this;
switch (_that) {
case _MatchReport() when $default != null:
return $default(_that.players,_that.submittedAt);case _:
  return null;

}
}

}

/// @nodoc


class _MatchReport extends MatchReport {
  const _MatchReport({ Map<String, PlayerMatchLine> players = const <String, PlayerMatchLine>{}, this.submittedAt}): _players = players,super._();
  

 final  Map<String, PlayerMatchLine> _players;
@override@JsonKey() Map<String, PlayerMatchLine> get players {
  if (_players is EqualUnmodifiableMapView) return _players;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_players);
}

@override final  DateTime? submittedAt;

/// Create a copy of MatchReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchReportCopyWith<_MatchReport> get copyWith => __$MatchReportCopyWithImpl<_MatchReport>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchReport&&const DeepCollectionEquality().equals(other.players, _players)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_players),submittedAt);
}

@override
String toString() {
    return 'MatchReport(players: $players, submittedAt: $submittedAt)';
}


}

/// @nodoc
abstract mixin class _$MatchReportCopyWith<$Res> implements $MatchReportCopyWith<$Res> {
  factory _$MatchReportCopyWith(_MatchReport value, $Res Function(_MatchReport) _then) = __$MatchReportCopyWithImpl;
@override @useResult
$Res call({
 Map<String, PlayerMatchLine> players, DateTime? submittedAt
});




}
/// @nodoc
class __$MatchReportCopyWithImpl<$Res>
    implements _$MatchReportCopyWith<$Res> {
  __$MatchReportCopyWithImpl(this._self, this._then);

  final _MatchReport _self;
  final $Res Function(_MatchReport) _then;

/// Create a copy of MatchReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? players = null,Object? submittedAt = freezed,}) {
  return _then(_MatchReport(
players: null == players ? _self._players : players // ignore: cast_nullable_to_non_nullable
as Map<String, PlayerMatchLine>,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$MotmResult {

 List<UserSummary> get winners; int get votes; int get totalVotes;
/// Create a copy of MotmResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MotmResultCopyWith<MotmResult> get copyWith => _$MotmResultCopyWithImpl<MotmResult>(this as MotmResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MotmResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MotmResult&&const DeepCollectionEquality().equals(other.winners, _this.winners)&&(identical(other.votes, _this.votes) || other.votes == _this.votes)&&(identical(other.totalVotes, _this.totalVotes) || other.totalVotes == _this.totalVotes));
}


@override
int get hashCode {
  final _this = this as MotmResult;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.winners),_this.votes,_this.totalVotes);
}

@override
String toString() {
  final _this = this as MotmResult;
  return 'MotmResult(winners: ${_this.winners}, votes: ${_this.votes}, totalVotes: ${_this.totalVotes})';
}


}

/// @nodoc
abstract mixin class $MotmResultCopyWith<$Res>  {
  factory $MotmResultCopyWith(MotmResult value, $Res Function(MotmResult) _then) = _$MotmResultCopyWithImpl;
@useResult
$Res call({
 List<UserSummary> winners, int votes, int totalVotes
});




}
/// @nodoc
class _$MotmResultCopyWithImpl<$Res>
    implements $MotmResultCopyWith<$Res> {
  _$MotmResultCopyWithImpl(this._self, this._then);

  final MotmResult _self;
  final $Res Function(MotmResult) _then;

/// Create a copy of MotmResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? winners = null,Object? votes = null,Object? totalVotes = null,}) {
  return _then(MotmResult(
winners: null == winners ? _self.winners : winners // ignore: cast_nullable_to_non_nullable
as List<UserSummary>,votes: null == votes ? _self.votes : votes // ignore: cast_nullable_to_non_nullable
as int,totalVotes: null == totalVotes ? _self.totalVotes : totalVotes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MotmResult].
extension MotmResultPatterns on MotmResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MotmResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MotmResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MotmResult value)  $default,){
final _that = this;
switch (_that) {
case _MotmResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MotmResult value)?  $default,){
final _that = this;
switch (_that) {
case _MotmResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<UserSummary> winners,  int votes,  int totalVotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MotmResult() when $default != null:
return $default(_that.winners,_that.votes,_that.totalVotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<UserSummary> winners,  int votes,  int totalVotes)  $default,) {final _that = this;
switch (_that) {
case _MotmResult():
return $default(_that.winners,_that.votes,_that.totalVotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<UserSummary> winners,  int votes,  int totalVotes)?  $default,) {final _that = this;
switch (_that) {
case _MotmResult() when $default != null:
return $default(_that.winners,_that.votes,_that.totalVotes);case _:
  return null;

}
}

}

/// @nodoc


class _MotmResult implements MotmResult {
  const _MotmResult({ List<UserSummary> winners = const <UserSummary>[], this.votes = 0, this.totalVotes = 0}): _winners = winners;
  

 final  List<UserSummary> _winners;
@override@JsonKey() List<UserSummary> get winners {
  if (_winners is EqualUnmodifiableListView) return _winners;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_winners);
}

@override@JsonKey() final  int votes;
@override@JsonKey() final  int totalVotes;

/// Create a copy of MotmResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MotmResultCopyWith<_MotmResult> get copyWith => __$MotmResultCopyWithImpl<_MotmResult>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MotmResult&&const DeepCollectionEquality().equals(other.winners, _winners)&&(identical(other.votes, votes) || other.votes == votes)&&(identical(other.totalVotes, totalVotes) || other.totalVotes == totalVotes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_winners),votes,totalVotes);
}

@override
String toString() {
    return 'MotmResult(winners: $winners, votes: $votes, totalVotes: $totalVotes)';
}


}

/// @nodoc
abstract mixin class _$MotmResultCopyWith<$Res> implements $MotmResultCopyWith<$Res> {
  factory _$MotmResultCopyWith(_MotmResult value, $Res Function(_MotmResult) _then) = __$MotmResultCopyWithImpl;
@override @useResult
$Res call({
 List<UserSummary> winners, int votes, int totalVotes
});




}
/// @nodoc
class __$MotmResultCopyWithImpl<$Res>
    implements _$MotmResultCopyWith<$Res> {
  __$MotmResultCopyWithImpl(this._self, this._then);

  final _MotmResult _self;
  final $Res Function(_MotmResult) _then;

/// Create a copy of MotmResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? winners = null,Object? votes = null,Object? totalVotes = null,}) {
  return _then(_MotmResult(
winners: null == winners ? _self._winners : winners // ignore: cast_nullable_to_non_nullable
as List<UserSummary>,votes: null == votes ? _self.votes : votes // ignore: cast_nullable_to_non_nullable
as int,totalVotes: null == totalVotes ? _self.totalVotes : totalVotes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
