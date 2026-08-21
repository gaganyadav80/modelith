/// Value-equality helpers called by generated `==` and `hashCode`.
///
/// Generated code only reaches for these when a field's static type actually
/// needs them: the generator picks the right call at build time, so a `String`
/// field compiles to `a == b` and only a `List`/`Set`/`Map`/`dynamic` field pays
/// for a helper call. Nothing here allocates a props list, and no collection is
/// ever sorted.
abstract final class ModelEquality {
  const ModelEquality._();

  /// Compares two values of unknown static type — a field typed `dynamic`,
  /// `Object?` or by a type parameter, or an element inside a collection.
  static bool objects(Object? a, Object? b) {
    if (identical(a, b)) return true;
    // Each container kind is checked from both sides: a `List` and a `Set`
    // holding the same elements are not equal, even though `Set` is an
    // `Iterable`.
    if (a is Set || b is Set) return a is Set && b is Set && sets(a, b);
    if (a is Map || b is Map) return a is Map && b is Map && maps(a, b);
    if (a is Iterable || b is Iterable) {
      return a is Iterable && b is Iterable && iterables(a, b);
    }
    return a == b;
  }

  /// Order-sensitive comparison, recursing into elements.
  static bool iterables(Iterable<Object?>? a, Iterable<Object?>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a is Set != b is Set) return false;

    if (a is List<Object?> && b is List<Object?>) {
      final length = a.length;
      if (length != b.length) return false;
      for (var i = 0; i < length; i++) {
        if (!objects(a[i], b[i])) return false;
      }
      return true;
    }

    // Walked in lockstep so a lazy iterable is traversed exactly once; using
    // `length` + `elementAt` here would be quadratic.
    final iteratorA = a.iterator;
    final iteratorB = b.iterator;
    while (true) {
      final hasA = iteratorA.moveNext();
      if (hasA != iteratorB.moveNext()) return false;
      if (!hasA) return true;
      if (!objects(iteratorA.current, iteratorB.current)) return false;
    }
  }

  /// Order-insensitive comparison.
  ///
  /// Elements are matched through the set's own hash lookup, which is `O(n)`.
  /// An element that is itself a collection cannot be found that way — its
  /// `hashCode` is identity based — so those fall back to a linear deep scan.
  static bool sets(Set<Object?>? a, Set<Object?>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (final element in a) {
      if (b.contains(element)) continue;
      if ((element is Iterable || element is Map) &&
          b.any((other) => objects(element, other))) {
        continue;
      }
      return false;
    }
    return true;
  }

  /// Compares keys through hash lookup and values deeply.
  static bool maps(Map<Object?, Object?>? a, Map<Object?, Object?>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (final entry in a.entries) {
      final key = entry.key;
      if (!b.containsKey(key)) return false;
      if (!objects(entry.value, b[key])) return false;
    }
    return true;
  }

  /// Hash consistent with [objects]: order-sensitive for iterables,
  /// order-insensitive for sets and maps, plain `hashCode` for anything else.
  static int hashOf(Object? value) {
    if (value is Set) {
      var hash = 0;
      for (final element in value) {
        hash ^= hashOf(element);
      }
      return _finish(hash ^ value.length);
    }

    if (value is Map) {
      var hash = 0;
      for (final entry in value.entries) {
        hash ^= _combine(hashOf(entry.key), hashOf(entry.value));
      }
      return _finish(hash ^ value.length);
    }

    if (value is Iterable) {
      var hash = 0;
      var length = 0;
      for (final element in value) {
        hash = _combine(hash, hashOf(element));
        length++;
      }
      return _finish(hash ^ length);
    }

    return value.hashCode;
  }

  /// Used instead of `Object.hash` when a model has more fields than that
  /// function takes.
  static int hashAllOf(Iterable<Object?> values) {
    var hash = 0;
    for (final value in values) {
      hash = _combine(hash, hashOf(value));
    }
    return _finish(hash);
  }

  /// Jenkins hash combine, matching the shape `equatable` uses so migrated
  /// models keep well-distributed hashes.
  static int _combine(int hash, int value) {
    hash = 0x1fffffff & (hash + value);
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int _finish(int hash) {
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}
