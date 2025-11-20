import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:game_ex/core/utils/flame_game_extension.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/ddong_dodge_game.dart';
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

  // void updateBestScore(String id, int newScore) {
  //   final game = getGameById(id);
  //   if (game != null && newScore > game.bestScore) {
  //     // game.bestScore = newScore;
  //   }
  // }

  // FlameGame createGame(GameInfo gameInfo, Function(GameResult) _handleGameOver, VoidCallback _handlePause) {
  //   // 게임 팩토리 패턴
  //   switch (gameInfo.id) {
  //     case 'ddong_dodge':
  //       return DdongDodgeGame(onGameOver: _handleGameOver, onPause: _handlePause, userId: 'test_user', gameInfo: gameInfo);

  //     // case 'game_2':
  //     //   return Game2(
  //     //     onGameOver: _handleGameOver,
  //     //     onPause: _handlePause,
  //     //     userId: ref.read(currentUserProvider).id,
  //     //   );

  //     default:
  //       throw Exception('Unknown game: ${gameInfo.id}');
  //   }
  //   // }
  // }
}
