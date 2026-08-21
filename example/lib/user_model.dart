import 'package:modelith/modelith.dart';
import 'package:modelith_example/address_model.dart';

part 'user_model.g.dart';

/// A nested model: [address] is itself a `@Model` class, and [tags] exercises
/// Equatable's deep collection comparison.
@Model(explicitToJson: true)
class UserModel with _$UserModel {
  const UserModel({
    required this.id,
    required this.address,
    this.tags = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @ModelField()
  final String id;

  @ModelField()
  final AddressModel address;

  @ModelField()
  final List<String> tags;
}
