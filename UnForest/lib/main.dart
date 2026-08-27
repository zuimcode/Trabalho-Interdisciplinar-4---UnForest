import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'character_selection_page.dart';
import 'player/hero.dart';
import 'game/game_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.setLandscape();
  await Flame.device.fullScreen();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CharacterSelectionPage(), // Tela inicial
      //home: const GamePage(), // Tela inicial
      
      // Definição das rotas nomeadas do jogo
      routes: {
        '/character_selection': (context) => const CharacterSelectionPage(),
        //'/game': (context) => const GamePage(),
      },
    ),
  );
}

