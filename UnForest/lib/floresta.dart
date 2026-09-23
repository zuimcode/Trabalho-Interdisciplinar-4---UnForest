import 'package:flutter/material.dart';

class ItemLixo {
  final String id;
  final String assetPath;
  final double topRatio; // Proporção da altura da tela (0.0 a 1.0)
  final double leftRatio; // Proporção da largura da tela (0.0 a 1.0)
  final double sizeRatio; // Proporção do tamanho em relação à largura

  ItemLixo({
    required this.id,
    required this.assetPath,
    required this.topRatio,
    required this.leftRatio,
    this.sizeRatio = 0.15, // 15% da largura da tela por padrão
  });
}

class LixoTaskPage extends StatefulWidget {
  const LixoTaskPage({Key? key}) : super(key: key);

  @override
  State<LixoTaskPage> createState() => _LixoTaskPageState();
}

class _LixoTaskPageState extends State<LixoTaskPage> {
  late List<ItemLixo> _lixosRestantes;

  bool _gameIniciado = false; 
  bool _taskConcluida = false; 
  bool _lixeiraHighlight = false; // Para dar efeito visual na lixeira

  @override
  void initState() {
    super.initState();
    _resetTask();
  }

  void _resetTask() {
    setState(() {
      _gameIniciado = false;
      _taskConcluida = false;
      _lixeiraHighlight = false;
      // Definindo posições com base em percentuais (proporções) da tela
      _lixosRestantes = [
        ItemLixo(id: 'lixo_1', assetPath: 'assets/images/task_praia/garrafa.png', topRatio: 0.20, leftRatio: 0.70, sizeRatio: 0.15),
        ItemLixo(id: 'lixo_2', assetPath: 'assets/images/task_praia/lata.png', topRatio: 0.25, leftRatio: 0.85, sizeRatio: 0.15),
        ItemLixo(id: 'lixo_3', assetPath: 'assets/images/task_praia/peixe.png', topRatio: 0.18, leftRatio: 0.50, sizeRatio: 0.15),
        ItemLixo(id: 'lixo_4', assetPath: 'assets/images/task_praia/sacola.png', topRatio: 0.22, leftRatio: 0.30, sizeRatio: 0.15),
        ItemLixo(id: 'lixo_5', assetPath: 'assets/images/task_praia/maca.png', topRatio: 0.20, leftRatio: 0.10, sizeRatio: 0.15),
      ];
    });
  }

  void _onLixoColetado(ItemLixo lixo) {
    setState(() {
      _lixosRestantes.removeWhere((item) => item.id == lixo.id);

      if (_lixosRestantes.isEmpty) {
        _finalizarTask();
      }
    });
  }

  void _finalizarTask() {
    setState(() {
      _taskConcluida = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtendo as dimensões da tela atual via MediaQuery
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Fundo Dinâmico com Transição Suave (AnimatedCrossFade)
          Positioned.fill(
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 1200),
              crossFadeState: _taskConcluida
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Image.asset(
                'assets/images/task_praia/praia_feia3.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              secondChild: Image.asset(
                'assets/images/task_praia/praia_bonita.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // 2. Elementos do Jogo
          if (_gameIniciado && !_taskConcluida) ...[
            // Contador / Indicador Topo Proporcional
            Positioned(
              top: screenHeight * 0.05,
              left: screenWidth * 0.05,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.01,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Lixos restantes: ${_lixosRestantes.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.045, // Tamanho de fonte responsivo
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // A Lixeira (DragTarget) proporcional
            Positioned(
              bottom: screenHeight * 0.04,
              right: screenWidth * 0.07,
              child: DragTarget<ItemLixo>(
                onWillAcceptWithDetails: (details) {
                  setState(() => _lixeiraHighlight = true);
                  return true;
                },
                onLeave: (_) {
                  setState(() => _lixeiraHighlight = false);
                },
                onAcceptWithDetails: (details) {
                  setState(() => _lixeiraHighlight = false);
                  _onLixoColetado(details.data);
                },
                builder: (context, candidateData, rejectedData) {
                  return AnimatedScale(
                    scale: _lixeiraHighlight ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: Image.asset(
                      _lixeiraHighlight
                          ? 'assets/images/task_praia/lixeira_aberta.png'
                          : 'assets/images/task_praia/lixeira_fechada.png',
                      width: screenWidth * 0.35, // Proporcional à largura da tela
                      height: screenHeight * 0.35, // Proporcional à altura da tela
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),

            // Lixos Espalhados na Tela (Draggables) proporcionais
            ..._lixosRestantes.map((lixo) {
              final double calculatedSize = screenWidth * lixo.sizeRatio;
              return Positioned(
                top: screenHeight * lixo.topRatio,
                left: screenWidth * lixo.leftRatio,
                child: Draggable<ItemLixo>(
                  data: lixo,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Image.asset(
                      lixo.assetPath,
                      width: calculatedSize * 1.2,
                      height: calculatedSize * 1.2,
                      fit: BoxFit.contain,
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: Image.asset(
                      lixo.assetPath,
                      width: calculatedSize,
                      height: calculatedSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                  child: Image.asset(
                    lixo.assetPath,
                    width: calculatedSize,
                    height: calculatedSize,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            }).toList(),
          ],

          // 3. Overlay Inicial (Instruções do Jogo) Responsivo
          if (!_gameIniciado) _buildIntroOverlay(screenWidth, screenHeight),

          // 4. Overlay de Vitória (Final do Jogo) Responsivo
          if (_taskConcluida) _buildVictoryOverlay(screenWidth, screenHeight),
        ],
      ),
    );
  }

  // Widget da Tela de Instruções
  Widget _buildIntroOverlay(double screenWidth, double screenHeight) {
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/task_praia/balao_praia.png',
              width: screenWidth * 0.85, // Ocupa 85% da largura da tela
              fit: BoxFit.contain,
            ),
            SizedBox(height: screenHeight * 0.03),
            GestureDetector(
              onTap: () {
                setState(() {
                  _gameIniciado = true;
                });
              },
              child: Image.asset(
                'assets/images/buttons/botao_check.png',
                width: screenWidth * 0.35, // Proporcional à tela
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget da Tela de Vitória
  Widget _buildVictoryOverlay(double screenWidth, double screenHeight) {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/task_praia/balao_task_concluida.png',
              width: screenWidth * 0.85,
              fit: BoxFit.contain,
            ),
            SizedBox(height: screenHeight * 0.03),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Image.asset(
                'assets/images/buttons/botao_saida.png',
                width: screenWidth * 0.25,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}