// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'converter_model.dart';

// **************************************************************************
// ModelGenerator
// **************************************************************************

ConverterModel _$ConverterModelFromJson(Map<String, dynamic> json) =>
    ConverterModel(
      slug: ConverterModel._slugFromJson(json['slug'] as String),
      tags: ConverterModel._tagsFromJson(json['tags'] as String),
      legacyId: ConverterModel._readLegacyId(json, 'id') as String?,
    );

Map<String, dynamic> _$ConverterModelToJson(ConverterModel instance) =>
    <String, dynamic>{
      'slug': ConverterModel._slugToJson(instance.slug),
      'tags': ConverterModel._tagsToJson(instance.tags),
      'id': instance.legacyId,
    };

extension $ConverterModelCopyWith on ConverterModel {
  ConverterModel copyWith({
    String? slug,
    List<String>? tags,
    Object? legacyId = $unset,
  }) => ConverterModel(
    slug: slug ?? this.slug,
    tags: tags ?? this.tags,
    legacyId: legacyId == $unset ? this.legacyId : legacyId as String?,
  );
}

mixin _$ConverterModel {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ConverterModel || runtimeType != other.runtimeType) {
      return false;
    }
    final self = this as ConverterModel;
    return self.slug == other.slug &&
        ModelEquality.iterables(self.tags, other.tags) &&
        self.legacyId == other.legacyId;
  }

  @override
  int get hashCode {
    final self = this as ConverterModel;
    return Object.hash(
      runtimeType,
      self.slug,
      ModelEquality.hashOf(self.tags),
      self.legacyId,
    );
  }

  @override
  String toString() {
    final self = this as ConverterModel;
    return 'ConverterModel(slug: ${self.slug}, tags: ${self.tags}, legacyId: ${self.legacyId})';
  }
}
