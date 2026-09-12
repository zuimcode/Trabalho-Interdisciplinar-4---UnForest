import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:UnForest/cidade.dart';

void main() {
  testWidgets('Carrega a tela do jogo', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CidadePage(),
        ),
      );
      await tester.pumpAndSettle();
    });

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == 'assets/images/buttons/balão_cidade.png',
      ),
      findsOneWidget,
    );
  });
}