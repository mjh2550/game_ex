import 'dart:math';

import 'package:flame/components.dart';
import 'package:game_ex/features/games/ddong_dodge/data/difficulty_system.dart';
import 'package:game_ex/features/games/ddong_dodge/domain/ddong.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/ddong_dodge_game.dart';

class DdongSpawner extends Component with HasGameReference<DdongDodgeGame> {
  final Random _random = Random();

  double spawnTimer = 0;
  double spawnInterval = 1.0;

  final DifficultySystem difficultySystem;

  DdongSpawner(this.difficultySystem);

  @override
  void update(double dt) {
    super.update(dt);

    if (game.isGameOver) {
      return;
    }

    spawnTimer += dt;

    if (spawnTimer >= spawnInterval) {
      spawnDdong();
      spawnTimer = 0;
      spawnInterval = difficultySystem.getDdongSpawnInterval();
    }
  }

  void spawnDdong() {
    final count = difficultySystem.getDdongsPerSpawn();
    final baseSpeed = difficultySystem.getDdongSpeed();
    final width = game.size.x;
    final laneWidth = width / (count + 1);

    for (int i = 0; i < count; i++) {
      final laneCenter = laneWidth * (i + 1);
      final jitter = (_random.nextDouble() - 0.5) * laneWidth * 0.72;
      final radius = 17 + _random.nextDouble() * 8;
      final x = (laneCenter + jitter).clamp(radius, width - radius).toDouble();
      final y = -radius - (_random.nextDouble() * 90) - (i * 16);
      final speed = baseSpeed + _random.nextDouble() * 80;

      game.add(Ddong(position: Vector2(x, y), speed: speed, radius: radius));
    }
  }

  void spawnMultipleDdongs(int count) {
    for (int i = 0; i < count; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (!isRemoved && !game.isGameOver) {
          spawnDdong();
        }
      });
    }
  }
}
