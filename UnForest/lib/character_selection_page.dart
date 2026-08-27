import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'settings_page.dart';
import 'game/game_page.dart';

class CharacterSelectionPage extends StatefulWidget {
  const CharacterSelectionPage({super.key});

  @override
  State<CharacterSelectionPage> createState() => _CharacterSelectionPageState();
}

class _CharacterSelectionPageState extends State<CharacterSelectionPage> {
  late VideoPlayerController _videoController;
  String? _selectedCharacter; // Guarda o personagem selecionado no momento

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/videos/videofundo.mp4')
      ..initialize().then((_) {
        if (mounted) setState(() {});
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

  // Executado SOMENTE quando o usuário clica no botão de CHECK
  Future<void> _confirmSelectionAndNavigate() async {
    if (_selectedCharacter == null) return;

    // 1. Salva a variável no local storage apenas neste momento
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('is_character', _selectedCharacter!); //string gaia ou teco

    if (!mounted) return;

    // 2. Transiciona para a GamePage
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const GamePage(),
      ),
    );
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

          // 2. BOTÕES DE SELEÇÃO (GAIA E TECO)
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
                          // Apenas troca o estado local (permite alternar)
                          setState(() {
                            _selectedCharacter = 'gaia';
                          });
                        },
                        child: Image.asset(
                          _selectedCharacter == 'gaia'
                              ? 'assets/images/buttons/botão_selecionado_gaia.png'
                              : 'assets/images/buttons/botão_selecionar_mão.png',
                          height: 100,
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
                          // Apenas troca o estado local (permite alternar)
                          setState(() {
                            _selectedCharacter = 'teco';
                          });
                        },
                        child: Image.asset(
                          _selectedCharacter == 'teco'
                              ? 'assets/images/buttons/botão_selecionado_teco.png'
                              : 'assets/images/buttons/botão_selecionar_mão.png',
                          height: 100,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. BOTÃO 'X' (CANTO SUPERIOR ESQUERDO)
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Image.asset(
                    'assets/images/buttons/botão_saida_x.png',
                    height: 100,
                  ),
                ),
              ),
            ),
          ),

          // 4. BOTÃO CONFIGURAÇÃO (ABRE O POP-UP)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () => showSettingsDialog(context),
                  child: Image.asset(
                    'assets/images/buttons/botão_configuração_engrenagem_.png',
                    height: 100,
                  ),
                ),
              ),
            ),
          ),

          // 5. BOTÃO CHECK (SÓ APARECE SE UM PERSONAGEM FOR SELECIONADO)
          if (_selectedCharacter != null)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: _confirmSelectionAndNavigate,
                    child: Image.asset(
                      'assets/images/buttons/botão_check.png',
                      height: 50,
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