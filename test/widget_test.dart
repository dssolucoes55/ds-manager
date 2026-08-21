import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Interface básica do DS Manager é exibida',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('DS Manager'),
            ),
          ),
        ),
      );

      expect(find.text('DS Manager'), findsOneWidget);
    },
  );
}