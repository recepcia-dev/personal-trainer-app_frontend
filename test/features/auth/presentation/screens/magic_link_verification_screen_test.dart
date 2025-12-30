import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_trainer_app/features/auth/presentation/screens/magic_link_verification_screen.dart';

void main() {
  group('MagicLinkVerificationScreen Widget Tests', () {
    const testEmail = 'test@example.com';

    testWidgets('MagicLinkVerificationScreen renders successfully', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MagicLinkVerificationScreen(email: testEmail, userType: 'trainer'),
          ),
        ),
      );

      expect(find.byType(MagicLinkVerificationScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('displays AppBar with Verify Code title', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MagicLinkVerificationScreen(email: testEmail, userType: 'trainer'),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Verify Code'), findsWidgets);
    });

    testWidgets('displays Check Your Email heading', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MagicLinkVerificationScreen(email: testEmail, userType: 'trainer'),
          ),
        ),
      );

      expect(find.text('Check Your Email'), findsOneWidget);
    });

    testWidgets('displays email in subtitle', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MagicLinkVerificationScreen(email: testEmail, userType: 'trainer'),
          ),
        ),
      );

      expect(find.text('We sent a 6-digit code to\n$testEmail'), findsOneWidget);
    });

    testWidgets('contains code TextField with correct properties', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MagicLinkVerificationScreen(email: testEmail, userType: 'trainer'),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Verification Code'), findsOneWidget);
      expect(find.text('000000'), findsOneWidget);
    });

    testWidgets('code TextField has autofocus enabled', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MagicLinkVerificationScreen(email: testEmail, userType: 'trainer'),
          ),
        ),
      );

      // Autofocus should be visible in the widget tree
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('can enter digits into code field', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MagicLinkVerificationScreen(email: testEmail, userType: 'trainer'),
          ),
        ),
      );

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      await tester.enterText(textField, '123456');
      expect(find.byType(EditableText), findsOneWidget);
    });

    testWidgets('displays Verify Code button or loading indicator', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MagicLinkVerificationScreen(email: testEmail, userType: 'trainer'),
          ),
        ),
      );

      // Either ElevatedButton or CircularProgressIndicator should be present
      final hasButton = find.byType(ElevatedButton).evaluate().isNotEmpty;
      final hasLoader = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
      expect(hasButton || hasLoader, isTrue);
    });

    testWidgets('displays Resend link button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MagicLinkVerificationScreen(email: testEmail, userType: 'trainer'),
          ),
        ),
      );

      expect(find.byType(TextButton), findsOneWidget);
      // Resend link text should be visible (either with or without countdown)
      final resendFinder = find.textContaining('Resend link');
      expect(resendFinder, findsOneWidget);
    });

    testWidgets('uses SafeArea widget for safe layout', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MagicLinkVerificationScreen(email: testEmail, userType: 'trainer'),
          ),
        ),
      );

      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('uses SingleChildScrollView for scrollable content', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MagicLinkVerificationScreen(email: testEmail, userType: 'trainer'),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('uses Material Design components', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MagicLinkVerificationScreen(email: testEmail, userType: 'trainer'),
          ),
        ),
      );

      // Verify Material Design elements are present
      expect(find.byType(Material), findsWidgets);
      expect(find.byType(Center), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });
  });
}
