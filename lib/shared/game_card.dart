import 'package:flutter/material.dart';
import 'package:game_ex/shared/game_info.dart';

class GameCard extends StatelessWidget {
  final GameInfo game;
  final VoidCallback onTap;
  final int bestScore;

  const GameCard({
    super.key,
    required this.game,
    required this.onTap,
    this.bestScore = 0,
  });

  @override
  Widget build(BuildContext context) {
    final locked = !game.isUnlocked;
    final isKiosk = game.id == 'g002';
    final isRocket = game.id == 'g003';

    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: locked ? null : onTap,
        child: Ink(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE1E7EF)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ColoredBox(
                  color: locked
                      ? const Color(0xFFE9EDF3)
                      : const Color(0xFFEAF7FF),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (game.thumbnailUrl != null)
                        Image.asset(
                          game.thumbnailUrl!,
                          width: 82,
                          height: 82,
                          filterQuality: FilterQuality.none,
                        )
                      else if (isKiosk || isRocket)
                        Icon(
                          isRocket
                              ? Icons.local_shipping_rounded
                              : Icons.touch_app_rounded,
                          size: 70,
                          color: const Color(0xFF18212F),
                        )
                      else
                        const Icon(
                          Icons.videogame_asset_outlined,
                          size: 62,
                          color: Color(0xFF60707F),
                        ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: _StatusBadge(locked: locked),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF18212F),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      game.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.28,
                        color: Color(0xFF60707F),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          isKiosk
                              ? Icons.touch_app_rounded
                              : isRocket
                              ? Icons.keyboard_double_arrow_right_rounded
                              : Icons.keyboard_arrow_left_rounded,
                          size: 18,
                          color: const Color(0xFF2BB673),
                        ),
                        if (!isKiosk)
                          const Icon(
                            Icons.keyboard_arrow_right_rounded,
                            size: 18,
                            color: Color(0xFF2BB673),
                          ),
                        const SizedBox(width: 4),
                        Text(
                          isKiosk ? '터치' : '방향키/터치',
                          style: TextStyle(
                            color: const Color(0xFF2BB673),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        if (bestScore != 0)
                          Text(
                            'Best $bestScore',
                            style: const TextStyle(
                              color: Color(0xFFE56B1F),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.locked});

  final bool locked;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: locked ? const Color(0xFF60707F) : const Color(0xFF2BB673),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              locked ? Icons.lock_outline : Icons.check_circle_outline,
              size: 13,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              locked ? '잠김' : '오픈',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
