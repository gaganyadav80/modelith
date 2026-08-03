import 'package:modelith/modelith.dart';

part 'address_model.g.dart';

/// A flat model: nothing but `@Model()` plus the one `fromJson` line.
@Model()
class AddressModel with _$AddressModel implements JsonModel {
  const AddressModel({required this.city, required this.postcode});

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  @ModelField()
  final String city;

  @ModelField()
  final String? postcode;
}
