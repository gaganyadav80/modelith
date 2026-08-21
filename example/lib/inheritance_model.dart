import 'package:modelith/modelith.dart';

part 'inheritance_model.g.dart';

/// Fields every stored record carries. Not a `@Model` itself — it only supplies
/// state to the models that extend it.
abstract class RecordBase {
  const RecordBase({required this.id, required this.revision});

  final String id;

  /// Bumped on every write, so two records with the same content but different
  /// revisions are still the same record.
  @ModelField(equality: false)
  final int revision;
}

mixin Archivable {
  bool get archived;
}

/// Exercises inheritance: `id` and `revision` come from [RecordBase],
/// `archived` satisfies [Archivable], and only `title` is declared here.
///
/// Generated `==`, `hashCode` and `toString` list them superclass-first —
/// `id`, `archived`, `title` — and skip `revision`, which the base class opted
/// out of.
@Model()
class NoteModel extends RecordBase with Archivable, _$NoteModel {
  const NoteModel({
    required super.id,
    required super.revision,
    required this.archived,
    required this.title,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) =>
      _$NoteModelFromJson(json);

  Map<String, dynamic> toJson() => _$NoteModelToJson(this);

  @override
  final bool archived;

  final String title;
}

/// A `@Model` extending a `@Model`. `_$PinnedNoteModel` is applied after
/// `NoteModel`, so its `==` overrides the inherited one and compares `title`
/// too — and the `runtimeType` guard keeps a `NoteModel` and a
/// `PinnedNoteModel` with identical fields unequal in both directions.
@Model()
class PinnedNoteModel extends NoteModel with _$PinnedNoteModel {
  const PinnedNoteModel({
    required super.id,
    required super.revision,
    required super.archived,
    required super.title,
    required this.pinnedAt,
  });

  factory PinnedNoteModel.fromJson(Map<String, dynamic> json) =>
      _$PinnedNoteModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PinnedNoteModelToJson(this);

  final DateTime pinnedAt;
}
