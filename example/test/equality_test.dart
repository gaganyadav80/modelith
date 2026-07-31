import 'package:modelith_example/address_model.dart';
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

    test('collections inside props compare deeply', () {
      const first = UserModel(id: 'u', address: a, tags: ['x', 'y']);
      const second = UserModel(id: 'u', address: b, tags: ['x', 'y']);

      expect(first, second);
      expect(first, isNot(const UserModel(id: 'u', address: a, tags: ['x'])));
    });

    test('@ModelField(equality: false) is left out of props', () {
      expect(
        SessionModel(token: 't', deviceId: 'phone'),
        SessionModel(token: 't', deviceId: 'tablet'),
      );
    });

    test('@Model(stringify: true) prints the props', () {
      expect(
        SessionModel(token: 't', deviceId: 'd').toString(),
        'SessionModel(t, null)',
      );
    });
  });
}
