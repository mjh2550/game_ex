import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_ex/core/utils/flame_game_extension.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/ddong_dodge_game.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/game_state_provider.dart';

class GameHUD extends ConsumerWidget {
  GameHUD({Key? key, required this.game}) : super(key: key);

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
    final playTime = ref.watch(gameStateProvider.select((state) => state.playTime));
    final combo = ref.watch(gameStateProvider.select((state) => state.combo));
    
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 상단: 점수, 시간
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Score', style: TextStyle(fontSize: 14, color: Colors.black)),
                    Text(
                      '$score',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Time', style: TextStyle(fontSize: 14, color: Colors.black)),
                    Text(
                      '${playTime.toStringAsFixed(1)}s',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 8),

            // 콤보 표시
            if (combo > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Combo x$combo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

            Spacer(),

            // 일시정지 버튼
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.pause, color: Colors.white, size: 32),
                onPressed: () => game.pauseGame(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
