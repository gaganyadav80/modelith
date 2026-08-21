// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inheritance_model.dart';

// **************************************************************************
// ModelGenerator
// **************************************************************************

NoteModel _$NoteModelFromJson(Map<String, dynamic> json) => NoteModel(
  id: json['id'] as String,
  revision: (json['revision'] as num).toInt(),
  archived: json['archived'] as bool,
  title: json['title'] as String,
);

Map<String, dynamic> _$NoteModelToJson(NoteModel instance) => <String, dynamic>{
  'id': instance.id,
  'revision': instance.revision,
  'archived': instance.archived,
  'title': instance.title,
};

extension $NoteModelCopyWith on NoteModel {
  NoteModel copyWith({
    String? id,
    int? revision,
    bool? archived,
    String? title,
  }) => NoteModel(
    id: id ?? this.id,
    revision: revision ?? this.revision,
    archived: archived ?? this.archived,
    title: title ?? this.title,
  );
}

mixin _$NoteModel {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NoteModel || runtimeType != other.runtimeType) {
      return false;
    }
    final self = this as NoteModel;
    return self.id == other.id &&
        self.archived == other.archived &&
        self.title == other.title;
  }

  @override
  int get hashCode {
    final self = this as NoteModel;
    return Object.hash(runtimeType, self.id, self.archived, self.title);
  }

  @override
  String toString() {
    final self = this as NoteModel;
    return 'NoteModel(id: ${self.id}, archived: ${self.archived}, title: ${self.title})';
  }
}

PinnedNoteModel _$PinnedNoteModelFromJson(Map<String, dynamic> json) =>
    PinnedNoteModel(
      id: json['id'] as String,
      revision: (json['revision'] as num).toInt(),
      archived: json['archived'] as bool,
      title: json['title'] as String,
      pinnedAt: DateTime.parse(json['pinnedAt'] as String),
    );

Map<String, dynamic> _$PinnedNoteModelToJson(PinnedNoteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'revision': instance.revision,
      'archived': instance.archived,
      'title': instance.title,
      'pinnedAt': instance.pinnedAt.toIso8601String(),
    };

extension $PinnedNoteModelCopyWith on PinnedNoteModel {
  PinnedNoteModel copyWith({
    String? id,
    int? revision,
    bool? archived,
    String? title,
    DateTime? pinnedAt,
  }) => PinnedNoteModel(
    id: id ?? this.id,
    revision: revision ?? this.revision,
    archived: archived ?? this.archived,
    title: title ?? this.title,
    pinnedAt: pinnedAt ?? this.pinnedAt,
  );
}

mixin _$PinnedNoteModel {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PinnedNoteModel || runtimeType != other.runtimeType) {
      return false;
    }
    final self = this as PinnedNoteModel;
    return self.id == other.id &&
        self.archived == other.archived &&
        self.title == other.title &&
        self.pinnedAt == other.pinnedAt;
  }

  @override
  int get hashCode {
    final self = this as PinnedNoteModel;
    return Object.hash(
      runtimeType,
      self.id,
      self.archived,
      self.title,
      self.pinnedAt,
    );
  }

  @override
  String toString() {
    final self = this as PinnedNoteModel;
    return 'PinnedNoteModel(id: ${self.id}, archived: ${self.archived}, title: ${self.title}, pinnedAt: ${self.pinnedAt})';
  }
}
