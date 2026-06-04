import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_ex/features/games/group_quiz/data/group_quiz_question_repository.dart';
import 'package:game_ex/features/games/group_quiz/data/group_quiz_team_catalog.dart';
import 'package:game_ex/features/games/group_quiz/domain/group_quiz_config.dart';
import 'package:game_ex/features/games/group_quiz/domain/group_quiz_session.dart';
import 'package:game_ex/features/games/group_quiz/domain/quiz_question.dart';
import 'package:game_ex/features/games/group_quiz/domain/quiz_team.dart';
import 'package:game_ex/features/games/group_quiz/presentation/group_quiz_widgets.dart';
import 'package:game_ex/features/score/domain/score_record.dart';
import 'package:game_ex/features/score/presentation/score_provider.dart';
import 'package:game_ex/shared/game_catalog.dart';
import 'package:go_router/go_router.dart';

class GroupQuizScreen extends ConsumerStatefulWidget {
  const GroupQuizScreen({super.key});

  static const gameId = GameIds.groupQuiz;

  @override
  ConsumerState<GroupQuizScreen> createState() => _GroupQuizScreenState();
}

class _GroupQuizScreenState extends ConsumerState<GroupQuizScreen> {
  Timer? _timer;
  final _questionRepository = GroupQuizQuestionRepository();

  GroupQuizConfig _config = const GroupQuizConfig();
  late GroupQuizSession _session;
  bool _isSaving = false;
  bool _isLoadingQuestions = false;
  bool _roundScored = false;
  bool _awaitingCorrectTeam = false;
  String? _answerFeedback;
  List<String> _categories = const [GroupQuizConfig.allCategory];

  @override
  void initState() {
    super.initState();
    _session = GroupQuizSession.setup(
      config: _config,
      teams: buildGroupQuizTeams(_config.teamCount),
    );
    _loadCategories();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startGame() async {
    if (_isLoadingQuestions) {
      return;
    }

    setState(() {
      _isLoadingQuestions = true;
    });

    final List<QuizQuestion> questionDeck;
    try {
      questionDeck = await _questionRepository.buildDeck(
        roundLimit: _config.roundLimit,
        category: _config.category,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingQuestions = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('문제팩을 불러오지 못했어요.')));
      return;
    }

    if (!mounted) {
      return;
    }

    if (questionDeck.isEmpty) {
      setState(() {
        _isLoadingQuestions = false;
      });
      return;
    }

    setState(() {
      _isLoadingQuestions = false;
      _roundScored = false;
      _awaitingCorrectTeam = false;
      _answerFeedback = null;
      _session = _session.start(
        questionDeck: questionDeck,
        freshTeams: buildGroupQuizTeams(_config.teamCount),
      );
    });
    if (_config.hasTimeLimit) {
      _startTimer();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _questionRepository.loadCategories();
      if (!mounted) {
        return;
      }

      setState(() {
        _categories = categories;
        if (!categories.contains(_config.category)) {
          _config = _config.copyWith(category: GroupQuizConfig.allCategory);
          _session = GroupQuizSession.setup(
            config: _config,
            teams: buildGroupQuizTeams(_config.teamCount),
          );
        }
      });
    } catch (_) {
      // The start flow already shows an error if the question pack cannot load.
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_session.config.hasTimeLimit ||
          _session.answerVisible ||
          _isSaving) {
        return;
      }

      setState(() {
        _session = _session.tick();
      });

      if (_session.answerVisible) {
        _timer?.cancel();
        setState(() {
          _answerFeedback = '시간 종료! 정답을 확인하세요.';
          _roundScored = false;
          _awaitingCorrectTeam = false;
        });
      }
    });
  }

  void _revealAnswer() {
    _timer?.cancel();
    setState(() {
      _session = _session.revealAnswer();
      _answerFeedback = '정답을 공개했어요.';
      _roundScored = false;
      _awaitingCorrectTeam = false;
    });
  }

  void _passQuestion() {
    final next = _session.passQuestion();
    _handleAdvance(next);
  }

  void _advanceVisibleQuestion() {
    if (_awaitingCorrectTeam) {
      return;
    }

    final next = _roundScored
        ? _session.advanceRound()
        : _session.passQuestion();
    _handleAdvance(next);
  }

  void _submitAnswer(int optionIndex) {
    if (_session.answerVisible || _isSaving) {
      return;
    }

    if (optionIndex == _session.currentQuestion.answerIndex) {
      _timer?.cancel();
      setState(() {
        _answerFeedback = '정답입니다. 맞힌 팀을 선택하세요.';
        _roundScored = false;
        _awaitingCorrectTeam = true;
        _session = _session.revealAnswer();
      });
      return;
    }

    _timer?.cancel();
    setState(() {
      _roundScored = false;
      _awaitingCorrectTeam = false;
      _session = _session.revealAnswer();
      _answerFeedback = '오답입니다. 정답을 확인하세요.';
    });
  }

  void _awardCorrectTeam(QuizTeam team) {
    if (!_session.answerVisible || !_awaitingCorrectTeam || _isSaving) {
      return;
    }

    setState(() {
      _roundScored = true;
      _awaitingCorrectTeam = false;
      _answerFeedback = '${team.name} 정답!';
      _session = _session.scoreTeam(team);
    });
  }

  void _handleAdvance(
    ({GroupQuizSession session, GroupQuizAdvanceResult result}) next,
  ) {
    _timer?.cancel();
    setState(() {
      _session = next.session;
      _roundScored = false;
      _awaitingCorrectTeam = false;
      _answerFeedback = null;
    });

    if (next.result.finished) {
      _finishGame();
      return;
    }

    if (next.session.config.hasTimeLimit) {
      _startTimer();
    }
  }

  void _updateConfig(GroupQuizConfig config) {
    setState(() {
      _config = config;
      _session = GroupQuizSession.setup(
        config: config,
        teams: buildGroupQuizTeams(config.teamCount),
      );
      _roundScored = false;
      _awaitingCorrectTeam = false;
      _answerFeedback = null;
    });
  }

  Future<void> _finishGame() async {
    if (_isSaving) {
      return;
    }

    _timer?.cancel();
    setState(() {
      _isSaving = true;
    });

    final topTeam = _session.winner;
    final repository = await ref.read(localScoreRepositoryProvider.future);
    final saveResult = await repository.saveRecord(
      ScoreRecord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        gameId: GroupQuizScreen.gameId,
        playerName: topTeam.name,
        score: topTeam.score,
        playTime: _session.estimatedPlayTime,
        nearMissCount: _config.roundLimit,
        maxCombo: _session.maxCombo,
        difficultyReached: _config.roundLimit,
        playedAt: DateTime.now(),
      ),
    );

    ref.invalidate(bestScoreProvider(GroupQuizScreen.gameId));
    ref.invalidate(leaderboardRecordsProvider(GroupQuizScreen.gameId));

    if (!mounted) {
      return;
    }

    context.go(
      '/game-result',
      extra: {
        'gameId': GroupQuizScreen.gameId,
        'playerName': '${topTeam.name} 우승',
        'score': topTeam.score,
        'stats': {
          'quiz_rounds': _config.roundLimit,
          'category': _config.category,
          'winning_team_count': _config.teamCount,
          'max_combo': _session.maxCombo,
          'difficulty_reached': _config.roundLimit,
        },
        'isNewBest': saveResult.isNewBest,
        'bestScore': saveResult.bestScore,
        'rank': saveResult.rank,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        foregroundColor: const Color(0xFF18212F),
        title: const Text(
          '눈치 퀴즈 대작전',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: _session.started ? _buildPlayView() : _buildSetupView(),
      ),
    );
  }

  Widget _buildSetupView() {
    return GroupQuizSetupView(
      config: _config,
      categories: _categories,
      onConfigChanged: _updateConfig,
      onStart: _startGame,
      starting: _isLoadingQuestions,
    );
  }

  Widget _buildPlayView() {
    return GroupQuizPlayView(
      session: _session,
      answerFeedback: _answerFeedback,
      onAnswerSubmitted: _submitAnswer,
      correctAnswerPendingAward: _awaitingCorrectTeam,
      onCorrectTeamSelected: _awardCorrectTeam,
      onRevealAnswer: _revealAnswer,
      onPassQuestion: _passQuestion,
      onAdvanceVisibleQuestion: _advanceVisibleQuestion,
    );
  }
}
