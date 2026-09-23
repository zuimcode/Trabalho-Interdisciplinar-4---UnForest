import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:UnForest/player/hero.dart';

class GamePage extends StatelessWidget {
  final String selectedCharacter;

  const GamePage({super.key, this.selectedCharacter = 'teco'});

  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      showCollisionArea: false,
      map: WorldMapByTiled(WorldMapReader.fromAsset('mapa_neve_feia.json')),
      playerControllers: [
        Joystick(directional: JoystickDirectional()),
        Keyboard(),
      ],

      player: Heroi.fromName(
        position: Vector2(32 * 5, 32 * 5),
        nomePersonagem: selectedCharacter,
      ),

      cameraConfig: CameraConfig(moveOnlyMapArea: true, zoom: 1.5),
    );
  }
}
