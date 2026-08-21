# modelith

One annotation for Dart data models. `@Model()` generates `fromJson`/`toJson`,
`copyWith`, `==`/`hashCode`/`toString` into a single `.g.dart`. No base class, no
equality mixin — `with _$Foo` is the whole class header.

| Directory | Package | Role |
| --- | --- | --- |
| `modelith/` | `modelith` | annotations, runtime dependency — **start with its [README](modelith/README.md)** |
| `modelith_generator/` | `modelith_generator` | the builder, dev dependency |
| `example/` | `modelith_example` | one file per feature with its generated output committed, plus an equality benchmark |

[`VERIFICATION.md`](VERIFICATION.md) records the empirical checks behind the
design: which upstream APIs are callable, why `copyWith` and equality are
generated here rather than delegated (with benchmark numbers), why `toJson()` is
hand-written rather than emitted into the mixin, and the resolved upstream
versions.

```bash
cd example && dart pub get && dart run build_runner build && dart test
```
