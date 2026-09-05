class NewsSource {
  final String name;
  final String feedUrl;

  const NewsSource({required this.name, required this.feedUrl});
}

const List<NewsSource> usEconomyNewsSources = [
  NewsSource(
    name: 'CNBC Economy',
    feedUrl: 'https://www.cnbc.com/id/20910258/device/rss/rss.html',
  ),
  NewsSource(
    name: 'MarketWatch Top Stories',
    feedUrl: 'http://feeds.marketwatch.com/marketwatch/topstories/',
  ),
  NewsSource(
    name: 'Investing.com Economy',
    feedUrl: 'https://www.investing.com/rss/news_14.rss',
  ),
  NewsSource(
    name: 'WSJ Markets',
    feedUrl: 'https://feeds.a.dj.com/rss/RSSMarketsMain.xml',
  ),
  NewsSource(
    name: 'Federal Reserve Press Releases',
    feedUrl: 'https://www.federalreserve.gov/feeds/press_all.xml',
  ),
];
