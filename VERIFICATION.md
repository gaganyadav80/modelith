# Verification report (G1–G5)

Every check below was run against the installed versions on Dart 3.11.3, not
inferred from documentation.

## Naming

`pub.dev` availability was checked through `https://pub.dev/api/packages/<name>`
(404 = free; `freezed` returned 200 as a control):

| Candidate | Result | Rationale |
| --- | --- | --- |
| **`modelith` / `modelith_generator`** | 404 / 404 — **chosen** | "model" + "-ith"; short, pronounceable, reads like a monolith of model code generated from one annotation |
| `trimodel` / `trimodel_gen` | 404 | names the three unified features, but ages badly if a fourth is added |
| `modelweld` / `modelweld_generator` | 404 | evokes welding the three generators together; longer and harsher |

No collision with `freezed`, `json_serializable`, `built_value`,
`dart_mappable` or `copy_with_extension`.

## G1 — field subtype detection: **CONFIRMED**

`source_gen` 4.2.4 `TypeChecker.firstAnnotationOf` matches by assignability
(`isAssignableFrom` = `isExactly(element) || element.allSupertypes.any(...)`,
`lib/src/type_checker.dart:187`), and `ConstantReader.peek` resolves fields
through superclasses (`getFieldRecursive`, `lib/src/constants/reader.dart:262`).

`json_serializable` reads `JsonKey` with `firstAnnotationOf`
(`lib/src/utils.dart:24`), i.e. the assignable variant.

Empirical probe: a class annotated `@JsonSerializable()` with a field annotated
`@MyKey(name: 'renamed_alpha')`, where `class MyKey extends JsonKey`, generated

```dart
Probe _$ProbeFromJson(Map<String, dynamic> json) =>
    Probe(json['renamed_alpha'] as String, json['renamed_beta'] as String);
```

The subtype's inherited `name` was honoured identically to a native `@JsonKey`.
This is what lets `@ModelField` carry all json config. Confirmed again in the
example package: `@ModelField(name: 'access_token')` renames the key in both
directions.

## G2 — `JsonSerializableGenerator` is callable: **CONFIRMED**

`package:json_serializable/json_serializable.dart` exports
`JsonSerializableGenerator`. It is a `GeneratorForAnnotation<JsonSerializable>`
with

```dart
Iterable<String> generateForAnnotatedElement(
  Element element,
  ConstantReader annotation,
  BuildStep buildStep,
)
```

(`lib/src/json_serializable_generator.dart:57`), plus a public
`JsonSerializableGenerator({JsonSerializable? config, List<TypeHelper>? typeHelpers})`
constructor, and `JsonSerializable.fromJson(options.config)` for builder-option
parsing (used by their own `builder.dart`).

Passing a `ConstantReader` over a `@Model` constant works because the class
config is read by field name: `_valueForAnnotation` calls `reader.read('anyMap')`,
`reader.read('checked')`, … (`lib/src/utils.dart:59`). Note this uses `read`, not
`peek`, so **`@Model` must declare every mirrored field or generation throws** —
all 16 flags plus `converters` and `constructor` are declared on `@Model`.

Because `@Model` is *not* a `JsonSerializable` subtype, `json_serializable`'s own
builder does not fire on `@Model` classes: no double generation, and plain
`@JsonSerializable` classes elsewhere keep working.

## G3 — `copy_with_extension_gen` generator: **NOT PUBLICLY EXPORTED → option (b) chosen**

`copy_with_extension_gen` 15.0.1 exports exactly one symbol:

```dart
export 'src/builder_factory.dart' show copyWith;
```

`CopyWithGenerator` and the `Settings` it requires live in `lib/src/` and are
*technically* callable (`generateForAnnotatedElement(Element, ConstantReader,
BuildStep)` returning `Future<String>`), but only through an implementation
import.

Reported before implementing; the decision was **(b) generate `copyWith`
ourselves**. Consequences:

* `copy_with_extension` and `copy_with_extension_gen` are **not** dependencies of
  either package — one less upstream to track, and no implementation import.
* `@ModelField` does not need to be a `CopyWithField` subtype; it carries its own
  `copyWith: false` flag instead.
* `@Model(copyWith: false)` is honoured exactly, which the subtype-trigger
  alternative could not have offered.
* We own the `copyWith` codegen: named-constructor targeting, the
  nullable-vs-omitted sentinel, private and excluded fields. Semantics are
  documented in the `modelith` README and covered by
  `example/test/copy_with_test.dart`.

## G4 — single output: **CONFIRMED**

The builder is a single `SharedPartBuilder([ModelGenerator(...)], 'modelith')`
with `applies_builders: ["source_gen|combining_builder"]`, so the shared part is
merged into one file. The example package has five inputs and produces exactly
five `.g.dart` files and nothing else; `opt_out_models.g.dart` holds three
models' json functions, extensions and mixins in one file.
`example/test/single_output_test.dart` asserts the 1:1 mapping and that each
generated file has a single `part of` and a single generator header.

## G5 — pinned versions

Resolved during verification (Dart SDK 3.11.3, Flutter 3.41.5):

| Package | Resolved | Constraint used |
| --- | --- | --- |
| `analyzer` | 13.3.0 | `^13.3.0` |
| `build` | 4.0.9 | `^4.0.0` |
| `build_runner` | 2.15.3 | `^2.15.0` (dev) |
| `build_test` | 3.5.18 | `^3.0.0` (dev) |
| `equatable` | 2.1.0 | `^2.1.0` |
| `json_annotation` | 4.12.0 | `^4.12.0` |
| `json_serializable` | 6.14.1 | `^6.14.0` |
| `meta` | 1.19.0 | `^1.19.0` |
| `source_gen` | 4.2.4 | `^4.2.0` |
| `dart_style` | 3.1.12 | transitive (output formatting) |
| `copy_with_extension` / `copy_with_extension_gen` | 15.0.1 | **not depended on** (see G3) |

## Additional findings not in the original gates

### The `_$Foo` mixin cannot use an `on` clause

`mixin _$Foo on Foo` is illegal for the class it is generated for:

```
error - 'Foo' can't be a superinterface of itself: _$Foo, Foo. - recursive_interface_inheritance
```

`mixin _$Foo implements Foo` fails the same way. The mixin therefore has no
superclass constraint and reaches the instance through one cast per member:

```dart
mixin _$Foo {
  List<Object?> get props {
    final self = this as Foo;
    return [self.bar];
  }

  Map<String, dynamic> toJson() => _$FooToJson(this as Foo);
}
```

A side benefit: no field types are written into the mixin, so import prefixes
and private types cannot break it.

### `EquatableMixin` is deprecated

`equatable` 2.1.0 declares `abstract mixin class Equatable` and deprecates
`EquatableMixin` ("use Equatable as a mixin instead"). The documented header is
`class Foo with Equatable, _$Foo`, which analyzes clean; `EquatableMixin` would
raise `deprecated_member_use`. Deep collection comparison for lists, sets and
maps is built into `equatable`, so no extra flag was added.

### Nested models need `implements JsonModel`

`json_serializable` decides whether a nested type can be serialized by looking
for a `toJson` method on the type or its supertypes, falling back to
`jsonSerializableChecker.firstAnnotationOfExact` on that type
(`lib/src/type_helpers/json_helper.dart:229`). The exact-type check means a
`@Model` subtype trick cannot help here, and the nested model's `toJson()` lives
in a mixin whose part file does not exist yet while the outer model is being
generated — a genuine phase-ordering problem, not a caching artefact (it
reproduced on a clean build, a rebuild, and after touching the outer file).

Fix: `modelith` ships `abstract interface class JsonModel { Map<String, dynamic> toJson(); }`.
A nested model adds `implements JsonModel` to its header — the generated mixin
already satisfies it, so no body is written. The generator pre-checks fields
(including type arguments, so `List<Address>` is covered) and fails with

> Field `address` of `UserModel` embeds the model `AddressModel`, whose
> `toJson()` comes from a mixin that is not generated yet. Add
> `implements JsonModel` to the `AddressModel` declaration.

instead of the upstream "Could not generate `toJson` code" message. The
deserialize direction needs nothing: `json_serializable` finds the hand-written
`fromJson` constructor by name.

### Generics

`@Model(genericArgumentFactories: true)` on `class PageModel<T>` produces a
`extension $PageModelCopyWith<T> on PageModel<T>`, a `mixin _$PageModel<T>`, and
a `toJson(Object? Function(T value) toJsonT)` matching the generated
`_$PageModelToJson`. Covered by `example/test/generic_test.dart`.

### `FieldElement.isSynthetic` is gone in analyzer 13

Getter-induced fields are filtered with `isOriginDeclaration` instead.
