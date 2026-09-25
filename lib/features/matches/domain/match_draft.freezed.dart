// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MatchDraft {

 String get id; String get organizerId; String get title; Venue? get venue;/// Calendar day of the match (time part ignored).
 DateTime? get date;/// Minutes after midnight, e.g. 18:00 → 1080.
 int? get startMinutes; int? get endMinutes; MatchFormat get format; int get maxPlayers; Map<PositionGroup, int> get neededPositions; SkillLevel get skillLevel;/// Per-player fee in NPR; 0 = free.
 int get priceAmount; bool get isIndoor; String get description; String get rules; List<String> get photos;/// The organizer takes a roster spot too.
 bool get organizerPlaying; PositionGroup? get organizerGroup;/// SoloMatch users already confirmed (friends who are coming).
 List<LineupPlayer> get lineup;/// Confirmed friends who aren't on SoloMatch.
 int get guestCount;/// A venue slot booked through the app (see [DraftBooking]).
 DraftBooking? get booking; DateTime? get updatedAt;
/// Create a copy of MatchDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchDraftCopyWith<MatchDraft> get copyWith => _$MatchDraftCopyWithImpl<MatchDraft>(this as MatchDraft, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MatchDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchDraft&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizerId, _this.organizerId) || other.organizerId == _this.organizerId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.venue, _this.venue) || other.venue == _this.venue)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.startMinutes, _this.startMinutes) || other.startMinutes == _this.startMinutes)&&(identical(other.endMinutes, _this.endMinutes) || other.endMinutes == _this.endMinutes)&&(identical(other.format, _this.format) || other.format == _this.format)&&(identical(other.maxPlayers, _this.maxPlayers) || other.maxPlayers == _this.maxPlayers)&&const DeepCollectionEquality().equals(other.neededPositions, _this.neededPositions)&&(identical(other.skillLevel, _this.skillLevel) || other.skillLevel == _this.skillLevel)&&(identical(other.priceAmount, _this.priceAmount) || other.priceAmount == _this.priceAmount)&&(identical(other.isIndoor, _this.isIndoor) || other.isIndoor == _this.isIndoor)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.rules, _this.rules) || other.rules == _this.rules)&&const DeepCollectionEquality().equals(other.photos, _this.photos)&&(identical(other.organizerPlaying, _this.organizerPlaying) || other.organizerPlaying == _this.organizerPlaying)&&(identical(other.organizerGroup, _this.organizerGroup) || other.organizerGroup == _this.organizerGroup)&&const DeepCollectionEquality().equals(other.lineup, _this.lineup)&&(identical(other.guestCount, _this.guestCount) || other.guestCount == _this.guestCount)&&(identical(other.booking, _this.booking) || other.booking == _this.booking)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}


@override
int get hashCode {
  final _this = this as MatchDraft;
  return Object.hashAll([runtimeType,_this.id,_this.organizerId,_this.title,_this.venue,_this.date,_this.startMinutes,_this.endMinutes,_this.format,_this.maxPlayers,const DeepCollectionEquality().hash(_this.neededPositions),_this.skillLevel,_this.priceAmount,_this.isIndoor,_this.description,_this.rules,const DeepCollectionEquality().hash(_this.photos),_this.organizerPlaying,_this.organizerGroup,const DeepCollectionEquality().hash(_this.lineup),_this.guestCount,_this.booking,_this.updatedAt]);
}

@override
String toString() {
  final _this = this as MatchDraft;
  return 'MatchDraft(id: ${_this.id}, organizerId: ${_this.organizerId}, title: ${_this.title}, venue: ${_this.venue}, date: ${_this.date}, startMinutes: ${_this.startMinutes}, endMinutes: ${_this.endMinutes}, format: ${_this.format}, maxPlayers: ${_this.maxPlayers}, neededPositions: ${_this.neededPositions}, skillLevel: ${_this.skillLevel}, priceAmount: ${_this.priceAmount}, isIndoor: ${_this.isIndoor}, description: ${_this.description}, rules: ${_this.rules}, photos: ${_this.photos}, organizerPlaying: ${_this.organizerPlaying}, organizerGroup: ${_this.organizerGroup}, lineup: ${_this.lineup}, guestCount: ${_this.guestCount}, booking: ${_this.booking}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $MatchDraftCopyWith<$Res>  {
  factory $MatchDraftCopyWith(MatchDraft value, $Res Function(MatchDraft) _then) = _$MatchDraftCopyWithImpl;
@useResult
$Res call({
 String id, String organizerId, String title, Venue? venue, DateTime? date, int? startMinutes, int? endMinutes, MatchFormat format, int maxPlayers, Map<PositionGroup, int> neededPositions, SkillLevel skillLevel, int priceAmount, bool isIndoor, String description, String rules, List<String> photos, bool organizerPlaying, PositionGroup? organizerGroup, List<LineupPlayer> lineup, int guestCount, DraftBooking? booking, DateTime? updatedAt
});


$VenueCopyWith<$Res>? get venue;

}
/// @nodoc
class _$MatchDraftCopyWithImpl<$Res>
    implements $MatchDraftCopyWith<$Res> {
  _$MatchDraftCopyWithImpl(this._self, this._then);

  final MatchDraft _self;
  final $Res Function(MatchDraft) _then;

/// Create a copy of MatchDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizerId = null,Object? title = null,Object? venue = freezed,Object? date = freezed,Object? startMinutes = freezed,Object? endMinutes = freezed,Object? format = null,Object? maxPlayers = null,Object? neededPositions = null,Object? skillLevel = null,Object? priceAmount = null,Object? isIndoor = null,Object? description = null,Object? rules = null,Object? photos = null,Object? organizerPlaying = null,Object? organizerGroup = freezed,Object? lineup = null,Object? guestCount = null,Object? booking = freezed,Object? updatedAt = freezed,}) {
  return _then(MatchDraft(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizerId: null == organizerId ? _self.organizerId : organizerId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,venue: freezed == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as Venue?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,startMinutes: freezed == startMinutes ? _self.startMinutes : startMinutes // ignore: cast_nullable_to_non_nullable
as int?,endMinutes: freezed == endMinutes ? _self.endMinutes : endMinutes // ignore: cast_nullable_to_non_nullable
as int?,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as MatchFormat,maxPlayers: null == maxPlayers ? _self.maxPlayers : maxPlayers // ignore: cast_nullable_to_non_nullable
as int,neededPositions: null == neededPositions ? _self.neededPositions : neededPositions // ignore: cast_nullable_to_non_nullable
as Map<PositionGroup, int>,skillLevel: null == skillLevel ? _self.skillLevel : skillLevel // ignore: cast_nullable_to_non_nullable
as SkillLevel,priceAmount: null == priceAmount ? _self.priceAmount : priceAmount // ignore: cast_nullable_to_non_nullable
as int,isIndoor: null == isIndoor ? _self.isIndoor : isIndoor // ignore: cast_nullable_to_non_nullable
as bool,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as String,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<String>,organizerPlaying: null == organizerPlaying ? _self.organizerPlaying : organizerPlaying // ignore: cast_nullable_to_non_nullable
as bool,organizerGroup: freezed == organizerGroup ? _self.organizerGroup : organizerGroup // ignore: cast_nullable_to_non_nullable
as PositionGroup?,lineup: null == lineup ? _self.lineup : lineup // ignore: cast_nullable_to_non_nullable
as List<LineupPlayer>,guestCount: null == guestCount ? _self.guestCount : guestCount // ignore: cast_nullable_to_non_nullable
as int,booking: freezed == booking ? _self.booking : booking // ignore: cast_nullable_to_non_nullable
as DraftBooking?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of MatchDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VenueCopyWith<$Res>? get venue {
    if (_self.venue == null) {
    return null;
  }

  return $VenueCopyWith<$Res>(_self.venue!, (value) {
    return _then(_self.copyWith(venue: value));
  });
}
}


/// Adds pattern-matching-related methods to [MatchDraft].
extension MatchDraftPatterns on MatchDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchDraft value)  $default,){
final _that = this;
switch (_that) {
case _MatchDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchDraft value)?  $default,){
final _that = this;
switch (_that) {
case _MatchDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizerId,  String title,  Venue? venue,  DateTime? date,  int? startMinutes,  int? endMinutes,  MatchFormat format,  int maxPlayers,  Map<PositionGroup, int> neededPositions,  SkillLevel skillLevel,  int priceAmount,  bool isIndoor,  String description,  String rules,  List<String> photos,  bool organizerPlaying,  PositionGroup? organizerGroup,  List<LineupPlayer> lineup,  int guestCount,  DraftBooking? booking,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchDraft() when $default != null:
return $default(_that.id,_that.organizerId,_that.title,_that.venue,_that.date,_that.startMinutes,_that.endMinutes,_that.format,_that.maxPlayers,_that.neededPositions,_that.skillLevel,_that.priceAmount,_that.isIndoor,_that.description,_that.rules,_that.photos,_that.organizerPlaying,_that.organizerGroup,_that.lineup,_that.guestCount,_that.booking,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizerId,  String title,  Venue? venue,  DateTime? date,  int? startMinutes,  int? endMinutes,  MatchFormat format,  int maxPlayers,  Map<PositionGroup, int> neededPositions,  SkillLevel skillLevel,  int priceAmount,  bool isIndoor,  String description,  String rules,  List<String> photos,  bool organizerPlaying,  PositionGroup? organizerGroup,  List<LineupPlayer> lineup,  int guestCount,  DraftBooking? booking,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MatchDraft():
return $default(_that.id,_that.organizerId,_that.title,_that.venue,_that.date,_that.startMinutes,_that.endMinutes,_that.format,_that.maxPlayers,_that.neededPositions,_that.skillLevel,_that.priceAmount,_that.isIndoor,_that.description,_that.rules,_that.photos,_that.organizerPlaying,_that.organizerGroup,_that.lineup,_that.guestCount,_that.booking,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizerId,  String title,  Venue? venue,  DateTime? date,  int? startMinutes,  int? endMinutes,  MatchFormat format,  int maxPlayers,  Map<PositionGroup, int> neededPositions,  SkillLevel skillLevel,  int priceAmount,  bool isIndoor,  String description,  String rules,  List<String> photos,  bool organizerPlaying,  PositionGroup? organizerGroup,  List<LineupPlayer> lineup,  int guestCount,  DraftBooking? booking,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MatchDraft() when $default != null:
return $default(_that.id,_that.organizerId,_that.title,_that.venue,_that.date,_that.startMinutes,_that.endMinutes,_that.format,_that.maxPlayers,_that.neededPositions,_that.skillLevel,_that.priceAmount,_that.isIndoor,_that.description,_that.rules,_that.photos,_that.organizerPlaying,_that.organizerGroup,_that.lineup,_that.guestCount,_that.booking,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _MatchDraft extends MatchDraft {
  const _MatchDraft({required this.id, required this.organizerId, this.title = '', this.venue, this.date, this.startMinutes, this.endMinutes, this.format = MatchFormat.fiveASide, this.maxPlayers = 10,  Map<PositionGroup, int> neededPositions = const <PositionGroup, int>{}, this.skillLevel = SkillLevel.any, this.priceAmount = 0, this.isIndoor = false, this.description = '', this.rules = '',  List<String> photos = const <String>[], this.organizerPlaying = false, this.organizerGroup,  List<LineupPlayer> lineup = const <LineupPlayer>[], this.guestCount = 0, this.booking, this.updatedAt}): _neededPositions = neededPositions,_photos = photos,_lineup = lineup,super._();
  

@override final  String id;
@override final  String organizerId;
@override@JsonKey() final  String title;
@override final  Venue? venue;
/// Calendar day of the match (time part ignored).
@override final  DateTime? date;
/// Minutes after midnight, e.g. 18:00 → 1080.
@override final  int? startMinutes;
@override final  int? endMinutes;
@override@JsonKey() final  MatchFormat format;
@override@JsonKey() final  int maxPlayers;
 final  Map<PositionGroup, int> _neededPositions;
@override@JsonKey() Map<PositionGroup, int> get neededPositions {
  if (_neededPositions is EqualUnmodifiableMapView) return _neededPositions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_neededPositions);
}

@override@JsonKey() final  SkillLevel skillLevel;
/// Per-player fee in NPR; 0 = free.
@override@JsonKey() final  int priceAmount;
@override@JsonKey() final  bool isIndoor;
@override@JsonKey() final  String description;
@override@JsonKey() final  String rules;
 final  List<String> _photos;
@override@JsonKey() List<String> get photos {
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photos);
}

/// The organizer takes a roster spot too.
@override@JsonKey() final  bool organizerPlaying;
@override final  PositionGroup? organizerGroup;
/// SoloMatch users already confirmed (friends who are coming).
 final  List<LineupPlayer> _lineup;
/// SoloMatch users already confirmed (friends who are coming).
@override@JsonKey() List<LineupPlayer> get lineup {
  if (_lineup is EqualUnmodifiableListView) return _lineup;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lineup);
}

/// Confirmed friends who aren't on SoloMatch.
@override@JsonKey() final  int guestCount;
/// A venue slot booked through the app (see [DraftBooking]).
@override final  DraftBooking? booking;
@override final  DateTime? updatedAt;

/// Create a copy of MatchDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchDraftCopyWith<_MatchDraft> get copyWith => __$MatchDraftCopyWithImpl<_MatchDraft>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchDraft&&(identical(other.id, id) || other.id == id)&&(identical(other.organizerId, organizerId) || other.organizerId == organizerId)&&(identical(other.title, title) || other.title == title)&&(identical(other.venue, venue) || other.venue == venue)&&(identical(other.date, date) || other.date == date)&&(identical(other.startMinutes, startMinutes) || other.startMinutes == startMinutes)&&(identical(other.endMinutes, endMinutes) || other.endMinutes == endMinutes)&&(identical(other.format, format) || other.format == format)&&(identical(other.maxPlayers, maxPlayers) || other.maxPlayers == maxPlayers)&&const DeepCollectionEquality().equals(other.neededPositions, _neededPositions)&&(identical(other.skillLevel, skillLevel) || other.skillLevel == skillLevel)&&(identical(other.priceAmount, priceAmount) || other.priceAmount == priceAmount)&&(identical(other.isIndoor, isIndoor) || other.isIndoor == isIndoor)&&(identical(other.description, description) || other.description == description)&&(identical(other.rules, rules) || other.rules == rules)&&const DeepCollectionEquality().equals(other.photos, _photos)&&(identical(other.organizerPlaying, organizerPlaying) || other.organizerPlaying == organizerPlaying)&&(identical(other.organizerGroup, organizerGroup) || other.organizerGroup == organizerGroup)&&const DeepCollectionEquality().equals(other.lineup, _lineup)&&(identical(other.guestCount, guestCount) || other.guestCount == guestCount)&&(identical(other.booking, booking) || other.booking == booking)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,id,organizerId,title,venue,date,startMinutes,endMinutes,format,maxPlayers,const DeepCollectionEquality().hash(_neededPositions),skillLevel,priceAmount,isIndoor,description,rules,const DeepCollectionEquality().hash(_photos),organizerPlaying,organizerGroup,const DeepCollectionEquality().hash(_lineup),guestCount,booking,updatedAt]);
}

@override
String toString() {
    return 'MatchDraft(id: $id, organizerId: $organizerId, title: $title, venue: $venue, date: $date, startMinutes: $startMinutes, endMinutes: $endMinutes, format: $format, maxPlayers: $maxPlayers, neededPositions: $neededPositions, skillLevel: $skillLevel, priceAmount: $priceAmount, isIndoor: $isIndoor, description: $description, rules: $rules, photos: $photos, organizerPlaying: $organizerPlaying, organizerGroup: $organizerGroup, lineup: $lineup, guestCount: $guestCount, booking: $booking, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MatchDraftCopyWith<$Res> implements $MatchDraftCopyWith<$Res> {
  factory _$MatchDraftCopyWith(_MatchDraft value, $Res Function(_MatchDraft) _then) = __$MatchDraftCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizerId, String title, Venue? venue, DateTime? date, int? startMinutes, int? endMinutes, MatchFormat format, int maxPlayers, Map<PositionGroup, int> neededPositions, SkillLevel skillLevel, int priceAmount, bool isIndoor, String description, String rules, List<String> photos, bool organizerPlaying, PositionGroup? organizerGroup, List<LineupPlayer> lineup, int guestCount, DraftBooking? booking, DateTime? updatedAt
});


@override $VenueCopyWith<$Res>? get venue;

}
/// @nodoc
class __$MatchDraftCopyWithImpl<$Res>
    implements _$MatchDraftCopyWith<$Res> {
  __$MatchDraftCopyWithImpl(this._self, this._then);

  final _MatchDraft _self;
  final $Res Function(_MatchDraft) _then;

/// Create a copy of MatchDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizerId = null,Object? title = null,Object? venue = freezed,Object? date = freezed,Object? startMinutes = freezed,Object? endMinutes = freezed,Object? format = null,Object? maxPlayers = null,Object? neededPositions = null,Object? skillLevel = null,Object? priceAmount = null,Object? isIndoor = null,Object? description = null,Object? rules = null,Object? photos = null,Object? organizerPlaying = null,Object? organizerGroup = freezed,Object? lineup = null,Object? guestCount = null,Object? booking = freezed,Object? updatedAt = freezed,}) {
  return _then(_MatchDraft(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizerId: null == organizerId ? _self.organizerId : organizerId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,venue: freezed == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as Venue?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,startMinutes: freezed == startMinutes ? _self.startMinutes : startMinutes // ignore: cast_nullable_to_non_nullable
as int?,endMinutes: freezed == endMinutes ? _self.endMinutes : endMinutes // ignore: cast_nullable_to_non_nullable
as int?,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as MatchFormat,maxPlayers: null == maxPlayers ? _self.maxPlayers : maxPlayers // ignore: cast_nullable_to_non_nullable
as int,neededPositions: null == neededPositions ? _self._neededPositions : neededPositions // ignore: cast_nullable_to_non_nullable
as Map<PositionGroup, int>,skillLevel: null == skillLevel ? _self.skillLevel : skillLevel // ignore: cast_nullable_to_non_nullable
as SkillLevel,priceAmount: null == priceAmount ? _self.priceAmount : priceAmount // ignore: cast_nullable_to_non_nullable
as int,isIndoor: null == isIndoor ? _self.isIndoor : isIndoor // ignore: cast_nullable_to_non_nullable
as bool,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as String,photos: null == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<String>,organizerPlaying: null == organizerPlaying ? _self.organizerPlaying : organizerPlaying // ignore: cast_nullable_to_non_nullable
as bool,organizerGroup: freezed == organizerGroup ? _self.organizerGroup : organizerGroup // ignore: cast_nullable_to_non_nullable
as PositionGroup?,lineup: null == lineup ? _self._lineup : lineup // ignore: cast_nullable_to_non_nullable
as List<LineupPlayer>,guestCount: null == guestCount ? _self.guestCount : guestCount // ignore: cast_nullable_to_non_nullable
as int,booking: freezed == booking ? _self.booking : booking // ignore: cast_nullable_to_non_nullable
as DraftBooking?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of MatchDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VenueCopyWith<$Res>? get venue {
    if (_self.venue == null) {
    return null;
  }

  return $VenueCopyWith<$Res>(_self.venue!, (value) {
    return _then(_self.copyWith(venue: value));
  });
}
}

// dart format on
