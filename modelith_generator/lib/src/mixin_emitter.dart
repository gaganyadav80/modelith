import 'package:modelith_generator/src/class_shape.dart';
import 'package:modelith_generator/src/model_field_config.dart';
import 'package:modelith_generator/src/model_options.dart';

/// Emits `mixin _$Foo`, the only generated member that has to live *inside* the
/// class's interface: `props` satisfies `Equatable`, and `toJson()` spares the
/// developer a second glue line.
///
/// The mixin has no `on` clause — a mixin cannot be applied to the very class it
/// is constrained on — so members reach the instance through a single
/// `this as Foo` cast.
class MixinEmitter {
  const MixinEmitter({required this.shape, required this.options});

  final ClassShape shape;
  final ModelOptions options;

  String emit() {
    final members = <String>[
      if (options.equality) _props,
      if (options.equality && options.stringify != null) _stringify,
      if (options.serializable && options.createToJson) _toJson,
    ];

    final name = '_\$${shape.name}${shape.typeParameters}';
    if (members.isEmpty) {
      return 'mixin $name {}';
    }

    return 'mixin $name {\n${members.join('\n\n')}\n}';
  }

  String get _props {
    final fields = shape.declaredFields
        .where((field) => ModelFieldConfig.of(field).equality)
        .map((field) => field.displayName)
        .toList();

    if (fields.isEmpty) {
      return '  List<Object?> get props => const [];';
    }

    final values = fields.map((field) => 'self.$field').join(', ');
    return '  List<Object?> get props {\n'
        '    final self = this as ${shape.selfType};\n'
        '    return [$values];\n'
        '  }';
  }

  String get _stringify => '  bool? get stringify => ${options.stringify};';

  String get _toJson {
    final toJsonFunction = '_\$${shape.name}ToJson';
    if (!options.genericArgumentFactories) {
      return '  Map<String, dynamic> toJson() =>\n'
          '      $toJsonFunction(this as ${shape.selfType});';
    }

    final parameters = shape.element.typeParameters
        .map(
          (p) =>
              'Object? Function(${p.displayName} value) toJson${p.displayName}',
        )
        .join(', ');
    final arguments = shape.element.typeParameters
        .map((p) => 'toJson${p.displayName}')
        .join(', ');

    return '  Map<String, dynamic> toJson($parameters) =>\n'
        '      $toJsonFunction(this as ${shape.selfType}, $arguments);';
  }
}
