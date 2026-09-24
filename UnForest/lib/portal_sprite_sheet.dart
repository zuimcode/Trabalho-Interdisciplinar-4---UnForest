import 'package:bonfire/bonfire.dart';

class PortalSpriteSheet {
  static Future<SpriteAnimation> get portalActiveAnimation async {
    return SpriteAnimation.load(
      'tiled/ERW-Ancient Ruins/Props/animated/portal-all animations-grass land2.0.png',
      SpriteAnimationData.sequenced(
        amount: 30, // Quantidade total de quadros válidos
        amountPerRow: 8, // 8 colunas de quadros por linha
        stepTime: 0.1, // Duração de exibição de cada frame (em segundos)
        textureSize: Vector2(290, 192), // Resolução exata de cada frame na Sprite Sheet
      ),
    );
  }
}