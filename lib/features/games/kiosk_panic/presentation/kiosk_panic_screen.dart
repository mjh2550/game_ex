import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_ex/features/score/domain/score_record.dart';
import 'package:game_ex/features/score/presentation/score_provider.dart';
import 'package:game_ex/shared/player_name_dialog.dart';
import 'package:game_ex/shared/ready_start_overlay.dart';
import 'package:go_router/go_router.dart';

class KioskPanicScreen extends ConsumerStatefulWidget {
  const KioskPanicScreen({super.key});

  static const gameId = 'g002';

  @override
  ConsumerState<KioskPanicScreen> createState() => _KioskPanicScreenState();
}

const Map<String, String> _choiceEmoji = {
  '아메리카노': '☕',
  '라떼': '🥛',
  '바닐라라떼': '🍦',
  '딸기스무디': '🍓',
  '제로콜라': '🥤',
  '불고기버거': '🍔',
  '새우버거': '🍤',
  '감자튀김': '🍟',
  '김치볶음밥': '🍚',
  '라면': '🍜',
  '김밥': '🍙',
  '떡볶이': '🌶️',
  '치즈돈까스': '🧀',
  '핫도그': '🌭',
  '치킨너겟': '🍗',
  '초코케이크': '🍰',
  '얼음 적게': '🧊',
  '얼음 많이': '🧊',
  '샷 추가': '➕',
  '휘핑 빼기': '🚫',
  '매운맛': '🔥',
  '순한맛': '🙂',
  '치즈 추가': '🧀',
  '소스 많이': '🥫',
  '피클 빼기': '🥒',
  '포장': '🛍️',
  '매장 식사': '🍽️',
  '쿠폰 사용': '🎟️',
  '카드 결제': '💳',
  '현금 결제': '💵',
  '영수증 없음': '🗑️',
  '영수증 출력': '🧾',
  '사이즈업': '⬆️',
  '세트 변경': '🔁',
};

String _emojiForChoice(String choice) => _choiceEmoji[choice] ?? '🔘';

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

  final List<String> _menus = const [
    '아메리카노',
    '라떼',
    '바닐라라떼',
    '딸기스무디',
    '제로콜라',
    '불고기버거',
    '새우버거',
    '감자튀김',
    '김치볶음밥',
    '라면',
    '김밥',
    '떡볶이',
    '치즈돈까스',
    '핫도그',
    '치킨너겟',
    '초코케이크',
  ];

  final List<String> _options = const [
    '얼음 적게',
    '얼음 많이',
    '샷 추가',
    '휘핑 빼기',
    '매운맛',
    '순한맛',
    '치즈 추가',
    '소스 많이',
    '피클 빼기',
    '포장',
    '매장 식사',
    '쿠폰 사용',
    '카드 결제',
    '현금 결제',
    '영수증 없음',
    '영수증 출력',
    '사이즈업',
    '세트 변경',
  ];

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
    final choiceCount = min(5 + _difficulty, _menus.length + _options.length);
    final pool = [..._menus, ..._options]..shuffle(_random);

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
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
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

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.score,
    required this.time,
    required this.totalTime,
    required this.patience,
    required this.combo,
    required this.difficulty,
  });

  final int score;
  final int time;
  final int totalTime;
  final double patience;
  final int combo;
  final int difficulty;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF18212F),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _StatusMetric(label: 'Score', value: '$score'),
                _StatusMetric(label: 'Time', value: '${time}s'),
                _StatusMetric(label: 'Combo', value: 'x$combo'),
                _StatusMetric(label: 'Lv', value: '$difficulty'),
              ],
            ),
            const SizedBox(height: 12),
            _StatusBar(
              label: '남은 시간',
              value: time.clamp(0, totalTime) / totalTime,
              color: const Color(0xFF54C6EB),
            ),
            const SizedBox(height: 8),
            _StatusBar(
              label: '뒤 손님 인내심',
              value: patience.clamp(0, 100) / 100,
              color: patience > 35
                  ? const Color(0xFF2BB673)
                  : const Color(0xFFE56B1F),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFD4DEE8),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: value,
            backgroundColor: const Color(0xFF3B4657),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _CustomerPressurePanel extends StatelessWidget {
  const _CustomerPressurePanel({
    required this.patience,
    required this.difficulty,
    required this.drainPerSecond,
  });

  final double patience;
  final int difficulty;
  final double drainPerSecond;

  @override
  Widget build(BuildContext context) {
    final reaction = _reaction;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E7EF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: reaction.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SizedBox(
                width: 58,
                height: 58,
                child: Icon(reaction.icon, color: reaction.color, size: 36),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reaction.title,
                    style: const TextStyle(
                      color: Color(0xFF18212F),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reaction.message,
                    style: const TextStyle(
                      color: Color(0xFF60707F),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Lv $difficulty',
                  style: const TextStyle(
                    color: Color(0xFF18212F),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '-${drainPerSecond.toStringAsFixed(1)}/s',
                  style: TextStyle(
                    color: reaction.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _CustomerReaction get _reaction {
    if (patience > 70) {
      return const _CustomerReaction(
        icon: Icons.sentiment_satisfied_alt_rounded,
        color: Color(0xFF2BB673),
        title: '뒤 손님: 평온',
        message: '아직은 기다려줄 만한 분위기예요.',
      );
    }

    if (patience > 40) {
      return const _CustomerReaction(
        icon: Icons.visibility_rounded,
        color: Color(0xFFFFA726),
        title: '뒤 손님: 눈치',
        message: '어깨 너머로 주문을 확인하기 시작했습니다.',
      );
    }

    if (patience > 18) {
      return const _CustomerReaction(
        icon: Icons.record_voice_over_rounded,
        color: Color(0xFFE56B1F),
        title: '뒤 손님: 한숨',
        message: '“아... 아직도 고르는 중인가?”',
      );
    }

    return const _CustomerReaction(
      icon: Icons.warning_amber_rounded,
      color: Color(0xFFE53935),
      title: '뒤 손님: 폭발 직전',
      message: '실수하면 바로 분위기가 끝장납니다.',
    );
  }
}

class _CustomerReaction {
  const _CustomerReaction({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;
}

class _StatusMetric extends StatelessWidget {
  const _StatusMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFD4DEE8),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderPanel extends StatelessWidget {
  const _OrderPanel({
    required this.steps,
    required this.currentIndex,
    required this.expected,
  });

  final List<String> steps;
  final int currentIndex;
  final String expected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E7EF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '주문 목표',
              style: TextStyle(
                color: Color(0xFF60707F),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  _emojiForChoice(expected),
                  style: const TextStyle(fontSize: 30),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    expected,
                    style: const TextStyle(
                      color: Color(0xFF18212F),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (int i = 0; i < steps.length; i++)
                  _StepChip(
                    text: steps[i],
                    done: i < currentIndex,
                    active: i == currentIndex,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.text,
    required this.done,
    required this.active,
  });

  final String text;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Text(_emojiForChoice(text)),
      label: Text(text),
      backgroundColor: done
          ? const Color(0xFFDCF5E8)
          : active
          ? const Color(0xFFFFF0C2)
          : const Color(0xFFF5F7FB),
      side: BorderSide(
        color: active ? const Color(0xFFFFD166) : const Color(0xFFE1E7EF),
      ),
      labelStyle: const TextStyle(
        color: Color(0xFF18212F),
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _KioskPanel extends StatelessWidget {
  const _KioskPanel({required this.choices, required this.onPressed});

  final List<String> choices;
  final ValueChanged<String> onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB9E2F4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: choices.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 180,
            mainAxisExtent: 58,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) =>
              _KioskChoiceButton(choice: choices[index], onPressed: onPressed),
        ),
      ),
    );
  }
}

class _KioskChoiceButton extends StatelessWidget {
  const _KioskChoiceButton({required this.choice, required this.onPressed});

  final String choice;
  final ValueChanged<String> onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () => onPressed(choice),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF18212F),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFE1E7EF)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_emojiForChoice(choice), style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              choice,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
