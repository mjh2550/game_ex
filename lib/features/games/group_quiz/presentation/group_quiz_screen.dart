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
import 'package:go_router/go_router.dart';

class GroupQuizScreen extends ConsumerStatefulWidget {
  const GroupQuizScreen({super.key});

  static const gameId = 'g004';

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

  @override
  void initState() {
    super.initState();
    _session = GroupQuizSession.setup(
      config: _config,
      teams: buildGroupQuizTeams(_config.teamCount),
    );
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
      _session = _session.start(
        questionDeck: questionDeck,
        freshTeams: buildGroupQuizTeams(_config.teamCount),
      );
    });
    if (_config.hasTimeLimit) {
      _startTimer();
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
      }
    });
  }

  void _revealAnswer() {
    _timer?.cancel();
    setState(() {
      _session = _session.revealAnswer();
    });
  }

  void _awardTeam(QuizTeam team) {
    final next = _session.awardTeam(team);
    _handleAdvance(next);
  }

  void _passQuestion() {
    final next = _session.passQuestion();
    _handleAdvance(next);
  }

  void _handleAdvance(
    ({GroupQuizSession session, GroupQuizAdvanceResult result}) next,
  ) {
    _timer?.cancel();
    setState(() {
      _session = next.session;
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
      onConfigChanged: _updateConfig,
      onStart: _startGame,
      starting: _isLoadingQuestions,
    );
  }

  Widget _buildPlayView() {
    return GroupQuizPlayView(
      session: _session,
      onRevealAnswer: _revealAnswer,
      onAwardTeam: _awardTeam,
      onPassQuestion: _passQuestion,
    );
  }
}
