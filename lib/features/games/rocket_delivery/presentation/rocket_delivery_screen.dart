import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_ex/features/games/rocket_delivery/data/rocket_delivery_catalog.dart';
import 'package:game_ex/features/games/rocket_delivery/domain/delivery_package.dart';
import 'package:game_ex/features/games/rocket_delivery/domain/delivery_zone.dart';
import 'package:game_ex/features/games/rocket_delivery/domain/moving_package.dart';
import 'package:game_ex/features/games/rocket_delivery/domain/sort_feedback.dart';
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
  Timer? _zoneShuffleTimer;

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
  bool _zoneShuffleEnabled = true;
  bool _isZoneShuffleWarningVisible = false;
  int _lastShuffleDifficulty = 1;
  SortFeedback? _feedback;
  Timer? _feedbackTimer;

  late List<DeliveryZone> _activeZones;
  final List<MovingPackage> _packages = [];
  int _nextPackageId = 0;

  @override
  void initState() {
    super.initState();
    _activeZones = rocketDeliveryZones.take(4).toList();
    _refreshDifficulty();
    _spawnPackage();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _packageTimer?.cancel();
    _zoneShuffleTimer?.cancel();
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

  double get _scoreMultiplier => _zoneShuffleEnabled ? 1.5 : 1.0;

  MovingPackage get _currentPackage {
    return _packages.reduce((a, b) => a.progress >= b.progress ? a : b);
  }

  void _refreshDifficulty() {
    _difficulty = 1 + (_sortedCount ~/ 5);
    final zoneCount = min(4 + (_difficulty ~/ 2), rocketDeliveryZones.length);
    final unlockedZones = rocketDeliveryZones.take(zoneCount).toList();
    final unlockedCodes = unlockedZones.map((zone) => zone.code).toSet();
    final retainedZones = _activeZones
        .where((zone) => unlockedCodes.contains(zone.code))
        .toList();
    final retainedCodes = retainedZones.map((zone) => zone.code).toSet();
    final newZones = unlockedZones
        .where((zone) => !retainedCodes.contains(zone.code))
        .toList();
    _activeZones = [...retainedZones, ...newZones];

    if (_shouldShuffleZones) {
      _scheduleZoneShuffle();
    }
  }

  bool get _shouldShuffleZones {
    return _zoneShuffleEnabled &&
        _difficulty >= 5 &&
        _difficulty.isOdd &&
        _difficulty > _lastShuffleDifficulty &&
        !_isZoneShuffleWarningVisible;
  }

  void _setZoneShuffleEnabled(bool enabled) {
    setState(() {
      _zoneShuffleEnabled = enabled;
      if (!enabled) {
        _zoneShuffleTimer?.cancel();
        _isZoneShuffleWarningVisible = false;
      }
    });
  }

  void _scheduleZoneShuffle() {
    _lastShuffleDifficulty = _difficulty;
    _zoneShuffleTimer?.cancel();
    _isZoneShuffleWarningVisible = true;
    _zoneShuffleTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted || _isSaving) {
        return;
      }

      setState(() {
        _activeZones.shuffle(_random);
        _isZoneShuffleWarningVisible = false;
        _setFeedback(
          SortFeedback.notice(
            '배송구역 재배치 완료',
            Color(0xFFE56B1F),
            Icons.shuffle_rounded,
          ),
        );
      });
    });
  }

  void _spawnPackage() {
    _refreshDifficulty();
    final target = _activeZones[_random.nextInt(_activeZones.length)];
    final item =
        rocketDeliveryItems[_random.nextInt(rocketDeliveryItems.length)];

    _packages.add(
      MovingPackage(
        id: _nextPackageId++,
        package: DeliveryPackage(item: item, target: target),
      ),
    );
  }

  void _selectZone(DeliveryZone zone) {
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
        final baseScore = 60 + (_combo * 8) + (_difficulty * 8);
        _score += (baseScore * _scoreMultiplier).round();
        _refreshDifficulty();
        _setFeedback(
          SortFeedback.correct(
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
      _setFeedback(SortFeedback.wrong(count > 1 ? '$count개 놓침' : '분류 실패'));
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

  void _setFeedback(SortFeedback feedback) {
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
    _zoneShuffleTimer?.cancel();
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
        backgroundColor: const Color(0xFFEAF7FF),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xCCF5F7FB),
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
              Positioned.fill(
                child: Image.asset(
                  'assets/images/rocket_delivery_hud_bg.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              Positioned.fill(
                child: ColoredBox(
                  color: const Color(0xFFF5F7FB).withValues(alpha: 0.72),
                ),
              ),
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
                              zoneShuffleEnabled: _zoneShuffleEnabled,
                              scoreMultiplier: _scoreMultiplier,
                              onZoneShuffleChanged: _setZoneShuffleEnabled,
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
                              warningVisible: _isZoneShuffleWarningVisible,
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

class _RocketStatusPanel extends StatelessWidget {
  const _RocketStatusPanel({
    required this.score,
    required this.time,
    required this.totalTime,
    required this.lives,
    required this.combo,
    required this.difficulty,
    required this.zoneShuffleEnabled,
    required this.scoreMultiplier,
    required this.onZoneShuffleChanged,
  });

  final int score;
  final int time;
  final int totalTime;
  final int lives;
  final int combo;
  final int difficulty;
  final bool zoneShuffleEnabled;
  final double scoreMultiplier;
  final ValueChanged<bool> onZoneShuffleChanged;

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
            const SizedBox(height: 10),
            _RocketOptionSwitch(
              label: '구역 재배치',
              value: zoneShuffleEnabled,
              scoreMultiplier: scoreMultiplier,
              onChanged: onZoneShuffleChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _RocketOptionSwitch extends StatelessWidget {
  const _RocketOptionSwitch({
    required this.label,
    required this.value,
    required this.scoreMultiplier,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final double scoreMultiplier;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.tune_rounded, color: Color(0xFFD4DEE8), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFD4DEE8),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'x${scoreMultiplier.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: value
                          ? const Color(0xFFFFD166)
                          : const Color(0xFF8A98A8),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              activeThumbColor: const Color(0xFF2BB673),
              onChanged: onChanged,
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

  final List<MovingPackage> packages;
  final DeliveryPackage currentPackage;
  final double speed;
  final double spawnGap;
  final SortFeedback? feedback;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
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
                  : SortFeedbackBanner(
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

  final DeliveryPackage package;
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
            DecoratedBox(
              decoration: BoxDecoration(
                color: package.item.color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SizedBox(
                width: 34,
                height: 30,
                child: Icon(
                  package.item.icon,
                  size: 22,
                  color: package.item.color,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              package.item.label,
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

class SortFeedbackBanner extends StatelessWidget {
  const SortFeedbackBanner({super.key, required this.feedback});

  final SortFeedback feedback;

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
  const _ZonePanel({
    required this.zones,
    required this.warningVisible,
    required this.onPressed,
  });

  final List<DeliveryZone> zones;
  final bool warningVisible;
  final ValueChanged<DeliveryZone> onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7FF).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB9E2F4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: warningVisible
                  ? const _ZoneShuffleWarning()
                  : const SizedBox.shrink(),
            ),
            if (warningVisible) const SizedBox(height: 10),
            GridView.builder(
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
          ],
        ),
      ),
    );
  }
}

class _ZoneShuffleWarning extends StatelessWidget {
  const _ZoneShuffleWarning();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0C2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE56B1F), width: 1.5),
      ),
      child: const SizedBox(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shuffle_rounded, color: Color(0xFFE56B1F), size: 20),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                '배송구역 재배치 예정',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF18212F),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
