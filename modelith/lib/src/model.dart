import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta_meta.dart';

/// Marks a class as a Modelith data model.
///
/// A single `@Model()` produces, into one `.g.dart` part file:
///
/// * `_$FooFromJson` / `_$FooToJson` (delegated to `json_serializable`),
/// * a `$FooCopyWith` extension carrying `copyWith`,
/// * a `mixin _$Foo` supplying `props` (for `Equatable`) and `toJson()`.
///
/// The class stays an ordinary Dart class with real fields and a real
/// constructor. The one piece of glue that cannot be generated is the
/// `fromJson` factory — see the package README for why.
///
/// ```dart
/// @Model()
/// class Foo with Equatable, _$Foo {
///   const Foo(this.bar);
///
///   factory Foo.fromJson(Map<String, dynamic> json) => _$FooFromJson(json);
///
///   @ModelField(name: 'bar_value')
///   final String bar;
/// }
/// ```
///
/// The json-facing fields below mirror [JsonSerializable] by name and are
/// forwarded verbatim to `json_serializable`; leaving one `null` means "use
/// whatever the build configuration defaults to".
@Target({TargetKind.classType})
class Model {
  const Model({
    this.serializable = true,
    this.copyWith = true,
    this.equality = true,
    this.stringify,
    this.constructor,
    this.anyMap,
    this.checked,
    this.createFactory,
    this.createToJson,
    this.createFieldMap,
    this.createJsonKeys,
    this.createPerFieldToJson,
    this.createJsonSchema,
    this.dateTimeUtc,
    this.disallowUnrecognizedKeys,
    this.explicitToJson,
    this.fieldRename,
    this.genericArgumentFactories,
    this.ignoreUnannotated,
    this.includeIfNull,
    this.converters,
  });

  /// Generate `_$FooFromJson` / `_$FooToJson` and the `toJson()` member of the
  /// `_$Foo` mixin.
  ///
  /// When `false`, drop the hand-written `fromJson` factory from the class.
  final bool serializable;

  /// Generate the `$FooCopyWith` extension.
  final bool copyWith;

  /// Generate `props` into the `_$Foo` mixin.
  ///
  /// When `false`, drop `Equatable` from the class's `with` clause.
  final bool equality;

  /// Overrides `Equatable.stringify` for this model.
  ///
  /// `null` (the default) leaves the global `EquatableConfig.stringify` in
  /// charge.
  final bool? stringify;

  /// Name of the constructor used by both `fromJson` and `copyWith`.
  ///
  /// `null` means the unnamed constructor.
  final String? constructor;

  /// See [JsonSerializable.anyMap].
  final bool? anyMap;

  /// See [JsonSerializable.checked].
  final bool? checked;

  /// See [JsonSerializable.createFactory].
  final bool? createFactory;

  /// See [JsonSerializable.createToJson].
  final bool? createToJson;

  /// See [JsonSerializable.createFieldMap].
  final bool? createFieldMap;

  /// See [JsonSerializable.createJsonKeys].
  final bool? createJsonKeys;

  /// See [JsonSerializable.createPerFieldToJson].
  final bool? createPerFieldToJson;

  /// See [JsonSerializable.createJsonSchema].
  final bool? createJsonSchema;

  /// See [JsonSerializable.dateTimeUtc].
  final bool? dateTimeUtc;

  /// See [JsonSerializable.disallowUnrecognizedKeys].
  final bool? disallowUnrecognizedKeys;

  /// See [JsonSerializable.explicitToJson].
  final bool? explicitToJson;

  /// See [JsonSerializable.fieldRename].
  final FieldRename? fieldRename;

  /// See [JsonSerializable.genericArgumentFactories].
  final bool? genericArgumentFactories;

  /// See [JsonSerializable.ignoreUnannotated].
  final bool? ignoreUnannotated;

  /// See [JsonSerializable.includeIfNull].
  final bool? includeIfNull;

  /// See [JsonSerializable.converters].
  final List<JsonConverter>? converters;
}
