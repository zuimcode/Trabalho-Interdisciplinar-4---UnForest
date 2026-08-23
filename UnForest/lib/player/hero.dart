import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

class Heroi extends SimplePlayer {
  Heroi({required Vector2 position})
      : super(
          position: position,
          size: Vector2(32, 32),
          speed: 250,
          animation : SimpleDirectionAnimation(
            enabledFlipX: true,
            idleRight: SpriteAnimation.load(
              'player/idle.png',
              SpriteAnimationData.sequenced(
                amount: 4,
                stepTime: 0.15,
                textureSize: Vector2(32, 32),
                texturePosition: Vector2(0, 0),
              ),
            ),
            runRight: SpriteAnimation.load(
              'player/run.png',
              SpriteAnimationData.sequenced(
                amount: 6,
                stepTime: 0.15,
                textureSize: Vector2(32, 32),
                texturePosition: Vector2(0, 32),
              ),
            ),
          )
        ) {
    // mexer nesse trem, ta dando bo
    add(RectangleHitbox(
      size: Vector2(20, 16),
      position: Vector2(6, 16), 
    ));
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = Colors.blueAccent,
    );
    super.render(canvas);
  }
}