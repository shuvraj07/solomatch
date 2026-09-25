// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_match_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreateMatchState {

 MatchDraft get draft; CreateMatchStep get step;/// Saving, uploading or publishing.
 bool get busy;/// Changed since the last save.
 bool get dirty;
/// Create a copy of CreateMatchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateMatchStateCopyWith<CreateMatchState> get copyWith => _$CreateMatchStateCopyWithImpl<CreateMatchState>(this as CreateMatchState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CreateMatchState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateMatchState&&(identical(other.draft, _this.draft) || other.draft == _this.draft)&&(identical(other.step, _this.step) || other.step == _this.step)&&(identical(other.busy, _this.busy) || other.busy == _this.busy)&&(identical(other.dirty, _this.dirty) || other.dirty == _this.dirty));
}


@override
int get hashCode {
  final _this = this as CreateMatchState;
  return Object.hash(runtimeType,_this.draft,_this.step,_this.busy,_this.dirty);
}

@override
String toString() {
  final _this = this as CreateMatchState;
  return 'CreateMatchState(draft: ${_this.draft}, step: ${_this.step}, busy: ${_this.busy}, dirty: ${_this.dirty})';
}


}

/// @nodoc
abstract mixin class $CreateMatchStateCopyWith<$Res>  {
  factory $CreateMatchStateCopyWith(CreateMatchState value, $Res Function(CreateMatchState) _then) = _$CreateMatchStateCopyWithImpl;
@useResult
$Res call({
 MatchDraft draft, CreateMatchStep step, bool busy, bool dirty
});


$MatchDraftCopyWith<$Res> get draft;

}
/// @nodoc
class _$CreateMatchStateCopyWithImpl<$Res>
    implements $CreateMatchStateCopyWith<$Res> {
  _$CreateMatchStateCopyWithImpl(this._self, this._then);

  final CreateMatchState _self;
  final $Res Function(CreateMatchState) _then;

/// Create a copy of CreateMatchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? draft = null,Object? step = null,Object? busy = null,Object? dirty = null,}) {
  return _then(CreateMatchState(
draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as MatchDraft,step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as CreateMatchStep,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,dirty: null == dirty ? _self.dirty : dirty // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of CreateMatchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchDraftCopyWith<$Res> get draft {
  
  return $MatchDraftCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}


/// Adds pattern-matching-related methods to [CreateMatchState].
extension CreateMatchStatePatterns on CreateMatchState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateMatchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateMatchState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateMatchState value)  $default,){
final _that = this;
switch (_that) {
case _CreateMatchState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateMatchState value)?  $default,){
final _that = this;
switch (_that) {
case _CreateMatchState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MatchDraft draft,  CreateMatchStep step,  bool busy,  bool dirty)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateMatchState() when $default != null:
return $default(_that.draft,_that.step,_that.busy,_that.dirty);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MatchDraft draft,  CreateMatchStep step,  bool busy,  bool dirty)  $default,) {final _that = this;
switch (_that) {
case _CreateMatchState():
return $default(_that.draft,_that.step,_that.busy,_that.dirty);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MatchDraft draft,  CreateMatchStep step,  bool busy,  bool dirty)?  $default,) {final _that = this;
switch (_that) {
case _CreateMatchState() when $default != null:
return $default(_that.draft,_that.step,_that.busy,_that.dirty);case _:
  return null;

}
}

}

/// @nodoc


class _CreateMatchState implements CreateMatchState {
  const _CreateMatchState({required this.draft, this.step = CreateMatchStep.title, this.busy = false, this.dirty = false});
  

@override final  MatchDraft draft;
@override@JsonKey() final  CreateMatchStep step;
/// Saving, uploading or publishing.
@override@JsonKey() final  bool busy;
/// Changed since the last save.
@override@JsonKey() final  bool dirty;

/// Create a copy of CreateMatchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateMatchStateCopyWith<_CreateMatchState> get copyWith => __$CreateMatchStateCopyWithImpl<_CreateMatchState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateMatchState&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.step, step) || other.step == step)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.dirty, dirty) || other.dirty == dirty));
}


@override
int get hashCode {
    return Object.hash(runtimeType,draft,step,busy,dirty);
}

@override
String toString() {
    return 'CreateMatchState(draft: $draft, step: $step, busy: $busy, dirty: $dirty)';
}


}

/// @nodoc
abstract mixin class _$CreateMatchStateCopyWith<$Res> implements $CreateMatchStateCopyWith<$Res> {
  factory _$CreateMatchStateCopyWith(_CreateMatchState value, $Res Function(_CreateMatchState) _then) = __$CreateMatchStateCopyWithImpl;
@override @useResult
$Res call({
 MatchDraft draft, CreateMatchStep step, bool busy, bool dirty
});


@override $MatchDraftCopyWith<$Res> get draft;

}
/// @nodoc
class __$CreateMatchStateCopyWithImpl<$Res>
    implements _$CreateMatchStateCopyWith<$Res> {
  __$CreateMatchStateCopyWithImpl(this._self, this._then);

  final _CreateMatchState _self;
  final $Res Function(_CreateMatchState) _then;

/// Create a copy of CreateMatchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? draft = null,Object? step = null,Object? busy = null,Object? dirty = null,}) {
  return _then(_CreateMatchState(
draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as MatchDraft,step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as CreateMatchStep,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,dirty: null == dirty ? _self.dirty : dirty // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of CreateMatchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchDraftCopyWith<$Res> get draft {
  
  return $MatchDraftCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}

// dart format on
