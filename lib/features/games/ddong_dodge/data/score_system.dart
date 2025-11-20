class ScoreSystem {
  int score = 0;
  int combo = 0;
  int nearMissCount = 0;
  double survivalTime = 0;
  
  void update(double dt) {
    survivalTime += dt;
    // 1초당 10점
    score = (survivalTime * 10).toInt();
  }
  
  void addNearMissBonus() {
    combo++;
    nearMissCount++;
    final bonus = 50 * (1 + combo * 0.2);
    score += bonus.toInt();
  }
  
  void resetCombo() {
    combo = 0;
  }

  void reset() {
    score = 0;
    combo = 0;
    nearMissCount = 0;
    survivalTime = 0;
  }
  
  Map<String, dynamic> getGameStats() {
    return {
      'score': score,
      'survival_time': survivalTime,
      'near_miss_count': nearMissCount,
      'max_combo': combo,
    };
  }
}