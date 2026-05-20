import 'package:flutter/material.dart';
import 'package:game_ex/features/games/group_quiz/domain/quiz_team.dart';

const groupQuizTeamColors = [
  Color(0xFF2BB673),
  Color(0xFFE56B1F),
  Color(0xFF54C6EB),
  Color(0xFF8E6BE8),
];

List<QuizTeam> buildGroupQuizTeams(int count) {
  return [
    for (var index = 0; index < count; index++)
      QuizTeam(
        id: index,
        name: '${String.fromCharCode(65 + index)}팀',
        color: groupQuizTeamColors[index],
      ),
  ];
}
