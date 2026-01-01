import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kpg_shop/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: KGSShopApp()));

    // Verify that role selection screen is shown
    expect(find.text('KGS'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Customer'), findsOneWidget);
  });
}
