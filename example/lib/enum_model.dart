import 'package:modelith/modelith.dart';

part 'enum_model.g.dart';

/// Per-entry wire values, set with `@ModelValue`.
@ModelEnum()
enum Role {
  @ModelValue('admin')
  admin,
  @ModelValue('member')
  member,
  @ModelValue('guest')
  guest,
}

/// `fieldRename` encodes the entries that carry no `@ModelValue`, and
/// `alwaysCreate` emits the map whether or not a model in this library holds
/// the enum.
@ModelEnum(alwaysCreate: true, fieldRename: FieldRename.snake)
enum Tier { freeTrial, paidMonthly, paidYearly }

@Model()
class MemberModel with _$MemberModel {
  const MemberModel({required this.role, required this.tier, this.invitedBy});

  factory MemberModel.fromJson(Map<String, dynamic> json) =>
      _$MemberModelFromJson(json);

  Map<String, dynamic> toJson() => _$MemberModelToJson(this);

  /// A wire value outside the map falls back here instead of throwing.
  @ModelField(unknownEnumValue: Role.guest)
  final Role role;

  @ModelField()
  final Tier tier;

  @ModelField()
  final Role? invitedBy;
}

/// A second model over the same enums: each map is still emitted once, because
/// the generator deduplicates the fragments both models ask for.
@Model(copyWith: false)
class InviteModel with _$InviteModel {
  const InviteModel({required this.role, required this.tier});

  factory InviteModel.fromJson(Map<String, dynamic> json) =>
      _$InviteModelFromJson(json);

  Map<String, dynamic> toJson() => _$InviteModelToJson(this);

  @ModelField()
  final Role role;

  @ModelField()
  final Tier tier;
}
