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
    size = Vector2.all(radius * 2);
    anchor = Anchor.center;
    
    try {
      sprite = await Sprite.load('ddong2.jpeg');
      // 히트박스를 이미지의 60%로 설정 (균형잡힌 판정)
      add(CircleHitbox(
        radius: radius * 0.6,
        anchor: Anchor.center,
      ));
    } catch (e) {
      print('Failed to load ddong2.jpeg: $e');
      // 이미지 로드 실패 시 색상 원으로 대체
      add(CircleComponent(
        radius: radius,
        paint: Paint()..color = const Color.fromARGB(255, 139, 69, 19),
      ));
      add(CircleHitbox(
        radius: radius * 0.6,
        anchor: Anchor.center,
      ));
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

  // 충돌 감지 - Ddong은 충돌 처리하지 않음 (Player에서만 처리)
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    print('Collision points: $intersectionPoints');
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
