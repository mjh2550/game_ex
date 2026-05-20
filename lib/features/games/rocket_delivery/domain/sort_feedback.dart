import 'package:flutter/material.dart';

class SortFeedback {
  const SortFeedback({
    required this.correct,
    required this.message,
    required this.color,
    required this.icon,
  });

  factory SortFeedback.correct(String destination) {
    return SortFeedback(
      correct: true,
      message: '$destination 분류 성공',
      color: const Color(0xFF2BB673),
      icon: Icons.check_circle_rounded,
    );
  }

  factory SortFeedback.wrong(String reason) {
    return SortFeedback(
      correct: false,
      message: reason,
      color: const Color(0xFFE53935),
      icon: Icons.cancel_rounded,
    );
  }

  factory SortFeedback.notice(String message, Color color, IconData icon) {
    return SortFeedback(
      correct: false,
      message: message,
      color: color,
      icon: icon,
    );
  }

  final bool correct;
  final String message;
  final Color color;
  final IconData icon;
}
