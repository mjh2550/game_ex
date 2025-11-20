
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:game_ex/shared/game_info.dart';

class GameCard extends StatelessWidget {
  final GameInfo game;
  final VoidCallback onTap;

  const GameCard({
    required this.game,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: game.isUnlocked ? onTap : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 게임 썸네일
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (game.thumbnailUrl != null)
                  game.thumbnailUrl != null ? Image.asset(
                    game.thumbnailUrl!,
                    fit: BoxFit.cover,
                  ) : Container(color: Colors.grey, child: Text(game.name),),
                  if (!game.isUnlocked)
                    Container(
                      color: Colors.black54,
                      child: const Icon(
                        Icons.lock,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            
            // 게임 정보
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (game.bestScore != 0)
                      Text(
                        'Best: ${game.bestScore}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}