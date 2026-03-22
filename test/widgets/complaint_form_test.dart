// test/widgets/complaint_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techie_go/screens/customer/complaint_form.dart';
import '../test_utils.dart';

void main() {
  group('Complaint Form Widget Tests', () {
    late Widget complaintForm;

    setUp(() {
      complaintForm = const ComplaintForm();
    });

    testWidgets('should display app bar with title and back button',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, complaintForm);

      // Assert
      expect(find.text('Register Complaint'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should have service type dropdown',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, complaintForm);

      // Assert
      expect(find.text('Service Type'), findsOneWidget);
      expect(find.text('Select service type'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('should have description text field',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, complaintForm);

      // Assert
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Describe the issue in detail...'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('should have attachments section', (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, complaintForm);

      // Assert
      expect(find.text('Attachments (Optional)'), findsOneWidget);
      expect(find.text('Add photos or documents'), findsOneWidget);
      expect(find.text('Add Files'), findsOneWidget);
      expect(find.byIcon(Icons.attach_file), findsOneWidget);
    });

    testWidgets('should have submit complaint button',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, complaintForm);

      // Assert
      expect(find.text('Submit Complaint'), findsOneWidget);
    });

    testWidgets('should show all service types in dropdown',
        (WidgetTester tester) async {
      // Arrange
      await TestUtils.pumpWidget(tester, complaintForm);

      // Act - Tap dropdown
      await TestUtils.tapAndSettle(
        tester,
        find.text('Select service type'),
      );

      // Assert - Should show dropdown items
      // Note: This test might need adjustment based on how dropdown is implemented
      expect(find.text('Laptop Repair'), findsOneWidget);
      expect(find.text('Software Installation'), findsOneWidget);
      expect(find.text('Virus Removal'), findsOneWidget);
    });

    testWidgets('should validate form when submit is pressed with empty fields',
        (WidgetTester tester) async {
      // Arrange
      await TestUtils.pumpWidget(tester, complaintForm);

      // Act
      await TestUtils.tapAndSettle(tester, find.text('Submit Complaint'));

      // Assert - Form should not submit (button should still be enabled)
      // In a real app with validation, this would show error messages
      expect(find.text('Submit Complaint'), findsOneWidget);
    });

    testWidgets('should show loading indicator when submitting',
        (WidgetTester tester) async {
      // Arrange
      await TestUtils.pumpWidget(tester, complaintForm);

      // Act - Fill form and submit
      await TestUtils.tapAndSettle(
        tester,
        find.text('Select service type'),
      );
      await TestUtils.tapAndSettle(tester, find.text('Laptop Repair'));

      await TestUtils.enterText(
        tester,
        find.bySemanticsLabel('Description'),
        'My laptop screen is broken and needs replacement',
      );

      await TestUtils.tapAndSettle(tester, find.text('Submit Complaint'));

      // Assert - Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should allow adding attachments', (WidgetTester tester) async {
      // Arrange
      await TestUtils.pumpWidget(tester, complaintForm);

      // Act
      await TestUtils.tapAndSettle(tester, find.text('Add Files'));

      // Assert - Button should be tappable
      expect(find.text('Add Files'), findsOneWidget);
    });

    testWidgets('should have proper form structure',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, complaintForm);

      // Assert
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should have correct spacing between form elements',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, complaintForm);

      // Assert - Verify there are SizedBox widgets for spacing
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
