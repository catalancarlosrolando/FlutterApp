import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/myNavigatorbar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('statistics destination is visible and selectable', (
    tester,
  ) async {
    var selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: MyNavigationBar(
            currentIndex: selectedIndex,
            onDestinationSelected: (index) => selectedIndex = index,
          ),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Rutinas'), findsOneWidget);
    expect(find.text('Estadísticas'), findsOneWidget);

    await tester.tap(find.text('Estadísticas'));
    expect(selectedIndex, 2);
    expect(tester.takeException(), isNull);
  });
}
