class Article {
  final String title;
  final String summary;
  final String link;
  final String sourceName;
  final DateTime? publishedAt;
  final String? imageUrl;
  final bool isKorean;
  final bool isUnverified;

  const Article({
    required this.title,
    required this.summary,
    required this.link,
    required this.sourceName,
    required this.publishedAt,
    this.imageUrl,
    this.isKorean = false,
    this.isUnverified = false,
  });
}
