import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'character_selection_page.dart';
import 'settings_page.dart'; // Import da tela de configurações
import 'player/hero.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.setLandscape();
  await Flame.device.fullScreen();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CharacterSelectionPage(), // Tela inicial
      
      // Definição das rotas nomeadas
      routes: {
        '/settings': (context) => const SettingsPage(),
        '/character_selection': (context) => const CharacterSelectionPage(),
        '/game': (context) => const GamePage(),
      },
    ),
  );
}

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      showCollisionArea: true,
      map: WorldMapByTiled(
        WorldMapReader.fromAsset('maps/mapa.json'),
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