class DifficultySystem {
  double gameTime = 0;

  void reset() {
    gameTime = 0;
  }

  void update(double dt) {
    gameTime += dt;
  }

  int getDifficultyLevel() {
    if (gameTime < 20) return 1;
    if (gameTime < 45) return 2;
    if (gameTime < 75) return 3;
    if (gameTime < 110) return 4;
    return 5;
  }

  double getDdongSpeed() {
    final level = getDifficultyLevel();
    final ramp = (gameTime * 4).clamp(0, 180).toDouble();

    switch (level) {
      case 1:
        return 210 + ramp;
      case 2:
        return 270 + ramp;
      case 3:
        return 330 + ramp;
      case 4:
        return 390 + ramp;
      default:
        return 460 + ramp;
    }
  }

  double getDdongSpawnInterval() {
    switch (getDifficultyLevel()) {
      case 1:
        return 0.95;
      case 2:
        return 0.78;
      case 3:
        return 0.62;
      case 4:
        return 0.5;
      default:
        return 0.42;
    }
  }

  int getDdongsPerSpawn() {
    switch (getDifficultyLevel()) {
      case 1:
        return 1;
      case 2:
        return 2;
      case 3:
        return 3;
      case 4:
        return 4;
      default:
        return 5;
    }
  }
}
