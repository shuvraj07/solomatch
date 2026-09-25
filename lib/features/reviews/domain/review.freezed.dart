// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Review {

 String get matchId; String get reviewerId; String get revieweeId;/// 1–5.
 int get rating; String get comment; String get reviewerName; String? get reviewerPhotoUrl; String get matchTitle; DateTime? get createdAt;
/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewCopyWith<Review> get copyWith => _$ReviewCopyWithImpl<Review>(this as Review, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Review;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Review&&(identical(other.matchId, _this.matchId) || other.matchId == _this.matchId)&&(identical(other.reviewerId, _this.reviewerId) || other.reviewerId == _this.reviewerId)&&(identical(other.revieweeId, _this.revieweeId) || other.revieweeId == _this.revieweeId)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.reviewerName, _this.reviewerName) || other.reviewerName == _this.reviewerName)&&(identical(other.reviewerPhotoUrl, _this.reviewerPhotoUrl) || other.reviewerPhotoUrl == _this.reviewerPhotoUrl)&&(identical(other.matchTitle, _this.matchTitle) || other.matchTitle == _this.matchTitle)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as Review;
  return Object.hash(runtimeType,_this.matchId,_this.reviewerId,_this.revieweeId,_this.rating,_this.comment,_this.reviewerName,_this.reviewerPhotoUrl,_this.matchTitle,_this.createdAt);
}

@override
String toString() {
  final _this = this as Review;
  return 'Review(matchId: ${_this.matchId}, reviewerId: ${_this.reviewerId}, revieweeId: ${_this.revieweeId}, rating: ${_this.rating}, comment: ${_this.comment}, reviewerName: ${_this.reviewerName}, reviewerPhotoUrl: ${_this.reviewerPhotoUrl}, matchTitle: ${_this.matchTitle}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $ReviewCopyWith<$Res>  {
  factory $ReviewCopyWith(Review value, $Res Function(Review) _then) = _$ReviewCopyWithImpl;
@useResult
$Res call({
 String matchId, String reviewerId, String revieweeId, int rating, String comment, String reviewerName, String? reviewerPhotoUrl, String matchTitle, DateTime? createdAt
});




}
/// @nodoc
class _$ReviewCopyWithImpl<$Res>
    implements $ReviewCopyWith<$Res> {
  _$ReviewCopyWithImpl(this._self, this._then);

  final Review _self;
  final $Res Function(Review) _then;

/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? matchId = null,Object? reviewerId = null,Object? revieweeId = null,Object? rating = null,Object? comment = null,Object? reviewerName = null,Object? reviewerPhotoUrl = freezed,Object? matchTitle = null,Object? createdAt = freezed,}) {
  return _then(Review(
matchId: null == matchId ? _self.matchId : matchId // ignore: cast_nullable_to_non_nullable
as String,reviewerId: null == reviewerId ? _self.reviewerId : reviewerId // ignore: cast_nullable_to_non_nullable
as String,revieweeId: null == revieweeId ? _self.revieweeId : revieweeId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,reviewerName: null == reviewerName ? _self.reviewerName : reviewerName // ignore: cast_nullable_to_non_nullable
as String,reviewerPhotoUrl: freezed == reviewerPhotoUrl ? _self.reviewerPhotoUrl : reviewerPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,matchTitle: null == matchTitle ? _self.matchTitle : matchTitle // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Review].
extension ReviewPatterns on Review {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Review value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Review() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Review value)  $default,){
final _that = this;
switch (_that) {
case _Review():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Review value)?  $default,){
final _that = this;
switch (_that) {
case _Review() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String matchId,  String reviewerId,  String revieweeId,  int rating,  String comment,  String reviewerName,  String? reviewerPhotoUrl,  String matchTitle,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Review() when $default != null:
return $default(_that.matchId,_that.reviewerId,_that.revieweeId,_that.rating,_that.comment,_that.reviewerName,_that.reviewerPhotoUrl,_that.matchTitle,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String matchId,  String reviewerId,  String revieweeId,  int rating,  String comment,  String reviewerName,  String? reviewerPhotoUrl,  String matchTitle,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Review():
return $default(_that.matchId,_that.reviewerId,_that.revieweeId,_that.rating,_that.comment,_that.reviewerName,_that.reviewerPhotoUrl,_that.matchTitle,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String matchId,  String reviewerId,  String revieweeId,  int rating,  String comment,  String reviewerName,  String? reviewerPhotoUrl,  String matchTitle,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Review() when $default != null:
return $default(_that.matchId,_that.reviewerId,_that.revieweeId,_that.rating,_that.comment,_that.reviewerName,_that.reviewerPhotoUrl,_that.matchTitle,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _Review extends Review {
  const _Review({required this.matchId, required this.reviewerId, required this.revieweeId, required this.rating, this.comment = '', required this.reviewerName, this.reviewerPhotoUrl, required this.matchTitle, this.createdAt}): super._();
  

@override final  String matchId;
@override final  String reviewerId;
@override final  String revieweeId;
/// 1–5.
@override final  int rating;
@override@JsonKey() final  String comment;
@override final  String reviewerName;
@override final  String? reviewerPhotoUrl;
@override final  String matchTitle;
@override final  DateTime? createdAt;

/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewCopyWith<_Review> get copyWith => __$ReviewCopyWithImpl<_Review>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Review&&(identical(other.matchId, matchId) || other.matchId == matchId)&&(identical(other.reviewerId, reviewerId) || other.reviewerId == reviewerId)&&(identical(other.revieweeId, revieweeId) || other.revieweeId == revieweeId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.reviewerName, reviewerName) || other.reviewerName == reviewerName)&&(identical(other.reviewerPhotoUrl, reviewerPhotoUrl) || other.reviewerPhotoUrl == reviewerPhotoUrl)&&(identical(other.matchTitle, matchTitle) || other.matchTitle == matchTitle)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,matchId,reviewerId,revieweeId,rating,comment,reviewerName,reviewerPhotoUrl,matchTitle,createdAt);
}

@override
String toString() {
    return 'Review(matchId: $matchId, reviewerId: $reviewerId, revieweeId: $revieweeId, rating: $rating, comment: $comment, reviewerName: $reviewerName, reviewerPhotoUrl: $reviewerPhotoUrl, matchTitle: $matchTitle, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ReviewCopyWith<$Res> implements $ReviewCopyWith<$Res> {
  factory _$ReviewCopyWith(_Review value, $Res Function(_Review) _then) = __$ReviewCopyWithImpl;
@override @useResult
$Res call({
 String matchId, String reviewerId, String revieweeId, int rating, String comment, String reviewerName, String? reviewerPhotoUrl, String matchTitle, DateTime? createdAt
});




}
/// @nodoc
class __$ReviewCopyWithImpl<$Res>
    implements _$ReviewCopyWith<$Res> {
  __$ReviewCopyWithImpl(this._self, this._then);

  final _Review _self;
  final $Res Function(_Review) _then;

/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? matchId = null,Object? reviewerId = null,Object? revieweeId = null,Object? rating = null,Object? comment = null,Object? reviewerName = null,Object? reviewerPhotoUrl = freezed,Object? matchTitle = null,Object? createdAt = freezed,}) {
  return _then(_Review(
matchId: null == matchId ? _self.matchId : matchId // ignore: cast_nullable_to_non_nullable
as String,reviewerId: null == reviewerId ? _self.reviewerId : reviewerId // ignore: cast_nullable_to_non_nullable
as String,revieweeId: null == revieweeId ? _self.revieweeId : revieweeId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,reviewerName: null == reviewerName ? _self.reviewerName : reviewerName // ignore: cast_nullable_to_non_nullable
as String,reviewerPhotoUrl: freezed == reviewerPhotoUrl ? _self.reviewerPhotoUrl : reviewerPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,matchTitle: null == matchTitle ? _self.matchTitle : matchTitle // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
