// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enum_model.dart';

// **************************************************************************
// ModelGenerator
// **************************************************************************

MemberModel _$MemberModelFromJson(Map<String, dynamic> json) => MemberModel(
  role: $enumDecode(_$RoleEnumMap, json['role'], unknownValue: Role.guest),
  tier: $enumDecode(_$TierEnumMap, json['tier']),
  invitedBy: $enumDecodeNullable(_$RoleEnumMap, json['invitedBy']),
);

Map<String, dynamic> _$MemberModelToJson(MemberModel instance) =>
    <String, dynamic>{
      'role': _$RoleEnumMap[instance.role]!,
      'tier': _$TierEnumMap[instance.tier]!,
      'invitedBy': _$RoleEnumMap[instance.invitedBy],
    };

const _$RoleEnumMap = {
  Role.admin: 'admin',
  Role.member: 'member',
  Role.guest: 'guest',
};

const _$TierEnumMap = {
  Tier.freeTrial: 'free_trial',
  Tier.paidMonthly: 'paid_monthly',
  Tier.paidYearly: 'paid_yearly',
};

extension $MemberModelCopyWith on MemberModel {
  MemberModel copyWith({Role? role, Tier? tier, Object? invitedBy = $unset}) =>
      MemberModel(
        role: role ?? this.role,
        tier: tier ?? this.tier,
        invitedBy: invitedBy == $unset ? this.invitedBy : invitedBy as Role?,
      );
}

mixin _$MemberModel {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MemberModel || runtimeType != other.runtimeType) {
      return false;
    }
    final self = this as MemberModel;
    return self.role == other.role &&
        self.tier == other.tier &&
        self.invitedBy == other.invitedBy;
  }

  @override
  int get hashCode {
    final self = this as MemberModel;
    return Object.hash(runtimeType, self.role, self.tier, self.invitedBy);
  }

  @override
  String toString() {
    final self = this as MemberModel;
    return 'MemberModel(role: ${self.role}, tier: ${self.tier}, invitedBy: ${self.invitedBy})';
  }
}

InviteModel _$InviteModelFromJson(Map<String, dynamic> json) => InviteModel(
  role: $enumDecode(_$RoleEnumMap, json['role']),
  tier: $enumDecode(_$TierEnumMap, json['tier']),
);

Map<String, dynamic> _$InviteModelToJson(InviteModel instance) =>
    <String, dynamic>{
      'role': _$RoleEnumMap[instance.role]!,
      'tier': _$TierEnumMap[instance.tier]!,
    };

mixin _$InviteModel {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! InviteModel || runtimeType != other.runtimeType) {
      return false;
    }
    final self = this as InviteModel;
    return self.role == other.role && self.tier == other.tier;
  }

  @override
  int get hashCode {
    final self = this as InviteModel;
    return Object.hash(runtimeType, self.role, self.tier);
  }

  @override
  String toString() {
    final self = this as InviteModel;
    return 'InviteModel(role: ${self.role}, tier: ${self.tier})';
  }
}
