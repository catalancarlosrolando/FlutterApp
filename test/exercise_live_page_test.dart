import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/src/pages/exerciseLive_page.dart';

void main() {
  testWidgets('ExerciseLivePage renders from exercise parameters and handles Iniciar and Rest flow',
      (WidgetTester tester) async {
    const mockExercise = {
      'id': 'pecho_01',
      'name': 'Press de Banca Plano',
      'tiempo': '15 Minutos',
      'series': '4',
      'reps': '10-12',
      'peso': '40 kg',
      'descanso': '60 seg',
      'description': 'Ejercicio compuesto fundamental para desarrollo de pecho.',
    };

    await tester.pumpWidget(
      const MaterialApp(
        home: ExerciseLivePage(exercise: mockExercise),
      ),
    );

    await tester.pump();

    // Verify Title and Initial Header Action Button ("Iniciar")
    expect(find.text('Press de Banca Plano'), findsOneWidget);
    expect(find.text('Iniciar'), findsOneWidget);
    expect(find.text('DURACIÓN • 15 Minutos'), findsOneWidget);

    // Verify Rest Timer Card
    expect(find.text('DESCANSO • PRESS DE BANCA PLANO'), findsOneWidget);
    expect(find.text('Iniciar Descanso'), findsOneWidget);
    expect(find.text('01:00'), findsOneWidget);
    expect(find.text('-15s'), findsOneWidget);
    expect(find.text('+30s'), findsOneWidget);

    // Verify Exercise Sets Table (4 sets generated from 'series': '4')
    expect(find.text('1. Press de Banca Plano'), findsOneWidget);
    expect(find.text('Discos'), findsOneWidget);
    expect(find.text('SET'), findsOneWidget);
    expect(find.text('ANTERIOR'), findsOneWidget);
    expect(find.text('KG'), findsOneWidget);
    expect(find.text('REPS'), findsOneWidget);
    expect(find.text('LISTO'), findsOneWidget);
    expect(find.text('Añadir Serie'), findsOneWidget);

    // Tap Iniciar -> Button transforms into Finalizar
    await tester.tap(find.text('Iniciar'));
    await tester.pump();
    expect(find.text('Finalizar'), findsOneWidget);

    // Tap Iniciar Descanso -> starts running, shows Reiniciar descanso
    await tester.tap(find.text('Iniciar Descanso'));
    await tester.pump();
    expect(find.text('Reiniciar descanso'), findsOneWidget);

    // Tap Reiniciar descanso -> returns to initial time (01:00) and shows Iniciar Descanso
    await tester.tap(find.text('Reiniciar descanso'));
    await tester.pump();
    expect(find.text('Iniciar Descanso'), findsOneWidget);
    expect(find.text('01:00'), findsOneWidget);
  });
}
