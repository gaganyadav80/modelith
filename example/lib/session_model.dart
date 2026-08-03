import 'package:modelith/modelith.dart';

part 'session_model.g.dart';

/// Exercises the per-field options: a renamed json key, a field kept out of
/// equality, and a field that `copyWith` refuses to replace.
@Model()
class SessionModel with _$SessionModel {
  const SessionModel({
    required this.token,
    required this.deviceId,
    this.lastSeenAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) =>
      _$SessionModelFromJson(json);

  @ModelField(name: 'access_token')
  final String token;

  /// Assigned once at sign-in, so it is not part of identity and `copyWith`
  /// must not offer a way to swap it.
  @ModelField(name: 'device_id', equality: false, copyWith: false)
  final String deviceId;

  @ModelField(name: 'last_seen_at')
  final DateTime? lastSeenAt;
}
