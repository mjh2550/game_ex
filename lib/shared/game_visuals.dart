import 'package:flutter/material.dart';
import 'package:game_ex/shared/game_catalog.dart';

IconData iconForGame(String gameId) {
  return switch (gameId) {
    GameIds.ddongDodge => Icons.sentiment_very_dissatisfied_rounded,
    GameIds.kioskPanic => Icons.touch_app_rounded,
    GameIds.rocketDelivery => Icons.local_shipping_rounded,
    GameIds.groupQuiz => Icons.quiz_rounded,
    _ => Icons.sports_esports_rounded,
  };
}

String controlLabelForGame(String gameId) {
  return switch (gameId) {
    GameIds.kioskPanic => '터치',
    GameIds.groupQuiz => '진행자/입력',
    GameIds.rocketDelivery => '번호키/터치',
    _ => '방향키/터치',
  };
}
