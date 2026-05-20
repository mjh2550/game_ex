part of 'kiosk_panic_screen.dart';

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
        color: Colors.white.withValues(alpha: 0.93),
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

  CustomerReaction get _reaction => customerReactionForPatience(patience);
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
        color: Colors.white.withValues(alpha: 0.93),
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
                  emojiForKioskChoice(expected),
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
      avatar: Text(emojiForKioskChoice(text)),
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
        color: const Color(0xFFEAF7FF).withValues(alpha: 0.92),
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
          Text(
            emojiForKioskChoice(choice),
            style: const TextStyle(fontSize: 20),
          ),
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
