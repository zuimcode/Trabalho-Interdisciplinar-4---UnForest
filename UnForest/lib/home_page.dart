import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'credits_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double _larguraNovoJogo = 0.36;
  static const double _alturaNovoJogo = 0.75;
  static const double _ladoBotaoRedondo = 0.16;
  static const double _margemDosCantos = 16.0;

  static const String _pastaBotoes = 'assets/images/buttons';
  static const String _videoIntro =
      'assets/videos/video_fundo_sempersonagens.mp4';

  late final VideoPlayerController _video;
  Timer? _reservaDoFim;
  bool _introTerminou = false;

  @override
  void initState() {
    super.initState();
    _video = VideoPlayerController.asset(_videoIntro)
      ..addListener(_verificarFimDaIntro);
    _iniciarVideo();
  }

  Future<void> _iniciarVideo() async {
    try {
      await _video.initialize();
      if (!mounted) return;

      await _video.setLooping(false);
      await _video.setVolume(0.0);
      await _video.play();

      _reservaDoFim = Timer(
        _video.value.duration + const Duration(milliseconds: 400),
        _terminarIntro,
      );
      setState(() {});
    } catch (erro, pilha) {
      debugPrint('UnForest: falha ao carregar $_videoIntro -> $erro');
      debugPrintStack(stackTrace: pilha);
      _terminarIntro();
    }
  }

  void _verificarFimDaIntro() {
    if (_introTerminou || !_video.value.isInitialized) return;

    final duracao = _video.value.duration;
    if (duracao == Duration.zero) return;

    if (duracao - _video.value.position <= const Duration(milliseconds: 150)) {
      _terminarIntro();
    }
  }

  void _terminarIntro() {
    if (_introTerminou || !mounted) return;
    setState(() => _introTerminou = true);
  }

  void _pularIntro() {
    if (_introTerminou) return;

    if (_video.value.isInitialized) {
      _video.seekTo(_video.value.duration - const Duration(milliseconds: 60));
      _video.pause();
    }
    _terminarIntro();
  }

  void _abrirSelecaoDePersonagem() {
    Navigator.of(context).pushNamed('/character_selection');
  }

  void _abrirConfiguracoes() {
    showSettingsDialog(context);
  }

  void _abrirCreditos() {
    showCreditosDialog(context);
  }

  void _sairDoJogo() {
    SystemNavigator.pop();
  }

  @override
  void dispose() {
    _reservaDoFim?.cancel();
    _video.removeListener(_verificarFimDaIntro);
    _video.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tela = MediaQuery.sizeOf(context);
    final larguraNovoJogo = (tela.width * _larguraNovoJogo).clamp(180.0, 460.0);
    final ladoRedondo =
        (tela.shortestSide * _ladoBotaoRedondo).clamp(48.0, 96.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _pularIntro,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _fundoDeVideo(),
            IgnorePointer(
              ignoring: !_introTerminou,
              child: AnimatedOpacity(
                opacity: _introTerminou ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOut,
                child: SafeArea(
                  child: Stack(
                    children: [
                      Align(
                        alignment: const Alignment(0.0, _alturaNovoJogo),
                        child: _BotaoImagem(
                          arquivo: '$_pastaBotoes/botão_novojogo.png',
                          largura: larguraNovoJogo,
                          rotulo: 'Novo jogo',
                          onTap: _abrirSelecaoDePersonagem,
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(_margemDosCantos),
                          child: _BotaoImagem(
                            arquivo: '$_pastaBotoes/botão_saida_x.png',
                            largura: ladoRedondo,
                            rotulo: 'Sair',
                            onTap: _sairDoJogo,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(_margemDosCantos),
                          child: _BotaoImagem(
                            arquivo:
                                '$_pastaBotoes/botão_configuração_engrenagem_.png',
                            largura: ladoRedondo,
                            rotulo: 'Configurações',
                            onTap: _abrirConfiguracoes,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(_margemDosCantos),
                          child: _BotaoImagem(
                            arquivo:
                                '$_pastaBotoes/botão_créditos_interrogação_.png',
                            largura: ladoRedondo,
                            rotulo: 'Créditos',
                            onTap: _abrirCreditos,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fundoDeVideo() {
    if (!_video.value.isInitialized) {
      return const ColoredBox(color: Colors.black);
    }
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: _video.value.size.width,
        height: _video.value.size.height,
        child: VideoPlayer(_video),
      ),
    );
  }
}

class _BotaoImagem extends StatefulWidget {
  const _BotaoImagem({
    required this.arquivo,
    required this.largura,
    required this.rotulo,
    required this.onTap,
  });

  final String arquivo;
  final double largura;
  final String rotulo;
  final VoidCallback? onTap;

  @override
  State<_BotaoImagem> createState() => _BotaoImagemState();
}

class _BotaoImagemState extends State<_BotaoImagem> {
  bool _pressionado = false;

  void _marcarPressionado(bool valor) {
    if (widget.onTap == null || _pressionado == valor) return;
    setState(() => _pressionado = valor);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      label: widget.rotulo,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _marcarPressionado(true),
        onTapUp: (_) => _marcarPressionado(false),
        onTapCancel: () => _marcarPressionado(false),
        child: AnimatedScale(
          scale: _pressionado ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: Image.asset(
            widget.arquivo,
            width: widget.largura,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            excludeFromSemantics: true,
          ),
        ),
      ),
    );
  }
}
