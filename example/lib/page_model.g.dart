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
  List<Object?> get props {
    final self = this as PageModel<T>;
    return [self.items, self.total];
  }

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PageModelToJson(this as PageModel<T>, toJsonT);
}
