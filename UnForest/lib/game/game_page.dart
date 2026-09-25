import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:UnForest/player/hero.dart';
import 'package:UnForest/portal_decoration.dart';

class GamePage extends StatelessWidget {
  final String selectedCharacter;
  final String mapName;

  GamePage({
    Key? key,
    this.selectedCharacter = 'teco',
    this.mapName = 'mapa_neve.json',
  }) : super(key: key ?? ValueKey(mapName));

  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      key: ValueKey(mapName), // Força a recriação do widget ao trocar de mapa
      showCollisionArea: false,
      map: WorldMapByTiled(
        WorldMapReader.fromAsset(mapName),
        objectsBuilder: {
          'portal': (TiledObjectProperties properties) {
            // Trata aspas ou espaços acidentais vindos do Tiled
            String? destination = properties.others['targetMap']
                ?.toString()
                .replaceAll('"', '')
                .replaceAll("'", "")
                .trim();

            return PortalDecoration(
              position: properties.position,
              size: properties.size,
              targetMap: destination,
              selectedCharacter: selectedCharacter,
            );
          },
        },
      ),
      playerControllers: [
        Joystick(directional: JoystickDirectional()),
        Keyboard(),
      ],
      player: Heroi.fromName(
        position: Vector2(32 * 5, 32 * 5),
        nomePersonagem: selectedCharacter,
      ),
      cameraConfig: CameraConfig(
        moveOnlyMapArea: true,
        zoom: 1.5,
      ),
    );
  }
}