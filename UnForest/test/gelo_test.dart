import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:UnForest/gelo.dart';

// Limites usados em todos os testes: o filhote comeca em 800 (borda direita do
// cenario) e o encontro com os pais acontece em 100.
const double encontro = 100.0;
const double inicio = 800.0;

double mover(double posicao, double inclinacao, {double dt = 1 / 60}) {
  return calcularPosicaoFilhote(
    posicaoAtual: posicao,
    inclinacao: inclinacao,
    dt: dt,
    limiteEsquerdo: encontro,
    limiteDireito: inicio,
  );
}

void main() {
  group('calcularPosicaoFilhote', () {
    test('celular parado nao move o filhote', () {
      expect(mover(400, 0), 400);
    });

    test('tremida pequena dentro da zona morta nao move o filhote', () {
      expect(mover(400, 1.0), 400);
      expect(mover(400, -1.0), 400);
    });

    test('inclinar para a esquerda leva o filhote em direcao aos pais', () {
      expect(mover(400, 9.8), lessThan(400));
    });

    test('inclinar para a direita afasta o filhote dos pais', () {
      expect(mover(400, -9.8), greaterThan(400));
    });

    test('inclinacao maior move mais que inclinacao menor', () {
      final pouco = 400 - mover(400, 4.0);
      final muito = 400 - mover(400, 9.8);
      expect(muito, greaterThan(pouco));
    });

    test('o filhote para no ponto de encontro e nao passa dos pais', () {
      var posicao = inicio;
      for (var i = 0; i < 600; i++) {
        posicao = mover(posicao, 9.8);
      }
      expect(posicao, encontro);
    });

    test('inclinar para o lado errado trava na posicao inicial, sem sair da tela', () {
      var posicao = 300.0;
      for (var i = 0; i < 600; i++) {
        posicao = mover(posicao, -9.8);
      }
      expect(posicao, inicio);
    });

    test('inclinacao acima da gravidade nao acelera alem do limite', () {
      expect(mover(400, 30.0), mover(400, 9.8));
    });

    test('o deslocamento acompanha o tempo decorrido', () {
      final umQuadro = 400 - mover(400, 9.8, dt: 1 / 60);
      final doisQuadros = 400 - mover(400, 9.8, dt: 2 / 60);
      expect(doisQuadros, closeTo(umQuadro * 2, 0.001));
    });
  });

  group('GeloPage', () {
    // Sem acelerômetro de verdade o canal do sensors_plus estoura ao ser
    // ativado. O mock deixa a escuta abrir e nunca emitir nada, que e
    // exatamente o cenario do desktop: a tela tem que continuar de pe e cair
    // nos controles alternativos.
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      const canais = [
        'dev.fluttercommunity.plus/sensors/accelerometer',
        'dev.fluttercommunity.plus/sensors/method',
      ];
      for (final canal in canais) {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          MethodChannel(canal),
          (call) async => null,
        );
      }
    });

    // A pasta task-gelo/ nao estava declarada no pubspec e um dos arquivos tem
    // acento no nome, entao vale conferir que tudo o que a tela pede existe
    // mesmo dentro do bundle.
    test('todos os assets usados pela tela estao no bundle', () async {
      TestWidgetsFlutterBinding.ensureInitialized();

      const usados = [
        'assets/images/task-gelo/fundo_gelo_destruido_task_gelo.jpg',
        'assets/images/task-gelo/fundo_gelo_colorido_task_gelo.jpg',
        'assets/images/task-gelo/família_urso_triste_task_gelo.png',
        'assets/images/task-gelo/urso_triste_task_gelo.png',
        'assets/images/task-gelo/familia_urso_feliz_task_gelo.png',
        'assets/images/buttons/balão_gelo.png',
        'assets/images/buttons/balão_task_concluida.png',
        'assets/images/buttons/botao_check.png',
        'assets/images/buttons/botao_saida.png',
      ];

      for (final caminho in usados) {
        expect(
          rootBundle.load(caminho),
          completes,
          reason: '$caminho nao foi encontrado no bundle',
        );
      }
    });

    testWidgets('abre mostrando o balao de instrucoes', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GeloPage()));
      await tester.pump();

      expect(_acharImagem('assets/images/buttons/balão_gelo.png'), findsOneWidget);
    });

    testWidgets('depois do check os dois ursos aparecem separados',
        (tester) async {
      // runAsync deixa os PNGs serem decodificados de verdade. Sem isso as
      // imagens ficam com largura zero e o toque no botao erra o alvo.
      await tester.runAsync(() async {
        await tester.pumpWidget(const MaterialApp(home: GeloPage()));
        await Future.delayed(const Duration(milliseconds: 300));
        await tester.pump();

        await tester.tap(_acharImagem('assets/images/buttons/botao_check.png'));
        await tester.pump();
      });

      expect(
        _acharImagem('assets/images/task-gelo/família_urso_triste_task_gelo.png'),
        findsOneWidget,
      );
      expect(
        _acharImagem('assets/images/task-gelo/urso_triste_task_gelo.png'),
        findsOneWidget,
      );
      expect(
        _acharImagem('assets/images/task-gelo/familia_urso_feliz_task_gelo.png'),
        findsNothing,
      );

      // Encerra o loop da task para o teste nao terminar com timer pendente.
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    });
  });
}

Finder _acharImagem(String caminho) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Image &&
        widget.image is AssetImage &&
        (widget.image as AssetImage).assetName == caminho,
  );
}
