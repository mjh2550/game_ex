import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/ddong_dodge_game.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/player.dart';

class Ddong extends SpriteComponent with HasGameReference<DdongDodgeGame> {
  final double speed;
  final double radius;
  bool _nearMissAwarded = false;

  double get collisionRadius => radius * 0.34;

  Ddong({required Vector2 position, this.speed = 200.0, this.radius = 18.0})
    : super(position: position, anchor: Anchor.center, priority: 10);

  @override
  Future<void> onLoad() async {
    size = Vector2.all(radius * 2);
    sprite = await Sprite.load('openmoji_poop.png');
    add(
      CircleComponent(
        position: Vector2(size.x / 2, size.y / 2),
        radius: collisionRadius,
        anchor: Anchor.center,
        priority: 1,
        paint: Paint()
          ..color = const Color(0xCCE53935)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += speed * dt;
    _checkHitPlayer();
    _checkNearMiss();

    if (position.y > game.size.y + radius) {
      removeFromParent();
    }
  }

  void _checkNearMiss() {
    if (_nearMissAwarded || game.isGameOver || !game.hasPlayer) {
      return;
    }

    final player = game.player;
    final verticalGap = (position.y - player.position.y).abs();
    final horizontalGap = (position.x - player.position.x).abs();
    final hitZone = collisionRadius + Player.hitboxWidth / 2;
    final nearZone = hitZone + 28;

    if (position.y > player.position.y && verticalGap < collisionRadius + 12) {
      if (horizontalGap > hitZone && horizontalGap < nearZone) {
        _nearMissAwarded = true;
        game.registerNearMiss();
      }
    }
  }

  void _checkHitPlayer() {
    if (game.isGameOver || !game.hasPlayer) {
      return;
    }

    if (_circleOverlapsRect(
      position.x,
      position.y,
      collisionRadius,
      game.player.collisionRect,
    )) {
      game.player.takeDamage();
    }
  }

  bool _circleOverlapsRect(double cx, double cy, double r, Rect rect) {
    final closestX = cx.clamp(rect.left, rect.right);
    final closestY = cy.clamp(rect.top, rect.bottom);
    final dx = cx - closestX;
    final dy = cy - closestY;

    return math.sqrt((dx * dx) + (dy * dy)) <= r;
  }

  @override
  void onRemove() {
    if (!_nearMissAwarded && game.hasPlayer && !game.isGameOver) {
      final player = game.player;
      if ((position.x - player.position.x).abs() > radius + player.size.x) {
        game.scoreSystem.resetCombo();
      }
    }
    super.onRemove();
  }
}
