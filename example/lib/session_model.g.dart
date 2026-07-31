// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// ModelGenerator
// **************************************************************************

SessionModel _$SessionModelFromJson(Map<String, dynamic> json) => SessionModel(
  token: json['access_token'] as String,
  deviceId: json['device_id'] as String,
  lastSeenAt: json['last_seen_at'] == null
      ? null
      : DateTime.parse(json['last_seen_at'] as String),
);

Map<String, dynamic> _$SessionModelToJson(SessionModel instance) =>
    <String, dynamic>{
      'access_token': instance.token,
      'device_id': instance.deviceId,
      'last_seen_at': instance.lastSeenAt?.toIso8601String(),
    };

extension $SessionModelCopyWith on SessionModel {
  SessionModel copyWith({String? token, Object? lastSeenAt = $unset}) =>
      SessionModel(
        token: token ?? this.token,
        deviceId: deviceId,
        lastSeenAt: lastSeenAt == $unset
            ? this.lastSeenAt
            : lastSeenAt as DateTime?,
      );
}

mixin _$SessionModel {
  List<Object?> get props {
    final self = this as SessionModel;
    return [self.token, self.lastSeenAt];
  }

  bool? get stringify => true;

  Map<String, dynamic> toJson() => _$SessionModelToJson(this as SessionModel);
}
