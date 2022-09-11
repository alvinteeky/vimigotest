import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame_texturepacker/flame_texturepacker.dart';

class MyGame extends FlameGame {
  late SpriteAnimationComponent coin;
  Sprite? player;
  @override
  Future<void> onLoad() async {
    super.onLoad();
    final sprites = await fromJSONAtlas('animation.png', 'anim.json');
    SpriteAnimation walk = SpriteAnimation.spriteList(sprites, stepTime: 0.1);

    coin = SpriteAnimationComponent()
    ..animation = walk
    ..size = Vector2(100, 100);
    add(coin);
  }
}