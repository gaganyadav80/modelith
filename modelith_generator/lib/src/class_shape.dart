import 'package:analyzer/dart/element/element.dart';

/// Shared naming/type-parameter helpers for the class being generated for.
class ClassShape {
  const ClassShape(this.element);

  final ClassElement element;

  String get name => element.displayName;

  /// `<T, U>` for `class Foo<T extends num, U>`, or `''`.
  String get typeArguments => _typeParameters(withBounds: false);

  /// `<T extends num, U>` for `class Foo<T extends num, U>`, or `''`.
  String get typeParameters => _typeParameters(withBounds: true);

  /// `Foo<T, U>` — the class as it should be written in generated code.
  String get selfType => '$name$typeArguments';

  /// All non-static, non-synthetic fields declared by the class.
  ///
  /// Superclass fields are deliberately out of scope for v1 — see the README.
  Iterable<FieldElement> get declaredFields => element.fields.where(
    (field) => !field.isStatic && field.isOriginDeclaration,
  );

  /// The field or getter named [memberName], searching this class and then its
  /// superclasses.
  FieldElement? readableField(String memberName) {
    for (final field in declaredFields) {
      if (field.displayName == memberName) {
        return field;
      }
    }

    for (final supertype in element.allSupertypes) {
      for (final field in supertype.element.fields) {
        if (field.isStatic || !field.isOriginDeclaration) {
          continue;
        }
        if (field.displayName == memberName) {
          return field;
        }
      }
    }

    return null;
  }

  String _typeParameters({required bool withBounds}) {
    final parameters = element.typeParameters;
    if (parameters.isEmpty) {
      return '';
    }

    final rendered = parameters
        .map((p) => withBounds ? p.displayString() : p.displayName)
        .join(', ');

    return '<$rendered>';
  }
}
