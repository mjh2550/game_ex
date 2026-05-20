import 'dart:async';

import 'package:flutter/material.dart';

class ReadyStartOverlay extends StatefulWidget {
  const ReadyStartOverlay({super.key, required this.onCompleted});

  final VoidCallback onCompleted;

  @override
  State<ReadyStartOverlay> createState() => _ReadyStartOverlayState();
}

class _ReadyStartOverlayState extends State<ReadyStartOverlay>
    with SingleTickerProviderStateMixin {
  static const _steps = ['READY', '3', '2', '1', 'START'];

  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  Timer? _timer;
  int _stepIndex = 0;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.76, end: 1.08), weight: 58),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 42),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _playStep();
    _timer = Timer.periodic(const Duration(milliseconds: 760), (_) {
      if (_stepIndex >= _steps.length - 1) {
        _finish();
        return;
      }

      setState(() {
        _stepIndex++;
      });
      _playStep();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _playStep() {
    _controller.forward(from: 0);
  }

  void _finish() {
    if (_completed) {
      return;
    }

    _completed = true;
    _timer?.cancel();
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;
    final label = _steps[_stepIndex];
    final isStart = label == 'START';

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF07111F).withValues(alpha: 0.72),
          ),
          child: Center(
            child: FadeTransition(
              opacity: _opacity,
              child: ScaleTransition(
                scale: _scale,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isStart
                          ? const Color(0xFF2BB673)
                          : const Color(0xFFFFD166),
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x55000000),
                        blurRadius: 28,
                        offset: Offset(0, 16),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: compact ? 210 : 260,
                    height: compact ? 132 : 156,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isStart
                              ? Icons.play_arrow_rounded
                              : Icons.sports_esports_rounded,
                          color: isStart
                              ? const Color(0xFF2BB673)
                              : const Color(0xFFE56B1F),
                          size: compact ? 34 : 42,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          style: TextStyle(
                            color: const Color(0xFF18212F),
                            fontSize: compact
                                ? (label.length > 1 ? 36 : 54)
                                : (label.length > 1 ? 44 : 66),
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '곧 시작합니다',
                          style: TextStyle(
                            color: Color(0xFF60707F),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
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
      ),
    );
  }
}
