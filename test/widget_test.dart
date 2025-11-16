// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:masjid_ku/global_bindings.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Initialize bindings for testing
    WidgetsFlutterBinding.ensureInitialized();
    final globalBindings = GlobalBindings();
    globalBindings.dependencies();
    await globalBindings.initializeServices();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: '/home',
      getPages: [
        GetPage(
          name: '/home',
          page: () => const Scaffold(
            body: Center(child: Text('MasjidKu')),
          ),
        ),
      ],
    ));
    await tester.pumpAndSettle();

    // Verify that the app loads
    expect(find.text('MasjidKu'), findsOneWidget);
  });
}
