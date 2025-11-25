import 'dart:ui';

import 'package:flame/game.dart';
import 'package:game_ex/core/utils/flame_game_extension.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/ddong_dodge_game.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/game_state_provider.dart';
import 'package:game_ex/shared/game_info.dart';

class GameManager {
  final List<FlameGame> _games = [
    DdongDodgeGame(
      gameInfo: GameInfo(id: 'g001', name: 'ddong_dodge', description: 'dodge ddong game', routeName: '/ddong_dodge', isUnlocked: true),
      onGameOver: (GameResult result) {
        // 게임 오버 처리 로직
      },
      onPause: () {
        // 일시정지 처리 로직
      },
      userId: 'test_user',
      
    ),

    // 다른 게임 추가 가능
  ];

  List<GameInfo> get games => List.unmodifiable(_games.map((game) => game.gameInfo).whereType<GameInfo>());

  FlameGame? getGameById(String id) {
    return _games.firstWhere((game) => game.gameInfo?.id == id);
  }

  FlameGame createGame(
    String gameId, {
    required Function(GameResult) onGameOver,
    required VoidCallback onPause,
    Function(GameState)? onStateUpdate, // 추가
  }) {
    switch (gameId) {
      case 'g001':
        return DdongDodgeGame(
          gameInfo: GameInfo(
            id: 'g001',
            name: 'ddong_dodge',
            description: 'dodge ddong game',
            routeName: '/ddong_dodge',
            isUnlocked: true,
          ),
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
