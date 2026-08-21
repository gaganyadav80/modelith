import 'package:modelith/modelith.dart';

part 'prefs_model.g.dart';

/// Exercises every deep-equality path the generator can pick: an ordered list,
/// an unordered set, a map, a nested collection, and a field whose static type
/// is unknown until runtime.
@Model()
class PrefsModel with _$PrefsModel {
  const PrefsModel({
    required this.order,
    required this.labels,
    required this.limits,
    required this.matrix,
    this.extra,
  });

  factory PrefsModel.fromJson(Map<String, dynamic> json) =>
      _$PrefsModelFromJson(json);

  Map<String, dynamic> toJson() => _$PrefsModelToJson(this);

  @ModelField()
  final List<String> order;

  @ModelField()
  final Set<String> labels;

  @ModelField()
  final Map<String, int> limits;

  @ModelField()
  final List<List<int>> matrix;

  @ModelField()
  final Object? extra;
}
