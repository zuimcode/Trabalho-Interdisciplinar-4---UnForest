import 'package:flutter/material.dart';

enum AudioCategory { music, sfx, dialogue }

// Função utilitária para chamar o Pop-up de Configurações
Future<void> showSettingsDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
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
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        width: screenSize.width * 0.7,
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 380),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E231B),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF5A7232), width: 3),
          boxShadow: const [
            BoxShadow(
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
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