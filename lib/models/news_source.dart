class NewsSource {
  final String name;
  final String feedUrl;
  final bool isKorean;

  const NewsSource({
    required this.name,
    required this.feedUrl,
    this.isKorean = false,
  });
}

const List<NewsSource> economyNewsSources = [
  NewsSource(
    name: 'CNBC Economy',
    feedUrl: 'https://www.cnbc.com/id/20910258/device/rss/rss.html',
  ),
  NewsSource(
    name: 'CNBC Finance',
    feedUrl: 'https://www.cnbc.com/id/10000664/device/rss/rss.html',
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
  NewsSource(
    name: 'Forbes Business',
    feedUrl: 'https://www.forbes.com/business/feed/',
  ),
  NewsSource(name: 'Fortune', feedUrl: 'https://fortune.com/feed/'),
  NewsSource(
    name: 'NPR Business',
    feedUrl: 'https://feeds.npr.org/1006/rss.xml',
  ),
  NewsSource(
    name: 'BBC Business',
    feedUrl: 'http://feeds.bbci.co.uk/news/business/rss.xml',
  ),
  NewsSource(
    name: '한국경제 경제',
    feedUrl: 'https://www.hankyung.com/feed/economy',
    isKorean: true,
  ),
  NewsSource(
    name: '매일경제 경제',
    feedUrl: 'https://www.mk.co.kr/rss/30100041/',
    isKorean: true,
  ),
  NewsSource(
    name: '연합뉴스 경제',
    feedUrl: 'https://www.yna.co.kr/rss/economy.xml',
    isKorean: true,
  ),
  NewsSource(
    name: '동아일보 경제',
    feedUrl: 'https://rss.donga.com/economy.xml',
    isKorean: true,
  ),
];
