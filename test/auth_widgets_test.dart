import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_flow_flutter/features/authorization/widgets/auth_widgets.dart';

void main() {
  testWidgets('auth gradient button invokes its tap callback', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthGradientButton(
            label: 'Next',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
