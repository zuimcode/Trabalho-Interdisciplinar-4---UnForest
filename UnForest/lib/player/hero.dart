import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

class Heroi extends SimplePlayer {
  Heroi({required Vector2 position})
      : super(
          position: position,
          size: Vector2(32, 32),
          speed: 250,
        ) {
    // mexer nesse trem, ta dando bo
    add(RectangleHitbox(
      size: Vector2(8, 6),
      position: Vector2(4, 16), 
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