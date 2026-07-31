import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:json_serializable/json_serializable.dart';
import 'package:modelith/modelith.dart';
import 'package:modelith_generator/src/class_shape.dart';
import 'package:modelith_generator/src/copy_with_emitter.dart';
import 'package:modelith_generator/src/mixin_emitter.dart';
import 'package:modelith_generator/src/model_options.dart';
import 'package:modelith_generator/src/nested_model_check.dart';
import 'package:source_gen/source_gen.dart';

/// Generates everything a `@Model` class needs into a single shared part.
///
/// json is not reimplemented: the `@Model` constant is handed to
/// `JsonSerializableGenerator` as-is, which works because `@Model` mirrors
/// `JsonSerializable`'s field names and `ConstantReader` reads by name.
/// `copyWith` and `props` are emitted here.
class ModelGenerator extends GeneratorForAnnotation<Model> {
  ModelGenerator({JsonSerializable? jsonConfig})
    : _jsonGenerator = JsonSerializableGenerator(config: jsonConfig);

  final JsonSerializableGenerator _jsonGenerator;

  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement || element is EnumElement) {
      throw InvalidGenerationSourceError(
        '`@Model` can only be used on classes.',
        element: element,
      );
    }

    final options = ModelOptions.read(annotation);
    final shape = ClassShape(element);

    if (options.serializable) {
      NestedModelCheck(shape).run();
    }

    return <String>[
      if (options.serializable)
        ..._jsonGenerator.generateForAnnotatedElement(
          element,
          annotation,
          buildStep,
        ),
      if (options.copyWith)
        CopyWithEmitter(shape: shape, options: options).emit(),
      MixinEmitter(shape: shape, options: options).emit(),
    ].join('\n\n');
  }
}
