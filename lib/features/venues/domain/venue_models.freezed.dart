// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'venue_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OwnerProfile {

 String get uid; String get name; String get phone;
/// Create a copy of OwnerProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OwnerProfileCopyWith<OwnerProfile> get copyWith => _$OwnerProfileCopyWithImpl<OwnerProfile>(this as OwnerProfile, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OwnerProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OwnerProfile&&(identical(other.uid, _this.uid) || other.uid == _this.uid)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.phone, _this.phone) || other.phone == _this.phone));
}


@override
int get hashCode {
  final _this = this as OwnerProfile;
  return Object.hash(runtimeType,_this.uid,_this.name,_this.phone);
}

@override
String toString() {
  final _this = this as OwnerProfile;
  return 'OwnerProfile(uid: ${_this.uid}, name: ${_this.name}, phone: ${_this.phone})';
}


}

/// @nodoc
abstract mixin class $OwnerProfileCopyWith<$Res>  {
  factory $OwnerProfileCopyWith(OwnerProfile value, $Res Function(OwnerProfile) _then) = _$OwnerProfileCopyWithImpl;
@useResult
$Res call({
 String uid, String name, String phone
});




}
/// @nodoc
class _$OwnerProfileCopyWithImpl<$Res>
    implements $OwnerProfileCopyWith<$Res> {
  _$OwnerProfileCopyWithImpl(this._self, this._then);

  final OwnerProfile _self;
  final $Res Function(OwnerProfile) _then;

/// Create a copy of OwnerProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? name = null,Object? phone = null,}) {
  return _then(OwnerProfile(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OwnerProfile].
extension OwnerProfilePatterns on OwnerProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OwnerProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OwnerProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OwnerProfile value)  $default,){
final _that = this;
switch (_that) {
case _OwnerProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OwnerProfile value)?  $default,){
final _that = this;
switch (_that) {
case _OwnerProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String name,  String phone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OwnerProfile() when $default != null:
return $default(_that.uid,_that.name,_that.phone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String name,  String phone)  $default,) {final _that = this;
switch (_that) {
case _OwnerProfile():
return $default(_that.uid,_that.name,_that.phone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String name,  String phone)?  $default,) {final _that = this;
switch (_that) {
case _OwnerProfile() when $default != null:
return $default(_that.uid,_that.name,_that.phone);case _:
  return null;

}
}

}

/// @nodoc


class _OwnerProfile implements OwnerProfile {
  const _OwnerProfile({required this.uid, required this.name, required this.phone});
  

@override final  String uid;
@override final  String name;
@override final  String phone;

/// Create a copy of OwnerProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OwnerProfileCopyWith<_OwnerProfile> get copyWith => __$OwnerProfileCopyWithImpl<_OwnerProfile>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OwnerProfile&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone));
}


@override
int get hashCode {
    return Object.hash(runtimeType,uid,name,phone);
}

@override
String toString() {
    return 'OwnerProfile(uid: $uid, name: $name, phone: $phone)';
}


}

/// @nodoc
abstract mixin class _$OwnerProfileCopyWith<$Res> implements $OwnerProfileCopyWith<$Res> {
  factory _$OwnerProfileCopyWith(_OwnerProfile value, $Res Function(_OwnerProfile) _then) = __$OwnerProfileCopyWithImpl;
@override @useResult
$Res call({
 String uid, String name, String phone
});




}
/// @nodoc
class __$OwnerProfileCopyWithImpl<$Res>
    implements _$OwnerProfileCopyWith<$Res> {
  __$OwnerProfileCopyWithImpl(this._self, this._then);

  final _OwnerProfile _self;
  final $Res Function(_OwnerProfile) _then;

/// Create a copy of OwnerProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? name = null,Object? phone = null,}) {
  return _then(_OwnerProfile(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$VenueProfile {

/// Same as the owner's uid: one venue per owner account.
 String get id; String get name; String get address; String get city; String get phone; String get description; bool get isIndoor; Set<MatchFormat> get formats;/// Usual price for the pitch per hour, NPR. Each slot has its own price.
 int get pricePerHour; Set<Amenity> get amenities; List<String> get photos; VenueRatingSummary? get rating;
/// Create a copy of VenueProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VenueProfileCopyWith<VenueProfile> get copyWith => _$VenueProfileCopyWithImpl<VenueProfile>(this as VenueProfile, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VenueProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VenueProfile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.isIndoor, _this.isIndoor) || other.isIndoor == _this.isIndoor)&&const DeepCollectionEquality().equals(other.formats, _this.formats)&&(identical(other.pricePerHour, _this.pricePerHour) || other.pricePerHour == _this.pricePerHour)&&const DeepCollectionEquality().equals(other.amenities, _this.amenities)&&const DeepCollectionEquality().equals(other.photos, _this.photos)&&(identical(other.rating, _this.rating) || other.rating == _this.rating));
}


@override
int get hashCode {
  final _this = this as VenueProfile;
  return Object.hash(runtimeType,_this.id,_this.name,_this.address,_this.city,_this.phone,_this.description,_this.isIndoor,const DeepCollectionEquality().hash(_this.formats),_this.pricePerHour,const DeepCollectionEquality().hash(_this.amenities),const DeepCollectionEquality().hash(_this.photos),_this.rating);
}

@override
String toString() {
  final _this = this as VenueProfile;
  return 'VenueProfile(id: ${_this.id}, name: ${_this.name}, address: ${_this.address}, city: ${_this.city}, phone: ${_this.phone}, description: ${_this.description}, isIndoor: ${_this.isIndoor}, formats: ${_this.formats}, pricePerHour: ${_this.pricePerHour}, amenities: ${_this.amenities}, photos: ${_this.photos}, rating: ${_this.rating})';
}


}

/// @nodoc
abstract mixin class $VenueProfileCopyWith<$Res>  {
  factory $VenueProfileCopyWith(VenueProfile value, $Res Function(VenueProfile) _then) = _$VenueProfileCopyWithImpl;
@useResult
$Res call({
 String id, String name, String address, String city, String phone, String description, bool isIndoor, Set<MatchFormat> formats, int pricePerHour, Set<Amenity> amenities, List<String> photos, VenueRatingSummary? rating
});




}
/// @nodoc
class _$VenueProfileCopyWithImpl<$Res>
    implements $VenueProfileCopyWith<$Res> {
  _$VenueProfileCopyWithImpl(this._self, this._then);

  final VenueProfile _self;
  final $Res Function(VenueProfile) _then;

/// Create a copy of VenueProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? address = null,Object? city = null,Object? phone = null,Object? description = null,Object? isIndoor = null,Object? formats = null,Object? pricePerHour = null,Object? amenities = null,Object? photos = null,Object? rating = freezed,}) {
  return _then(VenueProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isIndoor: null == isIndoor ? _self.isIndoor : isIndoor // ignore: cast_nullable_to_non_nullable
as bool,formats: null == formats ? _self.formats : formats // ignore: cast_nullable_to_non_nullable
as Set<MatchFormat>,pricePerHour: null == pricePerHour ? _self.pricePerHour : pricePerHour // ignore: cast_nullable_to_non_nullable
as int,amenities: null == amenities ? _self.amenities : amenities // ignore: cast_nullable_to_non_nullable
as Set<Amenity>,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<String>,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as VenueRatingSummary?,
  ));
}

}


/// Adds pattern-matching-related methods to [VenueProfile].
extension VenueProfilePatterns on VenueProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VenueProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VenueProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VenueProfile value)  $default,){
final _that = this;
switch (_that) {
case _VenueProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VenueProfile value)?  $default,){
final _that = this;
switch (_that) {
case _VenueProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String address,  String city,  String phone,  String description,  bool isIndoor,  Set<MatchFormat> formats,  int pricePerHour,  Set<Amenity> amenities,  List<String> photos,  VenueRatingSummary? rating)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VenueProfile() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.city,_that.phone,_that.description,_that.isIndoor,_that.formats,_that.pricePerHour,_that.amenities,_that.photos,_that.rating);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String address,  String city,  String phone,  String description,  bool isIndoor,  Set<MatchFormat> formats,  int pricePerHour,  Set<Amenity> amenities,  List<String> photos,  VenueRatingSummary? rating)  $default,) {final _that = this;
switch (_that) {
case _VenueProfile():
return $default(_that.id,_that.name,_that.address,_that.city,_that.phone,_that.description,_that.isIndoor,_that.formats,_that.pricePerHour,_that.amenities,_that.photos,_that.rating);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String address,  String city,  String phone,  String description,  bool isIndoor,  Set<MatchFormat> formats,  int pricePerHour,  Set<Amenity> amenities,  List<String> photos,  VenueRatingSummary? rating)?  $default,) {final _that = this;
switch (_that) {
case _VenueProfile() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.city,_that.phone,_that.description,_that.isIndoor,_that.formats,_that.pricePerHour,_that.amenities,_that.photos,_that.rating);case _:
  return null;

}
}

}

/// @nodoc


class _VenueProfile extends VenueProfile {
  const _VenueProfile({required this.id, required this.name, this.address = '', required this.city, required this.phone, this.description = '', this.isIndoor = true,  Set<MatchFormat> formats = const <MatchFormat>{MatchFormat.fiveASide}, this.pricePerHour = 0,  Set<Amenity> amenities = const <Amenity>{},  List<String> photos = const <String>[], this.rating}): _formats = formats,_amenities = amenities,_photos = photos,super._();
  

/// Same as the owner's uid: one venue per owner account.
@override final  String id;
@override final  String name;
@override@JsonKey() final  String address;
@override final  String city;
@override final  String phone;
@override@JsonKey() final  String description;
@override@JsonKey() final  bool isIndoor;
 final  Set<MatchFormat> _formats;
@override@JsonKey() Set<MatchFormat> get formats {
  if (_formats is EqualUnmodifiableSetView) return _formats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_formats);
}

/// Usual price for the pitch per hour, NPR. Each slot has its own price.
@override@JsonKey() final  int pricePerHour;
 final  Set<Amenity> _amenities;
@override@JsonKey() Set<Amenity> get amenities {
  if (_amenities is EqualUnmodifiableSetView) return _amenities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_amenities);
}

 final  List<String> _photos;
@override@JsonKey() List<String> get photos {
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photos);
}

@override final  VenueRatingSummary? rating;

/// Create a copy of VenueProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VenueProfileCopyWith<_VenueProfile> get copyWith => __$VenueProfileCopyWithImpl<_VenueProfile>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VenueProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.description, description) || other.description == description)&&(identical(other.isIndoor, isIndoor) || other.isIndoor == isIndoor)&&const DeepCollectionEquality().equals(other.formats, _formats)&&(identical(other.pricePerHour, pricePerHour) || other.pricePerHour == pricePerHour)&&const DeepCollectionEquality().equals(other.amenities, _amenities)&&const DeepCollectionEquality().equals(other.photos, _photos)&&(identical(other.rating, rating) || other.rating == rating));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,address,city,phone,description,isIndoor,const DeepCollectionEquality().hash(_formats),pricePerHour,const DeepCollectionEquality().hash(_amenities),const DeepCollectionEquality().hash(_photos),rating);
}

@override
String toString() {
    return 'VenueProfile(id: $id, name: $name, address: $address, city: $city, phone: $phone, description: $description, isIndoor: $isIndoor, formats: $formats, pricePerHour: $pricePerHour, amenities: $amenities, photos: $photos, rating: $rating)';
}


}

/// @nodoc
abstract mixin class _$VenueProfileCopyWith<$Res> implements $VenueProfileCopyWith<$Res> {
  factory _$VenueProfileCopyWith(_VenueProfile value, $Res Function(_VenueProfile) _then) = __$VenueProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String address, String city, String phone, String description, bool isIndoor, Set<MatchFormat> formats, int pricePerHour, Set<Amenity> amenities, List<String> photos, VenueRatingSummary? rating
});




}
/// @nodoc
class __$VenueProfileCopyWithImpl<$Res>
    implements _$VenueProfileCopyWith<$Res> {
  __$VenueProfileCopyWithImpl(this._self, this._then);

  final _VenueProfile _self;
  final $Res Function(_VenueProfile) _then;

/// Create a copy of VenueProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? address = null,Object? city = null,Object? phone = null,Object? description = null,Object? isIndoor = null,Object? formats = null,Object? pricePerHour = null,Object? amenities = null,Object? photos = null,Object? rating = freezed,}) {
  return _then(_VenueProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isIndoor: null == isIndoor ? _self.isIndoor : isIndoor // ignore: cast_nullable_to_non_nullable
as bool,formats: null == formats ? _self._formats : formats // ignore: cast_nullable_to_non_nullable
as Set<MatchFormat>,pricePerHour: null == pricePerHour ? _self.pricePerHour : pricePerHour // ignore: cast_nullable_to_non_nullable
as int,amenities: null == amenities ? _self._amenities : amenities // ignore: cast_nullable_to_non_nullable
as Set<Amenity>,photos: null == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<String>,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as VenueRatingSummary?,
  ));
}


}

/// @nodoc
mixin _$VenueSlot {

 String get id; String get venueId; DateTime get startAt; DateTime get endAt;/// Price for the whole pitch for this slot, NPR.
 int get price; SlotStatus get status; SlotBooking? get booking;
/// Create a copy of VenueSlot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VenueSlotCopyWith<VenueSlot> get copyWith => _$VenueSlotCopyWithImpl<VenueSlot>(this as VenueSlot, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VenueSlot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VenueSlot&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.venueId, _this.venueId) || other.venueId == _this.venueId)&&(identical(other.startAt, _this.startAt) || other.startAt == _this.startAt)&&(identical(other.endAt, _this.endAt) || other.endAt == _this.endAt)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.booking, _this.booking) || other.booking == _this.booking));
}


@override
int get hashCode {
  final _this = this as VenueSlot;
  return Object.hash(runtimeType,_this.id,_this.venueId,_this.startAt,_this.endAt,_this.price,_this.status,_this.booking);
}

@override
String toString() {
  final _this = this as VenueSlot;
  return 'VenueSlot(id: ${_this.id}, venueId: ${_this.venueId}, startAt: ${_this.startAt}, endAt: ${_this.endAt}, price: ${_this.price}, status: ${_this.status}, booking: ${_this.booking})';
}


}

/// @nodoc
abstract mixin class $VenueSlotCopyWith<$Res>  {
  factory $VenueSlotCopyWith(VenueSlot value, $Res Function(VenueSlot) _then) = _$VenueSlotCopyWithImpl;
@useResult
$Res call({
 String id, String venueId, DateTime startAt, DateTime endAt, int price, SlotStatus status, SlotBooking? booking
});




}
/// @nodoc
class _$VenueSlotCopyWithImpl<$Res>
    implements $VenueSlotCopyWith<$Res> {
  _$VenueSlotCopyWithImpl(this._self, this._then);

  final VenueSlot _self;
  final $Res Function(VenueSlot) _then;

/// Create a copy of VenueSlot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? venueId = null,Object? startAt = null,Object? endAt = null,Object? price = null,Object? status = null,Object? booking = freezed,}) {
  return _then(VenueSlot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SlotStatus,booking: freezed == booking ? _self.booking : booking // ignore: cast_nullable_to_non_nullable
as SlotBooking?,
  ));
}

}


/// Adds pattern-matching-related methods to [VenueSlot].
extension VenueSlotPatterns on VenueSlot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VenueSlot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VenueSlot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VenueSlot value)  $default,){
final _that = this;
switch (_that) {
case _VenueSlot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VenueSlot value)?  $default,){
final _that = this;
switch (_that) {
case _VenueSlot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String venueId,  DateTime startAt,  DateTime endAt,  int price,  SlotStatus status,  SlotBooking? booking)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VenueSlot() when $default != null:
return $default(_that.id,_that.venueId,_that.startAt,_that.endAt,_that.price,_that.status,_that.booking);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String venueId,  DateTime startAt,  DateTime endAt,  int price,  SlotStatus status,  SlotBooking? booking)  $default,) {final _that = this;
switch (_that) {
case _VenueSlot():
return $default(_that.id,_that.venueId,_that.startAt,_that.endAt,_that.price,_that.status,_that.booking);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String venueId,  DateTime startAt,  DateTime endAt,  int price,  SlotStatus status,  SlotBooking? booking)?  $default,) {final _that = this;
switch (_that) {
case _VenueSlot() when $default != null:
return $default(_that.id,_that.venueId,_that.startAt,_that.endAt,_that.price,_that.status,_that.booking);case _:
  return null;

}
}

}

/// @nodoc


class _VenueSlot extends VenueSlot {
  const _VenueSlot({required this.id, required this.venueId, required this.startAt, required this.endAt, required this.price, required this.status, this.booking}): super._();
  

@override final  String id;
@override final  String venueId;
@override final  DateTime startAt;
@override final  DateTime endAt;
/// Price for the whole pitch for this slot, NPR.
@override final  int price;
@override final  SlotStatus status;
@override final  SlotBooking? booking;

/// Create a copy of VenueSlot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VenueSlotCopyWith<_VenueSlot> get copyWith => __$VenueSlotCopyWithImpl<_VenueSlot>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VenueSlot&&(identical(other.id, id) || other.id == id)&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.price, price) || other.price == price)&&(identical(other.status, status) || other.status == status)&&(identical(other.booking, booking) || other.booking == booking));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,venueId,startAt,endAt,price,status,booking);
}

@override
String toString() {
    return 'VenueSlot(id: $id, venueId: $venueId, startAt: $startAt, endAt: $endAt, price: $price, status: $status, booking: $booking)';
}


}

/// @nodoc
abstract mixin class _$VenueSlotCopyWith<$Res> implements $VenueSlotCopyWith<$Res> {
  factory _$VenueSlotCopyWith(_VenueSlot value, $Res Function(_VenueSlot) _then) = __$VenueSlotCopyWithImpl;
@override @useResult
$Res call({
 String id, String venueId, DateTime startAt, DateTime endAt, int price, SlotStatus status, SlotBooking? booking
});




}
/// @nodoc
class __$VenueSlotCopyWithImpl<$Res>
    implements _$VenueSlotCopyWith<$Res> {
  __$VenueSlotCopyWithImpl(this._self, this._then);

  final _VenueSlot _self;
  final $Res Function(_VenueSlot) _then;

/// Create a copy of VenueSlot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? venueId = null,Object? startAt = null,Object? endAt = null,Object? price = null,Object? status = null,Object? booking = freezed,}) {
  return _then(_VenueSlot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SlotStatus,booking: freezed == booking ? _self.booking : booking // ignore: cast_nullable_to_non_nullable
as SlotBooking?,
  ));
}


}

/// @nodoc
mixin _$VenueRating {

 String get venueId; String get matchId; String get matchTitle; String get reviewerId; String get reviewerName; String? get reviewerPhotoUrl; int get overall; int get pitch; int get facilities; int get value; String get comment; DateTime? get createdAt;
/// Create a copy of VenueRating
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VenueRatingCopyWith<VenueRating> get copyWith => _$VenueRatingCopyWithImpl<VenueRating>(this as VenueRating, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VenueRating;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VenueRating&&(identical(other.venueId, _this.venueId) || other.venueId == _this.venueId)&&(identical(other.matchId, _this.matchId) || other.matchId == _this.matchId)&&(identical(other.matchTitle, _this.matchTitle) || other.matchTitle == _this.matchTitle)&&(identical(other.reviewerId, _this.reviewerId) || other.reviewerId == _this.reviewerId)&&(identical(other.reviewerName, _this.reviewerName) || other.reviewerName == _this.reviewerName)&&(identical(other.reviewerPhotoUrl, _this.reviewerPhotoUrl) || other.reviewerPhotoUrl == _this.reviewerPhotoUrl)&&(identical(other.overall, _this.overall) || other.overall == _this.overall)&&(identical(other.pitch, _this.pitch) || other.pitch == _this.pitch)&&(identical(other.facilities, _this.facilities) || other.facilities == _this.facilities)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as VenueRating;
  return Object.hash(runtimeType,_this.venueId,_this.matchId,_this.matchTitle,_this.reviewerId,_this.reviewerName,_this.reviewerPhotoUrl,_this.overall,_this.pitch,_this.facilities,_this.value,_this.comment,_this.createdAt);
}

@override
String toString() {
  final _this = this as VenueRating;
  return 'VenueRating(venueId: ${_this.venueId}, matchId: ${_this.matchId}, matchTitle: ${_this.matchTitle}, reviewerId: ${_this.reviewerId}, reviewerName: ${_this.reviewerName}, reviewerPhotoUrl: ${_this.reviewerPhotoUrl}, overall: ${_this.overall}, pitch: ${_this.pitch}, facilities: ${_this.facilities}, value: ${_this.value}, comment: ${_this.comment}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $VenueRatingCopyWith<$Res>  {
  factory $VenueRatingCopyWith(VenueRating value, $Res Function(VenueRating) _then) = _$VenueRatingCopyWithImpl;
@useResult
$Res call({
 String venueId, String matchId, String matchTitle, String reviewerId, String reviewerName, String? reviewerPhotoUrl, int overall, int pitch, int facilities, int value, String comment, DateTime? createdAt
});




}
/// @nodoc
class _$VenueRatingCopyWithImpl<$Res>
    implements $VenueRatingCopyWith<$Res> {
  _$VenueRatingCopyWithImpl(this._self, this._then);

  final VenueRating _self;
  final $Res Function(VenueRating) _then;

/// Create a copy of VenueRating
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? venueId = null,Object? matchId = null,Object? matchTitle = null,Object? reviewerId = null,Object? reviewerName = null,Object? reviewerPhotoUrl = freezed,Object? overall = null,Object? pitch = null,Object? facilities = null,Object? value = null,Object? comment = null,Object? createdAt = freezed,}) {
  return _then(VenueRating(
venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,matchId: null == matchId ? _self.matchId : matchId // ignore: cast_nullable_to_non_nullable
as String,matchTitle: null == matchTitle ? _self.matchTitle : matchTitle // ignore: cast_nullable_to_non_nullable
as String,reviewerId: null == reviewerId ? _self.reviewerId : reviewerId // ignore: cast_nullable_to_non_nullable
as String,reviewerName: null == reviewerName ? _self.reviewerName : reviewerName // ignore: cast_nullable_to_non_nullable
as String,reviewerPhotoUrl: freezed == reviewerPhotoUrl ? _self.reviewerPhotoUrl : reviewerPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,overall: null == overall ? _self.overall : overall // ignore: cast_nullable_to_non_nullable
as int,pitch: null == pitch ? _self.pitch : pitch // ignore: cast_nullable_to_non_nullable
as int,facilities: null == facilities ? _self.facilities : facilities // ignore: cast_nullable_to_non_nullable
as int,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [VenueRating].
extension VenueRatingPatterns on VenueRating {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VenueRating value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VenueRating() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VenueRating value)  $default,){
final _that = this;
switch (_that) {
case _VenueRating():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VenueRating value)?  $default,){
final _that = this;
switch (_that) {
case _VenueRating() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String venueId,  String matchId,  String matchTitle,  String reviewerId,  String reviewerName,  String? reviewerPhotoUrl,  int overall,  int pitch,  int facilities,  int value,  String comment,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VenueRating() when $default != null:
return $default(_that.venueId,_that.matchId,_that.matchTitle,_that.reviewerId,_that.reviewerName,_that.reviewerPhotoUrl,_that.overall,_that.pitch,_that.facilities,_that.value,_that.comment,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String venueId,  String matchId,  String matchTitle,  String reviewerId,  String reviewerName,  String? reviewerPhotoUrl,  int overall,  int pitch,  int facilities,  int value,  String comment,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _VenueRating():
return $default(_that.venueId,_that.matchId,_that.matchTitle,_that.reviewerId,_that.reviewerName,_that.reviewerPhotoUrl,_that.overall,_that.pitch,_that.facilities,_that.value,_that.comment,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String venueId,  String matchId,  String matchTitle,  String reviewerId,  String reviewerName,  String? reviewerPhotoUrl,  int overall,  int pitch,  int facilities,  int value,  String comment,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _VenueRating() when $default != null:
return $default(_that.venueId,_that.matchId,_that.matchTitle,_that.reviewerId,_that.reviewerName,_that.reviewerPhotoUrl,_that.overall,_that.pitch,_that.facilities,_that.value,_that.comment,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _VenueRating implements VenueRating {
  const _VenueRating({required this.venueId, required this.matchId, required this.matchTitle, required this.reviewerId, required this.reviewerName, this.reviewerPhotoUrl, required this.overall, required this.pitch, required this.facilities, required this.value, this.comment = '', this.createdAt});
  

@override final  String venueId;
@override final  String matchId;
@override final  String matchTitle;
@override final  String reviewerId;
@override final  String reviewerName;
@override final  String? reviewerPhotoUrl;
@override final  int overall;
@override final  int pitch;
@override final  int facilities;
@override final  int value;
@override@JsonKey() final  String comment;
@override final  DateTime? createdAt;

/// Create a copy of VenueRating
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VenueRatingCopyWith<_VenueRating> get copyWith => __$VenueRatingCopyWithImpl<_VenueRating>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VenueRating&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.matchId, matchId) || other.matchId == matchId)&&(identical(other.matchTitle, matchTitle) || other.matchTitle == matchTitle)&&(identical(other.reviewerId, reviewerId) || other.reviewerId == reviewerId)&&(identical(other.reviewerName, reviewerName) || other.reviewerName == reviewerName)&&(identical(other.reviewerPhotoUrl, reviewerPhotoUrl) || other.reviewerPhotoUrl == reviewerPhotoUrl)&&(identical(other.overall, overall) || other.overall == overall)&&(identical(other.pitch, pitch) || other.pitch == pitch)&&(identical(other.facilities, facilities) || other.facilities == facilities)&&(identical(other.value, value) || other.value == value)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,venueId,matchId,matchTitle,reviewerId,reviewerName,reviewerPhotoUrl,overall,pitch,facilities,value,comment,createdAt);
}

@override
String toString() {
    return 'VenueRating(venueId: $venueId, matchId: $matchId, matchTitle: $matchTitle, reviewerId: $reviewerId, reviewerName: $reviewerName, reviewerPhotoUrl: $reviewerPhotoUrl, overall: $overall, pitch: $pitch, facilities: $facilities, value: $value, comment: $comment, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$VenueRatingCopyWith<$Res> implements $VenueRatingCopyWith<$Res> {
  factory _$VenueRatingCopyWith(_VenueRating value, $Res Function(_VenueRating) _then) = __$VenueRatingCopyWithImpl;
@override @useResult
$Res call({
 String venueId, String matchId, String matchTitle, String reviewerId, String reviewerName, String? reviewerPhotoUrl, int overall, int pitch, int facilities, int value, String comment, DateTime? createdAt
});




}
/// @nodoc
class __$VenueRatingCopyWithImpl<$Res>
    implements _$VenueRatingCopyWith<$Res> {
  __$VenueRatingCopyWithImpl(this._self, this._then);

  final _VenueRating _self;
  final $Res Function(_VenueRating) _then;

/// Create a copy of VenueRating
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? venueId = null,Object? matchId = null,Object? matchTitle = null,Object? reviewerId = null,Object? reviewerName = null,Object? reviewerPhotoUrl = freezed,Object? overall = null,Object? pitch = null,Object? facilities = null,Object? value = null,Object? comment = null,Object? createdAt = freezed,}) {
  return _then(_VenueRating(
venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,matchId: null == matchId ? _self.matchId : matchId // ignore: cast_nullable_to_non_nullable
as String,matchTitle: null == matchTitle ? _self.matchTitle : matchTitle // ignore: cast_nullable_to_non_nullable
as String,reviewerId: null == reviewerId ? _self.reviewerId : reviewerId // ignore: cast_nullable_to_non_nullable
as String,reviewerName: null == reviewerName ? _self.reviewerName : reviewerName // ignore: cast_nullable_to_non_nullable
as String,reviewerPhotoUrl: freezed == reviewerPhotoUrl ? _self.reviewerPhotoUrl : reviewerPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,overall: null == overall ? _self.overall : overall // ignore: cast_nullable_to_non_nullable
as int,pitch: null == pitch ? _self.pitch : pitch // ignore: cast_nullable_to_non_nullable
as int,facilities: null == facilities ? _self.facilities : facilities // ignore: cast_nullable_to_non_nullable
as int,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
