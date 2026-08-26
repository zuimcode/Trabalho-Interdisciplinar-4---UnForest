import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CharacterSelectionPage extends StatefulWidget {
  const CharacterSelectionPage({super.key});

  @override
  State<CharacterSelectionPage> createState() => _CharacterSelectionPageState();
}

class _CharacterSelectionPageState extends State<CharacterSelectionPage> {
  late VideoPlayerController _videoController;
  String? _selectedCharacter;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/videos/videofundo.mp4')
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. VÍDEO DE FUNDO EM LOOP
          Positioned.fill(
            child: _videoController.value.isInitialized
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController.value.size.width,
                        height: _videoController.value.size.height,
                        child: VideoPlayer(_videoController),
                      ),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
          ),

          // 2. BOTÕES DE SELEÇÃO AUMENTADOS (GAIA E TECO)
          SafeArea(
            child: Row(
              children: [
                // BOTÃO ESQUERDA (GAIA)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCharacter = 'gaia';
                          });
                        },
                        child: Image.asset(
                          _selectedCharacter == 'gaia'
                              ? 'assets/images/buttons/botão_selecionado_gaia.png'
                              : 'assets/images/buttons/botão_selecionar_mão.png',
                          height: 120, 
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // BOTÃO DIREITA (TECO)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCharacter = 'teco';
                          });
                        },
                        child: Image.asset(
                          _selectedCharacter == 'teco'
                              ? 'assets/images/buttons/botão_selecionado_teco.png'
                              : 'assets/images/buttons/botão_selecionar_mão.png',
                          height: 120, 
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. BOTÃO 'X' AUMENTADO (CANTO SUPERIOR ESQUERDO)
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Image.asset(
                    'assets/images/buttons/botão_saida_x.png',
                    height: 120, 
                  ),
                ),
              ),
            ),
          ),

          // 4. BOTÃO CONFIGURAÇÃO AUMENTADO (CANTO SUPERIOR DIREITO)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () {
                    // Ação de configurações
                  },
                  child: Image.asset(
                    'assets/images/buttons/botão_configuração_engrenagem_.png',
                    height: 120, 
                  ),
                ),
              ),
            ),
          ),

          // 5. BOTÃO CHECK AUMENTADO (CANTO INFERIOR DIREITO)
          if (_selectedCharacter != null)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () {
                      // Ação de confirmação
                    },
                    child: Image.asset(
                      'assets/images/buttons/botão_check.png',
                      height: 120, 
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}