// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// ModelGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  address: AddressModel.fromJson(json['address'] as Map<String, dynamic>),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'address': instance.address.toJson(),
  'tags': instance.tags,
};

extension $UserModelCopyWith on UserModel {
  UserModel copyWith({String? id, AddressModel? address, List<String>? tags}) =>
      UserModel(
        id: id ?? this.id,
        address: address ?? this.address,
        tags: tags ?? this.tags,
      );
}

mixin _$UserModel {
  List<Object?> get props {
    final self = this as UserModel;
    return [self.id, self.address, self.tags];
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this as UserModel);
}
