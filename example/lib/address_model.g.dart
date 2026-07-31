// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_model.dart';

// **************************************************************************
// ModelGenerator
// **************************************************************************

AddressModel _$AddressModelFromJson(Map<String, dynamic> json) => AddressModel(
  city: json['city'] as String,
  postcode: json['postcode'] as String?,
);

Map<String, dynamic> _$AddressModelToJson(AddressModel instance) =>
    <String, dynamic>{'city': instance.city, 'postcode': instance.postcode};

extension $AddressModelCopyWith on AddressModel {
  AddressModel copyWith({String? city, Object? postcode = $unset}) =>
      AddressModel(
        city: city ?? this.city,
        postcode: postcode == $unset ? this.postcode : postcode as String?,
      );
}

mixin _$AddressModel {
  List<Object?> get props {
    final self = this as AddressModel;
    return [self.city, self.postcode];
  }

  Map<String, dynamic> toJson() => _$AddressModelToJson(this as AddressModel);
}
