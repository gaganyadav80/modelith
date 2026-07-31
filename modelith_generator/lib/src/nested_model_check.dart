import 'package:analyzer/dart/element/type.dart';
import 'package:modelith/modelith.dart';
import 'package:modelith_generator/src/class_shape.dart';
import 'package:source_gen/source_gen.dart';

/// Guards against the one non-obvious requirement Modelith cannot remove.
///
/// A nested model's `toJson()` lives in its generated `_$Foo` mixin, which does
/// not exist yet while the *outer* model is being generated. `json_serializable`
/// therefore cannot see it and fails with a message about unsupported types.
/// Implementing [JsonModel] gives it a resolvable declaration to find.
///
/// Without this check the developer gets that upstream message pointing at the
/// field; with it they get told exactly what to add and where.
class NestedModelCheck {
  const NestedModelCheck(this.shape);

  static const _modelChecker = TypeChecker.typeNamed(Model);
  static const _jsonModelChecker = TypeChecker.typeNamed(JsonModel);

  final ClassShape shape;

  void run() {
    for (final field in shape.declaredFields) {
      for (final type in _interfaceTypesIn(field.type)) {
        final element = type.element;
        if (!_modelChecker.hasAnnotationOf(element, throwOnUnresolved: false)) {
          continue;
        }
        if (_jsonModelChecker.isAssignableFrom(element) ||
            element.getMethod('toJson') != null) {
          continue;
        }

        throw InvalidGenerationSourceError(
          'Field `${field.displayName}` of `${shape.name}` embeds the model '
          '`${element.displayName}`, whose `toJson()` comes from a mixin that '
          'is not generated yet. Add `implements JsonModel` to the '
          '`${element.displayName}` declaration.',
          element: field,
        );
      }
    }
  }

  /// [type] plus every interface type reachable through its type arguments, so
  /// `List<Address>` and `Map<String, Address>` are checked too.
  Iterable<InterfaceType> _interfaceTypesIn(DartType type) {
    if (type is! InterfaceType) {
      return const [];
    }

    return [type, ...type.typeArguments.expand(_interfaceTypesIn)];
  }
}
