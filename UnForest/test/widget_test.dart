// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:UnForest/cidade.dart';

void main() {
  testWidgets('Carrega a tela do jogo', (WidgetTester tester) async {
    await tester.pumpWidget(const CidadePage());
    await tester.pump();

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