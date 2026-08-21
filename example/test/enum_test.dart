import 'package:modelith_example/enum_model.dart';
import 'package:test/test.dart';

void main() {
  group('enums', () {
    test('@ModelValue sets the wire value of an entry', () {
      const member = MemberModel(role: Role.admin, tier: Tier.freeTrial);

      expect(member.toJson()['role'], 'admin');
      expect(MemberModel.fromJson(member.toJson()), member);
    });

    test('@ModelEnum(fieldRename:) encodes the unannotated entries', () {
      const member = MemberModel(role: Role.member, tier: Tier.paidMonthly);

      expect(member.toJson()['tier'], 'paid_monthly');
      expect(MemberModel.fromJson(member.toJson()).tier, Tier.paidMonthly);
    });

    test('unknownEnumValue catches a value outside the map', () {
      final member = MemberModel.fromJson({
        'role': 'owner',
        'tier': 'free_trial',
      });

      expect(member.role, Role.guest);
    });

    test('a value outside the map throws without unknownEnumValue', () {
      expect(
        () => MemberModel.fromJson({'role': 'admin', 'tier': 'lifetime'}),
        throwsArgumentError,
      );
    });

    test('a nullable enum field round-trips null', () {
      const member = MemberModel(role: Role.guest, tier: Tier.paidYearly);

      expect(member.toJson()['invitedBy'], isNull);
      expect(MemberModel.fromJson(member.toJson()).invitedBy, isNull);
    });

    test('enum fields take part in equality and copyWith', () {
      const member = MemberModel(role: Role.guest, tier: Tier.freeTrial);

      expect(
        member.copyWith(role: Role.admin),
        const MemberModel(role: Role.admin, tier: Tier.freeTrial),
      );
      expect(member.copyWith(role: Role.admin), isNot(member));
      expect(member.copyWith(invitedBy: Role.admin).invitedBy, Role.admin);
    });

    test('two models over the same enums share one generated map', () {
      const invite = InviteModel(role: Role.admin, tier: Tier.paidYearly);

      expect(invite.toJson(), {'role': 'admin', 'tier': 'paid_yearly'});
      expect(InviteModel.fromJson(invite.toJson()), invite);
    });
  });
}
