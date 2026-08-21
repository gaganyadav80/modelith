import 'package:modelith/modelith.dart';

part 'address_model.g.dart';

/// A flat model: nothing but `@Model()` plus the two json glue lines.
@Model()
class AddressModel with _$AddressModel {
  const AddressModel({required this.city, required this.postcode});

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  Map<String, dynamic> toJson() => _$AddressModelToJson(this);

  @ModelField()
  final String city;

  @ModelField()
  final String? postcode;
}
