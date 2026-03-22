// test/widgets/customer_dashboard_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techie_go/screens/customer/customer_dashboard.dart';
import 'package:techie_go/widgets/stat_card.dart';
import 'package:techie_go/widgets/complaint_card.dart';
import '../test_utils.dart';

void main() {
  group('Customer Dashboard Widget Tests', () {
    late Widget customerDashboard;

    setUp(() {
      customerDashboard = const CustomerDashboard();
    });

    testWidgets('should display app bar with title and notification icon',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, customerDashboard);

      // Assert
      expect(find.text('Customer Dashboard'), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('should display bottom navigation bar with three items',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, customerDashboard);

      // Assert
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('should display floating action button for new complaint',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, customerDashboard);

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should display welcome section with user info',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, customerDashboard);

      // Assert
      expect(find.text('Welcome back,'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should display all stat cards with correct values',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, customerDashboard);

      // Assert
      expect(find.byType(StatCard), findsNWidgets(4));
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('4.2'), findsOneWidget);
    });

    testWidgets('should display quick action buttons',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, customerDashboard);

      // Assert
      expect(find.text('New Complaint'), findsOneWidget);
      expect(find.text('Track'), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should display recent complaints section',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, customerDashboard);

      // Assert
      expect(find.text('Recent Complaints'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);
      expect(find.byType(ComplaintCard), findsNWidgets(2));
    });

    testWidgets(
        'should navigate between dashboard screens via bottom navigation',
        (WidgetTester tester) async {
      // Arrange
      await TestUtils.pumpWidget(tester, customerDashboard);

      // Act - Tap on History tab
      await TestUtils.tapAndSettle(tester, find.text('History'));

      // Assert - Should show history screen content
      expect(find.text('Complaint History'), findsOneWidget);
      expect(find.text('View all your past and current complaints'),
          findsOneWidget);

      // Act - Tap on Profile tab
      await TestUtils.tapAndSettle(tester, find.text('Profile'));

      // Assert - Should show profile screen content
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Customer'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('should display complaint cards with correct information',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, customerDashboard);

      // Assert
      final complaintCards =
          tester.widgetList<ComplaintCard>(find.byType(ComplaintCard));
      expect(complaintCards.length, 2);

      // Verify first complaint card
      expect(complaintCards.first.id, '#TC2025001');
      expect(complaintCards.first.serviceType, 'Laptop Repair');
      expect(complaintCards.first.status, 'In Progress');

      // Verify second complaint card
      expect(complaintCards.last.id, '#TC2025002');
      expect(complaintCards.last.serviceType, 'Software Installation');
      expect(complaintCards.last.status, 'Pending');
    });

    testWidgets('should have filter chips in history screen',
        (WidgetTester tester) async {
      // Arrange
      await TestUtils.pumpWidget(tester, customerDashboard);

      // Act - Navigate to history
      await TestUtils.tapAndSettle(tester, find.text('History'));

      // Assert
      expect(find.byType(FilterChip), findsNWidgets(4));
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('Resolved'), findsOneWidget);
    });
  });
}
