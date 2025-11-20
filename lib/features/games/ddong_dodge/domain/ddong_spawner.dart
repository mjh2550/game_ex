import 'dart:math';

import 'package:flame/components.dart';
import 'package:game_ex/features/games/ddong_dodge/data/difficulty_system.dart';
import 'package:game_ex/features/games/ddong_dodge/domain/ddong.dart';

class DdongSpawner extends Component with HasGameRef {
  
  double spawnTimer = 0;
  double spawnInterval = 1.5; // 초기 1.5초마다 생성
  
  final DifficultySystem difficultySystem;
  
  DdongSpawner(this.difficultySystem);
  
  @override
  void update(double dt) {
    super.update(dt);
    
    spawnTimer += dt;
    
    if (spawnTimer >= spawnInterval) {
      spawnDdong();
      spawnTimer = 0;
      
      // 난이도에 따라 간격 조정
      spawnInterval = difficultySystem.getDdongSpawnInterval();
    }
  }
  
  void spawnDdong() {
    final random = Random();
    final x = random.nextDouble() * gameRef.size.x;
    final speed = difficultySystem.getDdongSpeed();
    
    final ddong = Ddong(
      position: Vector2(x, -20),
      speed: speed,
    );
    
    gameRef.add(ddong); // 게임에 직접 추가
  }
  
  void spawnMultipleDdongs(int count) {
    for (int i = 0; i < count; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        spawnDdong();
      });
    }
  }
}