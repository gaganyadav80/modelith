# modelith

One annotation for Dart data models. `@Model()` on a plain class generates
`fromJson`/`toJson`, `copyWith` and value equality — all into a single
`.g.dart` part file.

Two annotations exist and that is the whole API surface: `@Model()` on the class,
`@ModelField()` on a field. You never write `@JsonSerializable`, `@JsonKey`,
`@CopyWith` or a hand-rolled `props`.

```dart
import 'package:modelith/modelith.dart';

part 'address_model.g.dart';

@Model()
class AddressModel with Equatable, _$AddressModel implements JsonModel {
  const AddressModel({required this.city, required this.postcode});

  // The one required glue line — see "Why the fromJson line" below.
  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  @ModelField()
  final String city;

  @ModelField(name: 'post_code')
  final String? postcode;
}
```

```dart
const a = AddressModel(city: 'Lisbon', postcode: '1100-062');
final b = AddressModel.fromJson({'city': 'Lisbon', 'post_code': '1100-062'});

a == b;                       // true — Equatable + generated props
a.hashCode == b.hashCode;     // true
a.toJson();                   // {'city': 'Lisbon', 'post_code': '1100-062'}
a.copyWith(city: 'Porto');    // AddressModel(Porto, 1100-062)
a.copyWith(postcode: null);   // nullable fields really can be nulled
```

The class stays an ordinary Dart class: real fields, a real constructor, no
factory-redirect shell, no global mapper registry. Everything generated is
idiomatic Dart you could have typed yourself.

## Install

```yaml
dependencies:
  modelith: ^0.1.0

dev_dependencies:
  build_runner: ^2.15.0
  modelith_generator: ^0.1.0
```

```bash
dart run build_runner build
```

## What gets generated

For `class Foo`, into `foo.g.dart` and nothing else:

| Output | Shape | Comes from |
| --- | --- | --- |
| `_$FooFromJson` / `_$FooToJson` | top-level functions | `json_serializable`, invoked by the generator |
| `$FooCopyWith` | `extension` on `Foo` | modelith |
| `_$Foo` | `mixin` with `props`, `toJson()` and optionally `stringify` | modelith |

## Why the `fromJson` line cannot be generated

Mixins, extensions and part files can only *add to a library*. None of them can
declare a constructor or add a member to an existing class body, so `with _$Foo`
fundamentally cannot supply `Foo.fromJson`. Dart **augmentations** would allow
generating a factory in place, but they are not in stable Dart as of mid-2026.

`freezed` avoids the line only by turning your class into a redirect shell over a
generated implementation class — exactly the lock-in modelith rejects. So: one
hand-written `fromJson` factory per serializable model. `toJson()` needs no line;
it lives in the `_$Foo` mixin.

## The `with` clause

`_$Foo` is always generated (empty if you switched everything off), so the `with`
clause never changes shape as you toggle flags.

| Flags | Class header | `fromJson` line |
| --- | --- | --- |
| default (all on) | `class Foo with Equatable, _$Foo` | required |
| `equality: false` | `class Foo with _$Foo` | required |
| `serializable: false` | `class Foo with Equatable, _$Foo` | omit |
| `serializable: false, equality: false` | `class Foo with _$Foo` | omit |

`copyWith` is an extension, so it never affects the header.

### Nesting a model inside another model

Add `implements JsonModel` to any serializable model that is used as a *field of
another model*:

```dart
@Model()
class AddressModel with Equatable, _$AddressModel implements JsonModel { ... }
```

`JsonModel` declares nothing but `Map<String, dynamic> toJson()`, which the
generated mixin already satisfies — there is no extra code to write. It exists
because the nested model's `toJson()` lives in a mixin that does not exist yet at
the moment the *outer* model's json code is generated, and `json_serializable`
needs a resolvable declaration to find. The generator detects the missing
interface and tells you exactly what to add, so you will never debug this from a
cryptic upstream message.

## `@Model` options

Modelith's own flags:

| Option | Default | Effect |
| --- | --- | --- |
| `serializable` | `true` | `_$FooFromJson` / `_$FooToJson` + `toJson()` in the mixin |
| `copyWith` | `true` | the `$FooCopyWith` extension |
| `equality` | `true` | `props` in the mixin |
| `stringify` | `null` | overrides `Equatable.stringify` for this model |
| `constructor` | `null` | constructor used by `fromJson` **and** `copyWith` |

Everything else mirrors `JsonSerializable` by name and is forwarded verbatim:
`anyMap`, `checked`, `converters`, `createFactory`, `createToJson`,
`createFieldMap`, `createJsonKeys`, `createPerFieldToJson`, `createJsonSchema`,
`dateTimeUtc`, `disallowUnrecognizedKeys`, `explicitToJson`, `fieldRename`,
`genericArgumentFactories`, `ignoreUnannotated`, `includeIfNull`. Leaving one
`null` means "use the build configuration default".

Builder options in `build.yaml` are the `json_serializable` options, and set the
project-wide defaults a `@Model` can override:

```yaml
targets:
  $default:
    builders:
      modelith_generator:modelith:
        options:
          field_rename: snake
          explicit_to_json: true
```

## `@ModelField` options

`ModelField extends JsonKey`, so every json option is available here —
`name`, `defaultValue`, `includeIfNull`, `includeFromJson`, `includeToJson`,
`fromJson`, `toJson`, `readValue`, `required`, `disallowNullValue`,
`unknownEnumValue` — plus two of ours:

| Option | Default | Effect |
| --- | --- | --- |
| `equality` | `true` | `false` leaves the field out of `props` |
| `copyWith` | `true` | `false` drops the `copyWith` parameter; the value is always carried over |

```dart
@ModelField(name: 'device_id', equality: false, copyWith: false)
final String deviceId;
```

Annotating a field is optional — unannotated fields are serialized, compared and
copied with the defaults.

## `copyWith` semantics

* A **non-nullable** field gets a typed optional parameter (`String? city`).
  `null` means "keep the current value", which is unambiguous because the field
  can never hold `null`.
* A **nullable** field (or one typed by a type parameter) gets
  `Object? postcode = $unset`, so passing an explicit `null` clears the field
  while omitting the argument keeps it. The trade-off is that the argument is
  statically `Object?`: a wrong type is caught at runtime, not compile time. This
  is the same trade-off `freezed` and `copy_with_extension` make, and it only
  applies to nullable fields.
* Private fields and `@ModelField(copyWith: false)` fields are always carried
  over.

### Generic models

`@Model(genericArgumentFactories: true)` works, and the generated `toJson()`
takes the per-argument encoder so it matches `_$FooToJson`:

```dart
@Model(genericArgumentFactories: true)
class PageModel<T> with Equatable, _$PageModel<T> {
  const PageModel({required this.items, required this.total});

  factory PageModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PageModelFromJson(json, fromJsonT);

  @ModelField()
  final List<T> items;

  @ModelField()
  final int total;
}

page.toJson((address) => address.toJson());
```

Note the `_$PageModel<T>` in the `with` clause, and that such a model cannot
also `implements JsonModel` — that interface declares a zero-argument
`toJson()`.

## Known limitations

* **Superclass fields are not included.** `props` and `copyWith` cover the
  fields the class itself declares. A `copyWith` *constructor parameter* that
  maps to an inherited field is still handled, but inherited fields are not added
  to `props` on their own.
* **Aliased imports.** Generated `copyWith` parameter types are written without
  import prefixes, so a model whose field type is imported under a prefix
  (`import '...' as x;`) may not compile. Same limitation as
  `json_serializable`.
* **`equality: false` means identity equality.** Nothing else changes.
* **A generic model with `genericArgumentFactories` cannot be nested** in
  another model, because its `toJson()` takes arguments and `JsonModel` does not.
* **Enums** are not `@Model` targets; use `@JsonEnum` from `json_annotation` as
  usual.
* Deep collection comparison comes from `equatable` itself (lists, sets and maps
  in `props` compare by value); there is no flag to turn it off.

## Escape hatch

Dropping modelith later is mechanical, because nothing about your class is
generated:

1. Copy `_$FooFromJson` / `_$FooToJson`, the `$FooCopyWith` extension and the
   `_$Foo` mixin body out of `foo.g.dart` into a normal file.
2. Delete the `part` directive and the `@Model` / `@ModelField` annotations.
3. Inline the mixin's `props` and `toJson()` into the class body if you prefer.

The class itself does not change, so there is no structural rewrite and no
migration of call sites.

## Packages

| Package | Role |
| --- | --- |
| `modelith` | annotations + `Equatable`/`json_annotation` re-exports (runtime dependency) |
| `modelith_generator` | the builder (dev dependency) |
