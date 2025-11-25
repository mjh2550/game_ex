import 'dart:ui';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:game_ex/features/games/ddong_dodge/data/difficulty_system.dart';
import 'package:game_ex/features/games/ddong_dodge/data/score_system.dart';
import 'package:game_ex/features/games/ddong_dodge/domain/ddong.dart';
import 'package:game_ex/features/games/ddong_dodge/domain/ddong_spawner.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/game_state_provider.dart';
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

class DdongDodgeGame extends FlameGame with HasCollisionDetection, KeyboardEvents {
  final Function(GameResult) onGameOver;
  final VoidCallback onPause;
  final String userId;
  final GameInfo gameInfo;
  final Function(GameState)? onStateUpdate; // Provider 업데이트 콜백 추가

  DdongDodgeGame({
    required this.gameInfo,
    required this.onGameOver,
    required this.onPause,
    required this.userId,
    this.onStateUpdate, // 선택적 파라미터
  });

  late Player player;
  late ScoreSystem scoreSystem;
  late DifficultySystem difficultySystem;
  
  bool isGameOver = false;
  
  // 터치 상태 추적
  bool isLeftPressed = false;
  bool isRightPressed = false;

  @override
  Color backgroundColor() => const Color(0xFFFFFFFF);

  // 디버그 모드 활성화 (히트박스 시각화)
  @override
  bool get debugMode => false;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    print('🎮 DdongDodgeGame.onLoad() started');
    print('Game size: $size');

    // 배경색을 흰색으로 설정
    final whitePaint = Paint()..color = Colors.white;
    add(
      RectangleComponent(
        size: Vector2(size.x, size.y),
        position: Vector2.zero(),
        paint: whitePaint,
        priority: -100, // 맨 뒤에 렌더링
      ),
    );
    print('✅ White background added');

    // 게임 초기화
    scoreSystem = ScoreSystem();
    difficultySystem = DifficultySystem();

    // 컴포넌트 추가
    // world.add(Background());
    
    print('🎮 Creating Player...');
    player = Player();
    add(player); // 게임에 직접 추가
    print('✅ Player added to game');
    
    add(DdongSpawner(difficultySystem)); 
    print('✅ DdongSpawner added');

    // HUD 오버레이 표시
    overlays.add('hud');
    print('✅ HUD overlay added');
    print('🎮 DdongDodgeGame.onLoad() completed');
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!paused && !isGameOver) {
      scoreSystem.update(dt);
      difficultySystem.update(dt);
      
      // Provider 상태 업데이트 (매 프레임)
      onStateUpdate?.call(GameState(
        score: scoreSystem.score,
        playTime: scoreSystem.survivalTime,
        combo: scoreSystem.combo,
        nearMissCount: scoreSystem.nearMissCount,
        difficultyLevel: difficultySystem.getDifficultyLevel(),
        isPaused: paused,
        isGameOver: isGameOver,
      ));
      
      // 터치 입력에 따른 플레이어 이동
      if (isLeftPressed) {
        player.moveLeft();
      } else if (isRightPressed) {
        player.moveRight();
      } else {
        player.stopMoving();
      }
    }
  }

  // 키보드 입력 처리
  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isKeyDown = event is KeyDownEvent;

    // 왼쪽 화살표 또는 A 키
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.keyA) {
      isLeftPressed = isKeyDown;
      return KeyEventResult.handled;
    }

    // 오른쪽 화살표 또는 D 키
    if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.keyD) {
      isRightPressed = isKeyDown;
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
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