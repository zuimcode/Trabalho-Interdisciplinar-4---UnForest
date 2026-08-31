import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ItemCidade {
  final UniqueKey id;
  Offset position;
  bool isBicycle;

  ItemCidade({
    required this.id,
    required this.position,
    this.isBicycle = false,   
  });
}

class CidadePage extends StatefulWidget {
  const CidadePage({Key? key}) : super(key: key);

  @override
  State<CidadePage> createState() => _CidadePageState();
}

class _CidadePageState extends State<CidadePage> {
  late VideoPlayerController _videoController;
  final List<ItemCidade> _itens = [];
  int _contadorBicicletas = 0;
  Timer? _timerSpawn;
  final Random _random = Random();
  bool _showInstructions = true;
  bool _showVictory = false;

  @override
  void initState() {
    super.initState();
    // 1. Inicializa o Vídeo de Fundo
    _videoController = VideoPlayerController.asset(
      'assets/videos/video-cidade/video_fundo_sempersonagens.mp4',
    )..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.play();
        setState(() {});
      });
  }

  void _iniciarTask() {
    setState(() {
      _showInstructions = false;
    });

    _timerSpawn?.cancel();
    _timerSpawn = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted || _contadorBicicletas >= 10 || _showVictory) {
        timer.cancel();
        return;
      }

      _gerarCarro();
    });
  }

  void _gerarCarro() {
    if (_itens.length >= 6) return; // Limite de itens simultâneos na tela

    final size = MediaQuery.of(context).size;
    
    // Define margens para o carro não aparecer fora da tela
    double posX = _random.nextDouble() * (size.width - 100);
    double posY = 100 + _random.nextDouble() * (size.height - 250);

    setState(() {
      _itens.add(
        ItemCidade(
          id: UniqueKey(),
          position: Offset(posX, posY),
        ),
      );
    });
  }

  void _transformarEmBicicleta(ItemCidade item) {
    if (item.isBicycle || _contadorBicicletas >= 10 || _showVictory) return;

    setState(() {
      item.isBicycle = true;
      _contadorBicicletas++;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _itens.removeWhere((element) => element.id == item.id);
        });
      }
    });

    if (_contadorBicicletas >= 10) {
      _exibirTelaSucesso();
    }
  }

  void _exibirTelaSucesso() {
    setState(() {
      _showVictory = true;
    });
  }

  @override
  void dispose() {
    _timerSpawn?.cancel();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Fundo em Vídeo
          _videoController.value.isInitialized
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),

          if (!_showInstructions && !_showVictory)
            ..._itens.map((item) {
              return Positioned(
                left: item.position.dx,
                top: item.position.dy,
                child: GestureDetector(
                  onTap: () => _transformarEmBicicleta(item),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Image.asset(
                      item.isBicycle
                          ? 'assets/images/task-cidade/bicicleta.png'
                          : 'assets/images/task-cidade/carro.png',
                      key: ValueKey(item.isBicycle),
                      width: 80,
                      height: 80,
                    ),
                  ),
                ),
              );
            }).toList(),

          if (!_showInstructions && !_showVictory)
            Positioned(
              top: 40,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/task-cidade/bicicleta.png',
                      width: 30,
                      height: 30,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$_contadorBicicletas / 10',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_showInstructions)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/buttons/balão_cidade.png',
                    height: 220,
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _iniciarTask,
                    child: Image.asset(
                      'assets/images/buttons/botao_check.png',
                      height: 70,
                    ),
                  ),
                ],
              ),
            ),

          if (_showVictory)
            Container(
              color: Colors.black38,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/buttons/balão_task_concluida.png',
                      height: 180,
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Image.asset(
                        'assets/images/buttons/botao_saida.png',
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
}