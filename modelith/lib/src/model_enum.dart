import 'package:json_annotation/json_annotation.dart';

/// Configures how an `enum` is encoded, for use on the `enum` declaration.
///
/// Enums are not `@Model` targets — they have no fields to copy or compare —
/// but a `@Model` class can hold one, and the generated `_$FooEnumMap` comes
/// from this annotation.
///
/// ```dart
/// @ModelEnum(fieldRename: FieldRename.snake)
/// enum Tier {
///   freeTrial, // 'free_trial'
///   @ModelValue('paid')
///   paidMonthly, // 'paid'
/// }
/// ```
///
/// With `alwaysCreate: true` the map is emitted even when no `@Model` class in
/// the library uses the enum. That needs a `part '<file>.g.dart';` in the file
/// declaring the enum, exactly like a model does.
///
/// See [JsonEnum] for the individual options.
// `ModelEnum` and [ModelValue] are aliases, not subtypes, and that is load
// bearing. `json_serializable` looks up the entry annotation with
// `firstAnnotationOfExact`, so a `class ModelValue implements JsonValue` would
// be skipped without an error — unlike [ModelField], which is found by
// assignability. An alias keeps the constant's type exactly the one being
// looked for while giving it a Modelith name.
typedef ModelEnum = JsonEnum;

/// The json value for a single `enum` entry, for use on the entry.
///
/// Takes precedence over [ModelEnum.fieldRename] and [ModelEnum.valueField].
///
/// ```dart
/// enum Role {
///   @ModelValue('admin')
///   admin,
///   @ModelValue('member')
///   member,
/// }
/// ```
///
/// The value has to be a `String`, an `int` or `null`.
typedef ModelValue = JsonValue;
