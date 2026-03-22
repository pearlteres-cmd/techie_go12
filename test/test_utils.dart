// test/test_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Common test utilities for widget testing
class TestUtils {
  /// Pump widget with MaterialApp wrapper
  static Future<void> pumpWidget(
    WidgetTester tester,
    Widget widget, {
    ThemeData? theme,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme ?? ThemeData(),
        home: Scaffold(body: widget),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Find text with case-insensitive search
  static Finder findText(String text) {
    return find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data != null &&
          widget.data!.toLowerCase().contains(text.toLowerCase()),
    );
  }

  /// Find button by its text
  static Finder findButton(String text) {
    return find.byWidgetPredicate(
      (widget) =>
          widget is ElevatedButton &&
          widget.child is Text &&
          (widget.child as Text).data?.toLowerCase() == text.toLowerCase(),
    );
  }

  /// Tap on a widget and wait for animations
  static Future<void> tapAndSettle(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Enter text into a TextField
  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// Verify snackbar is shown
  static void verifySnackbar(String message) {
    expect(find.text(message), findsOneWidget);
  }
}

/// Mock data for testing
class MockData {
  static const String testPhone = '9876543210';
  static const String testOTP = '123456';
  static const String testEmail = 'test@techiego.com';
  static const String testPassword = 'password123';

  static const List<String> serviceTypes = [
    'Laptop Repair',
    'Software Installation',
    'Virus Removal',
  ];
}
