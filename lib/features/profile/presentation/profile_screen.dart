import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            // 사용자 정보
            // UserInfoCard(),

            // // 전체 통계
            // OverallStatsCard(),

            // // 게임별 기록
            // GameRecordsSection(),

            // // 업적
            // AchievementsSection(),
          ],
        ),
      ),
    );
  }
}
