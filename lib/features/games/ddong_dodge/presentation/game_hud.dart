import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/ddong_dodge_game.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/game_state_provider.dart';

class GameHUD extends ConsumerWidget {
  const GameHUD({super.key, required this.game});

  final FlameGame game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (game) {
      DdongDodgeGame game => _buildDdongDodgeHUD(game, ref),
      _ => Container(),
    };
  }

  Widget _buildDdongDodgeHUD(DdongDodgeGame game, WidgetRef ref) {
    // Provider에서 실시간 상태 감지
    final score = ref.watch(gameStateProvider.select((state) => state.score));
    final playTime = ref.watch(
      gameStateProvider.select((state) => state.playTime),
    );
    final combo = ref.watch(gameStateProvider.select((state) => state.combo));
    final difficulty = ref.watch(
      gameStateProvider.select((state) => state.difficultyLevel),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _HudMetric(
                      label: 'Score',
                      value: '$score',
                      alignEnd: false,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 48),
                      child: _HudMetric(
                        label: 'Lv $difficulty',
                        value: '${playTime.toStringAsFixed(1)}s',
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (combo > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE56B1F),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Combo x$combo',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                tooltip: 'Pause',
                icon: const Icon(
                  Icons.pause_circle,
                  color: Color(0xFF263238),
                  size: 36,
                ),
                onPressed: () => game.pauseGame(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HudMetric extends StatelessWidget {
  const _HudMetric({
    required this.label,
    required this.value,
    required this.alignEnd,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x22008ECF)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: alignEnd
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF455A64)),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A252B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
