import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blud_flutter/main.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const BludApp());
    expect(find.text('BLUD Pariwisata'), findsOneWidget);
    expect(find.text('Wisata Banyumas'), findsOneWidget);
  });
}
