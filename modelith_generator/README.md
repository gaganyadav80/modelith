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

One `ModelGenerator`, wired as a single `SharedPartBuilder`, so source_gen's
combining builder produces exactly one `.g.dart` per input. It covers both
annotations that generate code — `@Model` on classes and `@ModelEnum` on enums —
and pools their output in one `Set` of code fragments. That is what keeps an
enum map single when the same enum is annotated `@ModelEnum(alwaysCreate: true)`
*and* held by a model, or held by several models; `json_serializable` unifies
its own two generators for the same reason.

For a `@Model` class the generator orchestrates rather than reimplements:

1. Reads modelith's own flags off `@Model` (`serializable`, `copyWith`,
   `equality`, `stringify`, `constructor`).
2. If `serializable`, hands the `@Model` constant straight to
   `JsonSerializableGenerator.generateForAnnotatedElement`. This works because
   `@Model` mirrors `JsonSerializable`'s field names and `ConstantReader` reads
   by name — no subtyping and therefore no double generation from
   `json_serializable`'s own builder.
3. If `copyWith`, emits the `$FooCopyWith` extension from the target
   constructor's parameters.
4. Emits `mixin _$Foo` with `==`, `hashCode` and an optional `toString`. The
   mixin has no `on` clause, so its superclass constraint is `Object` — which is
   what makes overriding `==` there legal. `toJson()` is left to the class body
   on purpose: a mixin member is unresolvable to `json_serializable` while an
   enclosing model is generated, which would break every nested model.

Equality is emitted field by field, with the comparison chosen from each field's
*static* type at build time (`field_equality.dart`): scalars become `a == b`,
collections call the matching `ModelEquality` helper, and only `dynamic` /
`Object` / type-parameter fields pay for runtime dispatch. Nothing allocates a
props list per comparison.

The field list `class_shape.dart` walks is `extends` and `with`, superclass-
first, so equality covers inherited state and lands in the same order
`json_serializable` writes `toJson` in. Interfaces are skipped — an implementing
class redeclares the member anyway — as is a superclass's private field from
another library, which the generated part cannot name.

Per-field json config rides on `@ModelField` for free: it implements `JsonKey`,
and source_gen's annotation matching is assignability based. `ModelField`
re-declares every `JsonKey` option as its own field instead of forwarding to a
superclass, because `json_serializable` reads `fromJson`/`toJson` with
`DartObject.getField`, which does not walk the analyzer's `(super)`
pseudo-field.

Enum maps come from `json_serializable`'s own `JsonEnumGenerator`, and
`@ModelEnum` / `@ModelValue` are aliases of `@JsonEnum` / `@JsonValue` rather
than subtypes. The entry annotation is looked up with `firstAnnotationOfExact`,
so a subtype would be dropped with no error — the one place where the
assignability trick behind `ModelField` does not apply.

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
