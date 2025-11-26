import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:game_ex/features/games/ddong_dodge/domain/ddong.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/ddong_dodge_game.dart';

class Player extends PositionComponent with HasGameReference<DdongDodgeGame>, CollisionCallbacks {
  static const double speed = 300.0;
  static const double sizeD = 30.0;
  static const double bottomMargin = 100.0;

  double moveDirection = 0.0; // -1: 좌, 0: 정지, 1: 우
  bool isInvulnerable = false;

  Player()
    : super(
        size: Vector2.all(sizeD),
        anchor: Anchor.topLeft,
        priority: 10, // 다른 컴포넌트보다 앞에 렌더링
      );

  @override
  Future<void> onLoad() async {
    print('🎮 Player.onLoad() called');
    print('Game size: ${game.size}');
    print('Player size: $size');
    print('Player priority: $priority');

    // 위치 설정 (world 좌표계에서 하단에 위치)
    position = Vector2(game.size.x / 2, game.size.y - bottomMargin);
    print('Player position set to: $position');

      print('🔵 Adding blue circle as player');
      final circleComponent = CircleComponent(
        radius: sizeD / 2,
        paint: Paint()..color = const Color.fromARGB(255, 0, 0, 255),
        anchor: Anchor.topLeft,
      );
      add(circleComponent);
      print('🔵 CircleComponent added with radius: ${circleComponent.radius}');

      // 충돌 감지 hitbox
      add(
        CircleHitbox(
          radius: sizeD / 2,
          anchor: Anchor.topLeft,
        ),
      );
    print('✅ Player loaded successfully at $position with size $size');
    print('Player children count: ${children.length}');
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

  @override
  void update(double dt) {
    super.update(dt);

    // 이동 방향에 따라 위치 업데이트
    position.x += moveDirection * speed * dt;

    // 경계 체크 - 화면 밖으로 나가지 않도록
    position.x = position.x.clamp(size.x / 2, game.size.x - size.x / 2);
  }

  // 충돌 감지
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    ///충돌좌표
    print('Collision points: $intersectionPoints');
    if (other is Ddong) {
      print('💥 Collision detected with Ddong!');
      takeDamage();
    }
  }

  void takeDamage() {
    if (!isInvulnerable) {
      print('💀 Player taking damage - Game Over!');
      // 게임 오버 처리
      game.onGameOver(
        GameResult(score: game.scoreSystem.score, playTime: game.scoreSystem.survivalTime, stats: game.scoreSystem.getGameStats(), metadata: {}),
      );
    }
  }
}
