import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ItemCidade {
  final UniqueKey id;
  Offset position;
  bool isBicycle;
  double speed;

  ItemCidade({
    required this.id,
    required this.position,
    this.isBicycle = false,
    this.speed = 2.0,
  });
}

class CidadePage extends StatefulWidget {
  const CidadePage({Key? key}) : super(key: key);

  @override
  State<CidadePage> createState() => _CidadePageState();
}

class _CidadePageState extends State<CidadePage> {
  final List<ItemCidade> _itens = [];
  int _contadorBicicletas = 0;
  Timer? _timerSpawn;
  Timer? _timerGameLoop;
  final Random _random = Random();
  bool _showInstructions = true;
  bool _showVictory = false;
  bool _taskConcluida = false; // Controle para trocar o fundo

  @override
  void initState() {
    super.initState();
  }

  void _iniciarTask() {
    setState(() {
      _showInstructions = false;
    });

    _timerSpawn?.cancel();
    _timerSpawn = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted || _contadorBicicletas >= 10) {
        timer.cancel();
        return;
      }
      _gerarCarro();
    });

    // Loop de movimento (~60 FPS)
    _timerGameLoop?.cancel();
    _timerGameLoop = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) return;
      _atualizarPosicoes();
    });
  }

  void _gerarCarro() {
    if (_itens.length >= 6 || _taskConcluida) return;

    final size = MediaQuery.of(context).size;

    // 3. Ajuste de altura: Posiciona os itens mais abaixo na tela (75% a 88%)
    double minHeight = size.height * 0.60;
    double maxHeight = size.height * 0.75;
    double posY = minHeight + _random.nextDouble() * (maxHeight - minHeight);

    double posX = -80.0;
    double velocidade = 1.5 + _random.nextDouble() * 2.0;

    setState(() {
      _itens.add(
        ItemCidade(
          id: UniqueKey(),
          position: Offset(posX, posY),
          speed: velocidade,
        ),
      );
    });
  }

  void _atualizarPosicoes() {
    final size = MediaQuery.of(context).size;

    setState(() {
      for (var item in _itens) {
        item.position = Offset(item.position.dx + item.speed, item.position.dy);
      }

      // 2. Os itens (carros e bicicletas) continuam andando e só somem ao sair da tela
      _itens.removeWhere((item) => item.position.dx > size.width + 100);
    });
  }

  void _transformarEmBicicleta(ItemCidade item) {
    if (item.isBicycle || _contadorBicicletas >= 10 || _showVictory) return;

    setState(() {
      item.isBicycle = true;
      _contadorBicicletas++;
    });

    // Removida a exclusão antecipada por tempo (Future.delayed) para deixá-las percorrer o caminho inteiro

    if (_contadorBicicletas >= 10 && !_taskConcluida) {
      _concluirTask();
    }
  }

  void _concluirTask() {
    _timerSpawn?.cancel(); // Para o surgimento de novos carros

    // 1. Troca o fundo imediatamente para a versão colorida
    setState(() {
      _taskConcluida = true;
    });

    // Aguarda 5 segundos antes de exibir o pop-up de vitória
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showVictory = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timerSpawn?.cancel();
    _timerGameLoop?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Troca dinâmica da imagem de fundo ao atingir a meta
          SizedBox.expand(
            child: Image.asset(
              _taskConcluida
                  ? 'assets/images/task-cidade/cidade_colorida.png'
                  : 'assets/images/task-cidade/fundo_cinza.png',
              fit: BoxFit.cover,
            ),
          ),

          // Renderização contínua dos veículos até a vitória final
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
                      width: 130,
                      height: 130,
                    ),
                  ),
                ),
              );
            }).toList(),

          // Indicador de Progresso
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

          // Tela Inicial de Instruções
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

          // Tela de Vitória (exibida 5 segundos após a conclusão)
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