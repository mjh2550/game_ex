class DifficultySystem {
  double gameTime = 0;

  void reset() {
    gameTime = 0;
  }
  
  void update(double dt) {
    gameTime += dt;
  }
  
  int getDifficultyLevel() {
    if (gameTime < 10) return 1;
    if (gameTime < 30) return 2;
    if (gameTime < 60) return 3;
    return 4;
  }
  
  double getDdongSpeed() {
    final level = getDifficultyLevel();
    print('Current Difficulty Level: $level');
    switch (level) {
      case 1: return 500.0;
      case 2: return 650.0;
      case 3: return 800.0;
      case 4: return 1000.0;
      default: return 500.0;
    }
  }
  
  double getDdongSpawnInterval() {
    switch (getDifficultyLevel()) {
      case 1: return 0.5;
      case 2: return 0.4;
      case 3: return 0.3;
      case 4: return 0.2;
      default: return 0.5;
    }
  }
  
  int getDdongsPerSpawn() {
    switch (getDifficultyLevel()) {
      case 1: return 5;
      case 2: return 7;
      case 3: return 10;
      case 4: return 20;
      default: return 5;
    }
  }
}