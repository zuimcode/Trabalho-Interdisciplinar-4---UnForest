import 'package:flutter/material.dart';

enum AudioCategory { music, sfx, dialogue }

// Função utilitária para chamar o Pop-up de Configurações de qualquer lugar
Future<void> showSettingsDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true, // Permite fechar ao tocar fora do modal
    barrierColor: Colors.black54, // Fundo escurecido semitransparente
    builder: (context) => const SettingsDialog(),
  );
}

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
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
    final screenSize = MediaQuery.of(context).size;
    final double activeVolume = _isMuted ? 0.0 : _currentSelectedVolume;

    return Dialog(
      backgroundColor: Colors.transparent, // Fundo transparente para usar o estilo da moldura
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        width: screenSize.width * 0.7, // Largura responsiva do Pop-up (70% da tela)
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 380),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E231B), // Cor escura base com tom de floresta
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF5A7232), width: 3), // Borda estilo madeira/natureza
          boxShadow: const [
            BoxShadow(
              //color: Colors.black80,
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // CONTEÚDO PRINCIPAL DO POP-UP
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    // Título / Tipo de Som
                    /*Image.asset(
                      'assets/images/buttons/botão_seleção_tipo_som.png',
                      height: 45,
                    ),
                    const SizedBox(height: 20),*/

                    // BOTÕES DE CATEGORIA DE ÁUDIO
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCategoryButton(
                          assetPath: 'assets/images/buttons/botão_seleção_música.png',
                          category: AudioCategory.music,
                        ),
                        const SizedBox(width: 12),
                        _buildCategoryButton(
                          assetPath: 'assets/images/buttons/botão_seleção_efeitos_sonoros.png',
                          category: AudioCategory.sfx,
                        ),
                        const SizedBox(width: 12),
                        _buildCategoryButton(
                          assetPath: 'assets/images/buttons/botão_seleção_diálogo.png',
                          category: AudioCategory.dialogue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // SLIDER DA FOLHA (APARECE SE UMA CATEGORIA FOR SELECIONADA)
                    if (_activeCategory != null) ...[
                      SizedBox(
                        width: 260,
                        height: 50,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final double sliderWidth = constraints.maxWidth;
                            const double leafSize = 40.0;
                            final double leafPosition = (sliderWidth - leafSize) * activeVolume;

                            return Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                Center(
                                  child: Image.asset(
                                    'assets/images/buttons/botão_volume.png',
                                    width: sliderWidth,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Positioned(
                                  left: leafPosition,
                                  child: Image.asset(
                                    'assets/images/buttons/botão_volume_folha.png',
                                    width: leafSize,
                                    height: leafSize,
                                  ),
                                ),
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
                      const SizedBox(height: 15),
                    ],

                    // BOTÃO DE MUTE / DESMUTE GLOBAL
                    GestureDetector(
                      onTap: _toggleMute,
                      child: Image.asset(
                        _isMuted
                            ? 'assets/images/buttons/botão_seleção_volume_mutado.png'
                            : 'assets/images/buttons/botão_seleção_volume_desmutado.png',
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // BOTÃO 'X' NO CANTO SUPERIOR ESQUERDO DO POP-UP
            Positioned(
              top: 0,
              left: 0,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Image.asset(
                  'assets/images/buttons/botão_saida_x.png',
                  height: 45,
                ),
              ),
            ),
          ],
        ),
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
                borderRadius: BorderRadius.circular(10),
              )
            : null,
        child: Image.asset(
          assetPath,
          height: 50,
        ),
      ),
    );
  }
}