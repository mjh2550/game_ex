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
    switch (getDifficultyLevel()) {
      case 1: return 350.0;
      case 2: return 450.0;
      case 3: return 550.0;
      case 4: return 650.0;
      default: return 350.0;
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
      case 1: return 2;
      case 2: return 3;
      case 3: return 3;
      case 4: return 4;
      default: return 2;
    }
  }
}