import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock PortalCard widget
class PortalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradientColors;
  final String buttonText;
  final VoidCallback onTap;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryTap;

  // Remove 'const' from constructor if it has non-const parameters
  const PortalCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.gradientColors,
    required this.buttonText,
    required this.onTap,
    this.secondaryButtonText,
    this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 10),
            Text(title),
            const SizedBox(height: 5),
            Text(description),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: onTap,
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}

// Static empty function for const constructors
void _emptyFunction() {}

void main() {
  group('PortalCard Widget Tests', () {
    testWidgets('should display all provided properties (using final)',
        (WidgetTester tester) async {
      // Arrange - Use 'final' not 'const' because onTap is not constant
      final portalCard = PortalCard(
        icon: Icons.person,
        title: 'Test Portal',
        description: 'Test description',
        gradientColors: [Colors.blue, Colors.green],
        buttonText: 'Test Button',
        onTap: () {
          // Empty function - cannot be const
        },
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: portalCard),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.text('Test Portal'), findsOneWidget);
      expect(find.text('Test description'), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets(
        'should display all provided properties (using static function)',
        (WidgetTester tester) async {
      // Arrange - Use static function to allow 'const'
      const portalCard = PortalCard(
        icon: Icons.person,
        title: 'Test Portal',
        description: 'Test description',
        gradientColors: [Colors.blue, Colors.green],
        buttonText: 'Test Button',
        onTap: _emptyFunction, // Static function reference
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: portalCard),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.text('Test Portal'), findsOneWidget);
      expect(find.text('Test description'), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('should display secondary button when provided',
        (WidgetTester tester) async {
      // Arrange - Use final for non-const widget
      final portalCard = PortalCard(
        icon: Icons.person,
        title: 'Test Portal',
        description: 'Test description',
        gradientColors: [Colors.blue, Colors.green],
        buttonText: 'Test Button',
        onTap: () {},
        secondaryButtonText: 'Secondary',
        onSecondaryTap: () {},
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: portalCard),
        ),
      );

      // Assert
      expect(find.text('Secondary'), findsOneWidget);
    });
  });
}
