// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ggrm_stock_app/main.dart';
import 'package:ggrm_stock_app/screens/login_screen.dart';

void main() {
  // Setup Firebase for testing
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GGRM Stock App Tests', () {
    testWidgets('Login screen renders correctly', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(MyApp());

      // Verify that login screen title exists
      expect(find.text('Selamat Datang'), findsOneWidget);
    });

    testWidgets('Login form has required fields', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      // Verify email and password fields exist
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('Login button exists', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      // Verify submit button exists
      expect(find.text('Masuk'), findsOneWidget);
    });

    testWidgets('Google Sign In button exists', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      // Verify Google Sign In button exists
      expect(find.text('Masuk dengan Google'), findsOneWidget);
    });

    testWidgets('Sign up link exists', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      // Verify sign up link exists
      expect(find.text('Daftar'), findsOneWidget);
    });
  });
}

