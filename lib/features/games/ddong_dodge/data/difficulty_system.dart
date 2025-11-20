class DifficultySystem {
  double gameTime = 0;

  void reset() {
    gameTime = 0;
  }
  
  void update(double dt) {
    gameTime += dt;
  }
  
  int getDifficultyLevel() {
    if (gameTime < 30) return 1;
    if (gameTime < 60) return 2;
    if (gameTime < 90) return 3;
    return 4;
  }
  
  double getDdongSpeed() {
    switch (getDifficultyLevel()) {
      case 1: return 150.0;
      case 2: return 250.0;
      case 3: return 350.0;
      case 4: return 450.0;
      default: return 200.0;
    }
  }
  
  double getDdongSpawnInterval() {
    switch (getDifficultyLevel()) {
      case 1: return 1.5;
      case 2: return 1.0;
      case 3: return 0.7;
      case 4: return 0.5;
      default: return 1.5;
    }
  }
  
  int getDdongsPerSpawn() {
    switch (getDifficultyLevel()) {
      case 1: return 1;
      case 2: return 2;
      case 3: return 2;
      case 4: return 3;
      default: return 1;
    }
  }
}