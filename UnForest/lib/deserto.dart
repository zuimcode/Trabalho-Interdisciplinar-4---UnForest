import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class DesertoPage extends StatefulWidget {
  const DesertoPage({super.key});

  @override
  State<DesertoPage> createState() => _DesertoPageState();
}

class _DesertoPageState extends State<DesertoPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _showInstructions = true;
  bool _taskCompleted = false;
  bool _showVictory = false;

  int _camelStage = 0;

  final List<String> _camelImages = [
    '../assets/images/task-deserto/camelo_com_sede.png',
    '../assets/images/task-deserto/camelo_feliz.png',
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playErrorSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/erro.mp3'));
    } catch (_) {}
  }

  Future<void> _playSuccessSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/sucesso.mp3'));
    } catch (_) {}
  }

  void _onCamelDropped(String itemType) {
    if (_camelStage == 0 && itemType == 'agua') {
      setState(() {
        _camelStage = 1;
      });
      _finishQuestSequence();
    } else {
      _playErrorSound();
      String nomeItem = itemType.toUpperCase();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ops! O camelo não quer $nomeItem, ele precisa de água!'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _onObstacleDropped(String itemType, String obstacleName) {
    _playErrorSound();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cuidado! Você perdeu a $itemType no(a) $obstacleName!'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.orange.shade800,
      ),
    );
  }

  void _finishQuestSequence() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _taskCompleted = true;
      });

      _playSuccessSound();

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        setState(() {
          _showVictory = true;
        });
      });
    });
  }

  Widget _buildImageWithFallback({
    required String path,
    required double height,
    required Color fallbackColor,
    required String fallbackText,
    BoxFit fit = BoxFit.contain,
    double? width,
  }) {
    return Image.asset(
      path,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          width: width ?? height,
          color: fallbackColor,
          alignment: Alignment.center,
          child: Text(
            fallbackText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. FUNDO
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(seconds: 2),
              child: _buildImageWithFallback(
                path: _taskCompleted
                    ? '../assets/images/task-deserto/deserto_feliz.JPG'
                    : '../assets/images/task-deserto/deserto_seco.JPG',
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
                fallbackColor: _taskCompleted ? Colors.green.shade200 : Colors.orange.shade200,
                fallbackText: _taskCompleted ? 'Fundo: Deserto Feliz' : 'Fundo: Deserto Seco',
              ),
            ),
          ),

          if (_taskCompleted)
            Positioned.fill(
              child: Container(
                color: Colors.lightBlueAccent.withOpacity(0.15),
              ),
            ),

          if (_showInstructions)
            Container(
              color: Colors.black.withOpacity(0.6),
            ),

          // 2. CONTEÚDO DO JOGO
          if (!_showInstructions && !_showVictory)
            SafeArea(
              child: Stack(
                children: [
                  // --- OBSTÁCULO 1 (CACTO GIGANTE) ---
                  Align(
                    alignment: const Alignment(-0.1, -0.2), 
                    child: _buildObstacle(
                      obstacleName: 'CACTO GIGANTE',
                      imagePath: '../assets/images/task-deserto/cacto_gigante.png',
                      fallbackColor: Colors.green.shade800,
                    ),
                  ),

                  // --- OBSTÁCULO 2 (AREIA MOVEDIÇA) ---
                  Align(
                    alignment: const Alignment(0.0, 0.7), 
                    child: _buildObstacle(
                      obstacleName: 'AREIA MOVEDIÇA',
                      imagePath: '../assets/images/task-deserto/areia_movedica.png',
                      fallbackColor: Colors.brown.shade700,
                    ),
                  ),

                  // --- CAMELO (ALVO) NO TOPO DIREITO ---
                  Align(
                    alignment: const Alignment(0.8, -0.4), 
                    child: DragTarget<String>(
                      onWillAcceptWithDetails: (details) => true,
                      onAcceptWithDetails: (details) {
                        _onCamelDropped(details.data);
                      },
                      builder: (context, candidateData, rejectedData) {
                        bool isHovering = candidateData.isNotEmpty;
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _buildImageWithFallback(
                            path: _camelImages[_camelStage],
                            height: isHovering ? 270 : 250, 
                            fallbackColor: Colors.brown.shade400,
                            fallbackText: _camelStage == 0 ? 'CAMELO\n(Com Sede)' : 'CAMELO\n(Feliz!)',
                          ),
                        );
                      },
                    ),
                  ),

                  // --- ÁGUA (ITEM PRINCIPAL) 
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 32.0, bottom: 32.0),
                      child: _buildDraggableItem('agua', '../assets/images/task-deserto/agua_oasis.png', Colors.blue, 'ÁGUA'),
                    ),
                  ),

                  //  OUTRO ITEM (DISTRAÇÃO) 
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 32.0, top: 32.0),
                      child: _buildDraggableItem('pedra', '../assets/images/task-deserto/pedra.png', Colors.grey, 'PEDRA'),
                    ),
                  ),
                ],
              ),
            ),

          // 3. TELA DE INSTRUÇÕES
          if (_showInstructions)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildImageWithFallback(
                    path: '../assets/images/task-deserto/instrucoes-deserto.png',
                    height: 220,
                    width: 300,
                    fallbackColor: Colors.white38,
                    fallbackText: 'INSTRUÇÕES:\n"Desvie dos obstáculos e leve a água ao camelo!"',
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showInstructions = false;
                      });
                    },
                    child: _buildImageWithFallback(
                      path: '../assets/images/buttons/botao_check.png',
                      height: 70,
                      width: 140,
                      fallbackColor: Colors.green,
                      fallbackText: 'JOGAR',
                    ),
                  ),
                ],
              ),
            ),

          // 4. OVERLAY DE VITÓRIA
          if (_showVictory)
            Container(
              color: Colors.black38,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildImageWithFallback(
                      path: '../assets/images/task-deserto/vitoria-deserto.png',
                      height: 180,
                      width: 300,
                      fallbackColor: Colors.white38,
                      fallbackText: 'VITÓRIA!',
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: _buildImageWithFallback(
                        path: '../assets/images/buttons/botao_saida.png',
                        height: 75,
                        width: 75,
                        fallbackColor: Colors.redAccent,
                        fallbackText: 'SAIR',
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // WIDGET DO OBSTÁCULO (ARMADILHA)
  Widget _buildObstacle({required String obstacleName, required String imagePath, required Color fallbackColor}) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        // Se soltar QUALQUER item aqui, perde o item
        _onObstacleDropped(details.data, obstacleName);
      },
      builder: (context, candidateData, rejectedData) {
        // Se o usuário passar o dedo com a água por cima do obstáculo, ele "reage" (fica maior) para dar a sensação de perigo
        bool isHovering = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          // Dá um pequeno pulo se estiver em perigo
          transform: isHovering ? (Matrix4.identity()..scale(1.1)) : Matrix4.identity(),
          child: _buildImageWithFallback(
            path: imagePath,
            height: 120, // Tamanho base do obstáculo
            fallbackColor: isHovering ? Colors.redAccent : fallbackColor, // Muda pra vermelho quando passa por cima!
            fallbackText: obstacleName,
          ),
        );
      },
    );
  }

  Widget _buildDraggableItem(String itemType, String imagePath, Color fallbackColor, String fallbackText) {
    return Draggable<String>(
      data: itemType,
      feedback: Material(
        color: Colors.transparent,
        child: _buildImageWithFallback(
          path: imagePath,
          height: 100,
          fallbackColor: fallbackColor.withOpacity(0.8),
          fallbackText: fallbackText,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildImageWithFallback(
          path: imagePath,
          height: 90,
          fallbackColor: fallbackColor,
          fallbackText: fallbackText,
        ),
      ),
      child: _buildImageWithFallback(
        path: imagePath,
        height: 90,
        fallbackColor: fallbackColor,
        fallbackText: fallbackText,
      ),
    );
  }
}