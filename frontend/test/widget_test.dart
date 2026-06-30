import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:blog_app/main.dart';

void main() {
  testWidgets('BlogApp opens login screen when token is missing', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const BlogApp());
    await tester.pumpAndSettle();

    expect(find.text('BlogApp'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
