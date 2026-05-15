import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: const Column(
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
