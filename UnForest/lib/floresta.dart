import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class FlorestaPage extends StatefulWidget {
  const FlorestaPage({super.key});

  @override
  State<FlorestaPage> createState() => _FlorestaPageState();
}

class _FlorestaPageState extends State<FlorestaPage> {
  // Controller do Audio Player para os sons de erro e sucesso
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Estados do jogo
  bool _showInstructions = true; // Exibe o overlay de instruções inicial
  bool _taskCompleted = false;    // Marca se a task foi concluída
  bool _showVictory = false;      // Exibe o overlay de vitória ao final

  // Etapa atual do plantio:
  // 0: buraco_terra (inicial)
  // 1: terra_com_semente
  // 2: terra_coberta
  // 3: terra_molhada
  // 4: terra_com_muda
  // 5: arvore_task (árvore adulta)
  int _plantStage = 0;

  // Lista dos caminhos das imagens da evolução da planta no buraco
  final List<String> _plantImages = [
    '../assets/images/task-floresta/buraco_terra_task_floresta.png',
    '../assets/images/task-floresta/terra_com_semente_task_floresta.png',
    '../assets/images/task-floresta/terra_coberta_task_floresta.png',
    '../assets/images/task-floresta/terra_molhada_task_floresta.png',
    '../assets/images/task-floresta/terra_com_muda_task_floresta.png',
    '../assets/images/task-floresta/arvore_task_floresta.png',
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Toca o som de erro
  Future<void> _playErrorSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/erro.mp3')); // Adicione seu som de erro em assets/audio/erro.mp3
    } catch (_) {}
  }

  // Toca o som de tarefa concluída
  Future<void> _playSuccessSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/sucesso.mp3')); // Adicione seu som de sucesso em assets/audio/sucesso.mp3
    } catch (_) {}
  }

  // Função para validar o item arrastado até o buraco
  void _onItemDropped(String itemType) {
    // Ordem correta esperada:
    // Estágio 0 espera: semente
    // Estágio 1 espera: terra
    // Estágio 2 espera: regador
    // Estágio 3 espera: muda
    bool isCorrect = false;

    if (_plantStage == 0 && itemType == 'semente') isCorrect = true;
    if (_plantStage == 1 && itemType == 'terra') isCorrect = true;
    if (_plantStage == 2 && itemType == 'regador') isCorrect = true;
    if (_plantStage == 3 && itemType == 'muda') isCorrect = true;

    if (isCorrect) {
      setState(() {
        _plantStage++;
      });

      // Se atingiu a última etapa do processo manual (estágio 4: muda inserida)
      if (_plantStage == 4) {
        _finishPlantingSequence();
      }
    } else {
      // Caso errar a sequência
      _playErrorSound();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sequência incorreta! Tente novamente.'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Sequência final de crescimento e conclusão da task
  void _finishPlantingSequence() {
    // Aguarda 3 segundos após a muda ser colocada para crescer para a árvore grande
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _plantStage = 5; // Imagem da árvore adulta
        _taskCompleted = true; // Alterna o fundo para a floresta bonita
      });

      // Toca som de vitória
      _playSuccessSound();

      // Exibe a tela/overlay de vitória com a mensagem "você conseguiu"
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        setState(() {
          _showVictory = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ==========================================
          // 1. IMAGEM DE FUNDO (FLORESTA FEIA OU BONITA)
          // ==========================================
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(seconds: 2), // Transição suave entre feia e bonita
              child: Image.asset(
                _taskCompleted
                    ? '../assets/images/task-floresta/floresta_bonita.JPG'
                    : '../assets/images/task-floresta/floresta_feia.JPG',
                key: ValueKey<bool>(_taskCompleted),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // Layer de brilhos/partículas visuais ao concluir a task
          if (_taskCompleted)
            Positioned.fill(
              child: Container(
                color: Colors.amber.withOpacity(0.15), // Efeito de brilho de iluminação
              ),
            ),

          // Escurece o fundo enquanto as instruções estão ativas
          if (_showInstructions)
            Container(
              color: Colors.black.withOpacity(0.6),
            ),

          // ==========================================
          // 2. CONTEÚDO DA TASK (BURACO E ITENS)
          // ==========================================
          if (!_showInstructions && !_showVictory)
            SafeArea(
              child: Stack(
                children: [
                  // --- BURACO / PLANTA NO MEIO DA TELA ---
                  Align(
                    alignment: const Alignment(0.0, 0.4), // Ajuste de posição no meio um pouco para baixo
                    child: DragTarget<String>(
                      onWillAcceptWithDetails: (details) => true,
                      onAcceptWithDetails: (details) {
                        _onItemDropped(details.data);
                      },
                      builder: (context, candidateData, rejectedData) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: Image.asset(
                            _plantImages[_plantStage],
                            key: ValueKey<int>(_plantStage),
                            height: _plantStage == 5 ? 200 : 120, // Aumenta de tamanho quando vira árvore
                          ),
                        );
                      },
                    ),
                  ),

                  // --- ITENS NAS LATERAIS PARA ARRASTAR ---
                  // Lado Esquerdo: Regador e Semente
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDraggableItem('semente', '../assets/images/task-floresta/semente_task_floresta.png'),
                          const SizedBox(height: 24),
                          _buildDraggableItem('regador', '../assets/images/task-floresta/regador_task_floresta.png'),
                        ],
                      ),
                    ),
                  ),

                  // Lado Direito: Terra e Muda
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDraggableItem('terra', '../assets/images/task-floresta/terra_task_floresta.png'),
                          const SizedBox(height: 24),
                          _buildDraggableItem('muda', '../assets/images/task-floresta/muda_task_floresta.png'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ==========================================
          // 3. INÍCIO DO TRECHO DO CÓDIGO: TELA DE INSTRUÇÕES
          // ==========================================
          if (_showInstructions)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Imagem das instruções
                  Image.asset(
                    '../assets/images/task-floresta/instrucoes-floresta.png',
                    height: 220,
                  ),
                  const SizedBox(height: 20),
                  // Botão check para iniciar a task
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showInstructions = false; // Fecha as instruções e inicia a task
                      });
                    },
                    child: Image.asset(
                      '../assets/images/buttons/botao_check.png',
                      height: 70,
                    ),
                  ),
                ],
              ),
            ),
          // ==========================================
          // FIM DO TRECHO DO CÓDIGO: TELA DE INSTRUÇÕES
          // ==========================================

          // ==========================================
          // 4. OVERLAY DE VITÓRIA / TELA FINAL
          // ==========================================
          if (_showVictory)
            Container(
              color: Colors.black38,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Imagem "Você conseguiu"
                    Image.asset(
                      '../assets/images/task-floresta/instrucoes-floresta.png', // Substitua pelo caminho da imagem "você conseguiu" se houver uma específica
                      height: 180,
                    ),
                    const SizedBox(height: 20),
                    // Botão de Voltar (X)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(); // Voltar para a tela anterior
                      },
                      child: Image.asset(
                        '../assets/images/buttons/botao_saida.png',
                        height: 75,
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

  // Widget auxiliar para criar os itens arrastáveis
  Widget _buildDraggableItem(String itemType, String imagePath) {
    return Draggable<String>(
      data: itemType,
      feedback: Material(
        color: Colors.transparent,
        child: Image.asset(
          imagePath,
          height: 80,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Image.asset(
          imagePath,
          height: 70,
        ),
      ),
      child: Image.asset(
        imagePath,
        height: 70,
      ),
    );
  }
}