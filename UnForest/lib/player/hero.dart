import 'package:bonfire/bonfire.dart';
import '/character_selection_page.dart';

// Enum para deixar a seleção explícita
enum TipoPersonagem { teco, gaia }

class Heroi extends SimplePlayer with BlockMovementCollision {
  Heroi({
    required super.position,
    TipoPersonagem personagem = TipoPersonagem.teco, // Valor padrão
  }) : super(
          size: Vector2(80, 80),
          speed: 120,
          // O "if" entra aqui no super via ternário:
          animation: personagem == TipoPersonagem.teco
              ? _animacoesTeco
              : _animacoesGaia,
        );

  // --- Animações do Teco ---
  static SimpleDirectionAnimation get _animacoesTeco => SimpleDirectionAnimation(
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
      );

  // --- Animações da Gaia ---
  static SimpleDirectionAnimation get _animacoesGaia => SimpleDirectionAnimation(
        enabledFlipX: true,
        idleRight: SpriteAnimation.load(
          'characters/gaia_idle.png',
          SpriteAnimationData.sequenced(
            amount: 8,
            stepTime: 0.15,
            textureSize: Vector2(128, 128),
            texturePosition: Vector2(0, 0),
          ),
        ),
        runRight: SpriteAnimation.load(
          'characters/gaia_run.png',
          SpriteAnimationData.sequenced(
            amount: 8,
            stepTime: 0.15,
            textureSize: Vector2(128, 128),
            texturePosition: Vector2(0, 0),
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

    if (hasGameRef && gameRef.map.size != Vector2.zero()) {
      position.x = position.x.clamp(0, gameRef.map.size.x - size.x);
      position.y = position.y.clamp(0, gameRef.map.size.y - size.y);
    }
  }
}