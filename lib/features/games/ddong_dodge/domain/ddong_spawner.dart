import 'dart:math';

import 'package:flame/components.dart';
import 'package:game_ex/features/games/ddong_dodge/data/difficulty_system.dart';
import 'package:game_ex/features/games/ddong_dodge/domain/ddong.dart';

class DdongSpawner extends Component with HasGameReference {
  
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
    final count = difficultySystem.getDdongsPerSpawn();
    final random = Random();
    final speed = difficultySystem.getDdongSpeed();
    
    // 모든 경우에 완전 랜덤으로 생성
    for (int i = 0; i < count; i++) {
      // x: 0 ~ 게임 화면 너비 (완전 랜덤)
      final x = random.nextDouble() * game.size.x;
      
      // y: -20 ~ -100 사이 (상단에서 약간 떨어진 곳)
      final y = -20 - random.nextDouble() * 80;
      
      game.add(Ddong(position: Vector2(x, y), speed: speed));
    }
  }
  
  void spawnMultipleDdongs(int count) {
    for (int i = 0; i < count; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        spawnDdong();
      });
    }
  }
}