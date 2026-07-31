// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opt_out_models.dart';

// **************************************************************************
// ModelGenerator
// **************************************************************************

extension $PlainPointCopyWith on PlainPoint {
  PlainPoint copyWith({int? x, int? y}) => PlainPoint(x ?? this.x, y ?? this.y);
}

mixin _$PlainPoint {
  List<Object?> get props {
    final self = this as PlainPoint;
    return [self.x, self.y];
  }
}

NoCopyToken _$NoCopyTokenFromJson(Map<String, dynamic> json) =>
    NoCopyToken(value: json['value'] as String);

Map<String, dynamic> _$NoCopyTokenToJson(NoCopyToken instance) =>
    <String, dynamic>{'value': instance.value};

mixin _$NoCopyToken {
  List<Object?> get props {
    final self = this as NoCopyToken;
    return [self.value];
  }

  Map<String, dynamic> toJson() => _$NoCopyTokenToJson(this as NoCopyToken);
}

MutableCounter _$MutableCounterFromJson(Map<String, dynamic> json) =>
    MutableCounter(count: (json['count'] as num).toInt());

Map<String, dynamic> _$MutableCounterToJson(MutableCounter instance) =>
    <String, dynamic>{'count': instance.count};

extension $MutableCounterCopyWith on MutableCounter {
  MutableCounter copyWith({int? count}) =>
      MutableCounter(count: count ?? this.count);
}

mixin _$MutableCounter {
  Map<String, dynamic> toJson() =>
      _$MutableCounterToJson(this as MutableCounter);
}
