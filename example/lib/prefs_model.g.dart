// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prefs_model.dart';

// **************************************************************************
// ModelGenerator
// **************************************************************************

PrefsModel _$PrefsModelFromJson(Map<String, dynamic> json) => PrefsModel(
  order: (json['order'] as List<dynamic>).map((e) => e as String).toList(),
  labels: (json['labels'] as List<dynamic>).map((e) => e as String).toSet(),
  limits: Map<String, int>.from(json['limits'] as Map),
  matrix: (json['matrix'] as List<dynamic>)
      .map((e) => (e as List<dynamic>).map((e) => (e as num).toInt()).toList())
      .toList(),
  extra: json['extra'],
);

Map<String, dynamic> _$PrefsModelToJson(PrefsModel instance) =>
    <String, dynamic>{
      'order': instance.order,
      'labels': instance.labels.toList(),
      'limits': instance.limits,
      'matrix': instance.matrix,
      'extra': instance.extra,
    };

extension $PrefsModelCopyWith on PrefsModel {
  PrefsModel copyWith({
    List<String>? order,
    Set<String>? labels,
    Map<String, int>? limits,
    List<List<int>>? matrix,
    Object? extra = $unset,
  }) => PrefsModel(
    order: order ?? this.order,
    labels: labels ?? this.labels,
    limits: limits ?? this.limits,
    matrix: matrix ?? this.matrix,
    extra: extra == $unset ? this.extra : extra,
  );
}

mixin _$PrefsModel {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PrefsModel || runtimeType != other.runtimeType) {
      return false;
    }
    final self = this as PrefsModel;
    return ModelEquality.iterables(self.order, other.order) &&
        ModelEquality.sets(self.labels, other.labels) &&
        ModelEquality.maps(self.limits, other.limits) &&
        ModelEquality.iterables(self.matrix, other.matrix) &&
        ModelEquality.objects(self.extra, other.extra);
  }

  @override
  int get hashCode {
    final self = this as PrefsModel;
    return Object.hash(
      runtimeType,
      ModelEquality.hashOf(self.order),
      ModelEquality.hashOf(self.labels),
      ModelEquality.hashOf(self.limits),
      ModelEquality.hashOf(self.matrix),
      ModelEquality.hashOf(self.extra),
    );
  }

  @override
  String toString() {
    final self = this as PrefsModel;
    return 'PrefsModel(order: ${self.order}, labels: ${self.labels}, limits: ${self.limits}, matrix: ${self.matrix}, extra: ${self.extra})';
  }

  Map<String, dynamic> toJson() => _$PrefsModelToJson(this as PrefsModel);
}
