import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:game_ex/core/utils/flame_game_extension.dart';
import 'package:game_ex/features/games/ddong_dodge/presentation/ddong_dodge_game.dart';

class GameHUD extends StatelessWidget {
  GameHUD({
    Key? key,
    required this.game,
  }) : super(key: key);
  
  final FlameGame game;
  
  @override
  Widget build(BuildContext context) {
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
                    Text(
                      'Score',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    Text(
                      'score',//'${game.gameInfo?.scoreSystem.score}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Time',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    Text(
                     'time',//'${game.scoreSystem.survivalTime.toStringAsFixed(1)}s',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 8),
            
            // 콤보 표시
            // if (game.scoreSystem.combo > 0)
            //   Container(
            //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //     decoration: BoxDecoration(
            //       color: Colors.orange,
            //       borderRadius: BorderRadius.circular(20),
            //     ),
            //     child: Text(
            //       'Combo x${game.scoreSystem.combo}',
            //       style: TextStyle(
            //         fontSize: 18,
            //         fontWeight: FontWeight.bold,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            
            // Spacer(),
            
            // // 일시정지 버튼
            // Align(
            //   alignment: Alignment.topRight,
            //   child: IconButton(
            //     icon: Icon(Icons.pause, color: Colors.white, size: 32),
            //     onPressed: () => game.pauseGame(),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}