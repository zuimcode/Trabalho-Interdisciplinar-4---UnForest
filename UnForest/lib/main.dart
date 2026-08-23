import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'player/hero.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.setLandscape();
  await Flame.device.fullScreen();

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GamePage(),
    ),
  );
}

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      showCollisionArea: true, //problema de sobreposicao(?)

      map: WorldMapByTiled(
        WorldMapReader.fromAsset('maps/mapa.json'),
        forceTileSize: Vector2(16, 16),
        
      ),

      playerControllers: [
        Joystick(directional: JoystickDirectional()),
        Keyboard(),
      ],
      player: Heroi(
        position: Vector2(96, 96), 
      ),
      cameraConfig: CameraConfig(
        zoom: 1.0, 
      ),
    );
  }
}