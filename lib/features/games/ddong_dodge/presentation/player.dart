import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:game_ex/features/games/ddong_dodge/domain/ddong.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/ddong_dodge_game.dart';

class Player extends SpriteComponent with HasGameReference<DdongDodgeGame>, CollisionCallbacks, DragCallbacks {
  static const double speed = 300.0;
  static const double sizeD = 40.0;

  Vector2 velocity = Vector2.zero();
  bool isInvulnerable = false;

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('player.png');
    size = Vector2.all(sizeD);
    anchor = Anchor.center;
    position = Vector2(game.size.x / 2, game.size.y - 100);

    add(CircleHitbox());
  }

  void reset() {
    position = Vector2(game.size.x / 2, game.size.y - 100);
    isInvulnerable = false;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 위치 업데이트
    position += velocity * dt;

    // 경계 체크
    position.x = position.x.clamp(size.x / 2, game.size.x - size.x / 2);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    velocity.x = event.localDelta.x * 60; // Assuming 60 FPS
  }

  @override
  bool collidingWith(PositionComponent other) {
    if (other is Ddong) {
      takeDamage();
    }
    return super.collidingWith(other);
  }

  void takeDamage() {
    if (!isInvulnerable) {
      // 게임 오버 처리
      game.onGameOver(
        GameResult(
          score: game.scoreSystem.score,
          playTime: game.scoreSystem.survivalTime,
          stats: game.scoreSystem.getGameStats(),
          metadata: {},
        ),
      );
    }
  }
}
