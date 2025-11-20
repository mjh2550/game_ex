import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: SingleChildScrollView(
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