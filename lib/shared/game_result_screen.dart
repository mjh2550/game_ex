import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GameResultScreen extends ConsumerWidget {
  final String gameId;
  final String playerName;
  final int score;
  final Map<String, dynamic> stats;
  final bool isNewBest;
  final int bestScore;
  final int rank;

  const GameResultScreen({
    super.key,
    required this.gameId,
    required this.playerName,
    required this.score,
    required this.stats,
    required this.isNewBest,
    required this.bestScore,
    required this.rank,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearMiss = stats['near_miss_count'] ?? 0;
    final ordersCompleted = stats['orders_completed'] ?? nearMiss;
    final maxCombo = stats['max_combo'] ?? 0;
    final difficulty = stats['difficulty_reached'] ?? 1;
    final isKiosk = gameId == 'g002';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 420;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                compact ? 14 : 20,
                compact ? 12 : 20,
                compact ? 14 : 20,
                compact ? 24 : 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE1E7EF)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1F18212F),
                          blurRadius: 22,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(compact ? 16 : 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: compact ? 88 : 118,
                            child: _GameResultVisual(
                              gameId: gameId,
                              compact: compact,
                            ),
                          ),
                          SizedBox(height: compact ? 14 : 22),
                          Text(
                            '게임 오버',
                            style: TextStyle(
                              color: const Color(0xFF18212F),
                              fontSize: compact ? 25 : 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isNewBest
                                ? '새 최고 기록입니다!'
                                : '다음 판은 조금 더 오래 버틸 수 있어요.',
                            style: TextStyle(
                              color: isNewBest
                                  ? const Color(0xFFE56B1F)
                                  : const Color(0xFF60707F),
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF7FF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFB9E2F4),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              child: Text(
                                playerName,
                                style: const TextStyle(
                                  color: Color(0xFF18212F),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xFF18212F),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 18,
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'SCORE',
                                    style: TextStyle(
                                      color: Color(0xFFFFD166),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    '$score',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: compact ? 42 : 56,
                                      fontWeight: FontWeight.w900,
                                      height: 1.05,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'BEST $bestScore',
                                    style: const TextStyle(
                                      color: Color(0xFFD4DEE8),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _ResultStat(
                                  label: isKiosk ? 'Orders' : 'Near Miss',
                                  value: '$ordersCompleted',
                                  icon: isKiosk
                                      ? Icons.receipt_long_rounded
                                      : Icons.flash_on_rounded,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _ResultStat(
                                  label: 'Max Combo',
                                  value: 'x$maxCombo',
                                  icon: Icons.local_fire_department_rounded,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _ResultStat(
                                  label: 'Level',
                                  value: '$difficulty',
                                  icon: Icons.speed_rounded,
                                ),
                              ),
                            ],
                          ),
                          if (rank > 0) ...[
                            const SizedBox(height: 12),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF7FF),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFB9E2F4),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.emoji_events_rounded,
                                      color: Color(0xFFE56B1F),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '로컬 순위 #$rank',
                                      style: const TextStyle(
                                        color: Color(0xFF18212F),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          _ResultActions(
                            compact: compact,
                            onRetry: () => context.go('/game/$gameId'),
                            onHome: () => context.go('/home'),
                            onLeaderboard: () =>
                                context.push('/leaderboard?game=$gameId'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ResultActions extends StatelessWidget {
  const _ResultActions({
    required this.compact,
    required this.onRetry,
    required this.onHome,
    required this.onLeaderboard,
  });

  final bool compact;
  final VoidCallback onRetry;
  final VoidCallback onHome;
  final VoidCallback onLeaderboard;

  @override
  Widget build(BuildContext context) {
    final retryButton = FilledButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.replay_rounded),
      label: const Text('다시하기'),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF2BB673),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    final homeButton = OutlinedButton.icon(
      onPressed: onHome,
      icon: const Icon(Icons.home_rounded),
      label: const Text('허브로'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF18212F),
        side: const BorderSide(color: Color(0xFFCAD4E1)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    final leaderboardButton = OutlinedButton.icon(
      onPressed: onLeaderboard,
      icon: const Icon(Icons.leaderboard_rounded),
      label: const Text('순위표'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF18212F),
        side: const BorderSide(color: Color(0xFFCAD4E1)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          retryButton,
          const SizedBox(height: 10),
          leaderboardButton,
          const SizedBox(height: 10),
          homeButton,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: retryButton),
            const SizedBox(width: 10),
            Expanded(child: homeButton),
          ],
        ),
        const SizedBox(height: 10),
        leaderboardButton,
      ],
    );
  }
}

class _GameResultVisual extends StatelessWidget {
  const _GameResultVisual({required this.gameId, required this.compact});

  final String gameId;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final boxSize = compact ? 88.0 : 118.0;
    final primarySize = compact ? 54.0 : 70.0;
    final secondarySize = compact ? 36.0 : 48.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFFFD166),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(width: boxSize, height: boxSize),
        ),
        if (gameId == 'g002') ...[
          Icon(
            Icons.touch_app_rounded,
            size: primarySize,
            color: const Color(0xFF18212F),
          ),
          Positioned(
            right: compact ? 104 : 148,
            bottom: compact ? 8 : 12,
            child: Icon(
              Icons.receipt_long_rounded,
              size: secondarySize,
              color: const Color(0xFF2BB673),
            ),
          ),
        ] else ...[
          Image.asset(
            'assets/images/openmoji_poop.png',
            width: primarySize,
            height: primarySize,
            filterQuality: FilterQuality.none,
          ),
          Positioned(
            right: compact ? 104 : 148,
            bottom: compact ? 8 : 12,
            child: Image.asset(
              'assets/images/openmoji_player.png',
              width: secondarySize,
              height: secondarySize,
              filterQuality: FilterQuality.none,
            ),
          ),
        ],
      ],
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E7EF)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFE56B1F), size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                color: Color(0xFF18212F),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF60707F),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
