// Ignore for testing purposes
// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/app.dart';
import 'package:mobile/counter/counter.dart';
import 'package:mobile/env/app_config.dart';

class _FakeAppConfig implements AppConfig {
  @override
  String get apiBaseUrl => 'https://test-api.example.com';
}

void main() {
  group('App', () {
    testWidgets('renders CounterPage', (tester) async {
      await tester.pumpWidget(App(config: _FakeAppConfig()));
      expect(find.byType(CounterPage), findsOneWidget);
    });
  });
}
