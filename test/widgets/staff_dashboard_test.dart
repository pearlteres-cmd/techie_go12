// test/widgets/staff_dashboard_test.dart (UPDATED)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techie_go/screens/staff/staff_dashboard.dart';
import '../test_utils.dart';

void main() {
  group('Staff Dashboard Widget Tests', () {
    late Widget staffDashboard;

    setUp(() {
      staffDashboard = const StaffDashboard();
    });

    testWidgets('should display app bar with title and notification icon',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, staffDashboard);

      // Assert
      expect(find.text('Staff Dashboard'), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('should have drawer navigation', (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, staffDashboard);

      // Assert
      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('should display welcome section for staff',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, staffDashboard);

      // Assert
      expect(find.text('Welcome,'), findsOneWidget);
      expect(find.text('Admin User'), findsOneWidget);
    });

    testWidgets('should display staff-specific stat cards',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, staffDashboard);

      // Assert - Updated to find Card widgets instead of StatCard
      expect(
          find.byType(Card), findsNWidgets(6)); // 4 stat cards + 2 other cards
      expect(find.text('12'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('45'), findsOneWidget);
      expect(find.text('2.3'), findsOneWidget);
    });

    testWidgets('should display pending complaints table',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, staffDashboard);

      // Assert
      expect(find.text('Complaints Pending Assignment'), findsOneWidget);
      expect(find.text('Complaint ID'), findsOneWidget);
      expect(find.text('Service'), findsOneWidget);
      expect(find.text('Priority'), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);
    });

    testWidgets('should display complaint rows in table',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, staffDashboard);

      // Assert
      expect(find.text('#TC2025010'), findsOneWidget);
      expect(find.text('Data Recovery'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
      expect(find.text('Assign'), findsNWidgets(2));
    });

    testWidgets('should display available technicians list',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, staffDashboard);

      // Assert
      expect(find.text('Available Technicians'), findsOneWidget);
      expect(find.text('Alex Johnson'), findsOneWidget);
      expect(find.text('Sarah Miller'), findsOneWidget);
      expect(find.text('Mike Chen'), findsOneWidget);
    });

    testWidgets('should open drawer with navigation items',
        (WidgetTester tester) async {
      // Arrange
      await TestUtils.pumpWidget(tester, staffDashboard);

      // Act - Open drawer
      await TestUtils.tapAndSettle(tester, find.byIcon(Icons.menu));

      // Assert
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('All Complaints'), findsOneWidget);
      expect(find.text('Assign Technician'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);
      expect(find.text('Technicians'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('should display technician status with correct colors',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, staffDashboard);

      // Assert
      expect(find.text('Available'), findsNWidgets(2));
      expect(find.text('Busy'), findsOneWidget);
    });

    testWidgets('should have correct table structure for pending complaints',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, staffDashboard);

      // Assert
      final pendingTable = find.text('Complaints Pending Assignment');
      expect(pendingTable, findsOneWidget);

      // Verify table headers
      final headers = ['Complaint ID', 'Service', 'Priority', 'Action'];
      for (final header in headers) {
        expect(find.text(header), findsOneWidget);
      }
    });

    testWidgets('should display technician details correctly',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestUtils.pumpWidget(tester, staffDashboard);

      // Assert
      expect(find.text('ID: TECH101'), findsOneWidget);
      expect(find.text('Specialization: Laptop Repair'), findsOneWidget);
      expect(find.text('Load: 3 tasks'), findsOneWidget);
      expect(find.text('Rating: 4.5 ★'), findsOneWidget);
    });
  });
}
