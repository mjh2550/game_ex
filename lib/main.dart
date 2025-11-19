import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

// void main() {
//   runApp(
//     GameWidget(
//       game: FlameGame(world: MyWorld()),
//     ),
//   );
// }

void main() {
  runApp(
    GameWidget(
      game: MyGame(),
      backgroundBuilder: (context) => Container(
        color: const Color(0xFF87CEEB),
      ),
      overlayBuilderMap: {
        'PauseMenu': (context, game) {
          return Container(
            color: const Color(0xFF000000),
            child: Text('A pause menu'),
          );
        },
      },
    ),
  );
}

class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    overlays.add('PauseMenu');
    add(MyWorld());
  }
}

class MyWorld extends World {
  @override
  Future<void> onLoad() async {
    add(Player(position: Vector2(0, 0)));
  }
}



class Player extends SpriteComponent with TapCallbacks {
  Player({super.position}) :
    super(size: Vector2.all(200), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('player.png');
  }
  
  @override
  void onTapUp(TapUpEvent info) {
    size += Vector2.all(50);
  }

  @override
  void onTapDown(TapDownEvent event) {
    // TODO: implement onLongTapDown
    size -= Vector2.all(50);
  }
}