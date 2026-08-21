import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:modelith_generator/builder.dart';
import 'package:test/test.dart';

/// Builds [source] as `pkg|lib/model.dart` and returns the single generated
/// part, or the build errors when generation failed.
///
/// [otherLibrary], when given, is written to `pkg|lib/other.dart` and imported
/// by `model.dart` — the only way to exercise anything that turns on the
/// declaring library, such as a private inherited field.
Future<_Generated> _generate(String source, {String? otherLibrary}) async {
  final readerWriter = TestReaderWriter(
    rootPackage: 'pkg',
    flattenOutput: true,
  );
  await readerWriter.testing.loadIsolateSources();

  final result = await testBuilder(
    modelith(BuilderOptions.empty),
    {
      'pkg|lib/model.dart':
          "import 'package:modelith/modelith.dart';\n"
          "${otherLibrary == null ? '' : "import 'other.dart';\n"}"
          "part 'model.g.dart';\n"
          '$source',
      if (otherLibrary != null)
        'pkg|lib/other.dart':
            "import 'package:modelith/modelith.dart';\n$otherLibrary",
    },
    onLog: (_) {},
    readerWriter: readerWriter,
    flattenOutput: true,
  );

  final outputs = result.outputs.toList();
  if (!result.succeeded) {
    return _Generated(part: null, errors: result.errors.join('\n'));
  }

  expect(outputs, hasLength(1), reason: 'expected exactly one part file');
  return _Generated(
    part: result.readerWriter.testing.readString(outputs.single),
    errors: '',
  );
}

void main() {
  test('emits json, copyWith and the mixin into one part', () async {
    final generated = await _generate('''
@Model()
class Foo with _\$Foo {
  const Foo({required this.bar, this.baz});

  factory Foo.fromJson(Map<String, dynamic> json) => _\$FooFromJson(json);

  Map<String, dynamic> toJson() => _\$FooToJson(this);

  @ModelField(name: 'bar_value')
  final String bar;

  @ModelField(equality: false, copyWith: false)
  final int? baz;
}
''');

    final part = generated.part!;
    expect(part, contains('Foo _\$FooFromJson('));
    expect(part, contains("'bar_value': instance.bar"));
    expect(part, contains('extension \$FooCopyWith on Foo {'));
    expect(part, contains('mixin _\$Foo {'));
    expect(part, contains('bool operator ==(Object other)'));
    expect(part, contains('return self.bar == other.bar;'));
    expect(part, contains('Object.hash(runtimeType, self.bar)'));
    expect(part, contains("return 'Foo(bar: \${self.bar})';"));
    expect(part, contains('baz: baz'));
  });

  test('keeps toJson out of the mixin', () async {
    final generated = await _generate('''
@Model()
class Foo with _\$Foo {
  const Foo(this.bar);

  factory Foo.fromJson(Map<String, dynamic> json) => _\$FooFromJson(json);

  Map<String, dynamic> toJson() => _\$FooToJson(this);

  final String bar;
}
''');

    final mixinBody = generated.part!.split('mixin _\$Foo {').last;
    expect(mixinBody, isNot(contains('toJson')));
  });

  test('applies the per-field fromJson and toJson functions', () async {
    final generated = await _generate('''
@Model()
class Foo with _\$Foo {
  const Foo(this.bar);

  factory Foo.fromJson(Map<String, dynamic> json) => _\$FooFromJson(json);

  Map<String, dynamic> toJson() => _\$FooToJson(this);

  @ModelField(fromJson: _barFromJson, toJson: _barToJson)
  final List<String> bar;

  static List<String> _barFromJson(String value) => value.split(',');

  static String _barToJson(List<String> value) => value.join(',');
}
''');

    expect(generated.errors, isEmpty);
    final part = generated.part!;
    expect(part, contains("Foo._barFromJson(json['bar'] as String)"));
    expect(part, contains("'bar': Foo._barToJson(instance.bar)"));
  });

  test('serializes a field whose type is another model', () async {
    final generated = await _generate('''
@Model(explicitToJson: true)
class Outer with _\$Outer {
  const Outer(this.inner);

  factory Outer.fromJson(Map<String, dynamic> json) => _\$OuterFromJson(json);

  Map<String, dynamic> toJson() => _\$OuterToJson(this);

  final Inner inner;
}

@Model()
class Inner with _\$Inner {
  const Inner(this.bar);

  factory Inner.fromJson(Map<String, dynamic> json) => _\$InnerFromJson(json);

  Map<String, dynamic> toJson() => _\$InnerToJson(this);

  final String bar;
}
''');

    expect(generated.errors, isEmpty);
    expect(generated.part, contains("'inner': instance.inner.toJson()"));
  });

  test('honours every opt-out flag', () async {
    final generated = await _generate('''
@Model(serializable: false, copyWith: false, equality: false)
class Foo with _\$Foo {
  const Foo(this.bar);

  final String bar;
}
''');

    final part = generated.part!;
    expect(part, isNot(contains('_\$FooFromJson')));
    expect(part, isNot(contains('CopyWith')));
    expect(part, isNot(contains('operator ==')));
    expect(part, contains('mixin _\$Foo {}'));
  });

  test('reads @ModelValue and @ModelEnum off an enum a model holds', () async {
    final generated = await _generate('''
@ModelEnum(fieldRename: FieldRename.snake)
enum Status {
  @ModelValue('OK')
  ok,
  needsReview,
}

@Model()
class Foo with _\$Foo {
  const Foo(this.status);

  factory Foo.fromJson(Map<String, dynamic> json) => _\$FooFromJson(json);

  Map<String, dynamic> toJson() => _\$FooToJson(this);

  final Status status;
}
''');

    expect(generated.errors, isEmpty);
    final part = generated.part!;
    expect(part, contains("Status.ok: 'OK'"));
    expect(part, contains("Status.needsReview: 'needs_review'"));
  });

  test('@ModelEnum(alwaysCreate: true) emits a map with no model', () async {
    final generated = await _generate('''
@ModelEnum(alwaysCreate: true)
enum Status { ok, failed }
''');

    expect(generated.errors, isEmpty);
    expect(generated.part, contains('const _\$StatusEnumMap = {'));
  });

  test('emits one enum map for two models over the same enum', () async {
    final generated = await _generate('''
@ModelEnum(alwaysCreate: true)
enum Status { ok, failed }

@Model()
class Foo with _\$Foo {
  const Foo(this.status);

  factory Foo.fromJson(Map<String, dynamic> json) => _\$FooFromJson(json);

  Map<String, dynamic> toJson() => _\$FooToJson(this);

  final Status status;
}

@Model()
class Bar with _\$Bar {
  const Bar(this.status);

  factory Bar.fromJson(Map<String, dynamic> json) => _\$BarFromJson(json);

  Map<String, dynamic> toJson() => _\$BarToJson(this);

  final Status status;
}
''');

    expect(generated.errors, isEmpty);
    expect(
      'const _\$StatusEnumMap = {'.allMatches(generated.part!),
      hasLength(1),
    );
  });

  test('includes inherited fields, superclass first', () async {
    final generated = await _generate('''
abstract class Base {
  const Base(this.id, this.ignored);

  final String id;

  @ModelField(equality: false)
  final int ignored;
}

mixin Timestamped {
  DateTime get createdAt;
}

@Model(serializable: false)
class Foo extends Base with Timestamped, _\$Foo {
  const Foo(super.id, super.ignored, this.createdAt, this.bar);

  @override
  final DateTime createdAt;

  final String bar;
}
''');

    expect(generated.errors, isEmpty);
    final part = generated.part!;
    expect(
      part,
      contains(
        'return self.id == other.id &&\n'
        '        self.createdAt == other.createdAt &&\n'
        '        self.bar == other.bar;',
      ),
    );
    expect(
      part,
      contains('Object.hash(runtimeType, self.id, self.createdAt, self.bar)'),
    );
    expect(
      part,
      contains(
        "return 'Foo(id: \${self.id}, createdAt: \${self.createdAt}, "
        "bar: \${self.bar})';",
      ),
    );
  });

  test('an override keeps its position but wins on options', () async {
    final generated = await _generate('''
abstract class Base {
  const Base();

  abstract final String id;

  abstract final int rank;
}

@Model(serializable: false, copyWith: false)
class Foo extends Base with _\$Foo {
  const Foo(this.bar, this.id, this.rank);

  final String bar;

  @override
  final String id;

  @override
  @ModelField(equality: false)
  final int rank;
}
''');

    expect(generated.errors, isEmpty);
    expect(
      generated.part,
      contains('return self.id == other.id && self.bar == other.bar;'),
    );
  });

  test('skips a private field inherited from another library', () async {
    final generated = await _generate(
      '''
@Model(serializable: false, copyWith: false)
class Foo extends Base with _\$Foo {
  const Foo(this.bar);

  final String bar;
}
''',
      otherLibrary: '''
abstract class Base {
  const Base();

  final String shared = '';

  final String _hidden = '';

  String get hidden => _hidden;
}
''',
    );

    expect(generated.errors, isEmpty);
    final part = generated.part!;
    expect(
      part,
      contains('return self.shared == other.shared && self.bar == other.bar;'),
    );
    expect(part, isNot(contains('_hidden')));
  });

  test('reports a missing constructor instead of crashing', () async {
    final generated = await _generate('''
@Model(serializable: false, constructor: 'nope')
class Foo with _\$Foo {
  const Foo(this.bar);

  final String bar;
}
''');

    expect(generated.part, isNull);
    expect(generated.errors, contains('no constructor named `nope`'));
  });
}

class _Generated {
  const _Generated({required this.part, required this.errors});

  final String? part;
  final String errors;
}
