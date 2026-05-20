import 'dart:ui';

import 'package:flame/game.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/ddong_dodge_game.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/game_state_provider.dart';
import 'package:game_ex/shared/game_info.dart';

class GameManager {
  static final List<GameInfo> _gameInfos = [
    GameInfo(
      id: 'g001',
      name: '똥 피하기',
      description: '방향키로 좌우 이동하며 떨어지는 장애물을 피하세요.',
      routeName: '/ddong_dodge',
      isUnlocked: true,
      thumbnailUrl: 'assets/images/openmoji_poop.png',
    ),
    GameInfo(
      id: 'g002',
      name: '키오스크 눈치게임',
      description: '뒤 손님의 압박 속에서 주문을 빠르게 완성하세요.',
      routeName: '/kiosk_panic',
      isUnlocked: true,
    ),
  ];

  List<GameInfo> get games => List.unmodifiable(_gameInfos);

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
      case 'g001':
        return DdongDodgeGame(
          gameInfo: GameInfo(
            id: 'g001',
            name: '똥 피하기',
            description: '방향키로 좌우 이동하며 떨어지는 장애물을 피하세요.',
            routeName: '/ddong_dodge',
            isUnlocked: true,
            thumbnailUrl: 'assets/images/openmoji_poop.png',
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
