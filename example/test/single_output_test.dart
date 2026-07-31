import 'dart:io';

import 'package:test/test.dart';

/// Everything Modelith generates has to land in exactly one part file per input,
/// so upgrading or dropping the generator never means reconciling several files.
void main() {
  test('each model file has exactly one generated part file', () {
    final files = Directory('lib')
        .listSync()
        .whereType<File>()
        .map((file) => file.uri.pathSegments.last)
        .toList();

    final sources = files
        .where((name) => name.endsWith('.dart') && !name.endsWith('.g.dart'))
        .toList();
    final generated = files.where((name) => name.endsWith('.g.dart')).toList();

    expect(sources, isNotEmpty);
    expect(
      generated..sort(),
      sources.map((name) => name.replaceAll('.dart', '.g.dart')).toList()
        ..sort(),
    );
  });

  test('generated files declare a single part-of and one generator header', () {
    for (final file in Directory('lib').listSync().whereType<File>().where(
      (file) => file.path.endsWith('.g.dart'),
    )) {
      final source = file.readAsStringSync();

      expect('part of'.allMatches(source), hasLength(1), reason: file.path);
      expect(
        'ModelGenerator'.allMatches(source),
        hasLength(1),
        reason: file.path,
      );
    }
  });
}
