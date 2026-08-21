import 'package:modelith_example/address_model.dart';
import 'package:modelith_example/converter_model.dart';
import 'package:modelith_example/session_model.dart';
import 'package:modelith_example/user_model.dart';
import 'package:test/test.dart';

void main() {
  group('json', () {
    test('flat model round-trips', () {
      const address = AddressModel(city: 'Lisbon', postcode: '1100-062');

      expect(address.toJson(), {'city': 'Lisbon', 'postcode': '1100-062'});
      expect(AddressModel.fromJson(address.toJson()), address);
    });

    test('nested model round-trips', () {
      const user = UserModel(
        id: 'u1',
        address: AddressModel(city: 'Lisbon', postcode: null),
        tags: ['a', 'b'],
      );

      expect(user.toJson(), {
        'id': 'u1',
        'address': {'city': 'Lisbon', 'postcode': null},
        'tags': ['a', 'b'],
      });
      expect(UserModel.fromJson(user.toJson()), user);
    });

    test('@ModelField(name:) renames the key in both directions', () {
      final session = SessionModel(
        token: 't',
        deviceId: 'd',
        lastSeenAt: DateTime.utc(2026, 7, 31),
      );

      expect(session.toJson(), {
        'access_token': 't',
        'device_id': 'd',
        'last_seen_at': '2026-07-31T00:00:00.000Z',
      });
      expect(SessionModel.fromJson(session.toJson()), session);
    });

    test('missing optional keys decode to null', () {
      expect(
        SessionModel.fromJson({'access_token': 't', 'device_id': 'd'}),
        SessionModel(token: 't', deviceId: 'd'),
      );
    });

    test('@ModelField(fromJson:) converts on the way in', () {
      final decoded = ConverterModel.fromJson({
        'slug': 'Lisbon-Centre',
        'tags': 'city,beach',
      });

      expect(decoded.slug, 'lisbon-centre');
      expect(decoded.tags, ['city', 'beach']);
    });

    test('@ModelField(toJson:) converts on the way out', () {
      const model = ConverterModel(slug: 'lisbon', tags: ['city', 'beach']);

      expect(model.toJson(), {
        'slug': 'LISBON',
        'tags': 'city,beach',
        'id': null,
      });
    });

    test('@ModelField(readValue:) falls back to the legacy key', () {
      final decoded = ConverterModel.fromJson({
        'slug': 'a',
        'tags': '',
        'legacy_id': 'old-1',
      });

      expect(decoded.legacyId, 'old-1');
      expect(decoded.tags, isEmpty);
    });
  });
}
