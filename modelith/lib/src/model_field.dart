import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta_meta.dart';

/// Per-field configuration for a [Model] class.
///
/// `ModelField` implements [JsonKey], so every json option is available here
/// and is picked up by `json_serializable` unchanged (annotation matching is
/// assignability based). The extra [equality] and [copyWith] flags control the
/// two things Modelith generates itself.
///
/// ```dart
/// @ModelField(name: 'display_name', equality: false)
/// final String displayName;
/// ```
///
/// Every [JsonKey] option is re-declared as a field of this class rather than
/// forwarded to `super`. That is load bearing: `json_serializable` reads
/// [fromJson] and [toJson] with `DartObject.getField`, which looks only at the
/// annotation's own fields and does not walk the analyzer's `(super)`
/// pseudo-field. A `super.fromJson` parameter here would store the function on
/// the [JsonKey] part of the constant, where that lookup cannot see it, and the
/// converter would be dropped from the generated code with no error.
///
/// Consequence: when `json_annotation` adds an option to [JsonKey], this class
/// stops compiling until the option is added below. That is deliberate — the
/// alternative is silently ignoring it.
// #CHANGE WHEN UPDATING json_annotation
@Target({TargetKind.field})
class ModelField implements JsonKey {
  const ModelField({
    this.equality = true,
    this.copyWith = true,
    this.defaultValue,
    this.disallowNullValue,
    this.explicitJsonNullWhenNonNullField,
    this.fromJson,
    this.includeFromJson,
    this.includeIfNull,
    this.includeToJson,
    this.name,
    this.readValue,
    this.required,
    this.toJson,
    this.unknownEnumValue,
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

  @override
  final Object? defaultValue;

  @override
  final bool? disallowNullValue;

  @override
  final bool? explicitJsonNullWhenNonNullField;

  @override
  final Function? fromJson;

  @override
  final bool? includeFromJson;

  @override
  final bool? includeIfNull;

  @override
  final bool? includeToJson;

  @override
  final String? name;

  @override
  final Object? Function(Map<dynamic, dynamic>, String)? readValue;

  @override
  final bool? required;

  @override
  final Function? toJson;

  @override
  final Enum? unknownEnumValue;

  /// Deprecated on [JsonKey] and intentionally not exposed on the constructor —
  /// use [includeFromJson] and [includeToJson] instead.
  @override
  // ignore: deprecated_member_use
  bool? get ignore => null;
}
