import 'package:modelith/modelith.dart';

part 'page_model.g.dart';

/// A generic model. With `genericArgumentFactories`, `toJson()` takes the
/// per-argument encoder, exactly like `_$PageModelToJson` does.
@Model(genericArgumentFactories: true)
class PageModel<T> with Equatable, _$PageModel<T> {
  const PageModel({required this.items, required this.total});

  factory PageModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PageModelFromJson(json, fromJsonT);

  @ModelField()
  final List<T> items;

  @ModelField()
  final int total;
}
