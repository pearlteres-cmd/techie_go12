import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techie_go/main.dart';

void main() {
  testWidgets('App loads without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(MyApp()); // Changed from techie_go() to MyApp()

    // Verify the app starts
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Login screen has email and password fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp()); // Changed from techie_go() to MyApp()

    // Look for text fields - adjust based on your actual login screen
    expect(find.byType(TextFormField), findsAtLeast(2));
  });

  testWidgets('Login button exists', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp()); // Changed from techie_go() to MyApp()

    // Look for login button - adjust text based on your app
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });
}