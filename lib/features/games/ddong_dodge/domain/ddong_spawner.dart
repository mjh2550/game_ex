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
    
    if (count == 1) {
      // 1개일 때는 완전 랜덤
      final x = random.nextDouble() * game.size.x;
      game.add(Ddong(position: Vector2(x, -20), speed: speed));
    } else {
      // 여러 개일 때는 화면을 균등 분할
      final screenWidth = game.size.x;
      final segmentWidth = screenWidth / count;
      
      for (int i = 0; i < count; i++) {
        // 각 구간 내에서 랜덤 위치
        final segmentStart = i * segmentWidth;
        final margin = segmentWidth * 0.1; // 구간 경계에서 10% 여유
        
        final x = segmentStart + margin + 
                  random.nextDouble() * (segmentWidth - 2 * margin);
        
        // y좌표도 약간씩 다르게 (-20 ~ -80 사이)
        final y = -20 - random.nextDouble() * 60;
        
        game.add(Ddong(position: Vector2(x, y), speed: speed));
      }
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