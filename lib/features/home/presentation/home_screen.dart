import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_ex/features/score/presentation/score_provider.dart';
import 'package:game_ex/shared/game_card.dart';
import 'package:game_ex/shared/game_info.dart';
import 'package:game_ex/shared/game_provider.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final games = ref.watch(gameListProvider);
    final featuredGame = _todayFeaturedGame(games);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        foregroundColor: const Color(0xFF18212F),
        title: const Text(
          '미니게임천국',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Leaderboard',
            icon: const Icon(Icons.leaderboard_outlined),
            onPressed: () =>
                context.push('/leaderboard?game=${featuredGame.id}'),
          ),
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                child: _FeaturedGamePanel(
                  game: featuredGame,
                  onPlay: () => context.push('/game/${featuredGame.id}'),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    const Text(
                      '게임 목록',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF18212F),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${games.where((game) => game.isUnlocked).length}/${games.length} 오픈',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF60707F),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260,
                  childAspectRatio: 0.86,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
                  final bestScore = ref.watch(bestScoreProvider(game.id));

                  return GameCard(
                    game: game,
                    bestScore: bestScore.value ?? 0,
                    onTap: () => context.push('/game/${game.id}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  GameInfo _todayFeaturedGame(List<GameInfo> games) {
    final activeGames = games.where((game) => game.isUnlocked).toList();
    if (activeGames.isEmpty) {
      return games.first;
    }

    final today = DateTime.now();
    final dayKey = DateTime(
      today.year,
      today.month,
      today.day,
    ).difference(DateTime(2026)).inDays;

    return activeGames[dayKey % activeGames.length];
  }
}

class _FeaturedGamePanel extends StatelessWidget {
  const _FeaturedGamePanel({required this.game, required this.onPlay});

  final GameInfo game;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF18212F),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F18212F),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 420;
            final isKiosk = game.id == 'g002';
            final isRocket = game.id == 'g003';

            final visual = SizedBox(
              width: compact ? 96 : 132,
              height: compact ? 96 : 132,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD166),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const SizedBox.expand(),
                  ),
                  if (isKiosk) ...[
                    Icon(
                      Icons.touch_app_rounded,
                      size: compact ? 60 : 82,
                      color: const Color(0xFF18212F),
                    ),
                    Positioned(
                      right: compact ? 10 : 16,
                      bottom: compact ? 10 : 16,
                      child: Icon(
                        Icons.receipt_long_rounded,
                        size: compact ? 40 : 52,
                        color: const Color(0xFF2BB673),
                      ),
                    ),
                  ] else if (isRocket) ...[
                    Icon(
                      Icons.local_shipping_rounded,
                      size: compact ? 62 : 84,
                      color: const Color(0xFF18212F),
                    ),
                    Positioned(
                      right: compact ? 10 : 16,
                      bottom: compact ? 10 : 16,
                      child: Icon(
                        Icons.inventory_2_rounded,
                        size: compact ? 40 : 52,
                        color: const Color(0xFF2BB673),
                      ),
                    ),
                  ] else ...[
                    Image.asset(
                      game.thumbnailUrl ?? 'assets/images/openmoji_poop.png',
                      width: compact ? 60 : 82,
                      height: compact ? 60 : 82,
                      filterQuality: FilterQuality.none,
                    ),
                    Positioned(
                      right: compact ? 10 : 16,
                      bottom: compact ? 10 : 16,
                      child: Image.asset(
                        'assets/images/openmoji_player.png',
                        width: compact ? 40 : 52,
                        height: compact ? 40 : 52,
                        filterQuality: FilterQuality.none,
                      ),
                    ),
                  ],
                ],
              ),
            );

            final content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '오늘의 게임',
                  style: TextStyle(
                    color: Color(0xFFFFD166),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  game.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  game.description,
                  style: TextStyle(
                    color: const Color(0xFFD4DEE8),
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('시작'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2BB673),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [visual, const SizedBox(height: 18), content],
              );
            }

            return Row(
              children: [
                Expanded(child: content),
                const SizedBox(width: 20),
                visual,
              ],
            );
          },
        ),
      ),
    );
  }
}
