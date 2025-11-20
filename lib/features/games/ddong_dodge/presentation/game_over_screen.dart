import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/ddong_dodge_game.dart';
import 'package:go_router/go_router.dart';

class GameOverScreen extends StatelessWidget {
  GameOverScreen({required this.game});

  final FlameGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Game Over',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.red),
            ),

            SizedBox(height: 40),

            // 최종 점수
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Text('Final Score', style: TextStyle(fontSize: 18, color: Colors.white70)),
                  SizedBox(height: 8),
                  Text(
                    '${(game as DdongDodgeGame).scoreSystem.score}',
                    style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.amber),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(label: 'Time', value: '${(game as DdongDodgeGame).scoreSystem.survivalTime.toStringAsFixed(1)}s'),
                      _StatItem(label: 'Near Miss', value: '${(game as DdongDodgeGame).scoreSystem.nearMissCount}'),
                      _StatItem(label: 'Best Combo', value: 'x${(game as DdongDodgeGame).scoreSystem.combo}'),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            // 버튼들
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.replay),
                  label: Text('Retry'),
                  onPressed: () {
                    (game as DdongDodgeGame).resetGame();
                    game.overlays.remove('game_over');
                  },
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                ),

                SizedBox(width: 20),

                ElevatedButton.icon(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                  onPressed: () {
                    context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                ),
              ],
            ),

            SizedBox(height: 20),

            // 순위 확인 버튼
            TextButton(
              child: Text('View Leaderboard'),
              onPressed: () {
                context.push('/leaderboard?game=ddong_dodge');
              },
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
        Text(label, style: TextStyle(fontSize: 14, color: Colors.white70)),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }
}
