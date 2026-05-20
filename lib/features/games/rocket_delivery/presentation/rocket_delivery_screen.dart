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

part 'rocket_delivery_widgets.dart';

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
  bool _isSetupVisible = true;
  bool _isReadyOverlayVisible = true;
  bool _isSaving = false;
  bool _zoneShuffleEnabled = true;
  bool _isZoneShuffleWarningVisible = false;
  bool _isZoneShuffleCompleteVisible = false;
  bool _isConveyorPaused = false;
  int _lastShuffleDifficulty = 1;
  SortFeedback? _feedback;
  Timer? _feedbackTimer;
  Timer? _zoneShuffleOverlayTimer;

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
    _zoneShuffleOverlayTimer?.cancel();
    _feedbackTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _startGame() {
    if (_isSetupVisible || !_isReadyOverlayVisible) {
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
    if (_isSaving || _isSetupVisible || _isReadyOverlayVisible) {
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
      if (_isSaving || _isSetupVisible || _isReadyOverlayVisible) {
        return;
      }

      if (!_isConveyorPaused) {
        setState(() {
          for (final package in _packages) {
            package.progress += _packageSpeed;
          }

          if (_packages.isEmpty || _packages.last.progress >= _spawnGap) {
            _spawnPackage();
          }
        });
      }

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
    if (!_isSetupVisible) {
      return;
    }

    setState(() {
      _zoneShuffleEnabled = enabled;
      if (!enabled) {
        _zoneShuffleTimer?.cancel();
        _zoneShuffleOverlayTimer?.cancel();
        _isZoneShuffleWarningVisible = false;
        _isZoneShuffleCompleteVisible = false;
        _isConveyorPaused = false;
      }
    });
  }

  void _confirmSetup() {
    setState(() {
      _isSetupVisible = false;
      _isReadyOverlayVisible = true;
    });
  }

  void _scheduleZoneShuffle() {
    _lastShuffleDifficulty = _difficulty;
    _zoneShuffleTimer?.cancel();
    _zoneShuffleOverlayTimer?.cancel();
    _isZoneShuffleWarningVisible = true;
    _isZoneShuffleCompleteVisible = false;
    _isConveyorPaused = false;
    _zoneShuffleTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted || _isSaving) {
        return;
      }

      setState(() {
        _activeZones.shuffle(_random);
        _isZoneShuffleWarningVisible = false;
        _isZoneShuffleCompleteVisible = true;
        _isConveyorPaused = true;
        _setFeedback(
          SortFeedback.notice(
            '배송구역 재배치 완료',
            Color(0xFFE56B1F),
            Icons.shuffle_rounded,
          ),
        );
      });
      _zoneShuffleOverlayTimer = Timer(const Duration(milliseconds: 1200), () {
        if (!mounted) {
          return;
        }

        setState(() {
          _isZoneShuffleCompleteVisible = false;
          _isConveyorPaused = false;
        });
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
    if (_isSaving || _isSetupVisible || _isReadyOverlayVisible) {
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
      LogicalKeyboardKey.digit1 || LogicalKeyboardKey.numpad1 => 0,
      LogicalKeyboardKey.digit2 || LogicalKeyboardKey.numpad2 => 1,
      LogicalKeyboardKey.digit3 || LogicalKeyboardKey.numpad3 => 2,
      LogicalKeyboardKey.digit4 || LogicalKeyboardKey.numpad4 => 3,
      LogicalKeyboardKey.digit5 => 4,
      LogicalKeyboardKey.numpad5 => 4,
      LogicalKeyboardKey.digit6 || LogicalKeyboardKey.numpad6 => 5,
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
    _zoneShuffleOverlayTimer?.cancel();
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
                            ),
                            const SizedBox(height: 14),
                            _ConveyorPanel(
                              packages: _packages,
                              currentPackage: _currentPackage.package,
                              speed: _packageSpeed,
                              spawnGap: _spawnGap,
                              paused: _isConveyorPaused,
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
              if (_isReadyOverlayVisible && !_isSetupVisible)
                ReadyStartOverlay(onCompleted: _startGame),
              if (_isSetupVisible)
                _RocketSetupOverlay(
                  zoneShuffleEnabled: _zoneShuffleEnabled,
                  scoreMultiplier: _scoreMultiplier,
                  onZoneShuffleChanged: _setZoneShuffleEnabled,
                  onStart: _confirmSetup,
                ),
              if (!_isReadyOverlayVisible)
                _ZoneShuffleTopOverlay(
                  warningVisible: _isZoneShuffleWarningVisible,
                  completeVisible: _isZoneShuffleCompleteVisible,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
