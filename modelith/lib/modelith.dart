/// One annotation for Dart data models: `fromJson`/`toJson`, `copyWith` and
/// value equality, all generated into a single part file.
///
/// Annotate a plain class with [Model], its fields with [ModelField], mix in the
/// generated `_$Foo`, and add the two json glue lines (`fromJson` factory and
/// `toJson()`). See the README for why those lines cannot be generated.
///
/// Enums a model holds are configured with [ModelEnum] and [ModelValue]. This
/// package is the only dependency any of it needs — `json_annotation` is a
/// transitive detail, re-exported here for the runtime helpers the generated
/// code calls.
library;

export 'package:json_annotation/json_annotation.dart';

export 'src/equality.dart';
export 'src/model.dart';
export 'src/model_enum.dart';
export 'src/model_field.dart';
export 'src/unset.dart';
