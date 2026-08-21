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
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddressModel || runtimeType != other.runtimeType) {
      return false;
    }
    final self = this as AddressModel;
    return self.city == other.city && self.postcode == other.postcode;
  }

  @override
  int get hashCode {
    final self = this as AddressModel;
    return Object.hash(runtimeType, self.city, self.postcode);
  }

  @override
  String toString() {
    final self = this as AddressModel;
    return 'AddressModel(city: ${self.city}, postcode: ${self.postcode})';
  }
}
