import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:UnForest/player/hero.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      showCollisionArea: true,
      map: WorldMapByTiled(
        WorldMapReader.fromAsset('teste_mapa.json'),
      ),
      playerControllers: [
        Joystick(directional: JoystickDirectional()),
        Keyboard(),
      ],
      player: Heroi(
        position: Vector2(32 * 5, 32 * 5),
      ),
      cameraConfig: CameraConfig(
        moveOnlyMapArea: true,
        zoom: 1.0,
      ),
    );
  }
}