import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/ddong_dodge_game.dart';
import 'package:go_router/go_router.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key, required this.game});

  final FlameGame game;

  @override
  Widget build(BuildContext context) {
    final ddongGame = game as DdongDodgeGame;

    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Game Over',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 40),

            // 최종 점수
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Final Score',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${ddongGame.scoreSystem.score}',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        label: 'Time',
                        value:
                            '${ddongGame.scoreSystem.survivalTime.toStringAsFixed(1)}s',
                      ),
                      _StatItem(
                        label: 'Near Miss',
                        value: '${ddongGame.scoreSystem.nearMissCount}',
                      ),
                      _StatItem(
                        label: 'Best Combo',
                        value: 'x${ddongGame.scoreSystem.maxCombo}',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 버튼들
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.replay),
                  label: const Text('Retry'),
                  onPressed: () {
                    ddongGame.resetGame();
                    game.overlays.remove('game_over');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                ElevatedButton.icon(
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                  onPressed: () {
                    context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 순위 확인 버튼
            TextButton(
              onPressed: () {
                context.push('/leaderboard?game=ddong_dodge');
              },
              child: const Text('View Leaderboard'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
