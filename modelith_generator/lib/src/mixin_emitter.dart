import 'package:analyzer/dart/element/element.dart';
import 'package:modelith_generator/src/class_shape.dart';
import 'package:modelith_generator/src/field_equality.dart';
import 'package:modelith_generator/src/model_field_config.dart';
import 'package:modelith_generator/src/model_options.dart';

/// Emits `mixin _$Foo`, the only generated code that has to live *inside* the
/// class's interface: `==`, `hashCode` and `toString`.
///
/// `toJson()` is deliberately *not* here. A `toJson()` living in the mixin is
/// invisible to `json_serializable` while an enclosing model is generated, so
/// every model embedding another model needed a marker interface to be
/// serializable. Declaring it in the class body instead removes that whole
/// failure mode.
///
/// The mixin has no `on` clause — a mixin cannot be applied to the very class it
/// is constrained on — so its superclass constraint is `Object`, which is
/// exactly what makes overriding `==` here legal. Members reach the instance
/// through a single `this as Foo` cast, which also keeps field type names (and
/// their import prefixes) out of the mixin.
class MixinEmitter {
  const MixinEmitter({required this.shape, required this.options});

  /// `Object.hash` accepts 20 positional values; `runtimeType` takes one slot.
  static const _maxHashArguments = 19;

  final ClassShape shape;
  final ModelOptions options;

  String emit() {
    final members = <String>[
      if (options.equality) _equals,
      if (options.equality) _hashCode,
      if (options.equality && options.stringify) _toString,
    ];

    final name = '_\$${shape.name}${shape.typeParameters}';
    if (members.isEmpty) {
      return 'mixin $name {}';
    }

    return 'mixin $name {\n${members.join('\n\n')}\n}';
  }

  /// The fields that define identity, superclass-first then declaration order.
  List<FieldElement> get _fields => shape.fields
      .where((field) => ModelFieldConfig.of(field).equality)
      .toList();

  String get _equals {
    final fields = _fields;
    final guard =
        '    if (identical(this, other)) return true;\n'
        '    if (other is! ${shape.selfType} || runtimeType != other.runtimeType) {\n'
        '      return false;\n'
        '    }';

    if (fields.isEmpty) {
      return '  @override\n'
          '  bool operator ==(Object other) {\n'
          '$guard\n'
          '    return true;\n'
          '  }';
    }

    final comparisons = fields
        .map(
          (field) =>
              FieldEqualityKind.of(field.type).comparison(field.displayName),
        )
        .join(' &&\n        ');

    return '  @override\n'
        '  bool operator ==(Object other) {\n'
        '$guard\n'
        '    final self = this as ${shape.selfType};\n'
        '    return $comparisons;\n'
        '  }';
  }

  String get _hashCode {
    final fields = _fields;
    if (fields.isEmpty) {
      return '  @override\n  int get hashCode => runtimeType.hashCode;';
    }

    final values = fields
        .map(
          (field) =>
              FieldEqualityKind.of(field.type).hashValue(field.displayName),
        )
        .toList();

    final combined = values.length <= _maxHashArguments
        ? 'Object.hash(runtimeType, ${values.join(', ')})'
        : 'ModelEquality.hashAllOf([runtimeType, ${values.join(', ')}])';

    return '  @override\n'
        '  int get hashCode {\n'
        '    final self = this as ${shape.selfType};\n'
        '    return $combined;\n'
        '  }';
  }

  String get _toString {
    final fields = _fields;
    if (fields.isEmpty) {
      return "  @override\n  String toString() => '${shape.name}()';";
    }

    final parts = fields
        .map((field) => '${field.displayName}: \${self.${field.displayName}}')
        .join(', ');

    return '  @override\n'
        '  String toString() {\n'
        '    final self = this as ${shape.selfType};\n'
        "    return '${shape.name}($parts)';\n"
        '  }';
  }
}
