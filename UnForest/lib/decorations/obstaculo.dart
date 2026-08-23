import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';


class Obstaculo extends GameDecorationWithCollision {
  final Color cor;
  // ver pq a colisao nao ta funcionando, talvez seja pq o tamanho do obstaculo e da hitbox sao diferentes
  Obstaculo({
    required Vector2 position,
    required Vector2 size,
    this.cor = Colors.grey,
  }) : super(
          position: position,
          size: size,
        ) {
    add(RectangleHitbox(size: size));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = cor,
    );
  }
}