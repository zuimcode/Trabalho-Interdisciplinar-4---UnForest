import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'character_selection_page.dart';
import 'home_page.dart';
import 'biomas.dart';
import 'game/game_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.setLandscape();
  await Flame.device.fullScreen();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(), // Tela inicial do jogo
      
      // Definição das rotas nomeadas
      routes: {
        '/home': (context) => const HomePage(),
        '/character_selection': (context) => const CharacterSelectionPage(),
        '/biomas': (context) => const BiomasPage(),
        //'/game': (context) => const GamePage(),
      },
    ),
  );
}