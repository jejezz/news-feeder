import 'package:flutter_test/flutter_test.dart';

import 'package:news_feeder/main.dart';

void main() {
  testWidgets('App shows the economy and IT news tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('경제 뉴스'), findsOneWidget);
    expect(find.text('IT 뉴스'), findsOneWidget);
  });
}
