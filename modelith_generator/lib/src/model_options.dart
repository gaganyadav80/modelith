import 'package:source_gen/source_gen.dart';

/// The Modelith-owned flags read off a `@Model` annotation.
///
/// Everything else on `@Model` mirrors `JsonSerializable` and is forwarded to
/// `json_serializable` untouched.
class ModelOptions {
  const ModelOptions({
    required this.serializable,
    required this.copyWith,
    required this.equality,
    required this.createToJson,
    required this.genericArgumentFactories,
    required this.stringify,
    required this.constructor,
  });

  factory ModelOptions.read(ConstantReader annotation) => ModelOptions(
    serializable: annotation.peek('serializable')?.boolValue ?? true,
    copyWith: annotation.peek('copyWith')?.boolValue ?? true,
    equality: annotation.peek('equality')?.boolValue ?? true,
    createToJson: annotation.peek('createToJson')?.boolValue ?? true,
    genericArgumentFactories:
        annotation.peek('genericArgumentFactories')?.boolValue ?? false,
    stringify: annotation.peek('stringify')?.boolValue ?? true,
    constructor: annotation.peek('constructor')?.stringValue,
  );

  final bool serializable;
  final bool copyWith;
  final bool equality;

  /// `@Model(createToJson: ...)`, forwarded from `JsonSerializable`.
  ///
  /// Decides whether the `_$Foo` mixin can expose `toJson()`.
  final bool createToJson;

  /// `@Model(genericArgumentFactories: ...)`, forwarded from
  /// `JsonSerializable`.
  ///
  /// Changes the signature of the generated `_$FooToJson`, and therefore of the
  /// `toJson()` wrapper.
  final bool genericArgumentFactories;

  /// Whether to generate `toString`. Only meaningful with [equality].
  final bool stringify;

  /// Constructor used for `copyWith` (and by `json_serializable` for
  /// `fromJson`). `null` means the unnamed constructor.
  final String? constructor;
}
