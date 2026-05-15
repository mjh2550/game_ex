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

class DdongDodgeGame extends FlameGame
    with HasCollisionDetection, KeyboardEvents {
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
  late DdongSpawner ddongSpawner;

  bool isGameOver = false;
  bool _isLoaded = false;
  double _stateUpdateTimer = 0;

  @override
  Color backgroundColor() => const Color(0xFFEAF7FF);

  @override
  bool get debugMode => false;

  bool get hasPlayer => _isLoaded && player.isMounted;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    scoreSystem = ScoreSystem();
    difficultySystem = DifficultySystem();
    ddongSpawner = DdongSpawner(difficultySystem);

    add(_DdongDodgeBackground());
    player = Player();
    add(player);
    add(ddongSpawner);

    overlays.add('hud');
    _isLoaded = true;
    _emitState();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!paused && !isGameOver) {
      scoreSystem.update(dt);
      difficultySystem.update(dt);

      _stateUpdateTimer += dt;
      if (_stateUpdateTimer >= 0.1) {
        _stateUpdateTimer = 0;
        _emitState();
      }

      final hasLeft = HardwareKeyboard.instance.logicalKeysPressed.contains(
        LogicalKeyboardKey.arrowLeft,
      );
      final hasRight = HardwareKeyboard.instance.logicalKeysPressed.contains(
        LogicalKeyboardKey.arrowRight,
      );
      if (hasLeft && !hasRight) {
        player.moveLeft();
      } else if (hasRight && !hasLeft) {
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
    return KeyEventResult.handled;
  }

  void triggerGameOver() {
    if (isGameOver) return;

    isGameOver = true;
    player.stopMoving();
    _emitState();
    pauseEngine();

    final result = GameResult(
      score: scoreSystem.score,
      playTime: scoreSystem.survivalTime,
      stats: {
        'near_miss_count': scoreSystem.nearMissCount,
        'max_combo': scoreSystem.maxCombo,
        'difficulty_reached': difficultySystem.getDifficultyLevel(),
      },
      metadata: {'game_version': '1.0.0'},
    );

    onGameOver(result);
  }

  void pauseGame() {
    pauseEngine();
    _emitState();
    onPause();
  }

  void resetGame() {
    isGameOver = false;
    scoreSystem.reset();
    difficultySystem.reset();

    for (final ddong in children.whereType<Ddong>().toList()) {
      ddong.removeFromParent();
    }

    player.reset();
    _stateUpdateTimer = 0;
    _emitState();
    resumeEngine();
  }

  void registerNearMiss() {
    scoreSystem.addNearMissBonus();
    _emitState();
  }

  void _emitState() {
    onStateUpdate?.call(
      GameState(
        score: scoreSystem.score,
        playTime: scoreSystem.survivalTime,
        combo: scoreSystem.combo,
        nearMissCount: scoreSystem.nearMissCount,
        difficultyLevel: difficultySystem.getDifficultyLevel(),
        isPaused: paused,
        isGameOver: isGameOver,
      ),
    );
  }
}

class _DdongDodgeBackground extends PositionComponent
    with HasGameReference<DdongDodgeGame> {
  _DdongDodgeBackground() : super(priority: -100);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void render(Canvas canvas) {
    final rect = Offset.zero & Size(size.x, size.y);
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFEAF7FF), Color(0xFFFFFFFF)],
      ).createShader(rect);

    canvas.drawRect(rect, skyPaint);

    final linePaint = Paint()
      ..color = const Color(0x22008ECF)
      ..strokeWidth = 1;

    for (double y = 80; y < size.y; y += 96) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), linePaint);
    }

    final floorPaint = Paint()..color = const Color(0xFFE7F3D2);
    canvas.drawRect(Rect.fromLTWH(0, size.y - 40, size.x, 40), floorPaint);
  }
}
