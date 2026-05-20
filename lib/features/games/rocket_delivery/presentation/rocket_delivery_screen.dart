import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_ex/features/score/domain/score_record.dart';
import 'package:game_ex/features/score/presentation/score_provider.dart';
import 'package:game_ex/shared/player_name_dialog.dart';
import 'package:game_ex/shared/ready_start_overlay.dart';
import 'package:go_router/go_router.dart';

class RocketDeliveryScreen extends ConsumerStatefulWidget {
  const RocketDeliveryScreen({super.key});

  static const gameId = 'g003';

  @override
  ConsumerState<RocketDeliveryScreen> createState() =>
      _RocketDeliveryScreenState();
}

class _RocketDeliveryScreenState extends ConsumerState<RocketDeliveryScreen> {
  static const _totalTime = 45;
  static const _maxLives = 3;

  final _random = Random();
  final _focusNode = FocusNode();
  Timer? _timer;
  Timer? _packageTimer;

  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  int _sortedCount = 0;
  int _missCount = 0;
  int _remainingTime = _totalTime;
  int _lives = _maxLives;
  int _difficulty = 1;
  bool _isReadyOverlayVisible = true;
  bool _isSaving = false;
  _SortFeedback? _feedback;
  Timer? _feedbackTimer;

  late List<_DeliveryZone> _activeZones;
  final List<_MovingPackage> _packages = [];
  int _nextPackageId = 0;

  final List<_DeliveryZone> _zones = const [
    _DeliveryZone('A', '강남', Icons.apartment_rounded, Color(0xFF2BB673)),
    _DeliveryZone('B', '홍대', Icons.storefront_rounded, Color(0xFFE56B1F)),
    _DeliveryZone('C', '잠실', Icons.stadium_rounded, Color(0xFF54C6EB)),
    _DeliveryZone('D', '용산', Icons.train_rounded, Color(0xFF8E6BE8)),
    _DeliveryZone('E', '성수', Icons.factory_rounded, Color(0xFFE84A5F)),
    _DeliveryZone('F', '판교', Icons.business_rounded, Color(0xFF60707F)),
  ];

  @override
  void initState() {
    super.initState();
    _activeZones = _zones.take(4).toList();
    _refreshDifficulty();
    _spawnPackage();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _packageTimer?.cancel();
    _feedbackTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _startGame() {
    if (!_isReadyOverlayVisible) {
      return;
    }

    setState(() {
      _isReadyOverlayVisible = false;
    });
    _focusNode.requestFocus();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _startPackageTimer();
  }

  void _tick() {
    if (_isSaving || _isReadyOverlayVisible) {
      return;
    }

    setState(() {
      _remainingTime--;
    });

    if (_remainingTime <= 0) {
      _finishGame();
    }
  }

  void _startPackageTimer() {
    _packageTimer?.cancel();
    _packageTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
      if (_isSaving || _isReadyOverlayVisible) {
        return;
      }

      setState(() {
        for (final package in _packages) {
          package.progress += _packageSpeed;
        }

        if (_packages.isEmpty || _packages.last.progress >= _spawnGap) {
          _spawnPackage();
        }
      });

      final missedCount = _packages
          .where((package) => package.progress >= 1)
          .length;
      if (missedCount > 0) {
        _registerMistakes(missedCount);
      }
    });
  }

  double get _packageSpeed => 0.012 + (_difficulty * 0.0028);

  double get _spawnGap => max(0.14, 0.34 - (_difficulty * 0.022));

  _MovingPackage get _currentPackage {
    return _packages.reduce((a, b) => a.progress >= b.progress ? a : b);
  }

  void _refreshDifficulty() {
    _difficulty = 1 + (_sortedCount ~/ 5);
    final zoneCount = min(4 + (_difficulty ~/ 2), _zones.length);
    _activeZones = _zones.take(zoneCount).toList();
  }

  void _spawnPackage() {
    _refreshDifficulty();
    final target = _activeZones[_random.nextInt(_activeZones.length)];
    final label = _boxLabels[_random.nextInt(_boxLabels.length)];

    _packages.add(
      _MovingPackage(
        id: _nextPackageId++,
        package: _DeliveryPackage(label: label, target: target),
      ),
    );
  }

  void _selectZone(_DeliveryZone zone) {
    if (_isSaving || _isReadyOverlayVisible) {
      return;
    }

    final currentPackage = _currentPackage;

    if (zone.code == currentPackage.package.target.code) {
      setState(() {
        _packages.removeWhere((package) => package.id == currentPackage.id);
        _sortedCount++;
        _combo++;
        _maxCombo = max(_maxCombo, _combo);
        _score += 60 + (_combo * 8) + (_difficulty * 8);
        _refreshDifficulty();
        _setFeedback(
          _SortFeedback.correct(
            '${currentPackage.package.target.code} ${currentPackage.package.target.name}',
          ),
        );
        if (_packages.isEmpty) {
          _spawnPackage();
        }
      });
      return;
    }

    _registerMistakes(1, packageId: currentPackage.id);
  }

  void _registerMistakes(int count, {int? packageId}) {
    if (_isSaving) {
      return;
    }

    setState(() {
      _missCount += count;
      _combo = 0;
      _lives -= count;
      _score = max(0, _score - 35);
      _setFeedback(_SortFeedback.wrong(count > 1 ? '$count개 놓침' : '분류 실패'));
      if (packageId == null) {
        _packages.removeWhere((package) => package.progress >= 1);
      } else {
        _packages.removeWhere((package) => package.id == packageId);
      }
      _refreshDifficulty();
      if (_packages.isEmpty) {
        _spawnPackage();
      }
    });

    if (_lives <= 0) {
      _finishGame();
    }
  }

  void _setFeedback(_SortFeedback feedback) {
    _feedbackTimer?.cancel();
    _feedback = feedback;
    _feedbackTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _feedback = null;
      });
    });
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return;
    }

    final key = event.logicalKey;
    final index = switch (key) {
      LogicalKeyboardKey.arrowLeft || LogicalKeyboardKey.keyA => 0,
      LogicalKeyboardKey.arrowUp || LogicalKeyboardKey.keyW => 1,
      LogicalKeyboardKey.arrowRight || LogicalKeyboardKey.keyD => 2,
      LogicalKeyboardKey.arrowDown || LogicalKeyboardKey.keyS => 3,
      LogicalKeyboardKey.digit5 => 4,
      LogicalKeyboardKey.digit6 => 5,
      _ => -1,
    };

    if (index >= 0 && index < _activeZones.length) {
      _selectZone(_activeZones[index]);
    }
  }

  Future<void> _finishGame() async {
    if (_isSaving) {
      return;
    }

    _timer?.cancel();
    _packageTimer?.cancel();
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
        gameId: RocketDeliveryScreen.gameId,
        playerName: playerName,
        score: _score,
        playTime: (_totalTime - _remainingTime).toDouble(),
        nearMissCount: _sortedCount,
        maxCombo: _maxCombo,
        difficultyReached: _difficulty,
        playedAt: DateTime.now(),
      ),
    );

    ref.invalidate(bestScoreProvider(RocketDeliveryScreen.gameId));
    ref.invalidate(leaderboardRecordsProvider(RocketDeliveryScreen.gameId));

    if (!mounted) {
      return;
    }

    context.go(
      '/game-result',
      extra: {
        'gameId': RocketDeliveryScreen.gameId,
        'playerName': playerName,
        'score': _score,
        'stats': {
          'packages_sorted': _sortedCount,
          'miss_count': _missCount,
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
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F7FB),
          elevation: 0,
          foregroundColor: const Color(0xFF18212F),
          title: const Text(
            '쿠팡 로켓배송',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 430;

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      compact ? 14 : 20,
                      8,
                      compact ? 14 : 20,
                      20,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _RocketStatusPanel(
                              score: _score,
                              time: _remainingTime,
                              totalTime: _totalTime,
                              lives: _lives,
                              combo: _combo,
                              difficulty: _difficulty,
                            ),
                            const SizedBox(height: 14),
                            _ConveyorPanel(
                              packages: _packages,
                              currentPackage: _currentPackage.package,
                              speed: _packageSpeed,
                              spawnGap: _spawnGap,
                              feedback: _feedback,
                            ),
                            const SizedBox(height: 14),
                            _ZonePanel(
                              zones: _activeZones,
                              onPressed: _selectZone,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (_isReadyOverlayVisible)
                ReadyStartOverlay(onCompleted: _startGame),
            ],
          ),
        ),
      ),
    );
  }
}

const _boxLabels = ['생수', '휴지', '간식', '충전기', '양말', '샴푸', '사료', '키보드'];

class _DeliveryZone {
  const _DeliveryZone(this.code, this.name, this.icon, this.color);

  final String code;
  final String name;
  final IconData icon;
  final Color color;
}

class _DeliveryPackage {
  const _DeliveryPackage({required this.label, required this.target});

  final String label;
  final _DeliveryZone target;
}

class _MovingPackage {
  _MovingPackage({required this.id, required this.package});

  final int id;
  final _DeliveryPackage package;
  double progress = 0;
}

class _SortFeedback {
  const _SortFeedback({
    required this.correct,
    required this.message,
    required this.color,
    required this.icon,
  });

  factory _SortFeedback.correct(String destination) {
    return _SortFeedback(
      correct: true,
      message: '$destination 분류 성공',
      color: const Color(0xFF2BB673),
      icon: Icons.check_circle_rounded,
    );
  }

  factory _SortFeedback.wrong(String reason) {
    return _SortFeedback(
      correct: false,
      message: reason,
      color: const Color(0xFFE53935),
      icon: Icons.cancel_rounded,
    );
  }

  final bool correct;
  final String message;
  final Color color;
  final IconData icon;
}

class _RocketStatusPanel extends StatelessWidget {
  const _RocketStatusPanel({
    required this.score,
    required this.time,
    required this.totalTime,
    required this.lives,
    required this.combo,
    required this.difficulty,
  });

  final int score;
  final int time;
  final int totalTime;
  final int lives;
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
                _RocketMetric(label: 'Score', value: '$score'),
                _RocketMetric(label: 'Time', value: '${time}s'),
                _RocketMetric(label: 'Life', value: 'x$lives'),
                _RocketMetric(label: 'Lv', value: '$difficulty'),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: time.clamp(0, totalTime) / totalTime,
                backgroundColor: const Color(0xFF3B4657),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF54C6EB),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'COMBO x$combo',
              style: const TextStyle(
                color: Color(0xFFFFD166),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RocketMetric extends StatelessWidget {
  const _RocketMetric({required this.label, required this.value});

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

class _ConveyorPanel extends StatelessWidget {
  const _ConveyorPanel({
    required this.packages,
    required this.currentPackage,
    required this.speed,
    required this.spawnGap,
    required this.feedback,
  });

  final List<_MovingPackage> packages;
  final _DeliveryPackage currentPackage;
  final double speed;
  final double spawnGap;
  final _SortFeedback? feedback;

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_shipping_rounded,
                  color: Color(0xFF18212F),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '컨베이어 벨트',
                    style: TextStyle(
                      color: Color(0xFF18212F),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '속도 ${speed.toStringAsFixed(3)} · 간격 ${spawnGap.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF60707F),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 126,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        top: 42,
                        bottom: 42,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF7FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFB9E2F4)),
                          ),
                        ),
                      ),
                      for (final movingPackage
                          in packages.toList()
                            ..sort((a, b) => a.progress.compareTo(b.progress)))
                        Positioned(
                          left:
                              (constraints.maxWidth - 92) *
                              movingPackage.progress.clamp(0, 1),
                          top: 8,
                          child: _PackageBox(
                            package: movingPackage.package,
                            isCurrent:
                                movingPackage.id ==
                                packages
                                    .reduce(
                                      (a, b) =>
                                          a.progress >= b.progress ? a : b,
                                    )
                                    .id,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: feedback == null
                  ? const SizedBox(height: 38)
                  : _SortFeedbackBanner(
                      key: ValueKey('${feedback!.correct}${feedback!.message}'),
                      feedback: feedback!,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageBox extends StatelessWidget {
  const _PackageBox({required this.package, required this.isCurrent});

  final _DeliveryPackage package;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFD166),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrent ? package.target.color : const Color(0xFFE56B1F),
          width: isCurrent ? 4 : 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        width: 92,
        height: 92,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_rounded,
              size: 32,
              color: Color(0xFF18212F),
            ),
            const SizedBox(height: 3),
            Text(
              package.label,
              style: const TextStyle(
                color: Color(0xFF18212F),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              package.target.code,
              style: TextStyle(
                color: package.target.color,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortFeedbackBanner extends StatelessWidget {
  const _SortFeedbackBanner({super.key, required this.feedback});

  final _SortFeedback feedback;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: feedback.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: feedback.color, width: 1.5),
      ),
      child: SizedBox(
        height: 38,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(feedback.icon, color: feedback.color, size: 20),
            const SizedBox(width: 7),
            Text(
              feedback.message,
              style: TextStyle(
                color: feedback.color,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZonePanel extends StatelessWidget {
  const _ZonePanel({required this.zones, required this.onPressed});

  final List<_DeliveryZone> zones;
  final ValueChanged<_DeliveryZone> onPressed;

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
          itemCount: zones.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 190,
            mainAxisExtent: 72,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final zone = zones[index];
            final hint = switch (index) {
              0 => '← A',
              1 => '↑ W',
              2 => '→ D',
              3 => '↓ S',
              _ => '${index + 1}',
            };

            return FilledButton(
              onPressed: () => onPressed(zone),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF18212F),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: zone.color, width: 1.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(zone.icon, color: zone.color, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${zone.code} ${zone.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    hint,
                    style: const TextStyle(
                      color: Color(0xFF60707F),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
