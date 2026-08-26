import 'package:flutter/material.dart';

class CharacterSelectionPage extends StatefulWidget {
  const CharacterSelectionPage({super.key});

  @override
  State<CharacterSelectionPage> createState() => _CharacterSelectionPageState();
}

class _CharacterSelectionPageState extends State<CharacterSelectionPage> {
  // Guarda o personagem selecionado: null = nenhum, 'gaia' = esquerda, 'teco' = direita
  String? _selectedCharacter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. FUNDO VERDE TEMPORÁRIO
          Container(
            color: Colors.green.shade800,
          ),

          // 2. CONTEÚDO CENTRAL (PERSONAGENS E BOTÕES DE SELEÇÃO)
          SafeArea(
            child: Row(
              children: [
                // PERSONAGEM DA ESQUERDA (GAIA)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Expanded(
                        child: Center(
                          child: Image(
                            image: AssetImage('assets/images/characters/jogador1.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      
                      // Botão / Indicador de Seleção da Gaia
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
                          height: 60,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // PERSONAGEM DA DIREITA (TECO)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Expanded(
                        child: Center(
                          child: Image(
                            image: AssetImage('assets/images/characters/jogador2.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // Botão / Indicador de Seleção do Teco
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
                          height: 60,
                        ),
                      ),
                      const SizedBox(height: 20),
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
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Image.asset(
                    'assets/images/buttons/botão_saida_x.png',
                    height: 45,
                  ),
                ),
              ),
            ),
          ),

          // 4. BOTÃO CONFIGURAÇÃO (CANTO SUPERIOR DIREITO)
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
                    height: 45,
                  ),
                ),
              ),
            ),
          ),

          // 5. BOTÃO CHECK (CANTO INFERIOR DIREITO) - Aparece só quando algum personagem for selecionado
          if (_selectedCharacter != null)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () {
                      // Ação ao confirmar a seleção e ir para a próxima página
                    },
                    child: Image.asset(
                      'assets/images/buttons/botão_check.png',
                      height: 55,
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