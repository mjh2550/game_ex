import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LeaderboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Leaderboard')),
      body: Column(
        children: [
          // 게임 선택 탭
          // GameSelector(),
          
          // // 기간 선택 (오늘, 이번주, 전체)
          // PeriodSelector(),
          
          // 순위 리스트
          // Expanded(
          //   child: LeaderboardList(),
          // ),
        ],
      ),
    );
  }
}