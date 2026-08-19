import 'package:flutter_test/flutter_test.dart';
import 'package:login_front/main.dart';

void main() {
  testWidgets('Tela de login e home aparecem corretamente',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Resenha ou Morte'), findsNothing);
  });
}
