import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:game_ex/features/games/group_quiz/domain/quiz_question.dart';

class GroupQuizQuestionRepository {
  GroupQuizQuestionRepository({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  Future<List<QuizQuestion>> loadQuestions() async {
    final raw = await _bundle.loadString(
      'assets/data/group_quiz_questions.json',
    );
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map>()
        .map((item) => QuizQuestion.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<QuizQuestion>> buildDeck({
    required int roundLimit,
    Random? random,
  }) async {
    final questions = await loadQuestions();
    if (questions.isEmpty) {
      return const [];
    }

    final source = random ?? Random();
    final deck = [...questions]..shuffle(source);
    while (deck.length < roundLimit) {
      deck.addAll([...questions]..shuffle(source));
    }

    return deck.take(roundLimit).toList();
  }
}
