import 'dart:io';

import 'package:modelith_example/opt_out_models.dart';
import 'package:test/test.dart';

void main() {
  group('@Model(serializable: false)', () {
    test('still gets copyWith and equality', () {
      const point = PlainPoint(1, 2);

      expect(point.copyWith(y: 5), const PlainPoint(1, 5));
      expect(point, const PlainPoint(1, 2));
    });

    test('emits no json functions', () {
      final source = File('lib/opt_out_models.g.dart').readAsStringSync();

      expect(source, isNot(contains('_\$PlainPointFromJson')));
      expect(source, isNot(contains('_\$PlainPointToJson')));
    });
  });

  group('@Model(copyWith: false)', () {
    test('still gets json and equality', () {
      const token = NoCopyToken(value: 'v');

      expect(token.toJson(), {'value': 'v'});
      expect(NoCopyToken.fromJson(token.toJson()), token);
    });

    test('emits no copyWith extension', () {
      final source = File('lib/opt_out_models.g.dart').readAsStringSync();

      expect(source, isNot(contains('\$NoCopyTokenCopyWith')));
    });
  });

  group('@Model(equality: false)', () {
    test('still gets json and copyWith', () {
      final counter = MutableCounter(count: 1);

      expect(counter.toJson(), {'count': 1});
      expect(counter.copyWith(count: 2).count, 2);
    });

    test('keeps identity equality', () {
      expect(MutableCounter(count: 1), isNot(MutableCounter(count: 1)));
    });

    test('emits no props', () {
      final source = File('lib/opt_out_models.g.dart').readAsStringSync();

      expect(source, isNot(contains('mixin _\$MutableCounter {\n  List')));
    });
  });
}
