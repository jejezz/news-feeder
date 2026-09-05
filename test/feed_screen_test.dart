import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_feeder/models/article.dart';
import 'package:news_feeder/screens/feed_screen.dart';

void main() {
  testWidgets('renders fetched articles with title, summary and source', (
    tester,
  ) async {
    final articles = [
      Article(
        title: 'Fed holds rates steady',
        summary: 'The Federal Reserve kept interest rates unchanged.',
        link: 'https://example.com/fed',
        sourceName: 'Federal Reserve Press Releases',
        publishedAt: DateTime(2026, 9, 5, 10, 30),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: FeedScreen(
          fetchArticles: () async => articles,
          translate: (text) async => '[번역] $text',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fed holds rates steady'), findsOneWidget);
    expect(
      find.text('The Federal Reserve kept interest rates unchanged.'),
      findsOneWidget,
    );
    expect(find.textContaining('Federal Reserve Press Releases'), findsOneWidget);
    expect(
      find.text('[번역] Fed holds rates steady'),
      findsOneWidget,
    );
  });

  testWidgets('shows empty state when no articles are returned', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: FeedScreen(fetchArticles: () async => [])),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('표시할 기사가 없습니다.\n네트워크 연결을 확인해 주세요.'),
      findsOneWidget,
    );
  });
}
