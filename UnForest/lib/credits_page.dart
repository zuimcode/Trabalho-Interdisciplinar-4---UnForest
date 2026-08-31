import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final screenSize = MediaQuery.sizeOf(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 650,
          maxHeight: screenSize.height * 0.8,
        ),
        child: Container(
          width: screenSize.width * 0.9,
          decoration: BoxDecoration(
            color: const Color(0xFFD9C5A0),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF4A3525), width: 5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 18,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(42, 70, 42, 32),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CRÉDITOS',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.tinos(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: const Color(0xFF3E2A1D),
                          ),
                        ),
                        const SizedBox(height: 28),
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
                              name: 'Guilherme Zuim - Desenvolvimento Backend',
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
                              name: 'Lucas Rodrigues - Desenvolvimento Backend',
                              imagePath: 'assets/images/criadores/lucasjose.png',
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
                top: 18,
                left: 18,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Image.asset(
                    'assets/images/buttons/botão_saida_x.png',
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
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
      style: GoogleFonts.tinos(
        fontSize: 15,
        height: 1.6,
        color: const Color(0xFF3E2A1D),
      ),
    );

    final image = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        imagePath,
        width: 58,
        height: 58,
        fit: BoxFit.cover,
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: imageOnLeft
          ? [image, const SizedBox(width: 12), nameText]
          : [nameText, const SizedBox(width: 12), image],
    );
  }
}