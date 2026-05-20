import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_ex/features/games/kiosk_panic/data/customer_reaction_catalog.dart';
import 'package:game_ex/features/games/kiosk_panic/data/kiosk_catalog.dart';
import 'package:game_ex/features/games/kiosk_panic/domain/customer_reaction.dart';
import 'package:game_ex/features/score/domain/score_record.dart';
import 'package:game_ex/features/score/presentation/score_provider.dart';
import 'package:game_ex/shared/player_name_dialog.dart';
import 'package:game_ex/shared/ready_start_overlay.dart';
import 'package:go_router/go_router.dart';

part 'kiosk_panic_widgets.dart';

class KioskPanicScreen extends ConsumerStatefulWidget {
  const KioskPanicScreen({super.key});

  static const gameId = 'g002';

  @override
  ConsumerState<KioskPanicScreen> createState() => _KioskPanicScreenState();
}

class _KioskPanicScreenState extends ConsumerState<KioskPanicScreen> {
  static const _totalTime = 45;
  static const _maxPatience = 100.0;

  final Random _random = Random();
  Timer? _timer;

  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  int _ordersCompleted = 0;
  int _wrongCount = 0;
  int _remainingTime = _totalTime;
  int _difficulty = 1;
  double _patience = _maxPatience;
  bool _isReadyOverlayVisible = true;
  bool _isSaving = false;

  late List<String> _targetSteps;
  late List<String> _choices;
  int _stepIndex = 0;

  @override
  void initState() {
    super.initState();
    _generateOrder();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    if (_isSaving || _isReadyOverlayVisible) {
      return;
    }

    setState(() {
      _remainingTime--;
      _patience = max(0, _patience - _patienceDrainPerSecond);
    });

    if (_remainingTime <= 0 || _patience <= 0) {
      _finishGame();
    }
  }

  double get _patienceDrainPerSecond => 1.2 + (_difficulty * 0.85);

  void _startGame() {
    if (!_isReadyOverlayVisible) {
      return;
    }

    setState(() {
      _isReadyOverlayVisible = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _generateOrder() {
    _difficulty = 1 + (_ordersCompleted ~/ 3);
    final stepCount = min(2 + _difficulty, 8);
    final choiceCount = min(
      5 + _difficulty,
      kioskMenus.length + kioskOptions.length,
    );
    final pool = [...kioskMenus, ...kioskOptions]..shuffle(_random);

    _targetSteps = pool.take(stepCount).toList();
    _choices = pool.take(max(choiceCount, stepCount + 1)).toList()
      ..shuffle(_random);
    _stepIndex = 0;
  }

  void _selectChoice(String choice) {
    if (_isSaving || _isReadyOverlayVisible) {
      return;
    }

    final expected = _targetSteps[_stepIndex];

    if (choice == expected) {
      setState(() {
        _stepIndex++;
        _score += 40 + (_combo * 6) + (_difficulty * 5);
      });

      if (_stepIndex >= _targetSteps.length) {
        setState(() {
          _ordersCompleted++;
          _combo++;
          _maxCombo = max(_maxCombo, _combo);
          _score += 120 + (_remainingTime * 2) + (_combo * 15);
          _patience = min(_maxPatience, _patience + 16);
          _generateOrder();
        });
      }
      return;
    }

    setState(() {
      _wrongCount++;
      _combo = 0;
      _score = max(0, _score - 25);
      _patience = max(0, _patience - (12 + (_difficulty * 2)));
    });

    if (_patience <= 0) {
      _finishGame();
    }
  }

  Future<void> _finishGame() async {
    if (_isSaving) {
      return;
    }

    _timer?.cancel();
    setState(() {
      _isSaving = true;
    });

    final repository = await ref.read(localScoreRepositoryProvider.future);
    if (!mounted) {
      return;
    }

    final playerName = await showPlayerNameDialog(
      context,
      recentName: repository.getLastPlayerName(),
    );

    if (!mounted || playerName == null) {
      return;
    }

    final saveResult = await repository.saveRecord(
      ScoreRecord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        gameId: KioskPanicScreen.gameId,
        playerName: playerName,
        score: _score,
        playTime: (_totalTime - _remainingTime).toDouble(),
        nearMissCount: _ordersCompleted,
        maxCombo: _maxCombo,
        difficultyReached: _difficulty,
        playedAt: DateTime.now(),
      ),
    );

    ref.invalidate(bestScoreProvider(KioskPanicScreen.gameId));
    ref.invalidate(leaderboardRecordsProvider(KioskPanicScreen.gameId));

    if (!mounted) {
      return;
    }

    context.go(
      '/game-result',
      extra: {
        'gameId': KioskPanicScreen.gameId,
        'score': _score,
        'playerName': playerName,
        'stats': {
          'orders_completed': _ordersCompleted,
          'wrong_count': _wrongCount,
          'max_combo': _maxCombo,
          'difficulty_reached': _difficulty,
        },
        'isNewBest': saveResult.isNewBest,
        'bestScore': saveResult.bestScore,
        'rank': saveResult.rank,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final expected = _targetSteps[_stepIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFEAF7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xCCF5F7FB),
        elevation: 0,
        foregroundColor: const Color(0xFF18212F),
        title: const Text(
          '키오스크 눈치게임',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 430;

            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/kiosk_panic_hud_bg.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
                Positioned.fill(
                  child: ColoredBox(
                    color: const Color(0xFFF5F7FB).withValues(alpha: 0.74),
                  ),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 14 : 20,
                    8,
                    compact ? 14 : 20,
                    20,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _StatusPanel(
                            score: _score,
                            time: _remainingTime,
                            totalTime: _totalTime,
                            patience: _patience,
                            combo: _combo,
                            difficulty: _difficulty,
                          ),
                          const SizedBox(height: 14),
                          _CustomerPressurePanel(
                            patience: _patience,
                            difficulty: _difficulty,
                            drainPerSecond: _patienceDrainPerSecond,
                          ),
                          const SizedBox(height: 14),
                          _OrderPanel(
                            steps: _targetSteps,
                            currentIndex: _stepIndex,
                            expected: expected,
                          ),
                          const SizedBox(height: 14),
                          _KioskPanel(
                            choices: _choices,
                            onPressed: _selectChoice,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isReadyOverlayVisible)
                  ReadyStartOverlay(onCompleted: _startGame),
              ],
            );
          },
        ),
      ),
    );
  }
}
