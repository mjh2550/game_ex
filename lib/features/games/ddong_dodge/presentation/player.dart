import 'dart:ui';

import 'package:flame/components.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/ddong_dodge_game.dart';

class Player extends SpriteComponent with HasGameReference<DdongDodgeGame> {
  static const double speed = 360.0;
  static const double playerSize = 54.0;
  static const double bottomMargin = 76.0;
  static const double hitboxWidth = 18.0;
  static const double hitboxHeight = 34.0;
  static const double hitboxOffsetY = 4.0;

  double moveDirection = 0.0;
  bool isInvulnerable = false;

  Player()
    : super(size: Vector2.all(playerSize), anchor: Anchor.center, priority: 20);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('openmoji_player.png');
    reset();

    final hitboxSize = Vector2(hitboxWidth, hitboxHeight);
    final hitboxPosition = Vector2(size.x / 2, size.y / 2 + hitboxOffsetY);

    add(
      RectangleComponent(
        position: hitboxPosition,
        size: hitboxSize,
        anchor: Anchor.center,
        priority: 1,
        paint: Paint()
          ..color = const Color(0xCC1A73E8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      ),
    );
  }

  void reset() {
    position = Vector2(game.size.x / 2, game.size.y - bottomMargin);
    isInvulnerable = false;
    moveDirection = 0.0;
  }

  void moveLeft() {
    moveDirection = -1.0;
  }

  void moveRight() {
    moveDirection = 1.0;
  }

  void stopMoving() {
    moveDirection = 0.0;
  }

  Rect get collisionRect {
    final center = Offset(position.x, position.y + hitboxOffsetY);
    return Rect.fromCenter(
      center: center,
      width: hitboxWidth,
      height: hitboxHeight,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.x += moveDirection * speed * dt;
    position.x = position.x.clamp(size.x / 2, game.size.x - size.x / 2);
  }

  void takeDamage() {
    if (!isInvulnerable) {
      game.triggerGameOver();
    }
  }
}
