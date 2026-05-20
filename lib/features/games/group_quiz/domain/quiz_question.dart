enum QuizQuestionType { initial, complete, commonSense }

extension QuizQuestionTypeParser on QuizQuestionType {
  String get code => switch (this) {
    QuizQuestionType.initial => 'initial',
    QuizQuestionType.complete => 'complete',
    QuizQuestionType.commonSense => 'commonSense',
  };

  static QuizQuestionType fromCode(String code) {
    return switch (code) {
      'initial' => QuizQuestionType.initial,
      'complete' => QuizQuestionType.complete,
      'commonSense' => QuizQuestionType.commonSense,
      _ => QuizQuestionType.commonSense,
    };
  }
}

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

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      type: QuizQuestionTypeParser.fromCode(json['type'] as String? ?? ''),
      category: json['category'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      hint: json['hint'] as String?,
      difficulty: json['difficulty'] as int? ?? 1,
    );
  }
}
