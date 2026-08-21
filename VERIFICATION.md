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

**Caveat — inheriting the options is not enough.** Detection and
`ConstantReader.read` are assignability/super aware, but `fromJson` and `toJson`
are not read through `ConstantReader`: `type_helper_ctx.dart:140` calls
`DartObject.getField(paramName)` directly, and
`DartObjectImpl.getField` is a flat lookup into `GenericState.fields`
(`analyzer .../constant/value.dart:549`). Options passed to a superclass
constructor live under the `(super)` pseudo-field
(`GenericState.SUPERCLASS_FIELD`), which that lookup never visits, so a
`super.fromJson` parameter is silently dropped from the generated code — no
error, no warning, and a wire-type mismatch that only fails at runtime.

`ModelField` therefore **implements** `JsonKey` and declares every option as its
own field. `readValue` was never affected (it is read via `ConstantReader`),
which is why the two bugs presented separately. Regression coverage:
`modelith_generator/test/model_generator_test.dart` ("applies the per-field
fromJson and toJson functions") and `example/lib/converter_model.dart`.

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
merged into one file. The example package has six inputs and produces exactly
six `.g.dart` files and nothing else; `opt_out_models.g.dart` holds three
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
| `equatable` | 2.1.0 | **not depended on** — dev-only, for the benchmark comparison |
| `json_annotation` | 4.12.0 | `^4.12.0` |
| `json_serializable` | 6.14.1 | `^6.14.0` |
| `meta` | 1.19.0 | `^1.19.0` |
| `source_gen` | 4.2.4 | `^4.2.0` |
| `dart_style` | 3.1.12 | transitive (output formatting) |
| `collection` | 1.19.1 | **not depended on** — dev-only, for the benchmark comparison |
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
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Foo || runtimeType != other.runtimeType) return false;
    final self = this as Foo;
    return self.bar == other.bar;
  }
}
```

Two side benefits: no field types are written into the mixin, so import prefixes
and private types cannot break it; and because the implicit constraint is
`Object`, overriding `==`/`hashCode`/`toString` here is legal — which is what
made dropping `Equatable` possible.

### `equatable` was dropped entirely

Two findings pushed equality out of `equatable` and into generated code:

1. `EquatableMixin` is deprecated in 2.1.0 ("use Equatable as a mixin instead";
   `abstract mixin class Equatable`), so the header would have been
   `class Foo with Equatable, _$Foo`.
2. `equatable`'s comparison helpers are **not reachable**. `equatable.dart`
   exports `src/equatable.dart`, `src/equatable_config.dart` and
   `src/equatable_mixin.dart`; `equals`, `mapPropsToHashCode` and
   `mapPropsToString` live in `src/equatable_utils.dart`, which nothing exports.
   Reusing them would need an implementation import — the thing rejected in G3.

Since the mixin has no `on` clause, its superclass constraint is `Object`, so it
can legally `@override` `==`, `hashCode` and `toString`, and in
`class Foo with _$Foo` it wins over `Object`. That removes `Equatable` from the
class header altogether: `with _$Foo` is the entire `with` clause, and
`modelith` has no `equatable` dependency.

`ModelEquality` in the runtime package carries the comparison, and
`FieldEqualityKind` in the generator picks the call from each field's **static**
type at build time — scalars compile to `a == b`, only collections and
`dynamic`/`Object`/type-parameter fields call a helper.

`DeepCollectionEquality` from `package:collection` was considered as the
replacement and rejected on measurements, not taste.
`example/benchmark/equality_benchmark.dart` (Dart 3.11.3, Apple Silicon, 300k
iterations, ns/op, median of three runs):

| Case | equatable | `DeepCollectionEquality` | modelith |
| --- | --- | --- | --- |
| `==`, scalar fields | ~24 | — | **~11** |
| `==`, list + set + map + nested list | ~545 | ~1450 | **~400** |
| `hashCode`, same collections | ~680–890 | ~420–570 | **~375–560** |

`DeepCollectionEquality` is ~3.5x slower than the generated code on deep `==`.
The generated code wins by doing less: compile-time dispatch instead of a runtime
`is Set`/`is Map`/`is Iterable` ladder per field, no props list allocated per
comparison, `O(n)` set/map matching through hash lookup where `equatable` scans
`O(n²)` (`b.any((e) => objectsEquals(element, e))`), a single lockstep walk for
lazy iterables where `equatable` uses `elementAt` in a loop, and no sorting
inside `hashCode` (`equatable`'s `_combine` sorts sets and map keys on every
call).

Two deliberate behaviour differences from `equatable`:

* `hashCode` uses `Object.hash`, which the SDK documents as *not* stable across
  runs. That is the `hashCode` contract; only golden tests asserting literal
  hashes are affected.
* A `List` and a `Set` holding the same elements are not equal. `equatable`'s
  `iterableEquals` only guards this with an `assert`, so in release mode it
  reports them equal; `ModelEquality.objects` checks the container kind from both
  sides.

### `toJson()` is hand-written, not emitted into the mixin

`json_serializable` decides whether a nested type can be serialized by looking
for a `toJson` method on the type or its supertypes, falling back to
`jsonSerializableChecker.firstAnnotationOfExact` on that type
(`lib/src/type_helpers/json_helper.dart:229`). The exact-type check means a
`@Model` subtype trick cannot help here.

A `toJson()` emitted into `mixin _$Foo` therefore breaks every nested model: the
mixin's part file does not exist yet while the **outer** model is being
generated, so the member is unresolvable and the build fails with

> Could not generate `toJson` code for `address` because of type `AddressModel`.

This is a genuine phase-ordering problem, not a caching artefact — it reproduced
on a clean build, a rebuild, and after touching the outer file. It also hit
models outside modelith: a plain `@JsonSerializable` class with a `@Model` field
got the same message with no modelith code in the loop to explain it.

A marker interface (`implements JsonModel`) was tried first and rejected: it made
"is this model nestable" a property of the *nested* class's header, so adding a
field to one model could require editing an unrelated file, and it needed a
pre-check in the generator purely to translate the upstream message.

Fix: the mixin never emits `toJson()`. Each serializable model declares it in the
class body next to the `fromJson` factory:

```dart
factory Foo.fromJson(Map<String, dynamic> json) => _$FooFromJson(json);

Map<String, dynamic> toJson() => _$FooToJson(this);
```

That is a real declaration in the class element, so `json_serializable` resolves
it in any generation order, from any outer model, `@Model` or not. Cost is one
line per model; `JsonModel` and the pre-check are gone. Covered by
`serializes a field whose type is another model` in
`modelith_generator/test/model_generator_test.dart` and by `example/lib/user_model.dart`.
The deserialize direction needed nothing either way: `json_serializable` finds the
hand-written `fromJson` constructor by name.

### Generics

`@Model(genericArgumentFactories: true)` on `class PageModel<T>` produces a
`extension $PageModelCopyWith<T> on PageModel<T>` and a `mixin _$PageModel<T>`.
The hand-written `toJson` takes the per-argument encoder to match
`_$PageModelToJson`. Covered by `example/test/generic_test.dart`.

### `FieldElement.isSynthetic` is gone in analyzer 13

Getter-induced fields are filtered with `isOriginDeclaration` instead.

### Enum annotations have to be aliases, not subtypes

`ModelField implements JsonKey` works because `json_serializable` matches
annotations by assignability. Enums do not follow that rule: `enum_utils.dart`
reads the per-entry annotation with

```dart
const TypeChecker.typeNamed(JsonValue, inPackage: 'json_annotation')
    .firstAnnotationOfExact(field)
```

so a `class ModelValue implements JsonValue` would be **silently ignored** —
entries would fall back to their renamed names with no error to point at.
`ModelEnum` and `ModelValue` are therefore `typedef`s, which keeps the constant's
type exactly `JsonEnum` / `JsonValue`. Verified by `reads @ModelValue and
@ModelEnum off an enum a model holds` in
`modelith_generator/test/model_generator_test.dart`, and by
`example/lib/enum_model.g.dart`, where `@ModelValue('admin')` reaches the map.

`@JsonEnum(alwaysCreate: true)` is handled by a second generator upstream
(`JsonEnumGenerator`, exported from `package:json_serializable`), which
`json_serializable` merges with its class generator through a private
`_UnifiedGenerator` so a shared enum map is not defined twice. Modelith needed the
same merge, and gets it by having `ModelGenerator` walk both annotations itself
and pool the fragments in a `Set` — the per-class output is returned as an
`Iterable<String>` rather than one joined string precisely so that a duplicate
map collapses. Verified by `emits one enum map for two models over the same enum`
and by `example/lib/enum_model.g.dart`, where `_$RoleEnumMap` is asked for by two
models and `_$TierEnumMap` by two models plus `alwaysCreate`, and each is defined
once.
