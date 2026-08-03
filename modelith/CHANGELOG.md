## 0.1.0

- Initial release: `@Model` and `@ModelField` annotations, the `JsonModel`
  interface for nested models, the `$unset` sentinel used by generated
  `copyWith`, and the `ModelEquality` helpers backing generated `==`/`hashCode`.
- Equality is self-contained: no `Equatable` base class or mixin, and no
  dependency on `equatable` or `package:collection`.
