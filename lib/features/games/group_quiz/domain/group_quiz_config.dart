class GroupQuizConfig {
  const GroupQuizConfig({
    this.teamCount = 2,
    this.roundLimit = 10,
    this.secondsPerRound = 8,
    this.attemptLimit = adaptiveAttempts,
    this.category = allCategory,
  });

  static const allCategory = '전체';
  static const adaptiveAttempts = -1;
  static const unlimitedAttempts = 0;

  final int teamCount;
  final int roundLimit;
  final int secondsPerRound;
  final int attemptLimit;
  final String category;

  bool get hasTimeLimit => secondsPerRound > 0;
  bool get hasAttemptLimit => attemptLimit != unlimitedAttempts;

  GroupQuizConfig copyWith({
    int? teamCount,
    int? roundLimit,
    int? secondsPerRound,
    int? attemptLimit,
    String? category,
  }) {
    return GroupQuizConfig(
      teamCount: teamCount ?? this.teamCount,
      roundLimit: roundLimit ?? this.roundLimit,
      secondsPerRound: secondsPerRound ?? this.secondsPerRound,
      attemptLimit: attemptLimit ?? this.attemptLimit,
      category: category ?? this.category,
    );
  }
}
