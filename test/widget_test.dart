import 'package:flutter_test/flutter_test.dart';

import 'package:news_feeder/main.dart';

void main() {
  testWidgets('App shows the feed app bar title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('경제 뉴스'), findsOneWidget);
  });
}
