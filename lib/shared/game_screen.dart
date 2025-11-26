import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/ddong_dodge_game.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/game_hud.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/game_over_screen.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/game_state_provider.dart';
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
        onStateUpdate: (gameState) {
          // 다음 프레임에서 provider 업데이트 (widget 빌드 중 수정 방지)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ref.read(gameStateProvider.notifier).updateState(gameState);
            }
          });
        },
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
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 사용 가능한 공간
            final maxWidth = constraints.maxWidth;
            final maxHeight = constraints.maxHeight;
            
            // 게임 크기 결정 (500x1000 이하면 종횡비 유지, 그 이상은 고정)
            late double gameWidth;
            late double gameHeight;
            
            if (maxWidth <= 500 || maxHeight <= 1000) {
              // 작은 화면: 종횡비 유지 (1:2)
              gameWidth = maxWidth * 0.9;
              gameHeight = gameWidth * 2;
              
              // 높이도 체크
              if (gameHeight > maxHeight * 0.9) {
                gameHeight = maxHeight * 0.9;
                gameWidth = gameHeight / 2;
              }
            } else {
              // 큰 화면: 고정 크기
              gameWidth = 500;
              gameHeight = 1000;
            }
            
            return SizedBox(
              width: gameWidth,
              height: gameHeight,
              child: Stack(
            children: [
              // 게임 화면
              GameWidget(
                  game: game,
                  overlayBuilderMap: {
                    'hud': (context, game) => GameHUD(game: game is FlameGame ? game : throw Exception('Invalid game type')),
                    'game_over': (context, game) => GameOverScreen(game: game is FlameGame ? game : throw Exception('Invalid game type')),
                  },
                  initialActiveOverlays: const ['hud'],
                ),
              
              // 좌우 이동 버튼
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 왼쪽 버튼
                    Listener(
                      onPointerDown: (_) {
                        if (game is DdongDodgeGame) {
                          (game as DdongDodgeGame).setTouchInput('left', true);
                        }
                      },
                      onPointerUp: (_) {
                        if (game is DdongDodgeGame) {
                          (game as DdongDodgeGame).setTouchInput('left', false);
                        }
                      },
                      onPointerCancel: (_) {
                        if (game is DdongDodgeGame) {
                          (game as DdongDodgeGame).setTouchInput('left', false);
                        }
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, size: 40, color: Colors.white),
                      ),
                    ),
                    
                    // 오른쪽 버튼
                    Listener(
                      onPointerDown: (_) {
                        if (game is DdongDodgeGame) {
                          (game as DdongDodgeGame).setTouchInput('right', true);
                        }
                      },
                      onPointerUp: (_) {
                        if (game is DdongDodgeGame) {
                          (game as DdongDodgeGame).setTouchInput('right', false);
                        }
                      },
                      onPointerCancel: (_) {
                        if (game is DdongDodgeGame) {
                          (game as DdongDodgeGame).setTouchInput('right', false);
                        }
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward, size: 40, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            ),
            );
          },
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