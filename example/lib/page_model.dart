import 'package:modelith/modelith.dart';

part 'page_model.g.dart';

/// A generic model. With `genericArgumentFactories`, both json lines take a
/// per-argument codec, matching the generated functions they delegate to.
@Model(genericArgumentFactories: true)
class PageModel<T> with _$PageModel<T> {
  const PageModel({required this.items, required this.total});

  factory PageModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PageModelFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PageModelToJson(this, toJsonT);

  @ModelField()
  final List<T> items;

  @ModelField()
  final int total;
}
