import 'package:flutter_test/flutter_test.dart';

import 'package:proyecto_kania/main.dart';

void main() {
  testWidgets('Carga de la aplicación principal', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that 'Inicio' appears on screen.
    expect(find.text('Inicio'), findsWidgets);
  });
}
