import 'package:flutter/material.dart';
import 'package:game_ex/features/games/kiosk_panic/domain/customer_reaction.dart';

CustomerReaction customerReactionForPatience(double patience) {
  if (patience > 70) {
    return const CustomerReaction(
      icon: Icons.sentiment_satisfied_alt_rounded,
      color: Color(0xFF2BB673),
      title: '뒤 손님: 평온',
      message: '아직은 기다려줄 만한 분위기예요.',
    );
  }

  if (patience > 40) {
    return const CustomerReaction(
      icon: Icons.visibility_rounded,
      color: Color(0xFFFFA726),
      title: '뒤 손님: 눈치',
      message: '어깨 너머로 주문을 확인하기 시작했습니다.',
    );
  }

  if (patience > 18) {
    return const CustomerReaction(
      icon: Icons.record_voice_over_rounded,
      color: Color(0xFFE56B1F),
      title: '뒤 손님: 한숨',
      message: '“아... 아직도 고르는 중인가?”',
    );
  }

  return const CustomerReaction(
    icon: Icons.warning_amber_rounded,
    color: Color(0xFFE53935),
    title: '뒤 손님: 폭발 직전',
    message: '실수하면 바로 분위기가 끝장납니다.',
  );
}
