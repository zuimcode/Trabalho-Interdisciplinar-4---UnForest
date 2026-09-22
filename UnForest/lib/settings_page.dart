import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AudioCategory { music, sfx, dialogue }

/// Pergaminho usado como fundo do pop-up. Ele ja traz a propria moldura de
/// pedra e os rolos de madeira, entao o painel nao desenha mais borda nem
/// sombra por baixo.
const String _fundoDoPainel = 'assets/images/buttons/balao_fala_pergaminho.png';

/// Proporcao do PNG (2001x1048). O painel segue essa proporcao para o
/// pergaminho nao esticar.
const double _proporcaoDoPainel = 2001 / 1048;

const double _larguraMaximaDoPainel = 760.0;

/// Fracao do painel ocupada pela moldura, medida sobre o proprio PNG: os rolos
/// de madeira nas laterais e as barras de pedra em cima e embaixo. O conteudo
/// so pode ocupar o pergaminho que sobra no meio.
const double _margemHorizontalDoPainel = 0.14;
const double _margemVerticalDoPainel = 0.28;

/// Posicao e tamanho do X de fechar, em fracao do painel. Fica apoiado no
/// canto da moldura de pedra, fora da area escrita do pergaminho.
const double _xEsquerda = 0.085;
const double _xTopo = 0.10;
const double _xAltura = 0.15;

// Função utilitária para chamar o Pop-up de Configurações
Future<void> showSettingsDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    //barrierColor: Colors.black70,
    builder: (context) => const SettingsDialog(),
  );
}

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  // Define 'music' como ativa inicialmente
  AudioCategory? _activeCategory = AudioCategory.music;
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

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _larguraMaximaDoPainel),
        child: AspectRatio(
          aspectRatio: _proporcaoDoPainel,
          child: LayoutBuilder(
            builder: (context, painel) => Stack(
              fit: StackFit.expand,
              children: [
                // PERGAMINHO DE FUNDO
                Image.asset(_fundoDoPainel, fit: BoxFit.fill),

                // CONTEÚDO PRINCIPAL, encaixado dentro da moldura.
                // O FittedBox reduz tudo junto quando a tela e pequena, em vez
                // de deixar o conteudo transbordar por cima da moldura.
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: painel.maxWidth * _margemHorizontalDoPainel,
                    vertical: painel.maxHeight * _margemVerticalDoPainel,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),

                        // TÍTULO MAPA ANTIGO (SEM CORES VIVAS)
                        _buildAncientMapTitle('CONFIGURAÇÕES'),

                        const SizedBox(height: 28),

                        // CATEGORIAS DE ÁUDIO (SELEÇÃO APENAS MUDANDO O TAMANHO)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCategoryButton(
                              assetPath:
                                  'assets/images/buttons/botão_seleção_música.png',
                              category: AudioCategory.music,
                            ),
                            const SizedBox(width: 20),
                            _buildCategoryButton(
                              assetPath:
                                  'assets/images/buttons/botão_seleção_efeitos_sonoros.png',
                              category: AudioCategory.sfx,
                            ),
                            const SizedBox(width: 20),
                            _buildCategoryButton(
                              assetPath:
                                  'assets/images/buttons/botão_seleção_diálogo.png',
                              category: AudioCategory.dialogue,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // SLIDER PERSONALIZADO DE VOLUME
                        if (_activeCategory != null) ...[
                          SizedBox(
                            width: 260,
                            height: 50,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final double sliderWidth = constraints.maxWidth;
                                const double leafSize = 40.0;
                                final double leafPosition =
                                    (sliderWidth - leafSize) * activeVolume;

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
                                      child: AnimatedOpacity(
                                        duration: const Duration(
                                          milliseconds: 150,
                                        ),
                                        opacity: _isMuted ? 0.4 : 1.0,
                                        child: Image.asset(
                                          'assets/images/buttons/botão_volume_folha.png',
                                          width: leafSize,
                                          height: leafSize,
                                        ),
                                      ),
                                    ),
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackShape:
                                            const RectangularSliderTrackShape(),
                                        activeTrackColor: Colors.transparent,
                                        inactiveTrackColor: Colors.transparent,
                                        thumbColor: Colors.transparent,
                                        overlayColor: Colors.transparent,
                                      ),
                                      child: Slider(
                                        value: activeVolume,
                                        min: 0.0,
                                        max: 1.0,
                                        onChanged: _isMuted
                                            ? null
                                            : _updateVolume,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // BOTÃO DE MUTE/DESMUTE
                        GestureDetector(
                          onTap: _toggleMute,
                          child: AnimatedScale(
                            scale: _isMuted ? 0.9 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            child: Image.asset(
                              _isMuted
                                  ? 'assets/images/buttons/botão_seleção_volume_mutado.png'
                                  : 'assets/images/buttons/botão_seleção_volume_desmutado.png',
                              height: 48,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // BOTÃO DE FECHAR 'X', apoiado sobre a moldura de pedra
                Positioned(
                  top: painel.maxHeight * _xTopo,
                  left: painel.maxWidth * _xEsquerda,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Image.asset(
                      'assets/images/buttons/botão_saida_x.png',
                      height: painel.maxHeight * _xAltura,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Título com estilo rústico de pergaminho/mapa antigo (Cinzel/Tinos)
  Widget _buildAncientMapTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: GoogleFonts.cinzel(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 3.0,
        color: const Color(0xFF2C1D11), // Castanho escuro estilo tinta antiga
        shadows: const [
          Shadow(offset: Offset(0, 1), blurRadius: 1, color: Color(0x40000000)),
        ],
      ),
    );
  }

  // Botão limpo: selecionado fica maior (scale 1.25) e não selecionado fica menor (scale 0.85)
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
      child: AnimatedScale(
        scale: isSelected ? 1.25 : 0.85,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isSelected ? 1.0 : 0.6,
          child: Image.asset(assetPath, height: 52),
        ),
      ),
    );
  }
}
