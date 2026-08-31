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

    // 2. Loop para gerar novos carros na tela a cada 1.5 segundos
    _timerSpawn = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (_contadorBicicletas < 10) {
        _gerarCarro();
      } else {
        timer.cancel();
      }
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
    if (item.isBicycle || _contadorBicicletas >= 10) return;

    setState(() {
      item.isBicycle = true;
      _contadorBicicletas++;
    });

    // Remove a bicicleta após 1.5 segundos da transformação
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _itens.removeWhere((element) => element.id == item.id);
        });
      }
    });

    // Verifica se completou a task
    if (_contadorBicicletas >= 10) {
      _exibirDialogSucesso();
    }
  }

  void _exibirDialogSucesso() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Task Concluída! 🎉'),
        content: const Text('Você transformou 10 carros em bicicletas com sucesso!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Adicione aqui a navegação de volta ou próxima ação
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
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

          // 2. Elementos Interativos (Carros / Bicicletas)
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

          // 3. Placa do Contador
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
        ],
      ),
    );
  }
}