import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:modelith_generator/builder.dart';
import 'package:test/test.dart';

/// Builds [source] as `pkg|lib/model.dart` and returns the single generated
/// part, or the build errors when generation failed.
Future<_Generated> _generate(String source) async {
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
          "part 'model.g.dart';\n"
          '$source',
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
class Foo with Equatable, _\$Foo {
  const Foo({required this.bar, this.baz});

  factory Foo.fromJson(Map<String, dynamic> json) => _\$FooFromJson(json);

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
    expect(part, contains('return [self.bar];'));
    expect(part, contains('baz: baz'));
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
    expect(part, isNot(contains('props')));
    expect(part, contains('mixin _\$Foo {}'));
  });

  test('reports a missing constructor instead of crashing', () async {
    final generated = await _generate('''
@Model(serializable: false, constructor: 'nope')
class Foo with Equatable, _\$Foo {
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
