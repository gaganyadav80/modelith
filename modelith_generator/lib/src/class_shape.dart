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

  /// Every non-static, non-synthetic field the class holds — its own and the
  /// ones it inherits through `extends` and `with` — superclass-first.
  ///
  /// A field keeps the position of its topmost declaration but is represented
  /// by its lowest one, so a `@ModelField` on an override wins. This is the
  /// same set and order `json_serializable` serializes, which is what keeps
  /// generated `==` and generated json talking about the same class.
  ///
  /// Fields reached only through `implements` are excluded: an implementing
  /// class has to redeclare them itself, so they arrive via its own
  /// declarations or not at all.
  Iterable<FieldElement> get fields {
    final byName = <String, FieldElement>{};

    for (final holder in _hierarchy) {
      for (final field in holder.fields) {
        if (field.isStatic || !field.isOriginDeclaration) {
          continue;
        }

        // A private field of another library is out of scope for the generated
        // part, so no generated member can read it.
        if (field.isPrivate && field.library != element.library) {
          continue;
        }

        byName[field.displayName] = field;
      }
    }

    return byName.values;
  }

  /// The field named [memberName] on the class, on anything it inherits from,
  /// or on anything it implements.
  ///
  /// Wider than [fields] on purpose: this answers "what type does this
  /// constructor parameter carry", and an interface declaration is a fine
  /// answer to that even though it is no part of the class's own state.
  FieldElement? readableField(String memberName) {
    for (final field in fields) {
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

  /// The class and everything it inherits state from, superclass-first:
  /// the topmost superclass, its mixins, ..., this class's mixins, this class.
  ///
  /// The order is the one Dart resolves members in, so walking it and letting
  /// later entries overwrite earlier ones lands on the declaration that
  /// actually runs.
  Iterable<InterfaceElement> get _hierarchy {
    final chain = <InterfaceElement>[];
    final visited = <InterfaceElement>{};

    for (InterfaceElement? current = element; current != null;) {
      if (!visited.add(current)) {
        break;
      }

      chain.add(current);
      chain.addAll(current.mixins.reversed.map((mixin) => mixin.element));

      final supertype = current.supertype;
      current = supertype == null || supertype.isDartCoreObject
          ? null
          : supertype.element;
    }

    return chain.reversed;
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
