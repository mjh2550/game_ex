import 'dart:ui';

import 'package:flame/game.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/ddong_dodge_game.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/game_state_provider.dart';
import 'package:game_ex/shared/game_catalog.dart';
import 'package:game_ex/shared/game_info.dart';

class GameManager {
  List<GameInfo> get games => List.unmodifiable(GameCatalog.games);

  FlameGame? getGameById(String id) {
    return null;
  }

  FlameGame createGame(
    String gameId, {
    required Function(GameResult) onGameOver,
    required VoidCallback onPause,
    Function(GameState)? onStateUpdate, // 추가
  }) {
    switch (gameId) {
      case GameIds.ddongDodge:
        return DdongDodgeGame(
          gameInfo: GameCatalog.findById(GameIds.ddongDodge)!,
          onGameOver: onGameOver,
          onPause: onPause,
          onStateUpdate: onStateUpdate,
          userId: 'test_user',
        );
      default:
        throw Exception('Unknown game: $gameId');
    }
  }
}
