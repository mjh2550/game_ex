import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:game_ex/features/games/ddong_dodge/data/difficulty_system.dart';
import 'package:game_ex/features/games/ddong_dodge/data/score_system.dart';
import 'package:game_ex/features/games/ddong_dodge/domain/ddong.dart';
import 'package:game_ex/features/games/ddong_dodge/domain/ddong_spawner.dart';
import 'package:game_ex/shared/game_info.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/player.dart';

class GameResult {
  final int score;
  final double playTime;
  final Map<String, dynamic> stats;
  final Map<String, dynamic> metadata;

  GameResult({
    required this.score,
    required this.playTime,
    required this.stats,
    required this.metadata,
  });
}

class DdongDodgeGame extends FlameGame with HasCollisionDetection {
  final Function(GameResult) onGameOver;
  final VoidCallback onPause;
  final String userId;
  final GameInfo gameInfo;

  DdongDodgeGame({
    required this.gameInfo,
    required this.onGameOver,
    required this.onPause,
    required this.userId,
  });

  late Player player;
  late ScoreSystem scoreSystem;
  late DifficultySystem difficultySystem;
  
  bool isGameOver = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 게임 초기화
    scoreSystem = ScoreSystem();
    difficultySystem = DifficultySystem();

    // 컴포넌트 추가
    // world.add(Background());
    
    player = Player();
    world.add(player);
    
    world.add(DdongSpawner(difficultySystem));

    // HUD 오버레이 표시
    overlays.add('hud');
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!paused && !isGameOver) {
      scoreSystem.update(dt);
      difficultySystem.update(dt);
    }
  }

  // 🏁 게임 오버 처리
  void triggerGameOver() {
    if (isGameOver) return;
    
    isGameOver = true;
    pauseEngine();

    // 결과 데이터 생성
    final result = GameResult(
      score: scoreSystem.score,
      playTime: scoreSystem.survivalTime,
      stats: {
        'near_miss_count': scoreSystem.nearMissCount,
        'max_combo': scoreSystem.combo,
        'difficulty_reached': difficultySystem.getDifficultyLevel(),
      },
      metadata: {
        // 'ddongs_spawned': difficultySystem.getDdongsPerSpawn(),
        'game_version': '1.0.0',
      },
    );

    // 🔄 Flutter 앱으로 콜백
    onGameOver(result);
  }

  // ⏸️ 일시정지
  void pauseGame() {
    pauseEngine();
    onPause();
  }

  // 🔄 게임 리셋
  void resetGame() {
    isGameOver = false;
    scoreSystem.reset();
    difficultySystem.reset();
    
    // 모든 똥 제거
    world.children.whereType<Ddong>().forEach((ddong) {
      ddong.removeFromParent();
    });
    
    // 플레이어 위치 초기화
    player.reset();
    
    resumeEngine();
  }
}