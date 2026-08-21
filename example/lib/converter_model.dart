import 'package:modelith/modelith.dart';

part 'converter_model.g.dart';

/// Exercises the json options that `json_serializable` reads as functions
/// rather than literals: [ModelField.fromJson], [ModelField.toJson] and
/// [ModelField.readValue].
@Model()
class ConverterModel with _$ConverterModel {
  const ConverterModel({required this.slug, required this.tags, this.legacyId});

  factory ConverterModel.fromJson(Map<String, dynamic> json) =>
      _$ConverterModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConverterModelToJson(this);

  @ModelField(fromJson: _slugFromJson, toJson: _slugToJson)
  final String slug;

  /// The wire format is a comma separated string, not a list.
  @ModelField(fromJson: _tagsFromJson, toJson: _tagsToJson)
  final List<String> tags;

  /// Read from either the new or the old key.
  @ModelField(name: 'id', readValue: _readLegacyId)
  final String? legacyId;

  static String _slugFromJson(String value) => value.toLowerCase();

  static String _slugToJson(String value) => value.toUpperCase();

  static List<String> _tagsFromJson(String value) =>
      value.isEmpty ? const [] : value.split(',');

  static String _tagsToJson(List<String> value) => value.join(',');

  static Object? _readLegacyId(Map<dynamic, dynamic> json, String key) =>
      json[key] ?? json['legacy_id'];
}
