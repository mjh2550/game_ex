import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GameResultScreen extends ConsumerWidget {
  final String gameId;
  final int score;
  final Map<String, dynamic> stats;
  final bool isNewBest;
  final int bestScore;
  final int rank;

  const GameResultScreen({
    super.key,
    required this.gameId,
    required this.score,
    required this.stats,
    required this.isNewBest,
    required this.bestScore,
    required this.rank,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearMiss = stats['near_miss_count'] ?? 0;
    final maxCombo = stats['max_combo'] ?? 0;
    final difficulty = stats['difficulty_reached'] ?? 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 118,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD166),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const SizedBox(width: 118, height: 118),
                            ),
                            Image.asset(
                              'assets/images/openmoji_poop.png',
                              width: 70,
                              height: 70,
                              filterQuality: FilterQuality.none,
                            ),
                            Positioned(
                              right: 148,
                              bottom: 12,
                              child: Image.asset(
                                'assets/images/openmoji_player.png',
                                width: 48,
                                height: 48,
                                filterQuality: FilterQuality.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        '게임 오버',
                        style: TextStyle(
                          color: Color(0xFF18212F),
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isNewBest ? '새 최고 기록입니다!' : '다음 판은 조금 더 오래 버틸 수 있어요.',
                        style: TextStyle(
                          color: isNewBest
                              ? const Color(0xFFE56B1F)
                              : const Color(0xFF60707F),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 56,
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
                              label: 'Near Miss',
                              value: '$nearMiss',
                              icon: Icons.flash_on_rounded,
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
                            border: Border.all(color: const Color(0xFFB9E2F4)),
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
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => context.go('/game/$gameId'),
                              icon: const Icon(Icons.replay_rounded),
                              label: const Text('다시하기'),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF2BB673),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => context.go('/home'),
                              icon: const Icon(Icons.home_rounded),
                              label: const Text('허브로'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF18212F),
                                side: const BorderSide(
                                  color: Color(0xFFCAD4E1),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
