import 'dart:collection';

import 'package:modelith/modelith.dart';
import 'package:test/test.dart';

void main() {
  group('ModelEquality.iterables', () {
    test('compares lists in order', () {
      expect(ModelEquality.iterables([1, 2], [1, 2]), isTrue);
      expect(ModelEquality.iterables([1, 2], [2, 1]), isFalse);
      expect(ModelEquality.iterables([1], [1, 2]), isFalse);
    });

    test('handles nulls and identity', () {
      const list = [1];

      expect(ModelEquality.iterables(null, null), isTrue);
      expect(ModelEquality.iterables(list, list), isTrue);
      expect(ModelEquality.iterables(null, list), isFalse);
      expect(ModelEquality.iterables(list, null), isFalse);
    });

    test('walks a non-list iterable exactly once', () {
      var reads = 0;
      Iterable<int> counted() => [1, 2, 3].map((value) {
        reads++;
        return value;
      });

      expect(ModelEquality.iterables(counted(), counted()), isTrue);
      expect(reads, 6);
    });

    test('recurses into nested collections', () {
      expect(
        ModelEquality.iterables(
          [
            [1, 2],
            {'a': 1},
          ],
          [
            [1, 2],
            {'a': 1},
          ],
        ),
        isTrue,
      );
    });

    test('a list and a lazy iterable of the same elements are equal', () {
      expect(ModelEquality.iterables([1, 2], [1, 2].map((e) => e)), isTrue);
      expect(
        ModelEquality.hashOf([1, 2]),
        ModelEquality.hashOf([1, 2].map((e) => e)),
      );
    });

    test('a List subtype is still compared by value', () {
      expect(
        ModelEquality.objects(UnmodifiableListView([1, 2]), [1, 2]),
        isTrue,
      );
    });
  });

  group('ModelEquality.sets', () {
    test('ignores order', () {
      expect(ModelEquality.sets({1, 2}, {2, 1}), isTrue);
      expect(ModelEquality.sets({1, 2}, {1}), isFalse);
      expect(ModelEquality.sets({1}, {2}), isFalse);
    });

    test('falls back to a deep scan for collection elements', () {
      expect(
        ModelEquality.sets(
          {
            [1, 2],
          },
          {
            [1, 2],
          },
        ),
        isTrue,
      );
      expect(
        ModelEquality.sets(
          {
            [1, 2],
          },
          {
            [2, 1],
          },
        ),
        isFalse,
      );
    });
  });

  group('ModelEquality.maps', () {
    test('compares by key and value', () {
      expect(ModelEquality.maps({'a': 1}, {'a': 1}), isTrue);
      expect(ModelEquality.maps({'a': 1}, {'a': 2}), isFalse);
      expect(ModelEquality.maps({'a': 1}, {'b': 1}), isFalse);
      expect(ModelEquality.maps({'a': 1}, {'a': 1, 'b': 2}), isFalse);
    });

    test('recurses into values', () {
      expect(
        ModelEquality.maps(
          {
            'a': [1, 2],
          },
          {
            'a': [1, 2],
          },
        ),
        isTrue,
      );
    });

    test('ignores insertion order', () {
      expect(ModelEquality.maps({'a': 1, 'b': 2}, {'b': 2, 'a': 1}), isTrue);
    });
  });

  group('ModelEquality.objects', () {
    test('dispatches on the runtime type', () {
      expect(ModelEquality.objects([1], [1]), isTrue);
      expect(ModelEquality.objects({1}, {1}), isTrue);
      expect(ModelEquality.objects({'a': 1}, {'a': 1}), isTrue);
      expect(ModelEquality.objects('a', 'a'), isTrue);
      expect(ModelEquality.objects(null, null), isTrue);
    });

    test('different container kinds are not equal', () {
      expect(ModelEquality.objects([1], {1}), isFalse);
      expect(ModelEquality.objects([1], 1), isFalse);
      expect(ModelEquality.objects({'a': 1}, ['a']), isFalse);
    });

    test('numbers compare by value across int and double', () {
      expect(ModelEquality.objects(1, 1.0), isTrue);
    });
  });

  group('ModelEquality.hashOf', () {
    test('equal values hash equally', () {
      expect(ModelEquality.hashOf([1, 2]), ModelEquality.hashOf([1, 2]));
      expect(ModelEquality.hashOf({1, 2}), ModelEquality.hashOf({2, 1}));
      expect(
        ModelEquality.hashOf({'a': 1, 'b': 2}),
        ModelEquality.hashOf({'b': 2, 'a': 1}),
      );
      expect(
        ModelEquality.hashOf([
          [1, 2],
        ]),
        ModelEquality.hashOf([
          [1, 2],
        ]),
      );
    });

    test('order matters for iterables but not for sets', () {
      expect(ModelEquality.hashOf([1, 2]), isNot(ModelEquality.hashOf([2, 1])));
      expect(ModelEquality.hashOf({1, 2}), ModelEquality.hashOf({2, 1}));
    });

    test('length is part of the hash', () {
      expect(
        ModelEquality.hashOf([1, 2]),
        isNot(ModelEquality.hashOf([1, 2, 2])),
      );
    });

    test('scalars fall through to hashCode', () {
      expect(ModelEquality.hashOf('a'), 'a'.hashCode);
      expect(ModelEquality.hashOf(null), null.hashCode);
    });
  });

  group('ModelEquality.hashAllOf', () {
    test('is order sensitive and deep', () {
      expect(
        ModelEquality.hashAllOf([
          'a',
          [1, 2],
        ]),
        ModelEquality.hashAllOf([
          'a',
          [1, 2],
        ]),
      );
      expect(
        ModelEquality.hashAllOf(['a', 'b']),
        isNot(ModelEquality.hashAllOf(['b', 'a'])),
      );
    });
  });
}
