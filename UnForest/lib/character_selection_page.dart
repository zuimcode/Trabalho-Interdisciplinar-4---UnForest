import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'main.dart'; // Import da GamePage

class CharacterSelectionPage extends StatefulWidget {
  const CharacterSelectionPage({super.key});

  @override
  State<CharacterSelectionPage> createState() => _CharacterSelectionPageState();
}

class _CharacterSelectionPageState extends State<CharacterSelectionPage> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    // Configure o caminho do seu vídeo aqui
    _videoController = VideoPlayerController.asset('assets/videos/fundo.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.setLooping(true);
        _videoController.setVolume(0.0);
        _videoController.play();
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void _selectCharacter(String characterType) {
    // Abre a GamePage substituindo a tela atual na pilha de navegação
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const GamePage(),
        // Se precisar passar o personagem escolhido: GamePage(selectedCharacter: characterType)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Fundo em Vídeo
          Positioned.fill(
            child: _videoController.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Sombra para dar destaque aos botões e personagens
          Container(color: Colors.black38),

          // 2. Dois Personagens + Botões de Seleção
          SafeArea(
            child: Row(
              children: [
                // Personagem 1 (Esquerda)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Expanded(
                        child: Center(
                          child: Icon(Icons.shield, size: 100, color: Colors.blueAccent),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _selectCharacter('hero_1'),
                        child: const Text('SELECIONAR'),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Divisória central
                const VerticalDivider(color: Colors.white24, width: 1),

                // Personagem 2 (Direita)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Expanded(
                        child: Center(
                          child: Icon(Icons.bolt, size: 100, color: Colors.amber),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _selectCharacter('hero_2'),
                        child: const Text('SELECIONAR'),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Botão "X" no canto superior esquerdo
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () {
                  // Ação ao clicar no 'X' (Exemplo: Voltar ao Menu Principal)
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}