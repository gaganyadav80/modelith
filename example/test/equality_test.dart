import 'package:modelith_example/address_model.dart';
import 'package:modelith_example/opt_out_models.dart';
import 'package:modelith_example/prefs_model.dart';
import 'package:modelith_example/session_model.dart';
import 'package:modelith_example/user_model.dart';
import 'package:test/test.dart';

void main() {
  group('equality', () {
    const a = AddressModel(city: 'Lisbon', postcode: '1100-062');
    const b = AddressModel(city: 'Lisbon', postcode: '1100-062');
    const c = AddressModel(city: 'Porto', postcode: '1100-062');

    test('same values are equal, different values are not', () {
      expect(a, b);
      expect(a, isNot(c));
    });

    test('hashCode is stable across equal instances', () {
      expect(a.hashCode, b.hashCode);
      expect(a.hashCode, a.hashCode);
    });

    test('equal instances dedupe in a Set', () {
      final unique = <AddressModel>{}..addAll([a, b, c]);

      expect(unique, hasLength(2));
    });

    test('equal instances collide as Map keys', () {
      final map = <AddressModel, int>{a: 1};
      map[b] = 2;

      expect(map, hasLength(1));
      expect(map[a], 2);
    });

    test('nested models compare by value', () {
      const first = UserModel(id: 'u', address: a, tags: ['x', 'y']);
      const second = UserModel(id: 'u', address: b, tags: ['x', 'y']);

      expect(first, second);
      expect(first, isNot(const UserModel(id: 'u', address: a, tags: ['x'])));
    });

    test('a value of another model type is never equal', () {
      const Object other = PlainPoint(1, 2);

      expect(a == other, isFalse);
    });

    test('@ModelField(equality: false) is left out', () {
      expect(
        SessionModel(token: 't', deviceId: 'phone'),
        SessionModel(token: 't', deviceId: 'tablet'),
      );
    });
  });

  group('generated toString', () {
    test('names each field that makes up equality', () {
      expect(
        SessionModel(token: 't', deviceId: 'd').toString(),
        'SessionModel(token: t, lastSeenAt: null)',
      );
    });

    test('@Model(stringify: false) falls back to the default', () {
      expect(
        const NoCopyToken(value: 'v').toString(),
        "Instance of 'NoCopyToken'",
      );
    });
  });

  group('deep collection equality', () {
    PrefsModel build({
      List<String> order = const ['a', 'b'],
      Set<String> labels = const {'x', 'y'},
      Map<String, int> limits = const {'a': 1},
      List<List<int>> matrix = const [
        [1, 2],
      ],
      Object? extra,
    }) => PrefsModel(
      order: order,
      labels: labels,
      limits: limits,
      matrix: matrix,
      extra: extra,
    );

    test('lists compare in order', () {
      expect(build(), build());
      expect(build(), isNot(build(order: ['b', 'a'])));
    });

    test('sets ignore order', () {
      expect(build(labels: {'y', 'x'}), build(labels: {'x', 'y'}));
      expect(build(), isNot(build(labels: {'x'})));
    });

    test('maps compare by key and value', () {
      expect(build(limits: {'a': 1}), build());
      expect(build(), isNot(build(limits: {'a': 2})));
      expect(build(), isNot(build(limits: {'b': 1})));
    });

    test('nested collections recurse', () {
      expect(
        build(
          matrix: [
            [1, 2],
          ],
        ),
        build(),
      );
      expect(
        build(),
        isNot(
          build(
            matrix: [
              [2, 1],
            ],
          ),
        ),
      );
    });

    test('a dynamically typed field is dispatched at runtime', () {
      expect(build(extra: ['a']), build(extra: ['a']));
      expect(build(extra: {'k': 'v'}), build(extra: {'k': 'v'}));
      expect(build(extra: ['a']), isNot(build(extra: ['b'])));
      expect(build(extra: ['a']), isNot(build(extra: 'a')));
    });

    test('equal collections hash equally', () {
      expect(build(labels: {'y', 'x'}).hashCode, build().hashCode);
      expect(
        build(
          matrix: [
            [1, 2],
          ],
        ).hashCode,
        build().hashCode,
      );
      expect(build(extra: ['a']).hashCode, build(extra: ['a']).hashCode);
    });

    test('collection-keyed models dedupe in a Set', () {
      final unique = <PrefsModel>{}
        ..addAll([
          build(),
          build(labels: {'y', 'x'}),
          build(order: ['b', 'a']),
        ]);

      expect(unique, hasLength(2));
    });

    test('a lazy iterable compares against a list of the same elements', () {
      expect(build(extra: [1, 2]), build(extra: [1, 2].map((e) => e)));
      expect(
        build(extra: [1, 2]).hashCode,
        build(extra: [1, 2].map((e) => e)).hashCode,
      );
    });
  });
}
