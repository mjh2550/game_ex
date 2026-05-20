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
