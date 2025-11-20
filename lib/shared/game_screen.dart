import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/ddong_dodge_game.dart';
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

  @override
  void initState() {
    super.initState();
    
    // 🎮 게임
    game = ref.watch(gameManagerProvider).getGameById(widget.gameId)!;
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
      // 🎮 GameWidget으로 Flame 게임 렌더링
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          // HUD (점수, 시간 등)
          'hud': (context, game) {
            return Text('HUD Overlay');
            // return GameHUD(game: game as dynamic);
          },
          
          // // 일시정지 메뉴
          // 'pause': (context, game) {
          //   return PauseMenu(
          //     onResume: () {
          //       game.overlays.remove('pause');
          //       game.resumeEngine();
          //     },
          //     onQuit: () {
          //       context.go('/home');
          //     },
          //   );
          // },
          
          // // 게임 오버 화면
          // 'game_over': (context, game) {
          //   return GameOverOverlay(
          //     game: game as dynamic,
          //     onRetry: () {
          //       game.overlays.remove('game_over');
          //       (game as dynamic).resetGame();
          //     },
          //     onHome: () {
          //       context.go('/home');
          //     },
          //   );
          // },
        },
        initialActiveOverlays: const ['hud'],
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