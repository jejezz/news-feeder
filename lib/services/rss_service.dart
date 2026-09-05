import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:webfeed_revised/webfeed_revised.dart';

import '../models/article.dart';
import '../models/news_source.dart';

class RssService {
  Future<List<Article>> fetchAll(List<NewsSource> sources) async {
    final results = await Future.wait(
      sources.map(_fetchOne),
      eagerError: false,
    );

    final articles = results.expand((articles) => articles).toList();
    articles.sort((a, b) {
      if (a.publishedAt == null || b.publishedAt == null) return 0;
      return b.publishedAt!.compareTo(a.publishedAt!);
    });
    return articles;
  }

  Future<List<Article>> _fetchOne(NewsSource source) async {
    try {
      final response = await http
          .get(
            Uri.parse(source.feedUrl),
            headers: {'User-Agent': 'Mozilla/5.0 (news_feeder app)'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return [];

      // Many feeds omit a charset in Content-Type even though the body is
      // UTF-8 (as declared in their XML prolog); response.body would then
      // fall back to Latin-1 and mangle non-ASCII text, so decode explicitly.
      final body = utf8.decode(response.bodyBytes, allowMalformed: true);
      final feed = RssFeed.parse(body);
      return (feed.items ?? [])
          .where((item) => item.title != null && item.link != null)
          .map(
            (item) => Article(
              title: item.title!,
              summary: (item.description ?? '').trim(),
              link: item.link!,
              sourceName: source.name,
              publishedAt: item.pubDate,
              imageUrl: _extractImageUrl(item),
              isKorean: source.isKorean,
            ),
          )
          .toList();
    } catch (_) {
      // Skip sources that fail to load so one bad feed doesn't break the rest.
      return [];
    }
  }

  String? _extractImageUrl(RssItem item) {
    final thumbnail = item.media?.thumbnails?.firstOrNull?.url;
    if (thumbnail != null) return thumbnail;

    final mediaContent = item.media?.contents?.firstOrNull?.url;
    if (mediaContent != null) return mediaContent;

    final enclosure = item.enclosure;
    if (enclosure?.url != null && (enclosure?.type?.startsWith('image') ?? false)) {
      return enclosure!.url;
    }

    return null;
  }
}

extension _FirstOrNull<T> on List<T>? {
  T? get firstOrNull {
    final list = this;
    if (list == null || list.isEmpty) return null;
    return list.first;
  }
}
