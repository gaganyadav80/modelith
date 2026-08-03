// Compares the equality Modelith generates against the two alternatives that
// were on the table: `Equatable` (props + runtime dispatch) and
// `DeepCollectionEquality` over a props list.
//
// Run with: dart run benchmark/equality_benchmark.dart
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:modelith_example/prefs_model.dart';
import 'package:modelith_example/session_model.dart';

/// Same shape as `SessionModel`, compared through Equatable.
class EquatableSession extends Equatable {
  const EquatableSession(this.token, this.lastSeenAt);

  final String token;
  final DateTime? lastSeenAt;

  @override
  List<Object?> get props => [token, lastSeenAt];
}

/// Same shape as `PrefsModel`, compared through Equatable.
class EquatablePrefs extends Equatable {
  const EquatablePrefs(this.order, this.labels, this.limits, this.matrix);

  final List<String> order;
  final Set<String> labels;
  final Map<String, int> limits;
  final List<List<int>> matrix;

  @override
  List<Object?> get props => [order, labels, limits, matrix];
}

/// Same shape again, compared through `package:collection`.
class DeepPrefs {
  const DeepPrefs(this.order, this.labels, this.limits, this.matrix);

  static const _equality = DeepCollectionEquality();

  final List<String> order;
  final Set<String> labels;
  final Map<String, int> limits;
  final List<List<int>> matrix;

  List<Object?> get props => [order, labels, limits, matrix];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeepPrefs &&
          runtimeType == other.runtimeType &&
          _equality.equals(props, other.props);

  @override
  int get hashCode => runtimeType.hashCode ^ _equality.hash(props);
}

const _iterations = 300000;

/// Runs [body] after a warmup and returns nanoseconds per iteration.
double _measure(void Function() body) {
  for (var i = 0; i < _iterations ~/ 10; i++) {
    body();
  }

  final stopwatch = Stopwatch()..start();
  for (var i = 0; i < _iterations; i++) {
    body();
  }
  stopwatch.stop();

  return stopwatch.elapsedMicroseconds * 1000 / _iterations;
}

void _report(String label, double baseline, double value) {
  final ratio = baseline / value;
  final speed = switch (ratio) {
    1 => 'baseline',
    >= 1 => '${ratio.toStringAsFixed(1)}x faster',
    _ => '${(1 / ratio).toStringAsFixed(1)}x slower',
  };
  print(
    '  ${label.padRight(26)} ${value.toStringAsFixed(1).padLeft(8)} ns  '
    '$speed',
  );
}

void main() {
  final order = ['alpha', 'beta', 'gamma', 'delta'];
  final labels = {'one', 'two', 'three', 'four'};
  final limits = {'a': 1, 'b': 2, 'c': 3, 'd': 4};
  final matrix = [
    [1, 2, 3],
    [4, 5, 6],
  ];

  final seenAt = DateTime.utc(2026, 7, 31);
  final sessionA = SessionModel(
    token: 'abc',
    deviceId: 'd',
    lastSeenAt: seenAt,
  );
  final sessionB = SessionModel(
    token: 'abc',
    deviceId: 'e',
    lastSeenAt: seenAt,
  );
  final equatableSessionA = EquatableSession('abc', seenAt);
  final equatableSessionB = EquatableSession('abc', seenAt);

  final prefsA = PrefsModel(
    order: order,
    labels: labels,
    limits: limits,
    matrix: matrix,
  );
  final prefsB = PrefsModel(
    order: List.of(order),
    labels: Set.of(labels),
    limits: Map.of(limits),
    matrix: matrix.map(List<int>.of).toList(),
  );
  final equatablePrefsA = EquatablePrefs(order, labels, limits, matrix);
  final equatablePrefsB = EquatablePrefs(
    List.of(order),
    Set.of(labels),
    Map.of(limits),
    matrix.map(List<int>.of).toList(),
  );
  final deepPrefsA = DeepPrefs(order, labels, limits, matrix);
  final deepPrefsB = DeepPrefs(
    List.of(order),
    Set.of(labels),
    Map.of(limits),
    matrix.map(List<int>.of).toList(),
  );

  print('== on scalar fields (String + DateTime?)');
  final scalarBaseline = _measure(() {
    if (!(equatableSessionA == equatableSessionB)) throw StateError('ne');
  });
  _report('equatable', scalarBaseline, scalarBaseline);
  _report(
    'modelith',
    scalarBaseline,
    _measure(() {
      if (!(sessionA == sessionB)) throw StateError('ne');
    }),
  );

  print('\n== on collection fields (list + set + map + nested list)');
  final deepBaseline = _measure(() {
    if (!(equatablePrefsA == equatablePrefsB)) throw StateError('ne');
  });
  _report('equatable', deepBaseline, deepBaseline);
  _report(
    'DeepCollectionEquality',
    deepBaseline,
    _measure(() {
      if (!(deepPrefsA == deepPrefsB)) throw StateError('ne');
    }),
  );
  _report(
    'modelith',
    deepBaseline,
    _measure(() {
      if (!(prefsA == prefsB)) throw StateError('ne');
    }),
  );

  print('\nhashCode on collection fields');
  final hashBaseline = _measure(() {
    equatablePrefsA.hashCode;
  });
  _report('equatable', hashBaseline, hashBaseline);
  _report(
    'DeepCollectionEquality',
    hashBaseline,
    _measure(() {
      deepPrefsA.hashCode;
    }),
  );
  _report(
    'modelith',
    hashBaseline,
    _measure(() {
      prefsA.hashCode;
    }),
  );
}
