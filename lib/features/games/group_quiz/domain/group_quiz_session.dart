import 'dart:math';

import 'package:game_ex/features/games/group_quiz/domain/group_quiz_config.dart';
import 'package:game_ex/features/games/group_quiz/domain/quiz_question.dart';
import 'package:game_ex/features/games/group_quiz/domain/quiz_team.dart';

class GroupQuizAdvanceResult {
  const GroupQuizAdvanceResult({required this.finished});

  final bool finished;
}

class GroupQuizSession {
  GroupQuizSession.setup({required this.config, required this.teams})
    : questions = const [],
      roundIndex = 0,
      remainingSeconds = config.secondsPerRound,
      attemptsRemaining = 0,
      maxCombo = 0,
      started = false,
      answerVisible = false;

  GroupQuizSession({
    required this.config,
    required this.teams,
    required this.questions,
    required this.roundIndex,
    required this.remainingSeconds,
    required this.attemptsRemaining,
    required this.maxCombo,
    required this.started,
    required this.answerVisible,
  });

  final GroupQuizConfig config;
  final List<QuizTeam> teams;
  final List<QuizQuestion> questions;
  final int roundIndex;
  final int remainingSeconds;
  final int attemptsRemaining;
  final int maxCombo;
  final bool started;
  final bool answerVisible;

  QuizQuestion get currentQuestion => questions[roundIndex];

  int get attemptLimit => attemptLimitForQuestion(currentQuestion);

  bool get hasAttemptLimit => config.hasAttemptLimit;

  int get round => roundIndex + 1;

  bool get isLastRound => roundIndex >= config.roundLimit - 1;

  bool get isTimerDanger =>
      config.hasTimeLimit && remainingSeconds <= 3 && !answerVisible;

  QuizTeam get winner {
    final ranked = [...teams]..sort((a, b) => b.score.compareTo(a.score));
    return ranked.first;
  }

  double get estimatedPlayTime =>
      (config.roundLimit * (config.hasTimeLimit ? config.secondsPerRound : 0))
          .toDouble();

  GroupQuizSession start({
    required List<QuizQuestion> questionDeck,
    required List<QuizTeam> freshTeams,
  }) {
    return GroupQuizSession(
      config: config,
      teams: freshTeams,
      questions: questionDeck,
      roundIndex: 0,
      remainingSeconds: config.secondsPerRound,
      attemptsRemaining: attemptLimitForQuestion(questionDeck.first),
      maxCombo: 0,
      started: true,
      answerVisible: false,
    );
  }

  GroupQuizSession tick() {
    if (answerVisible || !config.hasTimeLimit) {
      return this;
    }

    final nextSeconds = max(0, remainingSeconds - 1);
    return copyWith(
      remainingSeconds: nextSeconds,
      answerVisible: nextSeconds <= 0,
    );
  }

  GroupQuizSession revealAnswer() {
    return copyWith(answerVisible: true);
  }

  GroupQuizSession registerWrongAttempt() {
    if (answerVisible) {
      return this;
    }

    if (!hasAttemptLimit) {
      return this;
    }

    final nextAttempts = max(0, attemptsRemaining - 1);
    return copyWith(
      attemptsRemaining: nextAttempts,
      answerVisible: nextAttempts <= 0,
    );
  }

  ({GroupQuizSession session, GroupQuizAdvanceResult result}) awardTeam(
    QuizTeam team,
  ) {
    final timeBonus = config.hasTimeLimit ? remainingSeconds * 10 : 0;
    final earnedScore = 100 + timeBonus + (team.combo * 20);
    final nextCombo = team.combo + 1;
    final nextTeams = [
      for (final item in teams)
        item.id == team.id
            ? item.copyWith(score: item.score + earnedScore, combo: nextCombo)
            : item.copyWith(combo: 0),
    ];

    return copyWith(
      teams: nextTeams,
      maxCombo: max(maxCombo, nextCombo),
    ).advanceRound();
  }

  ({GroupQuizSession session, GroupQuizAdvanceResult result}) passQuestion() {
    final nextTeams = [for (final team in teams) team.copyWith(combo: 0)];
    return copyWith(teams: nextTeams).advanceRound();
  }

  ({GroupQuizSession session, GroupQuizAdvanceResult result}) advanceRound() {
    if (isLastRound) {
      return (
        session: this,
        result: const GroupQuizAdvanceResult(finished: true),
      );
    }

    final nextRoundIndex = roundIndex + 1;
    return (
      session: copyWith(
        roundIndex: nextRoundIndex,
        remainingSeconds: config.secondsPerRound,
        attemptsRemaining: attemptLimitForQuestion(questions[nextRoundIndex]),
        answerVisible: false,
      ),
      result: const GroupQuizAdvanceResult(finished: false),
    );
  }

  GroupQuizSession copyWith({
    GroupQuizConfig? config,
    List<QuizTeam>? teams,
    List<QuizQuestion>? questions,
    int? roundIndex,
    int? remainingSeconds,
    int? attemptsRemaining,
    int? maxCombo,
    bool? started,
    bool? answerVisible,
  }) {
    return GroupQuizSession(
      config: config ?? this.config,
      teams: teams ?? this.teams,
      questions: questions ?? this.questions,
      roundIndex: roundIndex ?? this.roundIndex,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      attemptsRemaining: attemptsRemaining ?? this.attemptsRemaining,
      maxCombo: maxCombo ?? this.maxCombo,
      started: started ?? this.started,
      answerVisible: answerVisible ?? this.answerVisible,
    );
  }

  static int attemptsForDifficulty(int difficulty) {
    return difficulty >= 3 ? 5 : 3;
  }

  int attemptLimitForQuestion(QuizQuestion question) {
    return switch (config.attemptLimit) {
      GroupQuizConfig.adaptiveAttempts => attemptsForDifficulty(
        question.difficulty,
      ),
      GroupQuizConfig.unlimitedAttempts => 0,
      _ => config.attemptLimit,
    };
  }
}
