enum QuizQuestionType { initial, complete, commonSense, multipleChoice }

extension QuizQuestionTypeParser on QuizQuestionType {
  String get code => switch (this) {
    QuizQuestionType.initial => 'initial',
    QuizQuestionType.complete => 'complete',
    QuizQuestionType.commonSense => 'commonSense',
    QuizQuestionType.multipleChoice => 'multipleChoice',
  };

  static QuizQuestionType fromCode(String code) {
    return switch (code) {
      'initial' => QuizQuestionType.initial,
      'complete' => QuizQuestionType.complete,
      'commonSense' => QuizQuestionType.commonSense,
      'multipleChoice' => QuizQuestionType.multipleChoice,
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
    required this.options,
    required this.answerIndex,
    this.hint,
    this.difficulty = 1,
  });

  final String id;
  final QuizQuestionType type;
  final String category;
  final String question;
  final String answer;
  final List<String> options;
  final int answerIndex;
  final String? hint;
  final int difficulty;

  String get correctOption => options.isEmpty ? '' : options[answerIndex];

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List? ?? const [])
        .map((item) => item.toString())
        .toList();
    final answerIndex = json['answerIndex'] as int? ?? 0;

    return QuizQuestion(
      id: json['id'] as String,
      type: QuizQuestionTypeParser.fromCode(json['type'] as String? ?? ''),
      category: json['category'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      options: options,
      answerIndex: options.isEmpty
          ? 0
          : answerIndex.clamp(0, options.length - 1),
      hint: json['hint'] as String?,
      difficulty: json['difficulty'] as int? ?? 1,
    );
  }
}
