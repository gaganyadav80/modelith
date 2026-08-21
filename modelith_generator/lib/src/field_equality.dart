import 'package:analyzer/dart/element/type.dart';

/// How a field participates in generated `==` and `hashCode`.
///
/// The kind is decided from the field's *static* type at build time, so a
/// `String` field compiles down to `a == b` with no helper call and no runtime
/// type test. Only fields that genuinely need deep comparison reach into
/// [ModelEquality].
enum FieldEqualityKind {
  /// `a == b` — scalars, enums, records, functions, other models.
  direct,

  /// Order-sensitive deep comparison: `List`, `Iterable` and their subtypes.
  iterable,

  /// Order-insensitive deep comparison.
  set,

  /// Deep comparison by key.
  map,

  /// Static type is unknown (`dynamic`, `Object`, a type parameter), so the
  /// dispatch has to happen at runtime.
  dynamic_;

  /// Picks the kind for [type].
  factory FieldEqualityKind.of(DartType type) {
    if (type is DynamicType ||
        type is InvalidType ||
        type is TypeParameterType ||
        type.isDartCoreObject) {
      return FieldEqualityKind.dynamic_;
    }

    if (type is! InterfaceType) {
      return FieldEqualityKind.direct;
    }

    if (_isOrImplements(type, _isSet)) return FieldEqualityKind.set;
    if (_isOrImplements(type, _isMap)) return FieldEqualityKind.map;
    if (_isOrImplements(type, _isIterable)) return FieldEqualityKind.iterable;

    return FieldEqualityKind.direct;
  }

  /// The expression comparing `self.<name>` with `other.<name>`.
  String comparison(String name) => switch (this) {
    FieldEqualityKind.direct => 'self.$name == other.$name',
    FieldEqualityKind.iterable =>
      'ModelEquality.iterables(self.$name, other.$name)',
    FieldEqualityKind.set => 'ModelEquality.sets(self.$name, other.$name)',
    FieldEqualityKind.map => 'ModelEquality.maps(self.$name, other.$name)',
    FieldEqualityKind.dynamic_ =>
      'ModelEquality.objects(self.$name, other.$name)',
  };

  /// The expression contributing `self.<name>` to the hash.
  String hashValue(String name) => switch (this) {
    FieldEqualityKind.direct => 'self.$name',
    _ => 'ModelEquality.hashOf(self.$name)',
  };

  static bool _isOrImplements(
    InterfaceType type,
    bool Function(InterfaceType) test,
  ) => test(type) || type.allSupertypes.any(test);

  static bool _isSet(InterfaceType type) => type.isDartCoreSet;

  static bool _isMap(InterfaceType type) => type.isDartCoreMap;

  static bool _isIterable(InterfaceType type) =>
      type.isDartCoreIterable || type.isDartCoreList;
}
