import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:modelith_generator/src/class_shape.dart';
import 'package:modelith_generator/src/model_field_config.dart';
import 'package:modelith_generator/src/model_options.dart';
import 'package:source_gen/source_gen.dart';

/// Emits `extension $FooCopyWith on Foo`.
///
/// The extension re-invokes the model's own constructor, so the generated code
/// stays readable and can be pasted into the class by hand if the generator is
/// ever dropped.
///
/// A parameter for a non-nullable field is typed (`String? name`) and `null`
/// means "keep the current value". A parameter for a nullable field takes
/// `Object?` defaulting to `$unset`, which is the only way to tell an explicit
/// `null` apart from an omitted argument.
class CopyWithEmitter {
  const CopyWithEmitter({required this.shape, required this.options});

  final ClassShape shape;
  final ModelOptions options;

  String emit() {
    final constructor = _constructor;
    final parameters = constructor.formalParameters;
    if (parameters.isEmpty) {
      throw InvalidGenerationSourceError(
        'The constructor used by `copyWith` on `${shape.name}` has no '
        'parameters. Add parameters or use `@Model(copyWith: false)`.',
        element: shape.element,
      );
    }

    final invocationName = options.constructor == null
        ? shape.selfType
        : '${shape.selfType}.${options.constructor}';

    final declarations = <String>[];
    final positionalArguments = <String>[];
    final namedArguments = <String>[];

    for (final parameter in parameters) {
      final name = parameter.displayName;
      final field = shape.readableField(name);

      if (field == null) {
        if (parameter.isRequired) {
          throw InvalidGenerationSourceError(
            'Constructor parameter `$name` of `${shape.name}` does not match '
            'any readable field, so `copyWith` cannot carry its value over. '
            'Rename it to match a field or use `@Model(copyWith: false)`.',
            element: shape.element,
          );
        }
        continue;
      }

      final replaceable =
          !name.startsWith('_') && ModelFieldConfig.of(field).copyWith;
      final argument = replaceable
          ? _Parameter(name: name, type: field.type)
          : null;

      if (argument != null) {
        declarations.add(argument.declaration);
      }

      final value = argument?.value ?? name;
      if (parameter.isPositional) {
        positionalArguments.add(value);
      } else {
        namedArguments.add('$name: $value');
      }
    }

    if (declarations.isEmpty) {
      throw InvalidGenerationSourceError(
        'Every field of `${shape.name}` is excluded from `copyWith`, so the '
        'generated method would do nothing. Use `@Model(copyWith: false)`.',
        element: shape.element,
      );
    }

    final arguments = [
      ...positionalArguments,
      ...namedArguments,
    ].join(',\n    ');

    return 'extension \$${shape.name}CopyWith${shape.typeParameters} on ${shape.selfType} {\n'
        '  ${shape.selfType} copyWith({\n'
        '    ${declarations.join(',\n    ')},\n'
        '  }) => $invocationName(\n'
        '    $arguments,\n'
        '  );\n'
        '}';
  }

  ConstructorElement get _constructor {
    final name = options.constructor;
    final constructor = name == null
        ? shape.element.unnamedConstructor
        : shape.element.getNamedConstructor(name);

    if (constructor == null) {
      throw InvalidGenerationSourceError(
        name == null
            ? 'Class `${shape.name}` has no unnamed constructor, which '
                  '`copyWith` needs. Point `@Model(constructor: ...)` at one.'
            : 'Class `${shape.name}` has no constructor named `$name`.',
        element: shape.element,
      );
    }

    return constructor;
  }
}

/// One replaceable `copyWith` parameter.
class _Parameter {
  const _Parameter({required this.name, required this.type});

  final String name;
  final DartType type;

  /// Nullable and type-parameter typed fields cannot use `null` as the "keep
  /// the current value" marker, because `null` is a legitimate new value.
  bool get _needsSentinel =>
      type.nullabilitySuffix != NullabilitySuffix.none ||
      type is DynamicType ||
      type is TypeParameterType;

  String get declaration => _needsSentinel
      ? 'Object? $name = \$unset'
      : '${type.getDisplayString()}? $name';

  String get value => _needsSentinel
      ? '$name == \$unset ? this.$name : $name as ${type.getDisplayString()}'
      : '$name ?? this.$name';
}
