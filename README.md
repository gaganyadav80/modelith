# modelith

One annotation for Dart data models. `@Model()` generates `fromJson`/`toJson`,
`copyWith` and value equality into a single `.g.dart`.

| Directory | Package | Role |
| --- | --- | --- |
| `modelith/` | `modelith` | annotations, runtime dependency — **start with its [README](modelith/README.md)** |
| `modelith_generator/` | `modelith_generator` | the builder, dev dependency |
| `example/` | `modelith_example` | five models with their generated output committed |

[`VERIFICATION.md`](VERIFICATION.md) records the empirical checks behind the
design: which upstream APIs are callable, why `copyWith` is generated here rather
than delegated, why nested models need `implements JsonModel`, and the resolved
upstream versions.

```bash
cd example && dart pub get && dart run build_runner build && dart test
```
