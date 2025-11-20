import 'package:flame/components.dart';
import 'package:game_ex/features/games/ddong_dodge/domain/ddong.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/ddong_dodge_game.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/player.dart';

class CollisionSystem extends Component with HasGameReference<DdongDodgeGame> {
  
  final Player player;
  final List<Ddong> ddongs;
  
  CollisionSystem({
    required this.player,
    required this.ddongs,
  });
  
  @override
  void update(double dt) {
    super.update(dt);
    
    for (final ddong in ddongs) {
      checkCollision(player, ddong);
      checkNearMiss(player, ddong);
    }
  }
  
  void checkCollision(Player player, Ddong ddong) {
    final distance = player.position.distanceTo(ddong.position);
    final minDistance = (player.size.x / 2) + (ddong.size.x / 2);
    
    if (distance < minDistance) {
      player.takeDamage();
    }
  }
  
  void checkNearMiss(Player player, Ddong ddong) {
    final distance = player.position.distanceTo(ddong.position);
    
    // 아슬아슬하게 피한 경우 (30-60 픽셀 사이)
    if (distance > 30 && distance < 60 && 
        ddong.position.y > player.position.y) {
      game.scoreSystem.addNearMissBonus();
    }
  }
}