import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:json_serializable/json_serializable.dart';
import 'package:modelith/modelith.dart';
import 'package:modelith_generator/src/class_shape.dart';
import 'package:modelith_generator/src/copy_with_emitter.dart';
import 'package:modelith_generator/src/mixin_emitter.dart';
import 'package:modelith_generator/src/model_options.dart';
import 'package:source_gen/source_gen.dart';

/// Generates everything a Modelith library needs into a single shared part.
///
/// Two annotations feed one output: `@Model` on classes and `@ModelEnum` on
/// enums. Their code fragments go through one [Set], which is what keeps an
/// enum map single when the same enum is both annotated
/// `@ModelEnum(alwaysCreate: true)` and used by a model in the library — the
/// reason `json_serializable` unifies its own two generators the same way.
class ModelGenerator extends Generator {
  ModelGenerator({JsonSerializable? jsonConfig})
    : _classes = _ModelClassGenerator(jsonConfig: jsonConfig);

  final _ModelClassGenerator _classes;

  static const _enums = JsonEnumGenerator();

  @override
  String generate(LibraryReader library, BuildStep buildStep) {
    final fragments = <String>{};

    for (final annotated in library.annotatedWith(_classes.typeChecker)) {
      fragments.addAll(
        _classes.generateForAnnotatedElement(
          annotated.element,
          annotated.annotation,
          buildStep,
        ),
      );
    }

    for (final annotated in library.annotatedWith(_enums.typeChecker)) {
      fragments.addAll(
        _enums.generateForAnnotatedElement(
          annotated.element,
          annotated.annotation,
          buildStep,
        ),
      );
    }

    return fragments.join('\n\n');
  }

  /// Also the name source_gen writes into the generated header.
  @override
  String toString() => 'ModelGenerator';
}

/// The `@Model` half: json, `copyWith` and the `_$Foo` mixin for one class.
///
/// json is not reimplemented: the `@Model` constant is handed to
/// `JsonSerializableGenerator` as-is, which works because `@Model` mirrors
/// `JsonSerializable`'s field names and `ConstantReader` reads by name.
/// `copyWith` and equality are emitted here.
class _ModelClassGenerator extends GeneratorForAnnotation<Model> {
  _ModelClassGenerator({JsonSerializable? jsonConfig})
    : _jsonGenerator = JsonSerializableGenerator(config: jsonConfig);

  final JsonSerializableGenerator _jsonGenerator;

  /// Returns the fragments separately rather than one joined string, so that
  /// [ModelGenerator] can drop a duplicate — two models in a library that hold
  /// the same enum each ask for its map.
  @override
  Iterable<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement || element is EnumElement) {
      throw InvalidGenerationSourceError(
        '`@Model` can only be used on classes.',
        element: element,
      );
    }

    final options = ModelOptions.read(annotation);
    final shape = ClassShape(element);

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
    ];
  }
}
