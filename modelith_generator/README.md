# modelith_generator

Code generator for [`modelith`](../modelith). Add it as a dev dependency and run
`build_runner`; the annotations, the `with`-clause matrix and every option are
documented in the `modelith` README.

```yaml
dependencies:
  modelith: ^0.1.0

dev_dependencies:
  build_runner: ^2.15.0
  modelith_generator: ^0.1.0
```

## How it works

One `ModelGenerator extends GeneratorForAnnotation<Model>`, wired as a single
`SharedPartBuilder`, so source_gen's combining builder produces exactly one
`.g.dart` per input.

The generator orchestrates rather than reimplements:

1. Reads modelith's own flags off `@Model` (`serializable`, `copyWith`,
   `equality`, `stringify`, `constructor`).
2. If `serializable`, hands the `@Model` constant straight to
   `JsonSerializableGenerator.generateForAnnotatedElement`. This works because
   `@Model` mirrors `JsonSerializable`'s field names and `ConstantReader` reads
   by name — no subtyping and therefore no double generation from
   `json_serializable`'s own builder.
3. If `copyWith`, emits the `$FooCopyWith` extension from the target
   constructor's parameters.
4. Emits `mixin _$Foo` with `props`, an optional `stringify` override, and
   `toJson()`.

Per-field json config rides on `@ModelField` for free: it is a `JsonKey`
subtype, and source_gen's annotation matching is assignability based.

Builder options are the `json_serializable` options and become the project-wide
json defaults:

```yaml
targets:
  $default:
    builders:
      modelith_generator:modelith:
        options:
          field_rename: snake
```

`VERIFICATION.md` records the empirical checks behind these claims and the
resolved upstream versions.
