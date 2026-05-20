import 'package:flutter/material.dart';

class QuizTeam {
  const QuizTeam({
    required this.id,
    required this.name,
    required this.color,
    this.score = 0,
    this.combo = 0,
  });

  final int id;
  final String name;
  final Color color;
  final int score;
  final int combo;

  QuizTeam copyWith({int? score, int? combo}) {
    return QuizTeam(
      id: id,
      name: name,
      color: color,
      score: score ?? this.score,
      combo: combo ?? this.combo,
    );
  }
}
