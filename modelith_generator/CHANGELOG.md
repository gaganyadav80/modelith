## 0.1.0

- Initial release: `ModelGenerator` and the `modelith` builder, producing json
  functions, a `copyWith` extension and the `_$Foo` mixin in a single part file.
- The mixin carries `==`, `hashCode`, `toString` and `toJson()`; equality is
  emitted field by field with the comparison picked from each field's static
  type at build time.
