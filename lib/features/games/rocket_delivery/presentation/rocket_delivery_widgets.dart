part of 'rocket_delivery_screen.dart';

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
  });

  final int score;
  final int time;
  final int totalTime;
  final int lives;
  final int combo;
  final int difficulty;
  final bool zoneShuffleEnabled;
  final double scoreMultiplier;

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
            const SizedBox(height: 8),
            _RocketOptionStatus(
              enabled: zoneShuffleEnabled,
              scoreMultiplier: scoreMultiplier,
            ),
          ],
        ),
      ),
    );
  }
}

class _RocketOptionStatus extends StatelessWidget {
  const _RocketOptionStatus({
    required this.enabled,
    required this.scoreMultiplier,
  });

  final bool enabled;
  final double scoreMultiplier;

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
            Icon(
              enabled ? Icons.shuffle_rounded : Icons.shuffle_on_rounded,
              color: enabled
                  ? const Color(0xFFFFD166)
                  : const Color(0xFF8A98A8),
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                enabled
                    ? '구역 재배치 ON · x${scoreMultiplier.toStringAsFixed(1)}'
                    : '구역 재배치 OFF · x1.0',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: enabled
                      ? const Color(0xFFFFD166)
                      : const Color(0xFFD4DEE8),
                  fontSize: 12,
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

class _RocketSetupOverlay extends StatelessWidget {
  const _RocketSetupOverlay({
    required this.zoneShuffleEnabled,
    required this.scoreMultiplier,
    required this.onZoneShuffleChanged,
    required this.onStart,
  });

  final bool zoneShuffleEnabled;
  final double scoreMultiplier;
  final ValueChanged<bool> onZoneShuffleChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0xFF18212F).withValues(alpha: 0.38),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE1E7EF)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x44000000),
                      blurRadius: 26,
                      offset: Offset(0, 16),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.local_shipping_rounded,
                        color: Color(0xFF18212F),
                        size: 58,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '배송 준비',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF18212F),
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '시작 전에 난이도 옵션을 정하세요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF60707F),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _RocketSetupOptionCard(
                        enabled: zoneShuffleEnabled,
                        scoreMultiplier: scoreMultiplier,
                        onChanged: onZoneShuffleChanged,
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: onStart,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('시작 준비'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2BB673),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RocketSetupOptionCard extends StatelessWidget {
  const _RocketSetupOptionCard({
    required this.enabled,
    required this.scoreMultiplier,
    required this.onChanged,
  });

  final bool enabled;
  final double scoreMultiplier;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: enabled ? const Color(0xFF54C6EB) : const Color(0xFFE1E7EF),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: enabled
                    ? const Color(0xFFFFD166)
                    : const Color(0xFFCAD4E1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.shuffle_rounded,
                  color: Color(0xFF18212F),
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '구역 재배치',
                    style: TextStyle(
                      color: Color(0xFF18212F),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    enabled
                        ? '난이도 상승 시 구역이 바뀌고 점수 x${scoreMultiplier.toStringAsFixed(1)}'
                        : '구역이 고정되고 기본 점수로 진행',
                    style: const TextStyle(
                      color: Color(0xFF60707F),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: enabled,
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
    required this.paused,
    required this.feedback,
  });

  final List<MovingPackage> packages;
  final DeliveryPackage currentPackage;
  final double speed;
  final double spawnGap;
  final bool paused;
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
                if (paused)
                  const _ConveyorPauseBadge()
                else
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
                      if (paused)
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF18212F,
                              ).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(child: _ConveyorPausePill()),
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

class _ConveyorPauseBadge extends StatelessWidget {
  const _ConveyorPauseBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF54C6EB)),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pause_rounded, color: Color(0xFF18212F), size: 16),
            SizedBox(width: 4),
            Text(
              '정지',
              style: TextStyle(
                color: Color(0xFF18212F),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConveyorPausePill extends StatelessWidget {
  const _ConveyorPausePill();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF18212F).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pause_rounded, color: Color(0xFFFFD166), size: 17),
            SizedBox(width: 6),
            Text(
              '컨베이어 일시정지',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
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
    required this.inputEnabled,
    required this.onPressed,
  });

  final List<DeliveryZone> zones;
  final bool warningVisible;
  final bool inputEnabled;
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: inputEnabled
                  ? const SizedBox.shrink()
                  : const _ZoneInputLockedNotice(),
            ),
            if (!inputEnabled) const SizedBox(height: 10),
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
                final hint = '${index + 1}';

                return FilledButton(
                  onPressed: inputEnabled ? () => onPressed(zone) : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFD4DEE8),
                    disabledForegroundColor: const Color(0xFF60707F),
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

class _ZoneInputLockedNotice extends StatelessWidget {
  const _ZoneInputLockedNotice();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF18212F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFD166)),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pause_rounded, color: Color(0xFFFFD166), size: 18),
            SizedBox(width: 7),
            Flexible(
              child: Text(
                '컨베이어 정지 중 · 분류 버튼 잠김',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
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

class _ZoneShuffleTopOverlay extends StatelessWidget {
  const _ZoneShuffleTopOverlay({
    required this.warningVisible,
    required this.completeVisible,
  });

  final bool warningVisible;
  final bool completeVisible;

  @override
  Widget build(BuildContext context) {
    final visible = warningVisible || completeVisible;
    final isComplete = completeVisible && !warningVisible;

    return IgnorePointer(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        reverseDuration: const Duration(milliseconds: 120),
        child: visible
            ? Align(
                alignment: Alignment.topCenter,
                key: ValueKey(isComplete ? 'shuffle-complete' : 'shuffle-warn'),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                  child: _ZoneShuffleOverlayCard(isComplete: isComplete),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _ZoneShuffleOverlayCard extends StatelessWidget {
  const _ZoneShuffleOverlayCard({required this.isComplete});

  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    final accent = isComplete
        ? const Color(0xFF2BB673)
        : const Color(0xFFE56B1F);
    final title = isComplete ? '재배치 완료!' : '잠깐!';
    final message = isComplete ? '배송구역 위치가 바뀌었어요' : '2초 뒤 배송구역이 바뀝니다';
    final icon = isComplete
        ? Icons.check_circle_rounded
        : Icons.shuffle_rounded;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF18212F).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SizedBox(
                      width: 46,
                      height: 46,
                      child: Icon(icon, color: accent, size: 30),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFD4DEE8),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!isComplete) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    key: const ValueKey('shuffle-countdown-bar'),
                    tween: Tween(begin: 1, end: 0),
                    duration: const Duration(seconds: 2),
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        minHeight: 8,
                        value: value,
                        backgroundColor: const Color(0xFF3B4657),
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
