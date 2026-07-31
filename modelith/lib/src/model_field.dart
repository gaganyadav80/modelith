import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta_meta.dart';

/// Per-field configuration for a [Model] class.
///
/// `ModelField` extends [JsonKey], so every json option is available here and
/// is picked up by `json_serializable` unchanged (annotation matching is
/// assignability based). The extra [equality] and [copyWith] flags control the
/// two things Modelith generates itself.
///
/// ```dart
/// @ModelField(name: 'display_name', equality: false)
/// final String displayName;
/// ```
@Target({TargetKind.field})
class ModelField extends JsonKey {
  const ModelField({
    this.equality = true,
    this.copyWith = true,
    super.defaultValue,
    super.disallowNullValue,
    super.fromJson,
    super.includeFromJson,
    super.includeIfNull,
    super.includeToJson,
    super.name,
    super.readValue,
    super.required,
    super.toJson,
    super.unknownEnumValue,
  });

  /// Whether this field participates in `==` / `hashCode`.
  ///
  /// When `false` the field is left out of the generated `props`.
  final bool equality;

  /// Whether `copyWith` accepts a replacement for this field.
  ///
  /// When `false` the field is always carried over from the receiver, so it can
  /// never be changed through `copyWith`. Private fields are treated this way
  /// implicitly, since a named parameter cannot be private.
  final bool copyWith;
}
