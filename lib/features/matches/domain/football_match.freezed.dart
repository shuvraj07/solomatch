// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'football_match.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FootballMatch {

 String get id; UserSummary get organizer; String get title; Venue get venue; DateTime get startAt; DateTime get endAt; MatchFormat get format; int get maxPlayers;/// Accepted players. Server-maintained.
 int get currentPlayers;/// Confirmed friends without a SoloMatch account (counted in
/// [currentPlayers], not on the roster).
 int get guestCount; PositionSlots get slots; SkillLevel get skillLevel; Price get price; bool get isIndoor; String get description; String get rules; List<String> get photos; MatchStatus get status; DateTime? get createdAt;/// Set when the match completes: end + 24 h. The report can be
/// edited and MOTM votes cast until then.
 DateTime? get votingClosesAt; MatchReport? get report;/// Null until voting closes.
 MotmResult? get motm;/// Set when the organizer booked a venue slot through the app.
 MatchBooking? get booking;/// Live match center: team names, score and how many people follow.
 MatchTeams get teams; LiveScore? get score; int get followerCount;
/// Create a copy of FootballMatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FootballMatchCopyWith<FootballMatch> get copyWith => _$FootballMatchCopyWithImpl<FootballMatch>(this as FootballMatch, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FootballMatch;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FootballMatch&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizer, _this.organizer) || other.organizer == _this.organizer)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.venue, _this.venue) || other.venue == _this.venue)&&(identical(other.startAt, _this.startAt) || other.startAt == _this.startAt)&&(identical(other.endAt, _this.endAt) || other.endAt == _this.endAt)&&(identical(other.format, _this.format) || other.format == _this.format)&&(identical(other.maxPlayers, _this.maxPlayers) || other.maxPlayers == _this.maxPlayers)&&(identical(other.currentPlayers, _this.currentPlayers) || other.currentPlayers == _this.currentPlayers)&&(identical(other.guestCount, _this.guestCount) || other.guestCount == _this.guestCount)&&(identical(other.slots, _this.slots) || other.slots == _this.slots)&&(identical(other.skillLevel, _this.skillLevel) || other.skillLevel == _this.skillLevel)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.isIndoor, _this.isIndoor) || other.isIndoor == _this.isIndoor)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.rules, _this.rules) || other.rules == _this.rules)&&const DeepCollectionEquality().equals(other.photos, _this.photos)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.votingClosesAt, _this.votingClosesAt) || other.votingClosesAt == _this.votingClosesAt)&&(identical(other.report, _this.report) || other.report == _this.report)&&(identical(other.motm, _this.motm) || other.motm == _this.motm)&&(identical(other.booking, _this.booking) || other.booking == _this.booking)&&(identical(other.teams, _this.teams) || other.teams == _this.teams)&&(identical(other.score, _this.score) || other.score == _this.score)&&(identical(other.followerCount, _this.followerCount) || other.followerCount == _this.followerCount));
}


@override
int get hashCode {
  final _this = this as FootballMatch;
  return Object.hashAll([runtimeType,_this.id,_this.organizer,_this.title,_this.venue,_this.startAt,_this.endAt,_this.format,_this.maxPlayers,_this.currentPlayers,_this.guestCount,_this.slots,_this.skillLevel,_this.price,_this.isIndoor,_this.description,_this.rules,const DeepCollectionEquality().hash(_this.photos),_this.status,_this.createdAt,_this.votingClosesAt,_this.report,_this.motm,_this.booking,_this.teams,_this.score,_this.followerCount]);
}

@override
String toString() {
  final _this = this as FootballMatch;
  return 'FootballMatch(id: ${_this.id}, organizer: ${_this.organizer}, title: ${_this.title}, venue: ${_this.venue}, startAt: ${_this.startAt}, endAt: ${_this.endAt}, format: ${_this.format}, maxPlayers: ${_this.maxPlayers}, currentPlayers: ${_this.currentPlayers}, guestCount: ${_this.guestCount}, slots: ${_this.slots}, skillLevel: ${_this.skillLevel}, price: ${_this.price}, isIndoor: ${_this.isIndoor}, description: ${_this.description}, rules: ${_this.rules}, photos: ${_this.photos}, status: ${_this.status}, createdAt: ${_this.createdAt}, votingClosesAt: ${_this.votingClosesAt}, report: ${_this.report}, motm: ${_this.motm}, booking: ${_this.booking}, teams: ${_this.teams}, score: ${_this.score}, followerCount: ${_this.followerCount})';
}


}

/// @nodoc
abstract mixin class $FootballMatchCopyWith<$Res>  {
  factory $FootballMatchCopyWith(FootballMatch value, $Res Function(FootballMatch) _then) = _$FootballMatchCopyWithImpl;
@useResult
$Res call({
 String id, UserSummary organizer, String title, Venue venue, DateTime startAt, DateTime endAt, MatchFormat format, int maxPlayers, int currentPlayers, int guestCount, PositionSlots slots, SkillLevel skillLevel, Price price, bool isIndoor, String description, String rules, List<String> photos, MatchStatus status, DateTime? createdAt, DateTime? votingClosesAt, MatchReport? report, MotmResult? motm, MatchBooking? booking, MatchTeams teams, LiveScore? score, int followerCount
});


$UserSummaryCopyWith<$Res> get organizer;$VenueCopyWith<$Res> get venue;$MatchReportCopyWith<$Res>? get report;$MotmResultCopyWith<$Res>? get motm;

}
/// @nodoc
class _$FootballMatchCopyWithImpl<$Res>
    implements $FootballMatchCopyWith<$Res> {
  _$FootballMatchCopyWithImpl(this._self, this._then);

  final FootballMatch _self;
  final $Res Function(FootballMatch) _then;

/// Create a copy of FootballMatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizer = null,Object? title = null,Object? venue = null,Object? startAt = null,Object? endAt = null,Object? format = null,Object? maxPlayers = null,Object? currentPlayers = null,Object? guestCount = null,Object? slots = null,Object? skillLevel = null,Object? price = null,Object? isIndoor = null,Object? description = null,Object? rules = null,Object? photos = null,Object? status = null,Object? createdAt = freezed,Object? votingClosesAt = freezed,Object? report = freezed,Object? motm = freezed,Object? booking = freezed,Object? teams = null,Object? score = freezed,Object? followerCount = null,}) {
  return _then(FootballMatch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizer: null == organizer ? _self.organizer : organizer // ignore: cast_nullable_to_non_nullable
as UserSummary,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as Venue,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as MatchFormat,maxPlayers: null == maxPlayers ? _self.maxPlayers : maxPlayers // ignore: cast_nullable_to_non_nullable
as int,currentPlayers: null == currentPlayers ? _self.currentPlayers : currentPlayers // ignore: cast_nullable_to_non_nullable
as int,guestCount: null == guestCount ? _self.guestCount : guestCount // ignore: cast_nullable_to_non_nullable
as int,slots: null == slots ? _self.slots : slots // ignore: cast_nullable_to_non_nullable
as PositionSlots,skillLevel: null == skillLevel ? _self.skillLevel : skillLevel // ignore: cast_nullable_to_non_nullable
as SkillLevel,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Price,isIndoor: null == isIndoor ? _self.isIndoor : isIndoor // ignore: cast_nullable_to_non_nullable
as bool,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as String,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MatchStatus,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,votingClosesAt: freezed == votingClosesAt ? _self.votingClosesAt : votingClosesAt // ignore: cast_nullable_to_non_nullable
as DateTime?,report: freezed == report ? _self.report : report // ignore: cast_nullable_to_non_nullable
as MatchReport?,motm: freezed == motm ? _self.motm : motm // ignore: cast_nullable_to_non_nullable
as MotmResult?,booking: freezed == booking ? _self.booking : booking // ignore: cast_nullable_to_non_nullable
as MatchBooking?,teams: null == teams ? _self.teams : teams // ignore: cast_nullable_to_non_nullable
as MatchTeams,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as LiveScore?,followerCount: null == followerCount ? _self.followerCount : followerCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of FootballMatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSummaryCopyWith<$Res> get organizer {
  
  return $UserSummaryCopyWith<$Res>(_self.organizer, (value) {
    return _then(_self.copyWith(organizer: value));
  });
}/// Create a copy of FootballMatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VenueCopyWith<$Res> get venue {
  
  return $VenueCopyWith<$Res>(_self.venue, (value) {
    return _then(_self.copyWith(venue: value));
  });
}/// Create a copy of FootballMatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchReportCopyWith<$Res>? get report {
    if (_self.report == null) {
    return null;
  }

  return $MatchReportCopyWith<$Res>(_self.report!, (value) {
    return _then(_self.copyWith(report: value));
  });
}/// Create a copy of FootballMatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MotmResultCopyWith<$Res>? get motm {
    if (_self.motm == null) {
    return null;
  }

  return $MotmResultCopyWith<$Res>(_self.motm!, (value) {
    return _then(_self.copyWith(motm: value));
  });
}
}


/// Adds pattern-matching-related methods to [FootballMatch].
extension FootballMatchPatterns on FootballMatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FootballMatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FootballMatch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FootballMatch value)  $default,){
final _that = this;
switch (_that) {
case _FootballMatch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FootballMatch value)?  $default,){
final _that = this;
switch (_that) {
case _FootballMatch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  UserSummary organizer,  String title,  Venue venue,  DateTime startAt,  DateTime endAt,  MatchFormat format,  int maxPlayers,  int currentPlayers,  int guestCount,  PositionSlots slots,  SkillLevel skillLevel,  Price price,  bool isIndoor,  String description,  String rules,  List<String> photos,  MatchStatus status,  DateTime? createdAt,  DateTime? votingClosesAt,  MatchReport? report,  MotmResult? motm,  MatchBooking? booking,  MatchTeams teams,  LiveScore? score,  int followerCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FootballMatch() when $default != null:
return $default(_that.id,_that.organizer,_that.title,_that.venue,_that.startAt,_that.endAt,_that.format,_that.maxPlayers,_that.currentPlayers,_that.guestCount,_that.slots,_that.skillLevel,_that.price,_that.isIndoor,_that.description,_that.rules,_that.photos,_that.status,_that.createdAt,_that.votingClosesAt,_that.report,_that.motm,_that.booking,_that.teams,_that.score,_that.followerCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  UserSummary organizer,  String title,  Venue venue,  DateTime startAt,  DateTime endAt,  MatchFormat format,  int maxPlayers,  int currentPlayers,  int guestCount,  PositionSlots slots,  SkillLevel skillLevel,  Price price,  bool isIndoor,  String description,  String rules,  List<String> photos,  MatchStatus status,  DateTime? createdAt,  DateTime? votingClosesAt,  MatchReport? report,  MotmResult? motm,  MatchBooking? booking,  MatchTeams teams,  LiveScore? score,  int followerCount)  $default,) {final _that = this;
switch (_that) {
case _FootballMatch():
return $default(_that.id,_that.organizer,_that.title,_that.venue,_that.startAt,_that.endAt,_that.format,_that.maxPlayers,_that.currentPlayers,_that.guestCount,_that.slots,_that.skillLevel,_that.price,_that.isIndoor,_that.description,_that.rules,_that.photos,_that.status,_that.createdAt,_that.votingClosesAt,_that.report,_that.motm,_that.booking,_that.teams,_that.score,_that.followerCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  UserSummary organizer,  String title,  Venue venue,  DateTime startAt,  DateTime endAt,  MatchFormat format,  int maxPlayers,  int currentPlayers,  int guestCount,  PositionSlots slots,  SkillLevel skillLevel,  Price price,  bool isIndoor,  String description,  String rules,  List<String> photos,  MatchStatus status,  DateTime? createdAt,  DateTime? votingClosesAt,  MatchReport? report,  MotmResult? motm,  MatchBooking? booking,  MatchTeams teams,  LiveScore? score,  int followerCount)?  $default,) {final _that = this;
switch (_that) {
case _FootballMatch() when $default != null:
return $default(_that.id,_that.organizer,_that.title,_that.venue,_that.startAt,_that.endAt,_that.format,_that.maxPlayers,_that.currentPlayers,_that.guestCount,_that.slots,_that.skillLevel,_that.price,_that.isIndoor,_that.description,_that.rules,_that.photos,_that.status,_that.createdAt,_that.votingClosesAt,_that.report,_that.motm,_that.booking,_that.teams,_that.score,_that.followerCount);case _:
  return null;

}
}

}

/// @nodoc


class _FootballMatch extends FootballMatch {
  const _FootballMatch({required this.id, required this.organizer, required this.title, required this.venue, required this.startAt, required this.endAt, required this.format, required this.maxPlayers, required this.currentPlayers, this.guestCount = 0, required this.slots, required this.skillLevel, required this.price, this.isIndoor = false, this.description = '', this.rules = '',  List<String> photos = const <String>[], required this.status, this.createdAt, this.votingClosesAt, this.report, this.motm, this.booking, this.teams = const (home: 'Team A', away: 'Team B'), this.score, this.followerCount = 0}): _photos = photos,super._();
  

@override final  String id;
@override final  UserSummary organizer;
@override final  String title;
@override final  Venue venue;
@override final  DateTime startAt;
@override final  DateTime endAt;
@override final  MatchFormat format;
@override final  int maxPlayers;
/// Accepted players. Server-maintained.
@override final  int currentPlayers;
/// Confirmed friends without a SoloMatch account (counted in
/// [currentPlayers], not on the roster).
@override@JsonKey() final  int guestCount;
@override final  PositionSlots slots;
@override final  SkillLevel skillLevel;
@override final  Price price;
@override@JsonKey() final  bool isIndoor;
@override@JsonKey() final  String description;
@override@JsonKey() final  String rules;
 final  List<String> _photos;
@override@JsonKey() List<String> get photos {
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photos);
}

@override final  MatchStatus status;
@override final  DateTime? createdAt;
/// Set when the match completes: end + 24 h. The report can be
/// edited and MOTM votes cast until then.
@override final  DateTime? votingClosesAt;
@override final  MatchReport? report;
/// Null until voting closes.
@override final  MotmResult? motm;
/// Set when the organizer booked a venue slot through the app.
@override final  MatchBooking? booking;
/// Live match center: team names, score and how many people follow.
@override@JsonKey() final  MatchTeams teams;
@override final  LiveScore? score;
@override@JsonKey() final  int followerCount;

/// Create a copy of FootballMatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FootballMatchCopyWith<_FootballMatch> get copyWith => __$FootballMatchCopyWithImpl<_FootballMatch>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FootballMatch&&(identical(other.id, id) || other.id == id)&&(identical(other.organizer, organizer) || other.organizer == organizer)&&(identical(other.title, title) || other.title == title)&&(identical(other.venue, venue) || other.venue == venue)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.format, format) || other.format == format)&&(identical(other.maxPlayers, maxPlayers) || other.maxPlayers == maxPlayers)&&(identical(other.currentPlayers, currentPlayers) || other.currentPlayers == currentPlayers)&&(identical(other.guestCount, guestCount) || other.guestCount == guestCount)&&(identical(other.slots, slots) || other.slots == slots)&&(identical(other.skillLevel, skillLevel) || other.skillLevel == skillLevel)&&(identical(other.price, price) || other.price == price)&&(identical(other.isIndoor, isIndoor) || other.isIndoor == isIndoor)&&(identical(other.description, description) || other.description == description)&&(identical(other.rules, rules) || other.rules == rules)&&const DeepCollectionEquality().equals(other.photos, _photos)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.votingClosesAt, votingClosesAt) || other.votingClosesAt == votingClosesAt)&&(identical(other.report, report) || other.report == report)&&(identical(other.motm, motm) || other.motm == motm)&&(identical(other.booking, booking) || other.booking == booking)&&(identical(other.teams, teams) || other.teams == teams)&&(identical(other.score, score) || other.score == score)&&(identical(other.followerCount, followerCount) || other.followerCount == followerCount));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,id,organizer,title,venue,startAt,endAt,format,maxPlayers,currentPlayers,guestCount,slots,skillLevel,price,isIndoor,description,rules,const DeepCollectionEquality().hash(_photos),status,createdAt,votingClosesAt,report,motm,booking,teams,score,followerCount]);
}

@override
String toString() {
    return 'FootballMatch(id: $id, organizer: $organizer, title: $title, venue: $venue, startAt: $startAt, endAt: $endAt, format: $format, maxPlayers: $maxPlayers, currentPlayers: $currentPlayers, guestCount: $guestCount, slots: $slots, skillLevel: $skillLevel, price: $price, isIndoor: $isIndoor, description: $description, rules: $rules, photos: $photos, status: $status, createdAt: $createdAt, votingClosesAt: $votingClosesAt, report: $report, motm: $motm, booking: $booking, teams: $teams, score: $score, followerCount: $followerCount)';
}


}

/// @nodoc
abstract mixin class _$FootballMatchCopyWith<$Res> implements $FootballMatchCopyWith<$Res> {
  factory _$FootballMatchCopyWith(_FootballMatch value, $Res Function(_FootballMatch) _then) = __$FootballMatchCopyWithImpl;
@override @useResult
$Res call({
 String id, UserSummary organizer, String title, Venue venue, DateTime startAt, DateTime endAt, MatchFormat format, int maxPlayers, int currentPlayers, int guestCount, PositionSlots slots, SkillLevel skillLevel, Price price, bool isIndoor, String description, String rules, List<String> photos, MatchStatus status, DateTime? createdAt, DateTime? votingClosesAt, MatchReport? report, MotmResult? motm, MatchBooking? booking, MatchTeams teams, LiveScore? score, int followerCount
});


@override $UserSummaryCopyWith<$Res> get organizer;@override $VenueCopyWith<$Res> get venue;@override $MatchReportCopyWith<$Res>? get report;@override $MotmResultCopyWith<$Res>? get motm;

}
/// @nodoc
class __$FootballMatchCopyWithImpl<$Res>
    implements _$FootballMatchCopyWith<$Res> {
  __$FootballMatchCopyWithImpl(this._self, this._then);

  final _FootballMatch _self;
  final $Res Function(_FootballMatch) _then;

/// Create a copy of FootballMatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizer = null,Object? title = null,Object? venue = null,Object? startAt = null,Object? endAt = null,Object? format = null,Object? maxPlayers = null,Object? currentPlayers = null,Object? guestCount = null,Object? slots = null,Object? skillLevel = null,Object? price = null,Object? isIndoor = null,Object? description = null,Object? rules = null,Object? photos = null,Object? status = null,Object? createdAt = freezed,Object? votingClosesAt = freezed,Object? report = freezed,Object? motm = freezed,Object? booking = freezed,Object? teams = null,Object? score = freezed,Object? followerCount = null,}) {
  return _then(_FootballMatch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizer: null == organizer ? _self.organizer : organizer // ignore: cast_nullable_to_non_nullable
as UserSummary,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as Venue,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as MatchFormat,maxPlayers: null == maxPlayers ? _self.maxPlayers : maxPlayers // ignore: cast_nullable_to_non_nullable
as int,currentPlayers: null == currentPlayers ? _self.currentPlayers : currentPlayers // ignore: cast_nullable_to_non_nullable
as int,guestCount: null == guestCount ? _self.guestCount : guestCount // ignore: cast_nullable_to_non_nullable
as int,slots: null == slots ? _self.slots : slots // ignore: cast_nullable_to_non_nullable
as PositionSlots,skillLevel: null == skillLevel ? _self.skillLevel : skillLevel // ignore: cast_nullable_to_non_nullable
as SkillLevel,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Price,isIndoor: null == isIndoor ? _self.isIndoor : isIndoor // ignore: cast_nullable_to_non_nullable
as bool,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as String,photos: null == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MatchStatus,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,votingClosesAt: freezed == votingClosesAt ? _self.votingClosesAt : votingClosesAt // ignore: cast_nullable_to_non_nullable
as DateTime?,report: freezed == report ? _self.report : report // ignore: cast_nullable_to_non_nullable
as MatchReport?,motm: freezed == motm ? _self.motm : motm // ignore: cast_nullable_to_non_nullable
as MotmResult?,booking: freezed == booking ? _self.booking : booking // ignore: cast_nullable_to_non_nullable
as MatchBooking?,teams: null == teams ? _self.teams : teams // ignore: cast_nullable_to_non_nullable
as MatchTeams,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as LiveScore?,followerCount: null == followerCount ? _self.followerCount : followerCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of FootballMatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSummaryCopyWith<$Res> get organizer {
  
  return $UserSummaryCopyWith<$Res>(_self.organizer, (value) {
    return _then(_self.copyWith(organizer: value));
  });
}/// Create a copy of FootballMatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VenueCopyWith<$Res> get venue {
  
  return $VenueCopyWith<$Res>(_self.venue, (value) {
    return _then(_self.copyWith(venue: value));
  });
}/// Create a copy of FootballMatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchReportCopyWith<$Res>? get report {
    if (_self.report == null) {
    return null;
  }

  return $MatchReportCopyWith<$Res>(_self.report!, (value) {
    return _then(_self.copyWith(report: value));
  });
}/// Create a copy of FootballMatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MotmResultCopyWith<$Res>? get motm {
    if (_self.motm == null) {
    return null;
  }

  return $MotmResultCopyWith<$Res>(_self.motm!, (value) {
    return _then(_self.copyWith(motm: value));
  });
}
}

// dart format on
