import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'character_selection_page.dart';
import 'home_page.dart';
import 'game/game_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.setLandscape();
  await Flame.device.fullScreen();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: const CharacterSelectionPage(), // Tela inicial
      //home: const GamePage(), // Tela inicial
      home: const HomePage(), // Tela inicial
      
      // Definição das rotas nomeadas do jogo
      routes: {
        '/home': (context) => const HomePage(),
        '/character_selection': (context) => const CharacterSelectionPage(),
        '/game': (context) => const GamePage(),
      },
    ),
  );
}

