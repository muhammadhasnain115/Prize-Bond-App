import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prize_bond/main.dart'; // Ensure this import path matches your project setup.

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Provide a value for `isLoggedIn`.
    await tester.pumpWidget(const MyApp(isLoggedIn: false));

    // Verify that the app starts at the login page or home page based on `isLoggedIn`.
    expect(find.text('Login'), findsOneWidget); // Adjust this to match the text on your login page.
    expect(find.text('Home'), findsNothing); // Adjust this to match the text on your home page.

    // Simulate navigation or interaction, if applicable.
    // Example: Navigate to the home page after login.

    // Verify changes in the widget tree.
  });
}
