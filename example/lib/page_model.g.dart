// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_model.dart';

// **************************************************************************
// ModelGenerator
// **************************************************************************

PageModel<T> _$PageModelFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => PageModel<T>(
  items: (json['items'] as List<dynamic>).map(fromJsonT).toList(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$PageModelToJson<T>(
  PageModel<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'items': instance.items.map(toJsonT).toList(),
  'total': instance.total,
};

extension $PageModelCopyWith<T> on PageModel<T> {
  PageModel<T> copyWith({List<T>? items, int? total}) =>
      PageModel<T>(items: items ?? this.items, total: total ?? this.total);
}

mixin _$PageModel<T> {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PageModel<T> || runtimeType != other.runtimeType) {
      return false;
    }
    final self = this as PageModel<T>;
    return ModelEquality.iterables(self.items, other.items) &&
        self.total == other.total;
  }

  @override
  int get hashCode {
    final self = this as PageModel<T>;
    return Object.hash(
      runtimeType,
      ModelEquality.hashOf(self.items),
      self.total,
    );
  }

  @override
  String toString() {
    final self = this as PageModel<T>;
    return 'PageModel(items: ${self.items}, total: ${self.total})';
  }
}
