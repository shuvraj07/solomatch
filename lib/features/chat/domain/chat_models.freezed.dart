// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatMember {

 String get name; String? get photoUrl;
/// Create a copy of ChatMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMemberCopyWith<ChatMember> get copyWith => _$ChatMemberCopyWithImpl<ChatMember>(this as ChatMember, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChatMember;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMember&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.photoUrl, _this.photoUrl) || other.photoUrl == _this.photoUrl));
}


@override
int get hashCode {
  final _this = this as ChatMember;
  return Object.hash(runtimeType,_this.name,_this.photoUrl);
}

@override
String toString() {
  final _this = this as ChatMember;
  return 'ChatMember(name: ${_this.name}, photoUrl: ${_this.photoUrl})';
}


}

/// @nodoc
abstract mixin class $ChatMemberCopyWith<$Res>  {
  factory $ChatMemberCopyWith(ChatMember value, $Res Function(ChatMember) _then) = _$ChatMemberCopyWithImpl;
@useResult
$Res call({
 String name, String? photoUrl
});




}
/// @nodoc
class _$ChatMemberCopyWithImpl<$Res>
    implements $ChatMemberCopyWith<$Res> {
  _$ChatMemberCopyWithImpl(this._self, this._then);

  final ChatMember _self;
  final $Res Function(ChatMember) _then;

/// Create a copy of ChatMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? photoUrl = freezed,}) {
  return _then(ChatMember(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMember].
extension ChatMemberPatterns on ChatMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMember value)  $default,){
final _that = this;
switch (_that) {
case _ChatMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMember value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? photoUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMember() when $default != null:
return $default(_that.name,_that.photoUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? photoUrl)  $default,) {final _that = this;
switch (_that) {
case _ChatMember():
return $default(_that.name,_that.photoUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? photoUrl)?  $default,) {final _that = this;
switch (_that) {
case _ChatMember() when $default != null:
return $default(_that.name,_that.photoUrl);case _:
  return null;

}
}

}

/// @nodoc


class _ChatMember implements ChatMember {
  const _ChatMember({required this.name, this.photoUrl});
  

@override final  String name;
@override final  String? photoUrl;

/// Create a copy of ChatMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMemberCopyWith<_ChatMember> get copyWith => __$ChatMemberCopyWithImpl<_ChatMember>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMember&&(identical(other.name, name) || other.name == name)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,photoUrl);
}

@override
String toString() {
    return 'ChatMember(name: $name, photoUrl: $photoUrl)';
}


}

/// @nodoc
abstract mixin class _$ChatMemberCopyWith<$Res> implements $ChatMemberCopyWith<$Res> {
  factory _$ChatMemberCopyWith(_ChatMember value, $Res Function(_ChatMember) _then) = __$ChatMemberCopyWithImpl;
@override @useResult
$Res call({
 String name, String? photoUrl
});




}
/// @nodoc
class __$ChatMemberCopyWithImpl<$Res>
    implements _$ChatMemberCopyWith<$Res> {
  __$ChatMemberCopyWithImpl(this._self, this._then);

  final _ChatMember _self;
  final $Res Function(_ChatMember) _then;

/// Create a copy of ChatMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? photoUrl = freezed,}) {
  return _then(_ChatMember(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$Conversation {

 String get id; ConversationType get type; String get matchId;/// The match title.
 String get title; List<String> get participantIds; Map<String, ChatMember> get participants; String? get lastMessageText; String? get lastMessageSenderId; DateTime? get lastMessageAt;/// When each member last read the conversation.
 Map<String, DateTime> get readAt;
/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationCopyWith<Conversation> get copyWith => _$ConversationCopyWithImpl<Conversation>(this as Conversation, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Conversation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Conversation&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.matchId, _this.matchId) || other.matchId == _this.matchId)&&(identical(other.title, _this.title) || other.title == _this.title)&&const DeepCollectionEquality().equals(other.participantIds, _this.participantIds)&&const DeepCollectionEquality().equals(other.participants, _this.participants)&&(identical(other.lastMessageText, _this.lastMessageText) || other.lastMessageText == _this.lastMessageText)&&(identical(other.lastMessageSenderId, _this.lastMessageSenderId) || other.lastMessageSenderId == _this.lastMessageSenderId)&&(identical(other.lastMessageAt, _this.lastMessageAt) || other.lastMessageAt == _this.lastMessageAt)&&const DeepCollectionEquality().equals(other.readAt, _this.readAt));
}


@override
int get hashCode {
  final _this = this as Conversation;
  return Object.hash(runtimeType,_this.id,_this.type,_this.matchId,_this.title,const DeepCollectionEquality().hash(_this.participantIds),const DeepCollectionEquality().hash(_this.participants),_this.lastMessageText,_this.lastMessageSenderId,_this.lastMessageAt,const DeepCollectionEquality().hash(_this.readAt));
}

@override
String toString() {
  final _this = this as Conversation;
  return 'Conversation(id: ${_this.id}, type: ${_this.type}, matchId: ${_this.matchId}, title: ${_this.title}, participantIds: ${_this.participantIds}, participants: ${_this.participants}, lastMessageText: ${_this.lastMessageText}, lastMessageSenderId: ${_this.lastMessageSenderId}, lastMessageAt: ${_this.lastMessageAt}, readAt: ${_this.readAt})';
}


}

/// @nodoc
abstract mixin class $ConversationCopyWith<$Res>  {
  factory $ConversationCopyWith(Conversation value, $Res Function(Conversation) _then) = _$ConversationCopyWithImpl;
@useResult
$Res call({
 String id, ConversationType type, String matchId, String title, List<String> participantIds, Map<String, ChatMember> participants, String? lastMessageText, String? lastMessageSenderId, DateTime? lastMessageAt, Map<String, DateTime> readAt
});




}
/// @nodoc
class _$ConversationCopyWithImpl<$Res>
    implements $ConversationCopyWith<$Res> {
  _$ConversationCopyWithImpl(this._self, this._then);

  final Conversation _self;
  final $Res Function(Conversation) _then;

/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? matchId = null,Object? title = null,Object? participantIds = null,Object? participants = null,Object? lastMessageText = freezed,Object? lastMessageSenderId = freezed,Object? lastMessageAt = freezed,Object? readAt = null,}) {
  return _then(Conversation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ConversationType,matchId: null == matchId ? _self.matchId : matchId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,participantIds: null == participantIds ? _self.participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as Map<String, ChatMember>,lastMessageText: freezed == lastMessageText ? _self.lastMessageText : lastMessageText // ignore: cast_nullable_to_non_nullable
as String?,lastMessageSenderId: freezed == lastMessageSenderId ? _self.lastMessageSenderId : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,readAt: null == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as Map<String, DateTime>,
  ));
}

}


/// Adds pattern-matching-related methods to [Conversation].
extension ConversationPatterns on Conversation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Conversation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Conversation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Conversation value)  $default,){
final _that = this;
switch (_that) {
case _Conversation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Conversation value)?  $default,){
final _that = this;
switch (_that) {
case _Conversation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ConversationType type,  String matchId,  String title,  List<String> participantIds,  Map<String, ChatMember> participants,  String? lastMessageText,  String? lastMessageSenderId,  DateTime? lastMessageAt,  Map<String, DateTime> readAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Conversation() when $default != null:
return $default(_that.id,_that.type,_that.matchId,_that.title,_that.participantIds,_that.participants,_that.lastMessageText,_that.lastMessageSenderId,_that.lastMessageAt,_that.readAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ConversationType type,  String matchId,  String title,  List<String> participantIds,  Map<String, ChatMember> participants,  String? lastMessageText,  String? lastMessageSenderId,  DateTime? lastMessageAt,  Map<String, DateTime> readAt)  $default,) {final _that = this;
switch (_that) {
case _Conversation():
return $default(_that.id,_that.type,_that.matchId,_that.title,_that.participantIds,_that.participants,_that.lastMessageText,_that.lastMessageSenderId,_that.lastMessageAt,_that.readAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ConversationType type,  String matchId,  String title,  List<String> participantIds,  Map<String, ChatMember> participants,  String? lastMessageText,  String? lastMessageSenderId,  DateTime? lastMessageAt,  Map<String, DateTime> readAt)?  $default,) {final _that = this;
switch (_that) {
case _Conversation() when $default != null:
return $default(_that.id,_that.type,_that.matchId,_that.title,_that.participantIds,_that.participants,_that.lastMessageText,_that.lastMessageSenderId,_that.lastMessageAt,_that.readAt);case _:
  return null;

}
}

}

/// @nodoc


class _Conversation extends Conversation {
  const _Conversation({required this.id, required this.type, required this.matchId, required this.title, required  List<String> participantIds,  Map<String, ChatMember> participants = const <String, ChatMember>{}, this.lastMessageText, this.lastMessageSenderId, this.lastMessageAt,  Map<String, DateTime> readAt = const <String, DateTime>{}}): _participantIds = participantIds,_participants = participants,_readAt = readAt,super._();
  

@override final  String id;
@override final  ConversationType type;
@override final  String matchId;
/// The match title.
@override final  String title;
 final  List<String> _participantIds;
@override List<String> get participantIds {
  if (_participantIds is EqualUnmodifiableListView) return _participantIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantIds);
}

 final  Map<String, ChatMember> _participants;
@override@JsonKey() Map<String, ChatMember> get participants {
  if (_participants is EqualUnmodifiableMapView) return _participants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_participants);
}

@override final  String? lastMessageText;
@override final  String? lastMessageSenderId;
@override final  DateTime? lastMessageAt;
/// When each member last read the conversation.
 final  Map<String, DateTime> _readAt;
/// When each member last read the conversation.
@override@JsonKey() Map<String, DateTime> get readAt {
  if (_readAt is EqualUnmodifiableMapView) return _readAt;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_readAt);
}


/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationCopyWith<_Conversation> get copyWith => __$ConversationCopyWithImpl<_Conversation>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Conversation&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.matchId, matchId) || other.matchId == matchId)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.participantIds, _participantIds)&&const DeepCollectionEquality().equals(other.participants, _participants)&&(identical(other.lastMessageText, lastMessageText) || other.lastMessageText == lastMessageText)&&(identical(other.lastMessageSenderId, lastMessageSenderId) || other.lastMessageSenderId == lastMessageSenderId)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&const DeepCollectionEquality().equals(other.readAt, _readAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,type,matchId,title,const DeepCollectionEquality().hash(_participantIds),const DeepCollectionEquality().hash(_participants),lastMessageText,lastMessageSenderId,lastMessageAt,const DeepCollectionEquality().hash(_readAt));
}

@override
String toString() {
    return 'Conversation(id: $id, type: $type, matchId: $matchId, title: $title, participantIds: $participantIds, participants: $participants, lastMessageText: $lastMessageText, lastMessageSenderId: $lastMessageSenderId, lastMessageAt: $lastMessageAt, readAt: $readAt)';
}


}

/// @nodoc
abstract mixin class _$ConversationCopyWith<$Res> implements $ConversationCopyWith<$Res> {
  factory _$ConversationCopyWith(_Conversation value, $Res Function(_Conversation) _then) = __$ConversationCopyWithImpl;
@override @useResult
$Res call({
 String id, ConversationType type, String matchId, String title, List<String> participantIds, Map<String, ChatMember> participants, String? lastMessageText, String? lastMessageSenderId, DateTime? lastMessageAt, Map<String, DateTime> readAt
});




}
/// @nodoc
class __$ConversationCopyWithImpl<$Res>
    implements _$ConversationCopyWith<$Res> {
  __$ConversationCopyWithImpl(this._self, this._then);

  final _Conversation _self;
  final $Res Function(_Conversation) _then;

/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? matchId = null,Object? title = null,Object? participantIds = null,Object? participants = null,Object? lastMessageText = freezed,Object? lastMessageSenderId = freezed,Object? lastMessageAt = freezed,Object? readAt = null,}) {
  return _then(_Conversation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ConversationType,matchId: null == matchId ? _self.matchId : matchId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,participantIds: null == participantIds ? _self._participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,participants: null == participants ? _self._participants : participants // ignore: cast_nullable_to_non_nullable
as Map<String, ChatMember>,lastMessageText: freezed == lastMessageText ? _self.lastMessageText : lastMessageText // ignore: cast_nullable_to_non_nullable
as String?,lastMessageSenderId: freezed == lastMessageSenderId ? _self.lastMessageSenderId : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,readAt: null == readAt ? _self._readAt : readAt // ignore: cast_nullable_to_non_nullable
as Map<String, DateTime>,
  ));
}


}

/// @nodoc
mixin _$ChatMessage {

 String get id; String get senderId; String? get text; String? get imageUrl;/// Null while the message is still being written by the server.
 DateTime? get sentAt;
/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageCopyWith<ChatMessage> get copyWith => _$ChatMessageCopyWithImpl<ChatMessage>(this as ChatMessage, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChatMessage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessage&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.senderId, _this.senderId) || other.senderId == _this.senderId)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl)&&(identical(other.sentAt, _this.sentAt) || other.sentAt == _this.sentAt));
}


@override
int get hashCode {
  final _this = this as ChatMessage;
  return Object.hash(runtimeType,_this.id,_this.senderId,_this.text,_this.imageUrl,_this.sentAt);
}

@override
String toString() {
  final _this = this as ChatMessage;
  return 'ChatMessage(id: ${_this.id}, senderId: ${_this.senderId}, text: ${_this.text}, imageUrl: ${_this.imageUrl}, sentAt: ${_this.sentAt})';
}


}

/// @nodoc
abstract mixin class $ChatMessageCopyWith<$Res>  {
  factory $ChatMessageCopyWith(ChatMessage value, $Res Function(ChatMessage) _then) = _$ChatMessageCopyWithImpl;
@useResult
$Res call({
 String id, String senderId, String? text, String? imageUrl, DateTime? sentAt
});




}
/// @nodoc
class _$ChatMessageCopyWithImpl<$Res>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._self, this._then);

  final ChatMessage _self;
  final $Res Function(ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? senderId = null,Object? text = freezed,Object? imageUrl = freezed,Object? sentAt = freezed,}) {
  return _then(ChatMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,sentAt: freezed == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessage].
extension ChatMessagePatterns on ChatMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessage value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessage value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String senderId,  String? text,  String? imageUrl,  DateTime? sentAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.senderId,_that.text,_that.imageUrl,_that.sentAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String senderId,  String? text,  String? imageUrl,  DateTime? sentAt)  $default,) {final _that = this;
switch (_that) {
case _ChatMessage():
return $default(_that.id,_that.senderId,_that.text,_that.imageUrl,_that.sentAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String senderId,  String? text,  String? imageUrl,  DateTime? sentAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.senderId,_that.text,_that.imageUrl,_that.sentAt);case _:
  return null;

}
}

}

/// @nodoc


class _ChatMessage implements ChatMessage {
  const _ChatMessage({required this.id, required this.senderId, this.text, this.imageUrl, this.sentAt});
  

@override final  String id;
@override final  String senderId;
@override final  String? text;
@override final  String? imageUrl;
/// Null while the message is still being written by the server.
@override final  DateTime? sentAt;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageCopyWith<_ChatMessage> get copyWith => __$ChatMessageCopyWithImpl<_ChatMessage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.text, text) || other.text == text)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,senderId,text,imageUrl,sentAt);
}

@override
String toString() {
    return 'ChatMessage(id: $id, senderId: $senderId, text: $text, imageUrl: $imageUrl, sentAt: $sentAt)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageCopyWith<$Res> implements $ChatMessageCopyWith<$Res> {
  factory _$ChatMessageCopyWith(_ChatMessage value, $Res Function(_ChatMessage) _then) = __$ChatMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String senderId, String? text, String? imageUrl, DateTime? sentAt
});




}
/// @nodoc
class __$ChatMessageCopyWithImpl<$Res>
    implements _$ChatMessageCopyWith<$Res> {
  __$ChatMessageCopyWithImpl(this._self, this._then);

  final _ChatMessage _self;
  final $Res Function(_ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? senderId = null,Object? text = freezed,Object? imageUrl = freezed,Object? sentAt = freezed,}) {
  return _then(_ChatMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,sentAt: freezed == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
