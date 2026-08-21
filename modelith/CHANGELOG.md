## 0.1.0

- Initial release: `@Model`, `@ModelField`, `@ModelEnum` and `@ModelValue`
  annotations, the `$unset` sentinel used by generated `copyWith`, and the
  `ModelEquality` helpers backing generated `==`/`hashCode`.
- A serializable model hand-writes both json lines (`fromJson` factory and
  `toJson()`). Keeping `toJson()` in the class body rather than the generated
  mixin is what lets a model be nested in another model with no marker interface.
- Equality is self-contained: no `Equatable` base class or mixin, and no
  dependency on `equatable` or `package:collection`.
- Fields inherited through `extends` and `with` take part in `==`, `hashCode`
  and `toString`, superclass-first, and honour `@ModelField(equality: false)`
  wherever they are declared.
- `ModelField` implements `JsonKey` and declares every json option itself rather
  than forwarding to `super`. `json_serializable` reads `fromJson`/`toJson` with
  a non-recursive `DartObject.getField`, so inherited values would be silently
  ignored.
- `ModelEnum` and `ModelValue` are aliases of `JsonEnum` and `JsonValue`, not
  subtypes: `json_serializable` matches the entry annotation by exact type, so a
  subtype would be dropped without an error. `json_annotation` therefore never
  has to appear in a consumer's imports or `pubspec.yaml`.
