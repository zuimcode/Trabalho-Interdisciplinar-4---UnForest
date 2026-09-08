import 'package:flutter/material.dart';

// Modelo para representar cada lixo na tela
class ItemLixo {
  final String id;
  final String assetPath;
  final double top;
  final double left;
  final double size;

  ItemLixo({
    required this.id,
    required this.assetPath,
    required this.top,
    required this.left,
    this.size = 60.0,
  });
}

class LixoTaskPage extends StatefulWidget {
  const LixoTaskPage({Key? key}) : super(key: key);

  @override
  State<LixoTaskPage> createState() => _LixoTaskPageState();
}

class _LixoTaskPageState extends State<LixoTaskPage> {
  // Lista inicial de lixos espalhados na tela
  late List<ItemLixo> _lixosRestantes;

  // Controle de estado de fluxo do jogo
  bool _gameIniciado = false; // Controla a tela inicial de instruções
  bool _taskConcluida = false; // Controla se o jogo acabou
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
      _lixosRestantes = [
        ItemLixo(id: 'lixo_1', assetPath: 'images/task_praia/garrafa.png', top: 450, left: 400, size: 150),
        ItemLixo(id: 'lixo_2', assetPath: 'images/task_praia/lata.png', top: 450, left: 600, size: 150),
        ItemLixo(id: 'lixo_3', assetPath: 'images/task_praia/peixe.png', top: 450, left: 800, size: 150),
        ItemLixo(id: 'lixo_4', assetPath: 'images/task_praia/sacola.png', top: 450, left: 1000, size: 150),
        ItemLixo(id: 'lixo_5', assetPath: 'images/task_praia/maca.png', top: 450, left: 200, size: 150),
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
    return Scaffold(
      body: Stack(
        children: [
          // 1. Fundo Dinâmico com Transição Suave (AnimatedCrossFade)
          Positioned.fill(
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 1200), // Tempo da animação
              crossFadeState: _taskConcluida
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Image.asset(
                'images/task_praia/praia_feia2.png', // Praia Suja
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              secondChild: Image.asset(
                'images/task_praia/praia_bonita.png', // Praia Limpa (Substitua pelo seu PNG)
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // 2. Elementos do Jogo (Só aparecem enquanto o jogo estiver rolando)
          if (_gameIniciado && !_taskConcluida) ...[
            // Contador / Indicador Topo
            Positioned(
              top: 40,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Lixos restantes: ${_lixosRestantes.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // A Lixeira (DragTarget)
            Positioned(
              bottom: 40,
              right: 30,
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
                          ? 'images/task_praia/lixeira_aberta.png'
                          : 'images/task_praia/lixeira_fechada.png',
                      width: 300,
                      height: 360,
                    ),
                  );
                },
              ),
            ),

            // Lixos Espalhados na Tela (Draggables)
            ..._lixosRestantes.map((lixo) {
              return Positioned(
                top: lixo.top,
                left: lixo.left,
                child: Draggable<ItemLixo>(
                  data: lixo,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Image.asset(
                      lixo.assetPath,
                      width: lixo.size * 1.2,
                      height: lixo.size * 1.2,
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: Image.asset(
                      lixo.assetPath,
                      width: lixo.size,
                      height: lixo.size,
                    ),
                  ),
                  child: Image.asset(
                    lixo.assetPath,
                    width: lixo.size,
                    height: lixo.size,
                  ),
                ),
              );
            }).toList(),
          ],

          // 3. Overlay Inicial (Instruções do Jogo)
          if (!_gameIniciado) _buildIntroOverlay(),

          // 4. Overlay de Vitória (Final do Jogo)
          if (_taskConcluida) _buildVictoryOverlay(),
        ],
      ),
    );
  }

  // Widget da Tela de Instruções (Antes do jogo começar)
  Widget _buildIntroOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // PNG com as Instruções
            Image.asset(
              'images/buttons/balao_fala_pergaminho.png', // Seu PNG explicativo
              width: 400,
            ),
            const SizedBox(height: 24),
            // Botão para iniciar o jogo
            GestureDetector(
              onTap: () {
                setState(() {
                  _gameIniciado = true;
                });
              },
              child: Image.asset(
                'images/buttons/botao_check.png', // Seu botão de Start/Play
                width: 150,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget da Tela de Vitória (Quando o jogo acaba)
  Widget _buildVictoryOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // PNG de mensagem final
            Image.asset(
              'images/buttons/balao_fala_pergaminho.png', // Seu PNG de Conclusão/Parabéns
              width: 400,
            ),
            const SizedBox(height: 24),
            // Botão para fechar a tela/sair da missão
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Image.asset(
                'images/buttons/botao_saida.png', // Seu botão para Sair
                width: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}