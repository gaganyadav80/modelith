// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opt_out_models.dart';

// **************************************************************************
// ModelGenerator
// **************************************************************************

extension $PlainPointCopyWith on PlainPoint {
  PlainPoint copyWith({int? x, int? y}) => PlainPoint(x ?? this.x, y ?? this.y);
}

mixin _$PlainPoint {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PlainPoint || runtimeType != other.runtimeType) {
      return false;
    }
    final self = this as PlainPoint;
    return self.x == other.x && self.y == other.y;
  }

  @override
  int get hashCode {
    final self = this as PlainPoint;
    return Object.hash(runtimeType, self.x, self.y);
  }

  @override
  String toString() {
    final self = this as PlainPoint;
    return 'PlainPoint(x: ${self.x}, y: ${self.y})';
  }
}

NoCopyToken _$NoCopyTokenFromJson(Map<String, dynamic> json) =>
    NoCopyToken(value: json['value'] as String);

Map<String, dynamic> _$NoCopyTokenToJson(NoCopyToken instance) =>
    <String, dynamic>{'value': instance.value};

mixin _$NoCopyToken {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NoCopyToken || runtimeType != other.runtimeType) {
      return false;
    }
    final self = this as NoCopyToken;
    return self.value == other.value;
  }

  @override
  int get hashCode {
    final self = this as NoCopyToken;
    return Object.hash(runtimeType, self.value);
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
