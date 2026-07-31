import 'package:modelith_example/address_model.dart';
import 'package:modelith_example/page_model.dart';
import 'package:test/test.dart';

void main() {
  group('generic model', () {
    const page = PageModel<AddressModel>(
      items: [AddressModel(city: 'Lisbon', postcode: null)],
      total: 1,
    );

    test('round-trips with argument factories', () {
      final json = page.toJson((address) => address.toJson());

      expect(json, {
        'items': [
          {'city': 'Lisbon', 'postcode': null},
        ],
        'total': 1,
      });
      expect(
        PageModel<AddressModel>.fromJson(
          json,
          (item) => AddressModel.fromJson(item as Map<String, dynamic>),
        ),
        page,
      );
    });

    test('copyWith keeps the type argument', () {
      final copy = page.copyWith(total: 2);

      expect(copy, isA<PageModel<AddressModel>>());
      expect(copy.total, 2);
      expect(copy.items, page.items);
    });
  });
}
