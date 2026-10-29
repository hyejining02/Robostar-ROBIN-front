import 'package:flutter/foundation.dart';

import '../models/access_control.dart';
import '../widgets/user_profile.dart';

/// A front-end view context, not a replacement for server-side authorization.
final selectedBusinessDivision = ValueNotifier<RobinBusinessDivision?>(null);

class BusinessDivisionScope {
  final Set<RobinBusinessDivision> allowed;
  final RobinBusinessDivision? selected;

  const BusinessDivisionScope._(this.allowed, this.selected);

  factory BusinessDivisionScope.current() {
    final profile = robinUserProfile.value;
    final memberships = robinTeams.value.where((team) =>
        team.memberIds.contains(profile.username) ||
        team.leaderId == profile.username);
    final divisions = memberships.map((team) => team.division).toSet();
    // Existing demo dealers represent the robot sales channel. Do not infer
    // division access from an editable department label.
    final allowed = profile.isDealer
        ? ({'dealer', 'kimdealer'}.contains(profile.username)
            ? <RobinBusinessDivision>{RobinBusinessDivision.robot}
            : <RobinBusinessDivision>{})
        : profile.isAdmin || divisions.contains(RobinBusinessDivision.common)
            ? <RobinBusinessDivision>{
                RobinBusinessDivision.robot,
                RobinBusinessDivision.platformModule,
              }
            : divisions.where((d) => d != RobinBusinessDivision.common).toSet();
    final preference = selectedBusinessDivision.value;
    return BusinessDivisionScope._(
      allowed,
      allowed.length == 1
          ? allowed.first
          : allowed.contains(preference)
              ? preference
              : null,
    );
  }

  bool includes(RobinBusinessDivision division) =>
      allowed.contains(division) && (selected == null || selected == division);

  String get label =>
      allowed.isEmpty ? '배정 사업부 없음' : selected?.label ?? '전체 사업부';
}
