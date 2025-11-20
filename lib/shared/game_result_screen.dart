import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GameResultScreen extends ConsumerWidget {
  final String gameId;
  final int score;
  final Map<String, dynamic> stats;

  const GameResultScreen({
    required this.gameId,
    required this.score,
    required this.stats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 순위 정보 가져오기
    // final rank = ref.watch(userRankProvider(gameId));

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Game Over', style: TextStyle(fontSize: 48)),
            SizedBox(height: 20),
            Text('Score: $score', style: TextStyle(fontSize: 32)),
            SizedBox(height: 20),
            // Text('Your Rank: #${rank.rank}'),
            SizedBox(height: 40),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.replay),
                  label: Text('Play Again'),
                  onPressed: () {
                    // 🔄 같은 게임 다시 플레이
                    context.go('/game/$gameId');
                  },
                ),
                SizedBox(width: 20),
                ElevatedButton.icon(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                  onPressed: () {
                    // 🏠 홈으로 돌아가기
                    context.go('/home');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}