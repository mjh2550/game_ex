import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/ddong_dodge_game.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/game_hud.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/game_over_screen.dart';
import 'package:game_ex/shared/game_provider.dart';
import 'package:go_router/go_router.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String gameId;

  const GameScreen({
    Key? key,
    required this.gameId,
  }) : super(key: key);

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late final FlameGame game;
  bool _isGameInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // didChangeDependencies에서 ref 사용 가능
    if (!_isGameInitialized) {
      final gameManager = ref.read(gameManagerProvider);
      game = gameManager.createGame(
        widget.gameId,
        onGameOver: _handleGameOver,
        onPause: _handlePause,
      );
      _isGameInitialized = true;
    }
  }

  // FlameGame _createGame(String gameId) {
  //   // 게임 팩토리 패턴
  //   switch (gameId) {
  //     case 'ddong_dodge':
  //       return DdongDodgeGame(
  //         onGameOver: _handleGameOver,
  //         onPause: _handlePause,
  //         // userId: ref.read(currentUserProvider).id,
  //         userId: 'test_user',
  //       );
      
  //     // case 'game_2':
  //     //   return Game2(
  //     //     onGameOver: _handleGameOver,
  //     //     onPause: _handlePause,
  //     //     userId: ref.read(currentUserProvider).id,
  //     //   );
      
  //     default:
  //       throw Exception('Unknown game: $gameId');
  //   }
  // }

  // 🏁 게임 오버 처리
  void _handleGameOver(GameResult result) {
    // 점수 저장
    // ref.read(scoreRepositoryProvider).saveScore(
    //   gameId: widget.gameId,
    //   score: result.score,
    //   metadata: result.metadata,
    // );

    // 결과 화면으로 이동
    context.go('/game-result', extra: {
      'gameId': widget.gameId,
      'score': result.score,
      'stats': result.stats,
    });
  }

  // ⏸️ 일시정지 처리
  void _handlePause() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('게임 일시정지'),
        content: const Text('게임을 계속하시겠습니까?'),
        actions: [
          TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          game.resumeEngine();
        },
        child: const Text('계속하기'),
          ),
          TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          context.go('/home');
        },
        child: const Text('홈으로'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTapDown: (details) {
          // 터치 위치 감지
          if (game is DdongDodgeGame) {
            final ddongGame = game as DdongDodgeGame;
            final tapX = details.globalPosition.dx;
            final screenWidth = MediaQuery.of(context).size.width;
            
            if (tapX < screenWidth / 2) {
              ddongGame.isLeftPressed = true;
            } else {
              ddongGame.isRightPressed = true;
            }
          }
        },
        onTapUp: (details) {
          // 터치 종료
          if (game is DdongDodgeGame) {
            final ddongGame = game as DdongDodgeGame;
            final tapX = details.globalPosition.dx;
            final screenWidth = MediaQuery.of(context).size.width;
            
            if (tapX < screenWidth / 2) {
              ddongGame.isLeftPressed = false;
            } else {
              ddongGame.isRightPressed = false;
            }
          }
        },
        onTapCancel: () {
          // 터치 취소
          if (game is DdongDodgeGame) {
            final ddongGame = game as DdongDodgeGame;
            ddongGame.isLeftPressed = false;
            ddongGame.isRightPressed = false;
          }
        },
        child: GameWidget(
          game: game,
          overlayBuilderMap: {
            'hud': (context, game) => GameHUD(game: game is FlameGame ? game : throw Exception('Invalid game type')),
            // 'pause': (context, game) => PauseMenu(game: game),
            'game_over': (context, game) => GameOverScreen(game: game is FlameGame ? game : throw Exception('Invalid game type')),
          },
          initialActiveOverlays: const ['hud'],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 게임 리소스 정리
    game.onRemove();
    super.dispose();
  }
}