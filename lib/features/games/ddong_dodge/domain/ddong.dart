import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/ddong_dodge_game.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/player.dart';

class Ddong extends SpriteComponent with HasGameReference<DdongDodgeGame>, CollisionCallbacks {
  final double speed;
  final double radius;

  Ddong({required Vector2 position, this.speed = 200.0, this.radius = 15.0}) : super(position: position);

  @override
  Future<void> onLoad() async {
    try {
      sprite = await Sprite.load('ddong2.jpeg');
      size = Vector2.all(radius * 2);
      anchor = Anchor.center;

      add(CircleHitbox());
    } catch (e) {
      print('Failed to load ddong2.jpeg: $e');
      // 이미지 로드 실패 시 색상 원으로 대체
      add(CircleComponent(
        radius: radius,
        paint: Paint()..color = const Color.fromARGB(255, 139, 69, 19),
      ));
      add(CircleHitbox());
      size = Vector2.all(radius * 2);
      anchor = Anchor.center;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 아래로 이동
    position.y += speed * dt;

    // 화면 밖으로 나가면 제거
    if (position.y > game.size.y + radius) {
      removeFromParent();
    }
  }

  // 충돌 감지
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is Player) {
      print('💥 Ddong collided with Player!');
      removeFromParent();
    }
  }

  void checkNearMiss(Player player) {
    final distance = position.distanceTo(player.position);
    if (distance < 50 && distance > 30) {
      // 근접 회피 보너스
      game.scoreSystem.addNearMissBonus();
    }
  }
}
