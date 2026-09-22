import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Painel de fundo. Ele ja traz a moldura de pedra e o titulo CREDITOS
/// desenhados, entao a tela nao repete o titulo nem desenha borda.
const String _fundoDoPainel = 'assets/images/buttons/tela_creditos.png';

/// Proporcao do PNG (1665x1267), seguida pelo painel para nao esticar a arte.
const double _proporcaoDoPainel = 1665 / 1267;

const double _larguraMaximaDoPainel = 650.0;

/// Fracao do painel ocupada pela moldura. O topo desconta tambem a placa do
/// titulo, que faz parte da imagem.
const double _margemLateral = 0.19;
const double _margemSuperior = 0.24;
const double _margemInferior = 0.17;

/// O miolo do painel e pedra escura, entao o texto vai em tom claro.
const Color _corDoTexto = Color(0xFFE9DFC6);

Future<void> showCreditosDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => const CreditsDialog(),
  );
}

class CreditsDialog extends StatelessWidget {
  const CreditsDialog({super.key});

  @override
  Widget build(BuildContext context) {
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
                // PAINEL DE FUNDO
                Image.asset(_fundoDoPainel, fit: BoxFit.fill),

                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: painel.maxWidth * _margemLateral,
                      right: painel.maxWidth * _margemLateral,
                      top: painel.maxHeight * _margemSuperior,
                      bottom: painel.maxHeight * _margemInferior,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            children: [
                              _creditRow(
                                name: 'Ane Madjarian - UI/UX',
                                imagePath: 'assets/images/criadores/ane.png',
                                imageOnLeft: true,
                              ),
                              const SizedBox(height: 14),
                              _creditRow(
                                name: 'Bruno Bicalho - Inteligência Artificial',
                                imagePath: 'assets/images/criadores/bruno.png',
                                imageOnLeft: false,
                              ),
                              const SizedBox(height: 14),
                              _creditRow(
                                name: 'Camila Menezes - Banco de Dados',
                                imagePath: 'assets/images/criadores/camila.png',
                                imageOnLeft: true,
                              ),
                              const SizedBox(height: 14),
                              _creditRow(
                                name:
                                    'Guilherme Zuim - Desenvolvimento Backend',
                                imagePath: 'assets/images/criadores/zuim.png',
                                imageOnLeft: false,
                              ),
                              const SizedBox(height: 14),
                              _creditRow(
                                name: 'Isabel Borges - Product Owner',
                                imagePath: 'assets/images/criadores/isabel.png',
                                imageOnLeft: true,
                              ),
                              const SizedBox(height: 14),
                              _creditRow(
                                name:
                                    'Lucas Rodrigues - Desenvolvimento Backend',
                                imagePath:
                                    'assets/images/criadores/lucasjose.png',
                                imageOnLeft: false,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: painel.maxHeight * 0.05,
                  left: painel.maxWidth * 0.05,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Image.asset(
                      'assets/images/buttons/botão_saida_x.png',
                      height: painel.maxHeight * 0.12,
                      fit: BoxFit.contain,
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

  Widget _creditRow({
    required String name,
    required String imagePath,
    required bool imageOnLeft,
  }) {
    final nameText = Text(
      name,
      textAlign: TextAlign.center,
      style: GoogleFonts.tinos(fontSize: 15, height: 1.6, color: _corDoTexto),
    );

    final image = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(imagePath, width: 58, height: 58, fit: BoxFit.cover),
    );

    // O nome vai dentro de um Flexible para quebrar em duas linhas quando a
    // linha inteira nao couber na largura util do painel.
    final nome = Flexible(child: nameText);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: imageOnLeft
          ? [image, const SizedBox(width: 12), nome]
          : [nome, const SizedBox(width: 12), image],
    );
  }
}
