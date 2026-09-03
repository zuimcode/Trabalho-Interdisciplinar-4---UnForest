import 'package:bonfire/bonfire.dart';

class Heroi extends SimplePlayer with BlockMovementCollision {
  Heroi({required super.position})
      : super(
          size: Vector2(80, 80),
          speed: 120,
          animation: SimpleDirectionAnimation(
            enabledFlipX: true,
            idleRight: SpriteAnimation.load(
              'characters/teco_idle.png',
              SpriteAnimationData.sequenced(
                amount: 8,
                stepTime: 0.15,
                textureSize: Vector2(128, 128),
                texturePosition: Vector2(0, 0),
              ),
            ),
            runRight: SpriteAnimation.load(
              'characters/teco_run.png',
              SpriteAnimationData.sequenced(
                amount: 8,
                stepTime: 0.15,
                textureSize: Vector2(128, 128),
                texturePosition: Vector2(0, 0),
              ),
            ),
          ),
        );

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2(30, 50),
        position: Vector2(26, 15),
        isSolid: true,             
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if(hasGameRef && gameRef.map.size != Vector2.zero()) {
      position.x = position.x.clamp(0, gameRef.map.size.x - size.x);
      position.y = position.y.clamp(0, gameRef.map.size.y - size.y);
    } 
  }
}