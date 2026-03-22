// test/widgets/customer_login_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techie_go/screens/auth/customer_login.dart';
import '../test_utils.dart';

void main() {
  group('Customer Login Widget Tests', () {
    late Widget customerLoginScreen;

    setUp(() {
      customerLoginScreen = const CustomerLogin();
    });

    testWidgets('should display app bar with back button and title',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, customerLoginScreen);

      // Assert
      expect(find.text('Customer Login'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should display logo and portal name',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, customerLoginScreen);

      // Assert
      expect(find.text('Techie Go'), findsOneWidget);
      expect(find.text('Customer Portal'), findsOneWidget);
    });

    testWidgets('should have phone number input field',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, customerLoginScreen);

      // Assert
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.byIcon(Icons.phone), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2)); // Changed to TextField
    });

    testWidgets('should have OTP input field with send button',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, customerLoginScreen);

      // Assert
      expect(find.text('OTP'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.text('Send OTP'), findsOneWidget);
    });

    testWidgets('should enable send OTP button when phone number is entered',
        (WidgetTester tester) async {
      // Arrange
      await TestUtils.pumpWidget(tester, customerLoginScreen);

      // Act
      await TestUtils.enterText(
        tester,
        find.bySemanticsLabel('Phone Number'),
        MockData.testPhone,
      );

      // Assert
      expect(find.text(MockData.testPhone), findsOneWidget);
      expect(find.text('Send OTP'), findsOneWidget);
    });

    testWidgets('should show success message when OTP is sent',
        (WidgetTester tester) async {
      // Arrange
      await TestUtils.pumpWidget(tester, customerLoginScreen);

      // Act
      await TestUtils.enterText(
        tester,
        find.bySemanticsLabel('Phone Number'),
        MockData.testPhone,
      );
      await TestUtils.tapAndSettle(tester, find.text('Send OTP'));

      // Assert
      expect(find.text('OTP sent to ${MockData.testPhone}'), findsOneWidget);
    });

    testWidgets('should have register and back to home links',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, customerLoginScreen);

      // Assert
      expect(find.text('New customer?'), findsOneWidget);
      expect(find.text('Register here'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);
    });

    testWidgets('should show loading indicator when logging in',
        (WidgetTester tester) async {
      // Arrange
      await TestUtils.pumpWidget(tester, customerLoginScreen);

      // Act
      // Find phone field by hint text
      await tester.enterText(find.byType(TextField).first, MockData.testPhone);
      await tester.pumpAndSettle();

      // Find OTP field (second TextField)
      await tester.enterText(find.byType(TextField).at(1), MockData.testOTP);
      await tester.pumpAndSettle();

      await TestUtils.tapAndSettle(tester, find.text('Login'));

      // Assert - Button should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // FIXED: Test for input decoration
    testWidgets('should find input fields with correct hints',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, customerLoginScreen);

      // Assert - Check that we can find fields by their hint text
      expect(find.text('Enter registered phone number'), findsOneWidget);
      expect(find.text('Enter 6-digit OTP'), findsOneWidget);
    });

    // New test to verify the UI structure
    testWidgets('should have proper form structure',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, customerLoginScreen);

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
      expect(
          find.byType(ElevatedButton), findsNWidgets(2)); // Send OTP and Login
    });
  });
}
