import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:modelith/modelith.dart';
import 'package:source_gen/source_gen.dart';

/// The Modelith-owned flags read off a `@ModelField` annotation.
///
/// The json options on the same annotation are read by `json_serializable`
/// itself — `ModelField` is a `JsonKey` subtype and `source_gen`'s annotation
/// matching is assignability based.
class ModelFieldConfig {
  const ModelFieldConfig({required this.equality, required this.copyWith});

  /// Reads the annotation off [field], falling back to the annotation defaults
  /// for an unannotated field.
  factory ModelFieldConfig.of(FieldElement field) {
    final annotation = _checker.firstAnnotationOf(field);
    if (annotation is! DartObject) {
      return defaults;
    }

    final reader = ConstantReader(annotation);
    return ModelFieldConfig(
      equality: reader.peek('equality')?.boolValue ?? defaults.equality,
      copyWith: reader.peek('copyWith')?.boolValue ?? defaults.copyWith,
    );
  }

  static const defaults = ModelFieldConfig(equality: true, copyWith: true);

  static const _checker = TypeChecker.typeNamed(ModelField);

  final bool equality;
  final bool copyWith;
}
