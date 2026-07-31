/// One annotation for Dart data models: `fromJson`/`toJson`, `copyWith` and
/// value equality, all generated into a single part file.
///
/// Annotate a plain class with [Model], its fields with [ModelField], and add
/// the single `fromJson` factory line. See the README for the `with`-clause
/// matrix and the reason that one line cannot be generated.
library;

export 'package:equatable/equatable.dart' show Equatable, EquatableConfig;
export 'package:json_annotation/json_annotation.dart';

export 'src/json_model.dart';
export 'src/model.dart';
export 'src/model_field.dart';
export 'src/unset.dart';
