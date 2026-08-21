# modelith

One annotation for Dart data models. `@Model()` on a plain class generates
`fromJson`/`toJson`, `copyWith` and value equality — all into a single
`.g.dart` part file.

Four annotations exist and that is the whole API surface: `@Model()` on the class,
`@ModelField()` on a field, `@ModelEnum()` and `@ModelValue()` on an enum a model
holds. You never write `@JsonSerializable`, `@JsonKey`, `@JsonEnum`, `@CopyWith`,
a `props` list, or an `==`/`hashCode` pair — and `modelith` is the only import.
There is no base class and no equality mixin to remember — `with _$AddressModel`
is the whole header.

```dart
import 'package:modelith/modelith.dart';

part 'address_model.g.dart';

@Model()
class AddressModel with _$AddressModel {
  const AddressModel({required this.city, required this.postcode});

  // The two required glue lines — see "Why the json lines" below.
  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  Map<String, dynamic> toJson() => _$AddressModelToJson(this);

  @ModelField()
  final String city;

  @ModelField(name: 'post_code')
  final String? postcode;
}
```

```dart
const a = AddressModel(city: 'Lisbon', postcode: '1100-062');
final b = AddressModel.fromJson({'city': 'Lisbon', 'post_code': '1100-062'});

a == b;                       // true — generated field-by-field ==
a.hashCode == b.hashCode;     // true
a.toString();                 // AddressModel(city: Lisbon, postcode: 1100-062)
a.toJson();                   // {'city': 'Lisbon', 'post_code': '1100-062'}
a.copyWith(city: 'Porto');    // AddressModel(city: Porto, postcode: 1100-062)
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
| `_$Foo` | `mixin` with `==`, `hashCode` and `toString` | modelith |

Plus one `const _$TierEnumMap` per enum the library serializes — see
[Enums](#enums).

## Why the json lines cannot be generated

Mixins, extensions and part files can only *add to a library*. None of them can
declare a constructor or add a member to an existing class body, so `with _$Foo`
fundamentally cannot supply `Foo.fromJson`. Dart **augmentations** would allow
generating a factory in place, but they are not in stable Dart as of mid-2026.

`freezed` avoids the line only by turning your class into a redirect shell over a
generated implementation class — exactly the lock-in modelith rejects. So: one
hand-written `fromJson` factory per serializable model.

`toJson()` *could* live in the mixin, and deliberately does not. A `toJson()`
reached through a mixin is invisible to `json_serializable` while an **enclosing**
model is being generated — the mixin does not exist yet at that point — so every
model embedding another model would need a marker interface to be serializable at
all. Declaring `toJson()` in the class body costs one line and removes that whole
failure mode: nesting just works.

## The `with` clause

Always `with _$Foo`, whatever the flags say. `_$Foo` is generated even when every
feature is switched off (empty in that case), so the class header never has to
change as you toggle things — and there is no second mixin or base class to keep
in sync.

| Flags | Class header | json lines |
| --- | --- | --- |
| default (all on) | `class Foo with _$Foo` | `fromJson` + `toJson` |
| `equality: false` | `class Foo with _$Foo` | `fromJson` + `toJson` |
| `createFactory: false` | `class Foo with _$Foo` | `toJson` only |
| `createToJson: false` | `class Foo with _$Foo` | `fromJson` only |
| `serializable: false` | `class Foo with _$Foo` | omit both |
| `serializable: false, equality: false` | `class Foo with _$Foo` | omit both |

`copyWith` is an extension, so it never affects the header.

The mixin can declare `==` because it has **no `on` clause**: its implicit
superclass constraint is `Object`, so overriding `Object`'s members there is
legal, and in `class Foo with _$Foo` the mixin sits above `Object` in the
linearization and wins. The one thing to know: anything mixed in *after* `_$Foo`
that also defines `==` takes precedence.

### Nesting a model inside another model

Nothing to do. A model used as a *field of another model* needs no marker
interface and no base class — its hand-written `toJson()` is a real declaration
in the class body, which is exactly what `json_serializable` resolves when it
generates the outer model. The nested model does not even have to be a `@Model`
class; any type with a `toJson()` and a `fromJson` factory works, as always.

## `@Model` options

Modelith's own flags:

| Option | Default | Effect |
| --- | --- | --- |
| `serializable` | `true` | `_$FooFromJson` / `_$FooToJson` |
| `copyWith` | `true` | the `$FooCopyWith` extension |
| `equality` | `true` | `props` in the mixin |
| `stringify` | `true` | generate `toString` listing the equality fields; ignored when `equality` is `false` |
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

`ModelField implements JsonKey`, so every json option is available here —
`name`, `defaultValue`, `includeIfNull`, `includeFromJson`, `includeToJson`,
`fromJson`, `toJson`, `readValue`, `required`, `disallowNullValue`,
`explicitJsonNullWhenNonNullField`, `unknownEnumValue` — plus two of ours:

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

## Enums

An `enum` a model holds is configured with `@ModelEnum` on the declaration and
`@ModelValue` on the entries. Nothing else is needed — `json_annotation` stays
out of your imports and out of your `pubspec.yaml`.

```dart
@ModelEnum(fieldRename: FieldRename.snake)
enum Tier {
  freeTrial, // 'free_trial'
  @ModelValue('paid')
  paidMonthly, // 'paid'
}

@Model()
class MemberModel with _$MemberModel {
  // ...
  @ModelField(unknownEnumValue: Role.guest)
  final Role role;
}
```

| Option | Default | Effect |
| --- | --- | --- |
| `ModelEnum.fieldRename` | `FieldRename.none` | encodes the entries that carry no `@ModelValue` |
| `ModelEnum.valueField` | `null` | field of an enhanced enum to encode instead of the entry name |
| `ModelEnum.alwaysCreate` | `false` | emit `_$TierEnumMap` even when no model in the library holds the enum |
| `ModelValue(value)` | — | wire value of one entry: a `String`, an `int` or `null` |
| `ModelField.unknownEnumValue` | `null` | entry to decode to when the wire value is not in the map, instead of throwing |

An enum is not a `@Model` target — it has no fields to copy or compare. Its map
is generated into the part file of the library that declares it, so a file
holding only enums still needs its `part '<file>.g.dart';` when `alwaysCreate`
is on. Enums used by a model need nothing: the map rides along in the model's
part file, once, however many models hold it.

`ModelEnum` and `ModelValue` are aliases of `JsonEnum` and `JsonValue`, not
subtypes. `json_serializable` matches the entry annotation by exact type, so a
subtype would be skipped silently; an alias is the same constant under a
Modelith name, and `@JsonEnum` / `@JsonValue` keep working unchanged.

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

`@Model(genericArgumentFactories: true)` works; both json lines take a
per-argument codec, matching the generated functions they delegate to:

```dart
@Model(genericArgumentFactories: true)
class PageModel<T> with _$PageModel<T> {
  const PageModel({required this.items, required this.total});

  factory PageModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PageModelFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PageModelToJson(this, toJsonT);

  @ModelField()
  final List<T> items;

  @ModelField()
  final int total;
}

page.toJson((address) => address.toJson());
```

Note the `_$PageModel<T>` in the `with` clause. Such a model still cannot be
*nested* in another model: `json_serializable` calls a zero-argument `toJson()`
on a field, and this one takes the encoder.

## Equality

`==`, `hashCode` and `toString` are generated field by field. There is no base
class, no `props` list to allocate on every comparison, and no dependency on
`equatable` or `package:collection` — the comparison helpers live in `modelith`
itself, and the generator only calls one when a field's static type actually
needs it.

| Field type | Generated comparison |
| --- | --- |
| `String`, `int`, enum, record, another model | `self.x == other.x` |
| `List`, `Iterable` (and subtypes) | `ModelEquality.iterables(...)` — order-sensitive, recursive |
| `Set` (and subtypes) | `ModelEquality.sets(...)` — order-insensitive |
| `Map` (and subtypes) | `ModelEquality.maps(...)` — by key, values recursive |
| `dynamic`, `Object`, a type parameter | `ModelEquality.objects(...)` — dispatched at runtime |

So a model of scalars compiles to plain `==` chains with no helper call at all:

```dart
mixin _$SessionModel {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SessionModel || runtimeType != other.runtimeType) {
      return false;
    }
    final self = this as SessionModel;
    return self.token == other.token && self.lastSeenAt == other.lastSeenAt;
  }

  @override
  int get hashCode {
    final self = this as SessionModel;
    return Object.hash(runtimeType, self.token, self.lastSeenAt);
  }
  ...
}
```

The `runtimeType` check keeps equality symmetric across subclasses, matching what
`Equatable` did.

### Inherited fields

Fields the model inherits through `extends` and `with` take part in `==`,
`hashCode` and `toString` alongside the ones it declares itself. The base class
does not have to be a `@Model`, and `@ModelField(equality: false)` works on its
fields too:

```dart
abstract class RecordBase {
  const RecordBase({required this.id, required this.revision});

  final String id;

  @ModelField(equality: false)
  final int revision;
}

@Model()
class NoteModel extends RecordBase with Archivable, _$NoteModel { ... }

// NoteModel(id: n1, archived: false, title: Groceries)
```

The order is superclass-first, then declaration order — the same list, in the
same order, that `json_serializable` writes into `toJson`, so generated equality
and generated json always talk about the same class. A field redeclared lower in
the hierarchy keeps the position of its topmost declaration but takes the
options from its lowest one, so a `@ModelField` on an override wins.

Two kinds of field are left out, because generated code cannot read them:

* a field reached only through `implements` — an implementing class redeclares
  it anyway, and it is picked up from that declaration;
* a private field of a superclass in *another library*, which is out of scope
  for the generated part.

A computed getter is never a field, so it never joins equality. Put the value in
a field if it should count.

### Performance

`example/benchmark/equality_benchmark.dart` compares the generated code against
an `Equatable` model of the same shape and against
`DeepCollectionEquality` over a props list (Dart 3.11.3, Apple Silicon, 300k
iterations, ns per operation — run it yourself, absolute numbers vary):

| Case | equatable | `DeepCollectionEquality` | modelith |
| --- | --- | --- | --- |
| `==`, scalar fields | ~24 ns | — | **~11 ns** (~2.2x faster) |
| `==`, list + set + map + nested list | ~545 ns | ~1450 ns | **~400 ns** (~1.35x faster) |
| `hashCode`, same collections | ~680–890 ns | ~420–570 ns | **~375–560 ns** |

`DeepCollectionEquality` was rejected on these numbers: ~3.5x slower than the
generated code on the deep `==` case. Where the generated code wins is in doing
less work — compile-time dispatch instead of a runtime `is Set`/`is Map`/`is
Iterable` ladder per field, no props list allocation per comparison, `O(n)` set
and map matching through hash lookup instead of `O(n²)` scans, and no sorting
inside `hashCode`.

### Migrating from `Equatable`

Drop `Equatable` from the `with` clause and delete the `props` override; that is
the whole change. Comparison semantics are the same for lists, sets, maps and
nested collections. Two differences worth knowing:

* `foo is Equatable` is now `false`. Anything branching on that type needs
  updating.
* `hashCode` values differ, and (per `Object.hash`'s contract) are not stable
  across runs. Nothing should ever persist a `hashCode`, but a golden test that
  asserts a literal hash will need to go.

## Known limitations

* **`copyWith` is driven by the constructor, not by the field list.** Equality
  covers inherited fields on its own (see [Inherited fields](#inherited-fields)),
  but `copyWith` can only offer a parameter the chosen constructor accepts — an
  inherited field the constructor never takes is carried over untouched.
* **Aliased imports.** Generated `copyWith` parameter types are written without
  import prefixes, so a model whose field type is imported under a prefix
  (`import '...' as x;`) may not compile. Same limitation as
  `json_serializable`.
* **`equality: false` means identity equality**, and also suppresses the
  generated `toString`.
* **`hashCode` is not stable across program runs**, because it is built with
  `Object.hash`. That is the documented Dart contract for `hashCode`; only golden
  tests asserting literal hash values are affected.
* **Superclass `==` is replaced, not extended.** A `@Model` class that extends a
  base class with its own `==` gets the generated one instead.
* **A generic model with `genericArgumentFactories` cannot be nested** in
  another model, because its `toJson()` takes arguments and `json_serializable`
  calls a field's `toJson()` with none.
* **Enums** are not `@Model` targets; annotate them with `@ModelEnum` instead.
* **Deep collection comparison is always on** for list, set and map fields;
  there is no flag to fall back to identity comparison. A field typed by a custom
  collection class that does *not* implement `Iterable`/`Map` is compared with
  its own `==`.

## Escape hatch

Dropping modelith later is mechanical, because nothing about your class is
generated:

1. Copy `_$FooFromJson` / `_$FooToJson`, the `$FooCopyWith` extension and the
   `_$Foo` mixin body out of `foo.g.dart` into a normal file.
2. Delete the `part` directive and the `@Model` / `@ModelField` annotations.
3. Paste the mixin's `==`, `hashCode` and `toString` into the class body if you
   prefer. They are ordinary Dart; the only symbol they reference
   from this package is `ModelEquality`, and only for collection fields.

The class itself does not change, so there is no structural rewrite and no
migration of call sites.

## Packages

| Package | Role |
| --- | --- |
| `modelith` | annotations, equality helpers, `json_annotation` re-export — the only runtime dependency you add |
| `modelith_generator` | the builder (dev dependency) |
