class ScoreRecord {
  final String id;
  final String gameId;
  final String playerName;
  final int score;
  final double playTime;
  final int nearMissCount;
  final int maxCombo;
  final int difficultyReached;
  final DateTime playedAt;

  const ScoreRecord({
    required this.id,
    required this.gameId,
    required this.playerName,
    required this.score,
    required this.playTime,
    required this.nearMissCount,
    required this.maxCombo,
    required this.difficultyReached,
    required this.playedAt,
  });

  factory ScoreRecord.fromJson(Map<String, dynamic> json) {
    return ScoreRecord(
      id: json['id'] as String,
      gameId: json['gameId'] as String,
      playerName: json['playerName'] as String? ?? '익명',
      score: json['score'] as int,
      playTime: (json['playTime'] as num).toDouble(),
      nearMissCount: json['nearMissCount'] as int,
      maxCombo: json['maxCombo'] as int,
      difficultyReached: json['difficultyReached'] as int,
      playedAt: DateTime.parse(json['playedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameId': gameId,
      'playerName': playerName,
      'score': score,
      'playTime': playTime,
      'nearMissCount': nearMissCount,
      'maxCombo': maxCombo,
      'difficultyReached': difficultyReached,
      'playedAt': playedAt.toIso8601String(),
    };
  }
}

class ScoreSaveResult {
  final ScoreRecord record;
  final int bestScore;
  final bool isNewBest;
  final int rank;

  const ScoreSaveResult({
    required this.record,
    required this.bestScore,
    required this.isNewBest,
    required this.rank,
  });
}
