/// `package:build` entry point for `modelith_generator`.
///
/// Not meant to be imported by hand-authored code — see `build.yaml`.
library;

import 'package:build/build.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:modelith_generator/src/model_generator.dart';
import 'package:source_gen/source_gen.dart';

/// Builder factory for `modelith`.
///
/// Builder options are the `json_serializable` options: they become the
/// project-wide json defaults that a `@Model` annotation can override
/// per class.
Builder modelith(BuilderOptions options) {
  final JsonSerializable jsonConfig;
  try {
    jsonConfig = JsonSerializable.fromJson(options.config);
  } on CheckedFromJsonException catch (e) {
    throw StateError(
      'Could not parse the options provided for `modelith`. '
      '${e.key == null ? '' : 'There is a problem with "${e.key}". '}'
      '${e.message ?? e.innerError ?? ''}',
    );
  }

  return SharedPartBuilder([
    ModelGenerator(jsonConfig: jsonConfig),
  ], 'modelith');
}
