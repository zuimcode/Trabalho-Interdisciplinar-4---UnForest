import 'package:bonfire/bonfire.dart';

class Heroi extends SimplePlayer {
  Heroi({required super.position})
      : super(
          size: Vector2(64, 64),
          speed: 250,
          animation: SimpleDirectionAnimation(
            enabledFlipX: true,
            idleRight: SpriteAnimation.load(
              'characters/player.png',
              SpriteAnimationData.sequenced(
                amount: 2,
                stepTime: 0.15,
                textureSize: Vector2(32, 32),
                texturePosition: Vector2(0, 0),
              ),
            ),
            runRight: SpriteAnimation.load(
              'characters/player.png',
              SpriteAnimationData.sequenced(
                amount: 8,
                stepTime: 0.15,
                textureSize: Vector2(32, 32),
                texturePosition: Vector2(0, 96),
              ),
            ),
          ),
        );

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2(20, 16),
        position: Vector2(6, 16),
      ),
    );
    return super.onLoad();
  }
}