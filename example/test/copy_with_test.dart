import 'package:modelith_example/address_model.dart';
import 'package:modelith_example/session_model.dart';
import 'package:modelith_example/user_model.dart';
import 'package:test/test.dart';

void main() {
  group('copyWith', () {
    const address = AddressModel(city: 'Lisbon', postcode: '1100-062');

    test('changes one field and leaves the rest intact', () {
      final copy = address.copyWith(city: 'Porto');

      expect(copy.city, 'Porto');
      expect(copy.postcode, '1100-062');
    });

    test('omitting every argument returns an equal value', () {
      expect(address.copyWith(), address);
    });

    test('a nullable field can be set back to null', () {
      expect(address.copyWith(postcode: null).postcode, isNull);
    });

    test('a non-null replacement for a nullable field is kept', () {
      expect(address.copyWith(postcode: '4000-001').postcode, '4000-001');
    });

    test('nested models can be replaced wholesale', () {
      const user = UserModel(id: 'u1', address: address);
      final copy = user.copyWith(address: address.copyWith(city: 'Braga'));

      expect(copy.address.city, 'Braga');
      expect(copy.id, 'u1');
    });

    test('@ModelField(copyWith: false) drops the parameter', () {
      final session = SessionModel(token: 't', deviceId: 'd');
      final copy = session.copyWith(token: 't2');

      expect(copy.token, 't2');
      expect(copy.deviceId, 'd');
    });
  });
}
