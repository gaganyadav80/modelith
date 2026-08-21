import 'package:modelith_example/inheritance_model.dart';
import 'package:test/test.dart';

const _note = NoteModel(
  id: 'n1',
  revision: 1,
  archived: false,
  title: 'Groceries',
);

void main() {
  test('a field inherited from the superclass separates two models', () {
    expect(_note.copyWith(id: 'n2'), isNot(_note));
    expect(_note.copyWith(id: 'n2').hashCode, isNot(_note.hashCode));
  });

  test('a field the superclass opted out of does not', () {
    expect(_note.copyWith(revision: 99), _note);
    expect(_note.copyWith(revision: 99).hashCode, _note.hashCode);
  });

  test('a field satisfying a mixin separates two models', () {
    expect(_note.copyWith(archived: true), isNot(_note));
  });

  test('toString lists inherited fields superclass-first', () {
    expect(
      _note.toString(),
      'NoteModel(id: n1, archived: false, title: Groceries)',
    );
  });

  group('a @Model extending a @Model', () {
    final pinned = PinnedNoteModel(
      id: 'n1',
      revision: 1,
      archived: false,
      title: 'Groceries',
      pinnedAt: DateTime.utc(2026),
    );

    test('compares its own fields as well as the inherited ones', () {
      expect(pinned.copyWith(pinnedAt: DateTime.utc(2027)), isNot(pinned));
      expect(pinned.copyWith(title: 'Errands'), isNot(pinned));
      expect(pinned.copyWith(revision: 99), pinned);
    });

    test('is never equal to its superclass, in either direction', () {
      expect(pinned == _note, isFalse);
      expect(_note == pinned, isFalse);
    });
  });

  test('json round-trips every field, opted out of equality or not', () {
    expect(NoteModel.fromJson(_note.toJson()).revision, 1);
    expect(_note.toJson(), {
      'id': 'n1',
      'revision': 1,
      'archived': false,
      'title': 'Groceries',
    });
  });
}
