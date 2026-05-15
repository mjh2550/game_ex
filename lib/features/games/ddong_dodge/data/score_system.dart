class ScoreSystem {
  int score = 0;
  int combo = 0;
  int maxCombo = 0;
  int nearMissCount = 0;
  double survivalTime = 0;
  int _bonusScore = 0;

  void update(double dt) {
    survivalTime += dt;
    score = (survivalTime * 10).toInt() + _bonusScore;
  }

  void addNearMissBonus() {
    combo++;
    if (combo > maxCombo) {
      maxCombo = combo;
    }
    nearMissCount++;
    final bonus = 50 * (1 + combo * 0.15);
    _bonusScore += bonus.toInt();
    score = (survivalTime * 10).toInt() + _bonusScore;
  }

  void resetCombo() {
    combo = 0;
  }

  void reset() {
    score = 0;
    combo = 0;
    maxCombo = 0;
    nearMissCount = 0;
    survivalTime = 0;
    _bonusScore = 0;
  }

  Map<String, dynamic> getGameStats() {
    return {
      'score': score,
      'survival_time': survivalTime,
      'near_miss_count': nearMissCount,
      'max_combo': maxCombo,
    };
  }
}
