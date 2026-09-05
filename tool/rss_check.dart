// ignore_for_file: avoid_print
import 'package:news_feeder/models/news_source.dart';
import 'package:news_feeder/services/rss_service.dart';

Future<void> main() async {
  final articles = await RssService().fetchAll(usEconomyNewsSources);
  print('Total articles: ${articles.length}');
  for (final a in articles.take(8)) {
    print('- [${a.sourceName}] ${a.title}');
    print('  ${a.summary.length > 100 ? a.summary.substring(0, 100) : a.summary}');
    print('  ${a.publishedAt} -> ${a.link}');
    print('  image: ${a.imageUrl}');
  }
}
