import 'package:flutter/foundation.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/ddong_dodge_game.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/game_hud.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/game_over_screen.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/game_state_provider.dart';
import 'package:game_ex/features/score/domain/score_record.dart';
import 'package:game_ex/features/score/presentation/score_provider.dart';
import 'package:game_ex/shared/game_provider.dart';
import 'package:go_router/go_router.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String gameId;

  const GameScreen({super.key, required this.gameId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late final FlameGame game;
  bool _isGameInitialized = false;

  bool get _usesMobileControls {
    if (kIsWeb) {
      return false;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };
  }

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
  Future<void> _handleGameOver(GameResult result) async {
    final scoreRepository = await ref.read(localScoreRepositoryProvider.future);
    final saveResult = await scoreRepository.saveRecord(
      ScoreRecord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        gameId: widget.gameId,
        score: result.score,
        playTime: result.playTime,
        nearMissCount: result.stats['near_miss_count'] as int? ?? 0,
        maxCombo: result.stats['max_combo'] as int? ?? 0,
        difficultyReached: result.stats['difficulty_reached'] as int? ?? 1,
        playedAt: DateTime.now(),
      ),
    );

    ref.invalidate(bestScoreProvider(widget.gameId));
    ref.invalidate(leaderboardRecordsProvider(widget.gameId));

    if (!mounted) {
      return;
    }

    context.go(
      '/game-result',
      extra: {
        'gameId': widget.gameId,
        'score': result.score,
        'stats': result.stats,
        'isNewBest': saveResult.isNewBest,
        'bestScore': saveResult.bestScore,
        'rank': saveResult.rank,
      },
    );
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
                  GameWidget(
                    game: game,
                    autofocus: true,
                    overlayBuilderMap: {
                      'hud': (context, game) => GameHUD(
                        game: game is FlameGame
                            ? game
                            : throw Exception('Invalid game type'),
                      ),
                      'game_over': (context, game) => GameOverScreen(
                        game: game is FlameGame
                            ? game
                            : throw Exception('Invalid game type'),
                      ),
                    },
                    initialActiveOverlays: const ['hud'],
                  ),
                  if (_usesMobileControls && game is DdongDodgeGame)
                    _MobileDirectionControls(game: game as DdongDodgeGame),
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

class _MobileDirectionControls extends StatelessWidget {
  const _MobileDirectionControls({required this.game});

  final DdongDodgeGame game;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 18,
      child: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 28),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _DirectionButton(
              icon: Icons.keyboard_arrow_left_rounded,
              onPressedChanged: (pressed) {
                game.setTouchInput('left', pressed);
              },
            ),
            _DirectionButton(
              icon: Icons.keyboard_arrow_right_rounded,
              onPressedChanged: (pressed) {
                game.setTouchInput('right', pressed);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DirectionButton extends StatelessWidget {
  const _DirectionButton({required this.icon, required this.onPressedChanged});

  final IconData icon;
  final ValueChanged<bool> onPressedChanged;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => onPressedChanged(true),
      onPointerUp: (_) => onPressedChanged(false),
      onPointerCancel: (_) => onPressedChanged(false),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xDD18212F),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.32)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: SizedBox(
          width: 76,
          height: 64,
          child: Icon(icon, size: 46, color: Colors.white),
        ),
      ),
    );
  }
}
