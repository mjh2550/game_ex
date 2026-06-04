import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:game_ex/features/games/group_quiz/domain/group_quiz_config.dart';
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

  Future<List<String>> loadCategories() async {
    final questions = await loadQuestions();
    final categories = {
      GroupQuizConfig.allCategory,
      for (final question in questions) question.category,
    };
    return categories.toList();
  }

  Future<List<QuizQuestion>> buildDeck({
    required int roundLimit,
    required String category,
    Random? random,
  }) async {
    final questions = await loadQuestions();
    final filteredQuestions = category == GroupQuizConfig.allCategory
        ? questions
        : questions.where((question) => question.category == category).toList();
    if (filteredQuestions.isEmpty) {
      return const [];
    }

    final source = random ?? Random();
    final deck = [...filteredQuestions]..shuffle(source);
    while (deck.length < roundLimit) {
      deck.addAll([...filteredQuestions]..shuffle(source));
    }

    return deck.take(roundLimit).toList();
  }
}
