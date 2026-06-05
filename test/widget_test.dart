import 'package:flutter_test/flutter_test.dart';

import 'package:jejaksehat_mobile/main.dart';

void main() {
  testWidgets('opens login screen after splash', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.text('Login'), findsWidgets);
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
