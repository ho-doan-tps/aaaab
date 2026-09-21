import 'package:flutter_test/flutter_test.dart';

import 'package:example_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('Counter: 0'), findsOneWidget);
    expect(find.bySemanticsIdentifier('increment_button'), findsOneWidget);

    await tester.tap(find.bySemanticsIdentifier('increment_button'));
    await tester.pump();

    expect(find.text('Counter: 1'), findsOneWidget);
  });
}
