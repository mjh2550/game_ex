class GroupQuizConfig {
  const GroupQuizConfig({
    this.teamCount = 2,
    this.roundLimit = 10,
    this.secondsPerRound = 8,
    this.category = allCategory,
  });

  static const allCategory = '전체';

  final int teamCount;
  final int roundLimit;
  final int secondsPerRound;
  final String category;

  bool get hasTimeLimit => secondsPerRound > 0;

  GroupQuizConfig copyWith({
    int? teamCount,
    int? roundLimit,
    int? secondsPerRound,
    String? category,
  }) {
    return GroupQuizConfig(
      teamCount: teamCount ?? this.teamCount,
      roundLimit: roundLimit ?? this.roundLimit,
      secondsPerRound: secondsPerRound ?? this.secondsPerRound,
      category: category ?? this.category,
    );
  }
}
