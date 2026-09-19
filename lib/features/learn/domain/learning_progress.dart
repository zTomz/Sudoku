enum LearningSkill() {
  rules,
  candidates,
  nakedSingle,
  hiddenSingle,
  lockedCandidates,
  pairs,
  triples,
  wings,
}

final class const LearningProgress({
  final Set<LearningSkill> completedSkills = const {},
}) {
  factory empty() => const LearningProgress();

  int get completedCount => completedSkills.length;
  bool get complete => completedCount == LearningSkill.values.length;

  bool isCompleted(LearningSkill skill) => completedSkills.contains(skill);

  bool isUnlocked(LearningSkill skill) {
    final index = LearningSkill.values.indexOf(skill);
    return index == 0 || isCompleted(LearningSkill.values[index - 1]);
  }

  LearningProgress completeSkill(LearningSkill skill) {
    if (!isUnlocked(skill) || isCompleted(skill)) return this;
    return LearningProgress(completedSkills: {...completedSkills, skill});
  }

  Map<String, Object?> toJson() => {
    'completedSkills': completedSkills.map((skill) => skill.name).toList(),
  };

  factory fromJson(Map<String, Object?> json) {
    final raw = json['completedSkills'];
    if (raw is! List<Object?>) {
      throw const FormatException('Invalid learning progress');
    }
    final completed = <LearningSkill>{};
    for (final value in raw) {
      if (value is! String) {
        throw const FormatException('Invalid learning progress');
      }
      try {
        completed.add(LearningSkill.values.byName(value));
      } on ArgumentError {
        throw const FormatException('Invalid learning skill');
      }
    }
    for (var index = 1; index < LearningSkill.values.length; index++) {
      if (completed.contains(LearningSkill.values[index]) &&
          !completed.contains(LearningSkill.values[index - 1])) {
        throw const FormatException('Learning skills must be sequential');
      }
    }
    return LearningProgress(completedSkills: Set.unmodifiable(completed));
  }
}
