enum QuizQuestionType { initial, complete, commonSense }

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.type,
    required this.category,
    required this.question,
    required this.answer,
    this.hint,
    this.difficulty = 1,
  });

  final String id;
  final QuizQuestionType type;
  final String category;
  final String question;
  final String answer;
  final String? hint;
  final int difficulty;
}
