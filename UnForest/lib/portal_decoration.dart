import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'portal_sprite_sheet.dart';
import 'game/game_page.dart'; // Import da sua GamePage

class PortalDecoration extends GameDecoration with Sensor {
  final String? targetMap;
  final String selectedCharacter;
  bool _hasTriggered = false;

  PortalDecoration({
    required super.position,
    required super.size,
    this.targetMap,
    this.selectedCharacter = 'teco',
  });

  @override
  Future<void> onLoad() async {
    setAnimation(await PortalSpriteSheet.portalActiveAnimation);

    add(
      RectangleHitbox(
        size: Vector2(size.x * 0.3, size.y * 0.25),
        position: Vector2(size.x * 0.35, size.y * 0.6),
      ),
    );

    return super.onLoad();
  }

  @override
  void onContact(GameComponent component) {
    if (component is Player && !_hasTriggered) {
      _hasTriggered = true;
      _goToNextMap();
    }
  }

  void _goToNextMap() {
    if (targetMap == null || targetMap!.isEmpty) return;

    // Transição/Navegação para a próxima fase carregando o novo mapa
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GamePage(
          mapName: targetMap!,
          selectedCharacter: selectedCharacter,
        ),
      ),
    );
  }

  @override
  void onContactExit(GameComponent component) {}
}