import 'package:flutter/material.dart';
import 'package:flutter_application/src/models/app_user.dart';
import 'package:flutter_application/src/pages/rejected_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppUser enums', () {
    test('UserRole.fromString parses admin and defaults to user', () {
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString('user'), UserRole.user);
      expect(UserRole.fromString(null), UserRole.user);
      expect(UserRole.fromString('other'), UserRole.user);
    });

    test('UserStatus.fromString parses approved, rejected, pending', () {
      expect(UserStatus.fromString('approved'), UserStatus.approved);
      expect(UserStatus.fromString('rejected'), UserStatus.rejected);
      expect(UserStatus.fromString('pending'), UserStatus.pending);
      expect(UserStatus.fromString(null), UserStatus.pending);
    });
  });

  testWidgets('RejectedPage renders blocked message and sign out button', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: RejectedPage(email: 'user@test.com')),
    );

    expect(find.text('Acceso denegado'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });
}
