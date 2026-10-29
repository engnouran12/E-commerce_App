import 'package:e_commerce/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Login screen renders when there is no cached session',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(isLoggedIn: false));

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Welcome to E-Comm'), findsOneWidget);
  });
}
