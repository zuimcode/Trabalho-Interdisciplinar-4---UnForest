import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

// ===========================================================================
// AJUSTES DO MOVIMENTO
// ===========================================================================

/// Sinal aplicado a leitura do acelerometro.
///
/// A pagina fica travada em `landscapeLeft` enquanto esta aberta, entao o eixo
/// Y do aparelho aponta para a direita da tela: inclinar a borda esquerda do
/// celular para baixo deixa o Y positivo, e o filhote anda para a esquerda.
///
/// Se no aparelho a direcao sair invertida, troque este valor para -1.0.
const double _sinalDoEixo = 1.0;

/// Inclinacao (em m/s^2) ignorada para o celular parado na mao nao fazer o
/// filhote andar sozinho.
const double _zonaMorta = 1.6;

/// Inclinacao a partir da qual o filhote ja anda na velocidade maxima. Fica
/// bem abaixo da gravidade (9.8) para a crianca nao precisar virar o celular
/// de lado por completo.
const double _inclinacaoMaxima = 6.5;

/// Velocidade maxima do filhote, em pixels logicos por segundo.
const double _velocidadeMaxima = 260.0;

/// Calcula a nova posicao horizontal do filhote a partir da inclinacao do
/// aparelho.
///
/// [posicaoAtual] e a distancia atual em pixels logicos entre a borda esquerda
/// do cenario e a borda esquerda do filhote. [inclinacao] e a leitura do
/// acelerometro ja com o sinal corrigido: positiva quando o celular esta
/// virado para a esquerda. [dt] e o tempo decorrido desde o quadro anterior,
/// em segundos.
///
/// O resultado fica sempre entre [limiteEsquerdo] (o ponto de encontro com os
/// pais) e [limiteDireito] (a posicao inicial), entao inclinar para o lado
/// errado nunca joga o filhote para fora da tela.
double calcularPosicaoFilhote({
  required double posicaoAtual,
  required double inclinacao,
  required double dt,
  required double limiteEsquerdo,
  required double limiteDireito,
}) {
  final intensidade = (inclinacao.abs() - _zonaMorta) /
      (_inclinacaoMaxima - _zonaMorta);

  if (intensidade <= 0) {
    return posicaoAtual.clamp(limiteEsquerdo, limiteDireito);
  }

  final velocidade =
      intensidade.clamp(0.0, 1.0) * _velocidadeMaxima * inclinacao.sign;

  // Inclinacao positiva (celular virado para a esquerda) diminui a posicao,
  // ou seja, aproxima o filhote dos pais.
  final nova = posicaoAtual - velocidade * dt;
  return nova.clamp(limiteEsquerdo, limiteDireito);
}

// ===========================================================================
// TELA DA TASK
// ===========================================================================

const String _pastaGelo = 'assets/images/task-gelo';
const String _pastaBotoes = 'assets/images/buttons';

/// Proporcao largura/altura de cada PNG, usada para manter os ursos sem
/// distorcao quando a altura e calculada a partir da tela.
const double _proporcaoPais = 1519 / 1381;
const double _proporcaoFilhote = 1612 / 1301;
const double _proporcaoFamilia = 1574 / 1333;

/// Margem transparente a esquerda do PNG do filhote, somada a uma leve
/// sobreposicao. Sem descontar isso as duas placas de gelo parariam com um vao
/// visivel entre elas em vez de encostarem.
const double _margemDaPlaca = 0.22;

/// Tempo sem nenhuma leitura do acelerometro antes de liberar os controles
/// alternativos. No celular o primeiro evento chega quase na hora, entao isso
/// so dispara no desktop e no navegador.
const Duration _esperaPeloSensor = Duration(milliseconds: 1200);

class GeloPage extends StatefulWidget {
  const GeloPage({super.key});

  @override
  State<GeloPage> createState() => _GeloPageState();
}

class _GeloPageState extends State<GeloPage> {
  final FocusNode _foco = FocusNode();
  final Stopwatch _relogio = Stopwatch();

  StreamSubscription<AccelerometerEvent>? _inscricaoSensor;
  Timer? _esperaDoSensor;
  Timer? _loop;

  double _ultimoTick = 0;
  double _leituraDoSensor = 0;
  int _direcaoDoTeclado = 0;

  /// Liga os controles por teclado e por arrastar quando o aparelho nao tem
  /// acelerometro.
  bool _semSensor = false;

  bool _iniciado = false;
  bool _unidos = false;
  bool _mostrarVitoria = false;

  _Cena? _cena;
  double _posicaoFilhote = 0;

  @override
  void initState() {
    super.initState();

    // Trava numa unica orientacao para o eixo do acelerometro nao inverter
    // quando a crianca gira o celular.
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

    _ouvirSensor();
  }

  void _ouvirSensor() {
    _esperaDoSensor = Timer(_esperaPeloSensor, _liberarControlesAlternativos);

    try {
      _inscricaoSensor = accelerometerEventStream().listen(
        (evento) {
          _esperaDoSensor?.cancel();
          _leituraDoSensor = evento.y * _sinalDoEixo;
        },
        onError: (_) => _liberarControlesAlternativos(),
        cancelOnError: true,
      );
    } catch (_) {
      _liberarControlesAlternativos();
    }
  }

  void _liberarControlesAlternativos() {
    if (_semSensor || !mounted) return;
    setState(() => _semSensor = true);
  }

  void _iniciarTask() {
    setState(() => _iniciado = true);

    _relogio.start();
    _ultimoTick = 0;
    _loop = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final agora = _relogio.elapsedMicroseconds / 1000000;
      final dt = agora - _ultimoTick;
      _ultimoTick = agora;
      _avancar(dt);
    });
  }

  double get _inclinacaoAtual {
    if (_semSensor) return _direcaoDoTeclado * _inclinacaoMaxima;
    return _leituraDoSensor;
  }

  void _avancar(double dt) {
    final cena = _cena;
    if (!mounted || _unidos || cena == null) return;

    final nova = calcularPosicaoFilhote(
      posicaoAtual: _posicaoFilhote,
      inclinacao: _inclinacaoAtual,
      dt: dt,
      limiteEsquerdo: cena.encontro,
      limiteDireito: cena.inicio,
    );

    if (nova == _posicaoFilhote) return;
    setState(() => _posicaoFilhote = nova);

    if (nova <= cena.encontro) _unirFamilia();
  }

  void _unirFamilia() {
    _loop?.cancel();
    setState(() => _unidos = true);

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => _mostrarVitoria = true);
    });
  }

  /// Controle alternativo: arrastar o filhote com o dedo ou com o mouse.
  void _arrastarFilhote(DragUpdateDetails detalhes) {
    final cena = _cena;
    if (cena == null || _unidos) return;

    final nova = (_posicaoFilhote + detalhes.delta.dx)
        .clamp(cena.encontro, cena.inicio);

    if (nova == _posicaoFilhote) return;
    setState(() => _posicaoFilhote = nova);

    if (nova <= cena.encontro) _unirFamilia();
  }

  /// Controle alternativo: setas do teclado.
  KeyEventResult _aoPressionarTecla(FocusNode _, KeyEvent evento) {
    if (!_semSensor) return KeyEventResult.ignored;

    final esquerda = evento.logicalKey == LogicalKeyboardKey.arrowLeft;
    final direita = evento.logicalKey == LogicalKeyboardKey.arrowRight;
    if (!esquerda && !direita) return KeyEventResult.ignored;

    if (evento is KeyUpEvent) {
      _direcaoDoTeclado = 0;
    } else {
      _direcaoDoTeclado = esquerda ? 1 : -1;
    }
    return KeyEventResult.handled;
  }

  @override
  void dispose() {
    _loop?.cancel();
    _esperaDoSensor?.cancel();
    _inscricaoSensor?.cancel();
    _foco.dispose();

    // Devolve as duas orientacoes que o resto do jogo usa.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Focus(
        focusNode: _foco,
        autofocus: true,
        onKeyEvent: _aoPressionarTecla,
        child: LayoutBuilder(
          builder: (context, restricoes) {
            final cena = _Cena.medir(restricoes.biggest);

            // Na primeira medida o filhote comeca encostado na borda direita.
            if (_cena == null) _posicaoFilhote = cena.inicio;
            _cena = cena;

            return Stack(
              children: [
                ..._fundo(),
                // Os ursos continuam na tela durante a vitoria: a familia
                // reunida e a recompensa da tarefa, o balao so entra por cima.
                if (_iniciado) ..._ursos(cena),
                if (_iniciado && _semSensor && !_unidos) _dicaSemSensor(),
                if (!_iniciado) _instrucoes(cena),
                if (_mostrarVitoria) _vitoria(cena),
              ],
            );
          },
        ),
      ),
    );
  }

  /// O fundo colorido fica por cima do destruido e so aparece quando a familia
  /// se junta.
  ///
  /// Sao duas camadas com opacidade animada em vez de um `AnimatedCrossFade`
  /// porque o Stack interno dele nao limita o tamanho dos filhos, e a imagem
  /// acaba recebendo restricao infinita de altura.
  List<Widget> _fundo() {
    return [
      Positioned.fill(
        child: Image.asset(
          '$_pastaGelo/fundo_gelo_destruido_task_gelo.jpg',
          fit: BoxFit.cover,
        ),
      ),
      Positioned.fill(
        child: AnimatedOpacity(
          opacity: _unidos ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOut,
          child: Image.asset(
            '$_pastaGelo/fundo_gelo_colorido_task_gelo.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    ];
  }

  List<Widget> _ursos(_Cena cena) {
    if (_unidos) {
      return [
        Positioned(
          left: cena.esquerdaDaFamilia,
          bottom: cena.linhaDagua,
          child: Image.asset(
            '$_pastaGelo/familia_urso_feliz_task_gelo.png',
            height: cena.alturaFamilia,
            width: cena.larguraFamilia,
          ),
        ),
      ];
    }

    return [
      Positioned(
        left: cena.esquerdaDosPais,
        bottom: cena.linhaDagua,
        child: Image.asset(
          '$_pastaGelo/família_urso_triste_task_gelo.png',
          height: cena.alturaPais,
          width: cena.larguraPais,
        ),
      ),
      Positioned(
        left: _posicaoFilhote,
        bottom: cena.linhaDagua,
        child: GestureDetector(
          onHorizontalDragUpdate: _semSensor ? _arrastarFilhote : null,
          child: Image.asset(
            '$_pastaGelo/urso_triste_task_gelo.png',
            height: cena.alturaFilhote,
            width: cena.larguraFilhote,
          ),
        ),
      ),
    ];
  }

  Widget _dicaSemSensor() {
    return Positioned(
      top: 24,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Sem acelerometro: use as setas do teclado ou arraste o filhote',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _instrucoes(_Cena cena) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              '$_pastaBotoes/balão_gelo.png',
              height: cena.alturaDoBalao,
            ),
            SizedBox(height: cena.altura * 0.03),
            GestureDetector(
              onTap: _iniciarTask,
              child: Image.asset(
                '$_pastaBotoes/botao_check.png',
                height: cena.alturaDoBotao,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vitoria(_Cena cena) {
    return Container(
      color: Colors.black.withValues(alpha: 0.38),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              '$_pastaBotoes/balão_task_concluida.png',
              height: cena.alturaDoBalao,
            ),
            SizedBox(height: cena.altura * 0.03),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Image.asset(
                '$_pastaBotoes/botao_saida.png',
                height: cena.alturaDoBotao,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Todas as medidas da cena derivadas do tamanho da tela, para os ursos
/// ficarem proporcionais em qualquer aparelho.
class _Cena {
  const _Cena({
    required this.altura,
    required this.esquerdaDosPais,
    required this.alturaPais,
    required this.larguraPais,
    required this.alturaFilhote,
    required this.larguraFilhote,
    required this.alturaFamilia,
    required this.larguraFamilia,
    required this.esquerdaDaFamilia,
    required this.linhaDagua,
    required this.encontro,
    required this.inicio,
  });

  factory _Cena.medir(Size tela) {
    final alturaPais = tela.height * 0.42;
    final alturaFilhote = tela.height * 0.30;
    final alturaFamilia = tela.height * 0.50;

    final larguraPais = alturaPais * _proporcaoPais;
    final larguraFilhote = alturaFilhote * _proporcaoFilhote;
    final larguraFamilia = alturaFamilia * _proporcaoFamilia;

    final esquerdaDosPais = tela.width * 0.05;
    final encontro =
        esquerdaDosPais + larguraPais - larguraFilhote * _margemDaPlaca;
    final inicio = tela.width - larguraFilhote - tela.width * 0.05;

    // A familia feliz nasce no meio do caminho entre os dois grupos, para a
    // troca de sprite nao dar um salto na tela.
    final centroDoEncontro = (esquerdaDosPais + encontro + larguraFilhote) / 2;

    return _Cena(
      altura: tela.height,
      esquerdaDosPais: esquerdaDosPais,
      alturaPais: alturaPais,
      larguraPais: larguraPais,
      alturaFilhote: alturaFilhote,
      larguraFilhote: larguraFilhote,
      alturaFamilia: alturaFamilia,
      larguraFamilia: larguraFamilia,
      esquerdaDaFamilia: centroDoEncontro - larguraFamilia / 2,
      linhaDagua: tela.height * 0.08,
      // Numa tela muito estreita o encontro poderia ficar depois do inicio, o
      // que inverteria os limites do clamp.
      encontro: encontro.clamp(0.0, inicio),
      inicio: inicio,
    );
  }

  final double altura;
  final double esquerdaDosPais;
  final double alturaPais;
  final double larguraPais;
  final double alturaFilhote;
  final double larguraFilhote;
  final double alturaFamilia;
  final double larguraFamilia;
  final double esquerdaDaFamilia;
  final double linhaDagua;

  /// Posicao em que o filhote encosta nos pais.
  final double encontro;

  /// Posicao inicial do filhote, na borda direita do cenario.
  final double inicio;

  double get alturaDoBalao => altura * 0.45;
  double get alturaDoBotao => altura * 0.16;
}
