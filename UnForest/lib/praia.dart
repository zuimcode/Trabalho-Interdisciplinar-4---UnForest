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

  // Controle de estado
  bool _taskConcluida = false;
  bool _lixeiraHighlight = false; // Para dar efeito visual quando passa o lixo por cima

  @override
  void initState() {
    super.initState();
    _resetTask();
  }

  void _resetTask() {
    setState(() {
      _taskConcluida = false;
      _lixeiraHighlight = false;
      // Configure aqui a lista de lixos com seus assets e posições (em pixels ou % da tela)
      _lixosRestantes = [
        ItemLixo(id: 'lixo_1', assetPath: 'assets/images/garrafa.png', top: 120, left: 50, size: 65),
        ItemLixo(id: 'lixo_2', assetPath: 'assets/images/lata.png', top: 250, left: 220, size: 55),
        ItemLixo(id: 'lixo_3', assetPath: 'assets/images/papel.png', top: 400, left: 80, size: 60),
        ItemLixo(id: 'lixo_4', assetPath: 'assets/images/sacola.png', top: 320, left: 270, size: 70),
        ItemLixo(id: 'lixo_5', assetPath: 'assets/images/maca.png', top: 180, left: 160, size: 50),
      ];
    });
  }

  // Chamado sempre que um lixo é jogado com sucesso na lixeira
  void _onLixoColetado(ItemLixo lixo) {
    // Tocar som de coleta aqui se desejar (ex: AudioPlayer().play(AssetSource('audio/pop.mp3')))
    
    setState(() {
      _lixosRestantes.removeWhere((item) => item.id == lixo.id);

      if (_lixosRestantes.isEmpty) {
        _finalizarTask();
      }
    });
  }

  void _finalizarTask() {
    // Tocar som de sucesso aqui
    setState(() {
      _taskConcluida = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Fundo do Cenário
          Positioned.fill(
            child: Image.asset(
              'assets/images/fundo_cenario.png', // Seu fundo
              fit: BoxFit.cover,
            ),
          ),

          // 2. Contador / Indicador Topo
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

          // 3. A Lixeira (DragTarget)
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
                        ? 'assets/images/lixeira_aberta.png' // Opcional: imagem da lixeira aberta
                        : 'assets/images/lixeira.png',
                    width: 120,
                    height: 140,
                  ),
                );
              },
            ),
          ),

          // 4. Lixos Espalhados na Tela (Draggables)
          ..._lixosRestantes.map((lixo) {
            return Positioned(
              top: lixo.top,
              left: lixo.left,
              child: Draggable<ItemLixo>(
                data: lixo,
                // Imagem arrastada pelo dedo
                feedback: Material(
                  color: Colors.transparent,
                  child: Image.asset(
                    lixo.assetPath,
                    width: lixo.size * 1.2,
                    height: lixo.size * 1.2,
                  ),
                ),
                // O que fica na posição original enquanto arrasta (transparente)
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: Image.asset(
                    lixo.assetPath,
                    width: lixo.size,
                    height: lixo.size,
                  ),
                ),
                // Imagem normal parada na tela
                child: Image.asset(
                  lixo.assetPath,
                  width: lixo.size,
                  height: lixo.size,
                ),
              ),
            );
          }).toList(),

          // 5. Overlay de Vitória / Conclusão
          if (_taskConcluida) _buildVictoryOverlay(),
        ],
      ),
    );
  }

  // Widget do Overlay de Vitória
  Widget _buildVictoryOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.greenAccent,
              size: 100,
            ),
            const SizedBox(height: 16),
            const Text(
              'Área Limpa!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Você recolheu todo o lixo com sucesso.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Concluir', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}