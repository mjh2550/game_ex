import 'package:flame/game.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/ddong_dodge_game.dart';
import 'package:game_ex/shared/game_info.dart';

extension FlameGameExtension on FlameGame {
  GameInfo? get gameInfo {
    if (this is DdongDodgeGame) {
      return (this as DdongDodgeGame).gameInfo as GameInfo?;
    }
    // 다른 게임들에 대한 처리 추가 가능
    return null;
  }
}