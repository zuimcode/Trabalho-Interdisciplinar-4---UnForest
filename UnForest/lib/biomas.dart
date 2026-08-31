import 'package:flutter/material.dart';
import 'floresta.dart'; // Import da página de floresta
import 'cidade.dart';

class BiomasPage extends StatelessWidget {
  const BiomasPage({super.key});

  void _navigateToBioma(BuildContext context, String biomaName) {
    if (biomaName == 'Floresta') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const FlorestaPage(),
        ),
      );
    } else {
      // Exibe mensagem informativa para biomas que ainda não foram criados
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('O bioma $biomaName estará disponível em breve!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> biomas = [
      'Deserto',
      'Gelo',
      'Floresta',
      'Cidade',
      'Praia',
    ];

    return Scaffold(
      backgroundColor: Colors.green.shade900,
      body: SafeArea(
        child: Stack(
          children: [
            // Botão de voltar (X) no canto superior esquerdo
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 36),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // Título e Lista de Botões dos Biomas
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'SELEÇÃO DE BIOMAS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Linha com os 5 botões de biomas
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: biomas.map((bioma) {
                      // Verifica se o bioma está ativo/disponível
                      final bool isDisponivel = bioma == 'Floresta' || bioma == 'Cidade';

                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDisponivel ? Colors.green.shade600 : Colors.black45,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isDisponivel ? Colors.lightGreenAccent : Colors.white30,
                              width: 2,
                            ),
                          ),
                        ),
                        onPressed: () => _navigateToBioma(context, bioma),
                        child: Text(
                          bioma.toUpperCase(),
                          style: TextStyle(
                            color: isDisponivel ? Colors.white : Colors.white70,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}