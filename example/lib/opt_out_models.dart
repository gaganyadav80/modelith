import 'package:modelith/modelith.dart';

part 'opt_out_models.g.dart';

/// `serializable: false` — no json functions, no `toJson()`, and no
/// hand-written `fromJson` line.
@Model(serializable: false)
class PlainPoint with _$PlainPoint {
  const PlainPoint(this.x, this.y);

  @ModelField()
  final int x;

  @ModelField()
  final int y;
}

/// `copyWith: false` — no `$NoCopyTokenCopyWith` extension. `stringify: false`
/// also drops the generated `toString`.
@Model(copyWith: false, stringify: false)
class NoCopyToken with _$NoCopyToken {
  const NoCopyToken({required this.value});

  factory NoCopyToken.fromJson(Map<String, dynamic> json) =>
      _$NoCopyTokenFromJson(json);

  @ModelField()
  final String value;
}

/// `equality: false` — no `props`, so `Equatable` is dropped from the `with`
/// clause and the class keeps identity equality.
@Model(equality: false)
class MutableCounter with _$MutableCounter {
  MutableCounter({required this.count});

  factory MutableCounter.fromJson(Map<String, dynamic> json) =>
      _$MutableCounterFromJson(json);

  @ModelField()
  int count;
}
