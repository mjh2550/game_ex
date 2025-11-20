import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/ddong_dodge_game.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/player.dart';

class Ddong extends SpriteComponent with HasGameReference<DdongDodgeGame>, CollisionCallbacks {
  final double speed;
  final double radius;

  Ddong({required Vector2 position, this.speed = 200.0, this.radius = 15.0}) : super(position: position);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('ddong.png');
    size = Vector2.all(radius * 2);
    anchor = Anchor.center;

    add(CircleHitbox());
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

  void checkNearMiss(Player player) {
    final distance = position.distanceTo(player.position);
    if (distance < 50 && distance > 30) {
      // 근접 회피 보너스
      game.scoreSystem.addNearMissBonus();
    }
  }
}
