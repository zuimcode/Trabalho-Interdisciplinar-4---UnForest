import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

enum AudioCategory { music, sfx, dialogue }

class _SettingsPageState extends State<SettingsPage> {
  AudioCategory? _activeCategory;
  bool _isMuted = false;

  double _musicVolume = 0.8;
  double _sfxVolume = 1.0;
  double _dialogueVolume = 0.9;

  double get _currentSelectedVolume {
    switch (_activeCategory) {
      case AudioCategory.music:
        return _musicVolume;
      case AudioCategory.sfx:
        return _sfxVolume;
      case AudioCategory.dialogue:
        return _dialogueVolume;
      case null:
        return 0.0;
    }
  }

  void _updateVolume(double newValue) {
    setState(() {
      switch (_activeCategory) {
        case AudioCategory.music:
          _musicVolume = newValue;
          break;
        case AudioCategory.sfx:
          _sfxVolume = newValue;
          break;
        case AudioCategory.dialogue:
          _dialogueVolume = newValue;
          break;
        case null:
          break;
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double activeVolume = _isMuted ? 0.0 : _currentSelectedVolume;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. CONTEÚDO CENTRAL
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Título / Tipo de Som
                    Image.asset(
                      'assets/images/buttons/botão_seleção_tipo_som.png',
                      height: 55,
                    ),
                    const SizedBox(height: 30),

                    // BOTÕES DE CATEGORIA DE ÁUDIO
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCategoryButton(
                          assetPath: 'assets/images/buttons/botão_seleção_música.png',
                          category: AudioCategory.music,
                        ),
                        const SizedBox(width: 15),
                        _buildCategoryButton(
                          assetPath: 'assets/images/buttons/botão_seleção_efeitos_sonoros.png',
                          category: AudioCategory.sfx,
                        ),
                        const SizedBox(width: 15),
                        _buildCategoryButton(
                          assetPath: 'assets/images/buttons/botão_seleção_diálogo.png',
                          category: AudioCategory.dialogue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // SLIDER DA FOLHA (APARECE SE UMA CATEGORIA FOR SELECIONADA)
                    if (_activeCategory != null) ...[
                      SizedBox(
                        width: 280,
                        height: 60,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final double sliderWidth = constraints.maxWidth;
                            const double leafSize = 45.0;
                            // Calcula a posição X da folha no slider
                            final double leafPosition = (sliderWidth - leafSize) * activeVolume;

                            return Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                // Barra de Volume (Fundo)
                                Center(
                                  child: Image.asset(
                                    'assets/images/buttons/botão_volume.png',
                                    width: sliderWidth,
                                    fit: BoxFit.contain,
                                  ),
                                ),

                                // Ícone da Folha em cima da barra
                                Positioned(
                                  left: leafPosition,
                                  child: Image.asset(
                                    'assets/images/buttons/botão_volume_folha.png',
                                    width: leafSize,
                                    height: leafSize,
                                  ),
                                ),

                                // Slider transparente por cima para capturar os gestos
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackShape: const RectangularSliderTrackShape(),
                                    activeTrackColor: Colors.transparent,
                                    inactiveTrackColor: Colors.transparent,
                                    thumbColor: Colors.transparent,
                                    overlayColor: Colors.transparent,
                                  ),
                                  child: Slider(
                                    value: activeVolume,
                                    min: 0.0,
                                    max: 1.0,
                                    onChanged: _isMuted ? null : _updateVolume,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // BOTÃO DE MUTE / DESMUTE GLOBAL
                    GestureDetector(
                      onTap: _toggleMute,
                      child: Image.asset(
                        _isMuted
                            ? 'assets/images/buttons/botão_seleção_volume_mutado.png'
                            : 'assets/images/buttons/botão_seleção_volume_desmutado.png',
                        height: 60,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. BOTÃO 'X' PARA VOLTAR (CANTO SUPERIOR ESQUERDO)
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Image.asset(
                    'assets/images/buttons/botão_saida_x.png',
                    height: 60,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton({
    required String assetPath,
    required AudioCategory category,
  }) {
    final bool isSelected = _activeCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeCategory = isSelected ? null : category;
        });
      },
      child: Container(
        decoration: isSelected
            ? BoxDecoration(
                border: Border.all(color: Colors.amber, width: 3),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Image.asset(
          assetPath,
          height: 65,
        ),
      ),
    );
  }
}