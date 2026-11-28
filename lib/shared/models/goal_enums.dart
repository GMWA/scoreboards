enum GoalStatus {
  valid('valid'),
  cancelled('cancelled'),
  pending('pending'),
  missed('missed');

  const GoalStatus(this.value);
  final String value;

  static GoalStatus fromString(String value) => GoalStatus.values
      .firstWhere((e) => e.value == value, orElse: () => GoalStatus.valid);
}

enum GoalType {
  normal('normal'),
  penalty('penalty'),
  ownGoal('own'),
  penaltyShootout('pso');

  const GoalType(this.value);
  final String value;

  static GoalType fromString(String value) => GoalType.values
      .firstWhere((e) => e.value == value, orElse: () => GoalType.normal);
}
